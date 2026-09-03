import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../app/shift_controller.dart';
import '../../data/order.dart';
import 'live_activity_service.dart';

/// Keeps the iOS Live Activity in step with [ShiftController], and routes the
/// taps that come back from it.
///
/// Nothing else in the app knows this exists: the bridge listens to the shift
/// the same way a screen would, so closing a stop through the ordinary delivery
/// / failure flows moves the island for free. Drop the two call sites in
/// `main.dart` and `AppShell` and the feature vanishes without a trace.
///
/// **One activity per stop, not per shift.** iOS ends a Live Activity after
/// roughly 8 hours and a courier's shift outlasts that, so the activity is
/// scoped to the stop in hand: it starts when a stop becomes current and ends
/// when it closes. The next stop gets a fresh one.
class LiveActivityBridge {
  LiveActivityBridge._();
  static final LiveActivityBridge instance = LiveActivityBridge._();

  static const MethodChannel _links = MethodChannel('orderbase/deep_links');

  bool _attached = false;

  /// The order the running activity is about, or null when none is running.
  String? _activeOrderNum;

  /// Last content we successfully pushed — guards against redundant updates,
  /// since [ShiftController] notifies on changes the island doesn't care about.
  DeliveryActivityState? _last;

  DeliveryPhase _phase = DeliveryPhase.enRoute;

  /// [_syncOnce] awaits several platform hops, so a notification arriving
  /// mid-flight could otherwise start a second activity for the same stop.
  /// Re-entrant calls set [_dirty] and the in-flight pass loops instead.
  bool _syncing = false;
  bool _dirty = false;

  void Function(String orderNum)? _onOpenOrder;

  /// An order tapped on the island before [onOpenOrder] existed. A cold launch
  /// delivers the URL while Dart is still starting up, well before [AppShell]
  /// has mounted, so it waits here rather than being dropped.
  String? _pendingOpenOrderNum;

  /// Called when the courier taps the island, with the order number WITHOUT
  /// '#'. Set by [AppShell], which owns navigation. Assigning it flushes any
  /// tap that arrived while it was null.
  set onOpenOrder(void Function(String orderNum)? handler) {
    _onOpenOrder = handler;
    final pending = _pendingOpenOrderNum;
    if (handler != null && pending != null) {
      _pendingOpenOrderNum = null;
      handler(pending);
    }
  }

  void Function(String orderNum)? get onOpenOrder => _onOpenOrder;

  /// Starts mirroring the shift. Idempotent, and returns immediately — the
  /// platform work runs in the background so it never delays the first frame.
  void attach() {
    if (_attached) return;
    _attached = true;
    _links.setMethodCallHandler(_onLink);
    ShiftController.instance.addListener(_scheduleSync);
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    await _sync();
    // A tap on the island can launch the app from cold, in which case the URL
    // reached the native side before the handler above existed.
    final pending = await LiveActivityService.instance.consumePendingLink();
    if (pending != null) await _handleLink(pending);
  }

  /// Moves the island to a different moment of the SAME stop (e.g. the COD
  /// sheet opening). Resets to [DeliveryPhase.enRoute] on the next stop.
  Future<void> setPhase(DeliveryPhase phase) async {
    if (_phase == phase) return;
    _phase = phase;
    await _sync();
  }

  void _scheduleSync() => unawaited(_sync());

  Future<void> _sync() async {
    if (_syncing) {
      _dirty = true;
      return;
    }
    _syncing = true;
    try {
      do {
        _dirty = false;
        await _syncOnce();
      } while (_dirty);
    } finally {
      _syncing = false;
    }
  }

  Future<void> _syncOnce() async {
    final shift = ShiftController.instance;
    // Nothing to show until the batch is physically carried from the branch.
    final stop = shift.accepted ? shift.nextStop : null;

    if (stop == null) {
      if (_activeOrderNum == null) return;
      _activeOrderNum = null;
      _last = null;
      _phase = DeliveryPhase.enRoute;
      await LiveActivityService.instance.end();
      return;
    }

    final orderNum = stop.num.replaceAll('#', '').trim();
    final isNewStop = _activeOrderNum != orderNum;
    if (isNewStop) _phase = DeliveryPhase.enRoute;

    final state = _stateFor(stop, shift, orderNum);

    if (isNewStop) {
      if (_activeOrderNum != null) await LiveActivityService.instance.end();
      // Claim the stop BEFORE awaiting, so a notification landing mid-request
      // cannot kick off a second activity for the same one.
      _activeOrderNum = orderNum;
      _last = state;
      if (!await LiveActivityService.instance.start(state)) {
        _activeOrderNum = null;
        _last = null;
      }
      return;
    }

    if (state == _last) return;
    final previous = _last;
    _last = state;
    if (!await LiveActivityService.instance.update(state)) _last = previous;
  }

  DeliveryActivityState _stateFor(
    Order stop,
    ShiftController shift,
    String orderNum,
  ) {
    return DeliveryActivityState(
      orderNum: orderNum,
      customer: stop.name,
      area: stop.area,
      addressDetail: stop.addr,
      stopNumber: shift.currentStopNumber,
      totalStops: shift.totalStops,
      codDue: stop.prepaid ? 0 : (stop.cod ?? 0),
      prepaid: stop.prepaid,
      dueLabel: stop.due,
      phase: _phase,
    );
  }

  Future<void> _onLink(MethodCall call) async {
    if (call.method != 'open') return;
    final url = call.arguments;
    if (url is String) await _handleLink(url);
  }

  /// `orderbase://call?num=89289` → dial that order's customer.
  /// `orderbase://order?num=89289` → open its detail screen.
  ///
  /// The phone number is looked up from the shift rather than read out of the
  /// URL, so a link forged by another app can only ever dial a customer this
  /// courier is already delivering to.
  Future<void> _handleLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'orderbase') return;
    final orderNum = uri.queryParameters['num'];
    if (orderNum == null || orderNum.isEmpty) return;

    switch (uri.host) {
      case 'call':
        final phone = ShiftController.instance.orderByNum('#$orderNum')?.phone;
        if (phone == null || phone.isEmpty) {
          debugPrint('[live_activity] no phone on order #$orderNum');
          return;
        }
        await LiveActivityService.instance.dial(phone);
      case 'order':
        final handler = _onOpenOrder;
        if (handler != null) {
          handler(orderNum);
        } else {
          _pendingOpenOrderNum = orderNum;
        }
    }
  }
}

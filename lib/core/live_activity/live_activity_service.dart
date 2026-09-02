import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Which moment of the current stop the Live Activity is showing.
///
/// Only [enRoute], [collecting] and [done] are driven today — the app has no
/// geofence, so nothing can tell us the courier physically [arrived]. The case
/// is modelled anyway because the island artwork already has a state for it;
/// wire it up the day a "وصلت" tap or a geofence exists.
enum DeliveryPhase { enRoute, arrived, collecting, done }

/// The payload behind the Dynamic Island / Lock Screen card for ONE stop.
///
/// Deliberately flat and primitive-only: it crosses a [MethodChannel] and is
/// re-decoded into the widget extension's `ContentState`, so every field here
/// has a twin in `ios/Shared/DeliveryActivityAttributes.swift`. Change one and
/// you must change the other.
@immutable
class DeliveryActivityState {
  const DeliveryActivityState({
    required this.orderNum,
    required this.customer,
    required this.area,
    required this.stopNumber,
    required this.totalStops,
    required this.codDue,
    required this.prepaid,
    this.addressDetail,
    this.dueLabel,
    this.phase = DeliveryPhase.enRoute,
  });

  /// Order number WITHOUT the leading '#' — it travels in a URL (the island's
  /// tap target is `orderbase://order?num=<orderNum>`) where '#' is a fragment.
  final String orderNum;

  final String customer;
  final String area;

  /// Street line, shown under the customer name on the roomier presentations.
  final String? addressDetail;

  final int stopNumber;
  final int totalStops;

  /// Cash still to collect on THIS order, 0 for a prepaid one.
  final int codDue;
  final bool prepaid;

  /// The promised-delivery label as the order carries it (e.g. "٢:٤٥ م").
  ///
  /// Not a countdown: [Order.due] is a formatted string, not a timestamp, so
  /// there is nothing to count down from. Give `Order` a real `DateTime` and
  /// the island can switch to SwiftUI's self-updating timer text — which ticks
  /// without us pushing an update at all.
  final String? dueLabel;

  final DeliveryPhase phase;

  DeliveryActivityState copyWith({DeliveryPhase? phase}) {
    return DeliveryActivityState(
      orderNum: orderNum,
      customer: customer,
      area: area,
      addressDetail: addressDetail,
      stopNumber: stopNumber,
      totalStops: totalStops,
      codDue: codDue,
      prepaid: prepaid,
      dueLabel: dueLabel,
      phase: phase ?? this.phase,
    );
  }

  Map<String, Object?> toMap() => <String, Object?>{
    'orderNum': orderNum,
    'customer': customer,
    'area': area,
    'addressDetail': addressDetail,
    'stopNumber': stopNumber,
    'totalStops': totalStops,
    'codDue': codDue,
    'prepaid': prepaid,
    'dueLabel': dueLabel,
    'phase': phase.name,
  };

  @override
  bool operator ==(Object other) =>
      other is DeliveryActivityState &&
      other.orderNum == orderNum &&
      other.customer == customer &&
      other.area == area &&
      other.addressDetail == addressDetail &&
      other.stopNumber == stopNumber &&
      other.totalStops == totalStops &&
      other.codDue == codDue &&
      other.prepaid == prepaid &&
      other.dueLabel == dueLabel &&
      other.phase == phase;

  @override
  int get hashCode => Object.hash(
    orderNum,
    customer,
    area,
    addressDetail,
    stopNumber,
    totalStops,
    codDue,
    prepaid,
    dueLabel,
    phase,
  );
}

/// Thin wrapper over the `orderbase/live_activity` platform channel.
///
/// **Every method is best-effort and silent on failure.** A courier on an
/// iPhone 8, on Android, on the web build, or on an iPhone whose owner turned
/// Live Activities off in Settings gets `false`/no-op — never an exception and
/// never a visible change. That is the whole contract: this feature is an
/// optional garnish on top of a fleet with mixed hardware, so nothing in the
/// app is allowed to depend on it having worked.
class LiveActivityService {
  LiveActivityService._();
  static final LiveActivityService instance = LiveActivityService._();

  static const MethodChannel _channel = MethodChannel(
    'orderbase/live_activity',
  );

  bool? _supported;

  /// True only on an iOS build whose device can actually show one right now.
  ///
  /// Cached after the first answer — `areActivitiesEnabled` can flip if the
  /// courier toggles the Settings switch mid-shift, which we accept: the next
  /// app launch picks it up, and a stale `true` just makes the calls no-op.
  Future<bool> isSupported() async {
    final cached = _supported;
    if (cached != null) return cached;
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      return _supported = false;
    }
    return _supported = await _invoke<bool>('isSupported') ?? false;
  }

  /// Begins a Live Activity for one stop. Returns false if it didn't start.
  Future<bool> start(DeliveryActivityState state) async {
    if (!await isSupported()) return false;
    return await _invoke<bool>('start', state.toMap()) ?? false;
  }

  /// Pushes new content into the running activity.
  Future<bool> update(DeliveryActivityState state) async {
    if (!await isSupported()) return false;
    return await _invoke<bool>('update', state.toMap()) ?? false;
  }

  /// Dismisses the running activity, if any. Safe to call unconditionally.
  Future<void> end() async {
    if (!await isSupported()) return;
    await _invoke<void>('end');
  }

  /// Opens the system dialer on [phone] (iOS shows its own call confirmation).
  ///
  /// Lives on this channel rather than pulling in `url_launcher` so the iOS
  /// build keeps its no-CocoaPods setup (see /CLAUDE.md).
  Future<void> dial(String phone) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return;
    await _invoke<void>('dial', <String, Object?>{'phone': phone});
  }

  /// A deep link that arrived before Dart was listening (cold start from the
  /// island), or null. Consumed once.
  Future<String?> consumePendingLink() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return null;
    return _invoke<String>('consumePendingLink');
  }

  Future<T?> _invoke<T>(String method, [Map<String, Object?>? args]) async {
    try {
      return await _channel.invokeMethod<T>(method, args);
    } on MissingPluginException {
      // No native side registered — an Android/web build, or an iOS build made
      // before the widget extension was added. Expected, not an error.
      return null;
    } on PlatformException catch (e) {
      debugPrint('[live_activity] $method failed: ${e.code} — ${e.message}');
      return null;
    }
  }
}

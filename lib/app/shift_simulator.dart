import 'dart:async';

import '../config/res/config_imports.dart';
import '../data/order.dart';
import '../features/notifications/presentation/imports/notifications_imports.dart';
import 'shift_controller.dart';

/// Plays the branch's side of the day so the app behaves like a real shift
/// without a backend: batches are dispatched on a clock, the cashier settles a
/// while after the courier is expected back, and every event files the same
/// notification a push would.
///
/// Every timer lives here and nowhere else, so swapping this for push
/// notifications later touches one file. Start it once from the shell; call
/// [restart] after «start new day».
class ShiftSimulator {
  ShiftSimulator({required this.shift, required this.notifications});

  final ShiftController shift;
  final NotificationsStore notifications;

  /// When the branch dispatches the second and third batches after the app
  /// opens. Short on purpose — this is a demo of the flow, not a real shift.
  static const Duration secondBatchAfter = Duration(seconds: 30);
  static const Duration thirdBatchAfter = Duration(minutes: 3);

  /// How long after the courier is «expected at the branch» the cashier
  /// settles the day.
  static const Duration settleAfterReturning = Duration(seconds: 40);

  final List<Timer> _timers = <Timer>[];
  Timer? _settleTimer;
  bool _wasOverLimit = false;
  bool _listening = false;

  void start() {
    stop();
    _wasOverLimit = shift.overCashLimit;
    if (!_listening) {
      shift.addListener(_onShiftChanged);
      _listening = true;
    }
    _timers.add(
      Timer(secondBatchAfter, () => _dispatch(sampleBatchTwoId, sampleBatchTwo)),
    );
    _timers.add(
      Timer(
        thirdBatchAfter,
        () => _dispatch(sampleBatchThreeId, sampleBatchThree),
      ),
    );
  }

  /// Cancel everything pending (the shell is going away or the day restarts).
  void stop() {
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
    _settleTimer?.cancel();
    _settleTimer = null;
  }

  /// «Start new day»: clear the shift and let the branch dispatch again.
  void restart() {
    stop();
    shift.startNewDay();
    start();
  }

  void dispose() {
    stop();
    if (_listening) {
      shift.removeListener(_onShiftChanged);
      _listening = false;
    }
  }

  void _dispatch(String id, List<Order> orders) {
    final batch = OrderBatch(id: id, orders: List<Order>.unmodifiable(orders));
    shift.assignBatch(batch);
    notifications.addBatchAssigned(batch, branch: shift.branchName);
  }

  void _onShiftChanged() {
    // Over the cash limit: one notification per crossing, not per delivery.
    final over = shift.overCashLimit;
    if (over && !_wasOverLimit) {
      notifications.addCashOverLimit(
        cash: shift.cashInHand,
        limit: ShiftController.cashThresholdEgp,
      );
    }
    _wasOverLimit = over;

    // Expected back at the branch → the cashier settles a little later. A new
    // batch being carried in the meantime cancels it: the day is not over.
    if (shift.status == CourierStatus.returning) {
      _settleTimer ??= Timer(settleAfterReturning, _settle);
    } else {
      _settleTimer?.cancel();
      _settleTimer = null;
    }
  }

  void _settle() {
    _settleTimer = null;
    if (shift.status != CourierStatus.returning) return;
    final cashier = LocaleKeys.settlementCashierDefault.tr();
    shift.settleDay(cashier: cashier);
    final receipt = shift.settlement;
    if (receipt != null) {
      notifications.addDaySettled(cash: receipt.cash, cashier: cashier);
    }
  }
}

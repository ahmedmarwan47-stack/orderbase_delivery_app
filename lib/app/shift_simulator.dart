import 'dart:async';

import '../config/res/config_imports.dart';
import '../data/order.dart';
import '../features/notifications/presentation/imports/notifications_imports.dart';
import 'shift_controller.dart';

/// Plays the branch's side of the day so the app behaves like a real shift
/// without a backend: batches are dispatched one at a time, the cashier
/// settles once the courier is expected back, and every event files the same
/// notification a push would.
///
/// **The day is a chain, not a schedule.** A branch does not hand a courier
/// their next batch while the last one is still on the shelf — it waits until
/// they have actually carried it out. So the first batch lands [firstBatchAfter]
/// a fresh day begins, and every batch after it lands [nextBatchAfter] the
/// courier *confirms collecting* the previous one. Three batches, then the day
/// runs to settlement.
///
/// Every timer lives here and nowhere else, so swapping this for push
/// notifications later touches one file. Start it once from the shell; call
/// [restart] for «بدء يوم جديد».
class ShiftSimulator {
  ShiftSimulator({required this.shift, required this.notifications});

  final ShiftController shift;
  final NotificationsStore notifications;

  /// A fresh day is empty; the branch takes a moment to have anything ready.
  static const Duration firstBatchAfter = Duration(seconds: 10);

  /// From the courier confirming they carried a batch to the next one being
  /// dispatched.
  static const Duration nextBatchAfter = Duration(seconds: 20);

  /// How long after the courier is «expected at the branch» the cashier
  /// settles the day.
  static const Duration settleAfterReturning = Duration(seconds: 40);

  /// The day's batches, in the order the branch sends them.
  final List<OrderBatch> _plan = demoDayBatches;

  /// How many of [_plan] have already left the branch's hands.
  int _dispatched = 0;

  /// Carried-batch count at the last check, so a *rise* is the trigger.
  int _carried = 0;

  Timer? _dispatchTimer;
  Timer? _settleTimer;
  bool _wasOverLimit = false;
  bool _listening = false;

  /// Batches still to come today — the Account tab's demo row could show it.
  int get batchesLeft => _plan.length - _dispatched;

  void start() {
    stop();
    // Anything already in the shift counts against the plan: the app's own
    // seeded mid-day state opens with the first batch in hand, and the day
    // should still total three.
    _carried = shift.carriedBatches.length;
    _dispatched = _carried + shift.pendingBatches.length;
    _wasOverLimit = shift.overCashLimit;
    if (!_listening) {
      shift.addListener(_onShiftChanged);
      _listening = true;
    }
    // A day that has not started yet waits the short beat; one already under
    // way is treated as if its last batch had just been carried.
    _scheduleDispatch(_dispatched == 0 ? firstBatchAfter : nextBatchAfter);
  }

  /// Cancel everything pending (the shell is going away, or the day restarts).
  void stop() {
    _dispatchTimer?.cancel();
    _dispatchTimer = null;
    _settleTimer?.cancel();
    _settleTimer = null;
  }

  /// «بدء يوم جديد»: clear the shift and let the branch start dispatching from
  /// nothing, so the whole day can be watched from zero to settled.
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

  void _scheduleDispatch(Duration after) {
    if (_dispatched >= _plan.length) return;
    _dispatchTimer?.cancel();
    _dispatchTimer = Timer(after, _dispatch);
  }

  void _dispatch() {
    _dispatchTimer = null;
    if (_dispatched >= _plan.length) return;
    final batch = _plan[_dispatched];
    _dispatched += 1;
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

    // The courier just carried a batch out of the branch — start the clock on
    // the next one.
    final carried = shift.carriedBatches.length;
    if (carried > _carried) {
      _carried = carried;
      _scheduleDispatch(nextBatchAfter);
    } else if (carried < _carried) {
      _carried = carried; // the day was reset from under us
    }

    // Expected back at the branch → the cashier settles a little later. A new
    // batch carried in the meantime cancels it: the day is not over.
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

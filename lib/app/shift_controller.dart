import 'package:flutter/foundation.dart';

import '../data/order.dart';

/// The single source of truth for today's shift — the working set of orders and
/// whether the courier has collected the batch from the branch yet. Every
/// dynamic surface reads from here (Home's next-stop + KPIs, the Orders/Queue
/// list, the Returns list); the delivery/failure outcomes mutate it, so closing
/// a stop advances the next-stop, updates the counters and files the return in
/// one place.
///
/// A [ChangeNotifier] singleton (Flutter_Base ViewController style — no bloc):
/// listen with `ListenableBuilder(listenable: ShiftController.instance, …)`.
class ShiftController extends ChangeNotifier {
  ShiftController._();
  static final ShiftController instance = ShiftController._();

  /// Seeded from the sample batch; mutated in place as stops are closed.
  List<Order> _orders = List<Order>.from(sampleOrders);
  bool _accepted = false;
  bool _returnsHandedOver = false;

  List<Order> get orders => _orders;

  /// The branch the returns are physically handed back to.
  String get returnsBranch => 'Sale Sucre — مدينة نصر';

  /// True once the courier confirmed the branch pickup — until then the app
  /// opens on the "collect from branch" screen instead of Home.
  bool get accepted => _accepted;

  // ── route (the batch being delivered — postponed orders leave the route) ──
  List<Order> get routeStops =>
      _orders.where((o) => o.status != OrderStatus.postponed).toList();

  /// Stops already closed today (delivered or failed).
  int get closedStops =>
      routeStops.where((o) => o.status != OrderStatus.transit).length;

  int get totalStops => routeStops.length;

  /// 1-based number of the stop the courier is on now (capped at [totalStops]).
  int get currentStopNumber =>
      totalStops == 0 ? 0 : (closedStops + 1).clamp(1, totalStops);

  /// The next order to deliver — the first still in transit, or null when the
  /// route is complete.
  Order? get nextStop {
    for (final o in _orders) {
      if (o.status == OrderStatus.transit) return o;
    }
    return null;
  }

  // ── KPI counters ──
  int get inProgress =>
      _orders.where((o) => o.status == OrderStatus.transit).length;
  int get deliveredCount =>
      _orders.where((o) => o.status == OrderStatus.delivered).length;
  int get failedCount =>
      _orders.where((o) => o.status == OrderStatus.failed).length;

  /// Cash collected today = the real collected amount on each delivered COD
  /// order (falls back to the due amount when a specific figure wasn't recorded).
  int get collectedEgp => _orders
      .where((o) => o.status == OrderStatus.delivered && !o.prepaid)
      .fold(0, (sum, o) => sum + (o.collected ?? o.cod ?? 0));

  /// Cash still to collect = COD due on the orders still in transit (not prepaid).
  int get toCollectEgp => _orders
      .where((o) => o.status == OrderStatus.transit && !o.prepaid)
      .fold(0, (sum, o) => sum + (o.cod ?? 0));

  /// Orders returned to the branch (a failed delivery sends the pieces back).
  List<Order> get returns =>
      _orders.where((o) => o.status == OrderStatus.failed).toList();

  /// Returns still in the courier's custody — the same [returns] until the
  /// courier hands the batch to the branch, then empty (drives the returns
  /// page's empty state).
  List<Order> get pendingReturns => _returnsHandedOver ? const [] : returns;

  /// Total pieces across the pending returns (sum of item quantities).
  int get returnPieces => pendingReturns.fold(0, (sum, o) => sum + o.pieces);

  /// True once the courier confirmed handing the returns to the branch.
  bool get returnsHandedOver => _returnsHandedOver;

  Order? orderByNum(String number) {
    for (final o in _orders) {
      if (o.num == number) return o;
    }
    return null;
  }

  // ── mutations ──
  void acceptBatch() {
    if (_accepted) return;
    _accepted = true;
    notifyListeners();
  }

  void markDelivered(String number, {int? collected}) =>
      _update(number, (o) => o.copyWith(
            status: OrderStatus.delivered,
            collected: collected ?? o.cod,
          ));

  void markFailed(String number, {String? reason}) => _update(
        number,
        (o) => o.copyWith(status: OrderStatus.failed, reason: reason),
      );

  void markPostponed(String number) =>
      _update(number, (o) => o.copyWith(status: OrderStatus.postponed));

  /// Hand the whole returns batch to the branch — the returns leave the
  /// courier's custody, so the returns page flips to its empty state.
  void handOverReturns() {
    if (_returnsHandedOver) return;
    _returnsHandedOver = true;
    notifyListeners();
  }

  /// Return a postponed order to the active queue (status → transit).
  void returnToQueue(String number) =>
      _update(number, (o) => o.copyWith(status: OrderStatus.transit));

  /// Reset the shift (used on logout) — re-seed the batch, un-accept it.
  void reset() {
    _orders = List<Order>.from(sampleOrders);
    _accepted = false;
    _returnsHandedOver = false;
    notifyListeners();
  }

  void _update(String number, Order Function(Order) transform) {
    var changed = false;
    final next = <Order>[];
    for (final o in _orders) {
      if (o.num == number) {
        next.add(transform(o));
        changed = true;
      } else {
        next.add(o);
      }
    }
    if (changed) {
      _orders = next;
      notifyListeners();
    }
  }
}

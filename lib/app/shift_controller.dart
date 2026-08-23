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

  /// Batches dispatched to this courier but not yet carried out of the branch,
  /// oldest first. A day holds several — a new one often lands while the
  /// previous is still being delivered — and each keeps its identity so the
  /// Pickup tab can present them as the separate batches they are.
  final List<OrderBatch> _pendingBatches = <OrderBatch>[];

  /// Sequence behind the generated batch ids.
  int _batchSeq = 1;

  /// A batch that has arrived but whose announcement sheet has not been shown
  /// yet. Read once via [takeAnnouncement] so it cannot announce twice.
  List<Order>? _announcement;

  List<Order> get orders => _orders;

  /// Batches waiting at the branch. The Pickup tab renders one group per entry;
  /// carrying one merges its orders into the route and grows [totalStops].
  List<OrderBatch> get pendingBatches => List.unmodifiable(_pendingBatches);

  bool get hasPendingPickup => _pendingBatches.isNotEmpty;

  /// Every order waiting at the branch, flattened across batches.
  List<Order> get pendingPickup =>
      [for (final b in _pendingBatches) ...b.orders];

  /// The branch the returns are physically handed back to.
  String get returnsBranch => 'Sale Sucre — مدينة نصر';

  /// True once the courier confirmed the branch pickup — until then the app
  /// opens on the "collect from branch" screen instead of Home.
  bool get accepted => _accepted;

  /// Order numbers belonging to the batches the courier is actually carrying.
  /// Grows as further batches are carried, so the route is always "what is in
  /// the bag", never the whole day's history.
  final Set<String> _carried = <String>{};

  /// Record a batch as being in hand. Union, not replace: carrying a second
  /// batch adds to the route rather than starting a new one.
  void _markCarried(Iterable<Order> batch) =>
      _carried.addAll(batch.map((o) => o.num));

  // ── route (the batches being delivered — postponed orders leave the route) ──
  //
  // Scoped to what has actually been carried, so the counters are driven by the
  // real batch instead of a fixed day: carry four orders and the hero reads
  // "الطلب ١ من ٤", and it climbs as each one closes. Before anything is
  // carried there is no batch to scope to, so this falls back to the full set.
  List<Order> get routeStops {
    if (_carried.isEmpty) {
      // Nothing carried yet: the batch about to be collected is what the hero
      // should describe, so scope to what is still to deliver rather than the
      // whole day. Otherwise the courier lands on Home reading a count that
      // includes orders they closed hours ago.
      return _orders.where((o) => o.status == OrderStatus.transit).toList();
    }
    return _orders
        .where((o) => _carried.contains(o.num))
        .where((o) => o.status != OrderStatus.postponed)
        .toList();
  }

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
  /// Dispatch a new batch to the courier mid-day. The orders wait at the branch
  /// until [carryPendingBatch] moves them onto the route; the batch is also
  /// parked in [_announcement] so the shell can surface the dispatch sheet.
  void assignBatch(List<Order> batch) {
    if (batch.isEmpty) return;
    _batchSeq += 1;
    _pendingBatches.add(
      OrderBatch(id: 'batch-$_batchSeq', orders: List<Order>.unmodifiable(batch)),
    );
    _announcement = List<Order>.unmodifiable(batch);
    notifyListeners();
  }

  /// Returns a newly-arrived batch exactly once, so a rebuild cannot re-announce
  /// a batch the courier has already been told about.
  List<Order>? takeAnnouncement() {
    final batch = _announcement;
    _announcement = null;
    return batch;
  }

  void acceptBatch() {
    if (_accepted) return;
    _accepted = true;
    // The day's first batch is whatever is still to deliver at this point.
    _markCarried(_orders.where((o) => o.status == OrderStatus.transit));
    notifyListeners();
  }

  /// Carry one batch onto the active route. Totals grow, so "الطلب ٥ من ٨"
  /// becomes "الطلب ٥ من ١١" the moment this lands.
  void carryBatch(String id) {
    final i = _pendingBatches.indexWhere((b) => b.id == id);
    if (i < 0) return;
    final batch = _pendingBatches.removeAt(i);
    _orders = [..._orders, ...batch.orders];
    _markCarried(batch.orders);
    _accepted = true;
    notifyListeners();
  }

  /// Carry everything waiting at the branch in one action.
  void carryPendingBatch() {
    if (_pendingBatches.isEmpty) return;
    final incoming = pendingPickup;
    _orders = [..._orders, ...incoming];
    _markCarried(incoming);
    _pendingBatches.clear();
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
    _pendingBatches.clear();
    _carried.clear();
    _batchSeq = 1;
    _announcement = null;
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

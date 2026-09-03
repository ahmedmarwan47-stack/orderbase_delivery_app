import 'package:flutter/foundation.dart';

import '../data/order.dart';

/// Where the courier is in their day. Home's hero, the header's status line and
/// the settlement page all read this one value rather than re-deriving it.
enum CourierStatus {
  /// No batch has been dispatched yet — the day has not started.
  idle,

  /// At least one order in hand is still in transit.
  onRoute,

  /// Everything in hand is closed; the courier is expected back at the branch
  /// to hand over cash and returns, or to collect the next batch.
  returning,

  /// The branch has settled the day. Nothing is owed until a new batch lands.
  settled,
}

/// What the branch recorded when it settled the day.
class SettlementReceipt {
  const SettlementReceipt({
    required this.cashier,
    required this.at,
    required this.cash,
    required this.walletChange,
    required this.orderCount,
  });

  final String cashier;
  final DateTime at;
  final int cash;
  final int walletChange;
  final int orderCount;
}

/// The single source of truth for today's shift — the batches in hand, the
/// batches waiting at the branch, every order's live status, the cash the
/// courier is carrying, and where they are in the day. Every dynamic surface
/// reads from here; the delivery/failure outcomes, carrying a batch and the
/// branch's settlement all mutate it, so one change lands everywhere at once.
///
/// A [ChangeNotifier] singleton (Flutter_Base ViewController style — no bloc):
/// listen with `ListenableBuilder(listenable: ShiftController.instance, …)`.
class ShiftController extends ChangeNotifier {
  ShiftController._() {
    _seed();
  }
  static final ShiftController instance = ShiftController._();

  /// The most cash a courier should be carrying before heading back to the
  /// branch. A merchant setting in production; one demo figure here.
  static const int cashThresholdEgp = 3000;

  /// The branch the courier is assigned to today — where batches are collected
  /// and where cash and returns go back to.
  String get branchName => 'فرع مدينة نصر';
  String get branchAddress => 'Sale Sucre — مدينة نصر';
  String get branchPhone => '+20222600123';

  /// The branch the returns are physically handed back to.
  String get returnsBranch => branchAddress;

  /// Batches the courier has carried out of the branch, oldest first.
  final List<OrderBatch> _carried = <OrderBatch>[];

  /// Batches dispatched to this courier but not yet carried, oldest first.
  final List<OrderBatch> _pending = <OrderBatch>[];

  /// Live copies of every order in hand (status mutates as stops close).
  List<Order> _orders = <Order>[];

  /// Which carried batch each order arrived in, keyed by order number.
  final Map<String, String> _batchOf = <String, String>{};

  /// A batch that has arrived but whose announcement has not been shown yet.
  /// Read once via [takeAnnouncement] so it cannot announce twice.
  OrderBatch? _announcement;

  bool _returnsHandedOver = false;

  /// Orders whose cash the branch has already taken — they no longer count
  /// toward [cashInHand].
  final Set<String> _settledOrderNums = <String>{};
  SettlementReceipt? _settlement;

  // ── batches ──
  List<OrderBatch> get carriedBatches => List.unmodifiable(_carried);
  List<OrderBatch> get pendingBatches => List.unmodifiable(_pending);
  bool get hasPendingBatch => _pending.isNotEmpty;

  /// Every order waiting at the branch, flattened across batches.
  List<Order> get pendingOrders => [for (final b in _pending) ...b.orders];

  /// True once anything has been carried — the Live Activity gates on this.
  bool get accepted => _carried.isNotEmpty;

  List<Order> get orders => _orders;

  /// Live orders of one carried batch, in carry order.
  List<Order> ordersOfBatch(String batchId) =>
      _orders.where((o) => _batchOf[o.num] == batchId).toList();

  /// The batch an order was carried in; null for an order still at the branch.
  String? batchIdOf(String orderNum) => _batchOf[orderNum];

  /// 1-based position of a batch in the day, for copy that counts them.
  int batchNumberOf(String batchId) =>
      _carried.indexWhere((b) => b.id == batchId) + 1;

  /// The batch the courier is delivering right now — the one the next stop
  /// belongs to, else the last one carried.
  OrderBatch? get currentBatch {
    final next = nextStop;
    if (next != null) {
      final id = _batchOf[next.num];
      for (final b in _carried) {
        if (b.id == id) return b;
      }
    }
    return _carried.isEmpty ? null : _carried.last;
  }

  // ── status ──
  CourierStatus get status {
    if (inProgress > 0) return CourierStatus.onRoute;
    final unsettled = _orders.any(
      (o) =>
          o.status == OrderStatus.delivered &&
          !_settledOrderNums.contains(o.num),
    );
    if (unsettled || pendingReturns.isNotEmpty) return CourierStatus.returning;
    if (_settlement != null) return CourierStatus.settled;
    if (_carried.isNotEmpty) return CourierStatus.returning;
    return CourierStatus.idle;
  }

  /// True once the branch has settled the day (until a new batch is carried).
  bool get settled => _settlement != null && status != CourierStatus.onRoute;
  SettlementReceipt? get settlement => _settlement;

  // ── trip estimates ──
  /// Kilometres still to ride: the legs to the remaining stops of [batch]
  /// (all of it, before anything closes) plus the ride back to the branch.
  double remainingKmOf(OrderBatch batch) {
    final left = ordersOfBatch(batch.id)
        .where((o) => o.status == OrderStatus.transit)
        .fold<double>(0, (sum, o) => sum + (o.distanceKm ?? 0));
    return left + OrderBatch.returnLegKm;
  }

  /// When the courier is expected back at the branch after [batch]'s last
  /// stop, at city speed, counting from now. Riding time only — it does not
  /// include stops or handoffs, and the hero's tooltip says so.
  DateTime returnEtaOf(OrderBatch batch) {
    final minutes = (remainingKmOf(batch) / OrderBatch.cityKmPerHour * 60)
        .round();
    return DateTime.now().add(Duration(minutes: minutes));
  }

  /// "٥:٤٠ م" for [currentBatch]; null before anything is carried.
  String? get returnEtaLabel {
    final b = currentBatch;
    return b == null ? null : formatClockArabic(returnEtaOf(b));
  }

  /// Where the courier is travelling *from* on the current leg: the branch
  /// until the first stop closes, then the door they just left.
  PlaceKind get legOrigin {
    Order? lastClosed;
    for (final o in routeStops) {
      if (o.status == OrderStatus.delivered || o.status == OrderStatus.failed) {
        lastClosed = o;
      }
    }
    return lastClosed?.place ?? PlaceKind.branch;
  }

  // ── route (the current batch — postponed orders leave the route) ──
  List<Order> get routeStops {
    final b = currentBatch;
    if (b == null) return const [];
    return ordersOfBatch(
      b.id,
    ).where((o) => o.status != OrderStatus.postponed).toList();
  }

  int get closedStops =>
      routeStops.where((o) => o.status != OrderStatus.transit).length;

  int get totalStops => routeStops.length;

  /// 1-based number of the stop the courier is on now (capped at [totalStops]).
  int get currentStopNumber =>
      totalStops == 0 ? 0 : (closedStops + 1).clamp(1, totalStops);

  /// The next order to deliver — the first still in transit, or null when
  /// everything in hand is closed.
  Order? get nextStop {
    for (final o in _orders) {
      if (o.status == OrderStatus.transit) return o;
    }
    return null;
  }

  // ── KPI counters (the whole day) ──
  int get inProgress =>
      _orders.where((o) => o.status == OrderStatus.transit).length;
  int get deliveredCount =>
      _orders.where((o) => o.status == OrderStatus.delivered).length;
  int get failedCount =>
      _orders.where((o) => o.status == OrderStatus.failed).length;

  /// Cash collected today across every delivered COD order.
  int get collectedEgp => _orders
      .where((o) => o.status == OrderStatus.delivered && !o.prepaid)
      .fold(0, (sum, o) => sum + (o.collected ?? o.cod ?? 0));

  /// Cash physically on the courier: collected and not yet taken by the branch.
  int get cashInHand => _orders
      .where(
        (o) =>
            o.status == OrderStatus.delivered &&
            !o.prepaid &&
            !_settledOrderNums.contains(o.num),
      )
      .fold(0, (sum, o) => sum + (o.collected ?? o.cod ?? 0));

  /// Cash still to collect = COD due on the orders still in transit.
  int get toCollectEgp => _orders
      .where((o) => o.status == OrderStatus.transit && !o.prepaid)
      .fold(0, (sum, o) => sum + (o.cod ?? 0));

  /// The courier is carrying more than the branch allows.
  bool get overCashLimit => cashInHand > cashThresholdEgp;

  /// Orders returned to the branch (a failed delivery sends the pieces back).
  List<Order> get returns =>
      _orders.where((o) => o.status == OrderStatus.failed).toList();

  /// Returns still in the courier's custody — empty once handed over.
  List<Order> get pendingReturns => _returnsHandedOver ? const [] : returns;

  int get returnPieces => pendingReturns.fold(0, (sum, o) => sum + o.pieces);

  bool get returnsHandedOver => _returnsHandedOver;

  Order? orderByNum(String number) {
    for (final o in _orders) {
      if (o.num == number) return o;
    }
    for (final o in pendingOrders) {
      if (o.num == number) return o;
    }
    return null;
  }

  // ── mutations ──
  /// A batch has been dispatched to the courier. It waits at the branch until
  /// [carryBatch] moves it onto the route, and is parked in [_announcement]
  /// so the shell can raise the mid-flight sheet exactly once.
  void assignBatch(OrderBatch batch) {
    if (batch.orders.isEmpty) return;
    if (_pending.any((b) => b.id == batch.id) ||
        _carried.any((b) => b.id == batch.id)) {
      return;
    }
    _pending.add(batch);
    _announcement = batch;
    notifyListeners();
  }

  /// Returns a newly-arrived batch exactly once.
  OrderBatch? takeAnnouncement() {
    final batch = _announcement;
    _announcement = null;
    return batch;
  }

  /// Carry one waiting batch onto the route. Totals grow, so «الطلب ٥ من ٨»
  /// becomes the new batch's «الطلب ١ من ٣» the moment its first stop is next.
  void carryBatch(String id) {
    final i = _pending.indexWhere((b) => b.id == id);
    if (i < 0) return;
    _carry(_pending.removeAt(i));
    notifyListeners();
  }

  /// Carry everything waiting at the branch in one action.
  void carryAllPending() {
    if (_pending.isEmpty) return;
    for (final b in List<OrderBatch>.of(_pending)) {
      _carry(b);
    }
    _pending.clear();
    notifyListeners();
  }

  void _carry(OrderBatch batch) {
    _carried.add(batch);
    _orders = [..._orders, ...batch.orders];
    for (final o in batch.orders) {
      _batchOf[o.num] = batch.id;
    }
    // A new batch reopens the day: returns and cash start accruing again.
    _returnsHandedOver = false;
  }

  void markDelivered(String number, {int? collected}) => _update(
    number,
    (o) => o.copyWith(
      status: OrderStatus.delivered,
      collected: collected ?? o.cod,
    ),
  );

  void markFailed(String number, {String? reason}) => _update(
    number,
    (o) => o.copyWith(status: OrderStatus.failed, reason: reason),
  );

  void markPostponed(String number) =>
      _update(number, (o) => o.copyWith(status: OrderStatus.postponed));

  /// Hand the returns to the branch — they leave the courier's custody.
  void handOverReturns() {
    if (_returnsHandedOver) return;
    _returnsHandedOver = true;
    notifyListeners();
  }

  /// Return a postponed order to the active queue (status → transit).
  void returnToQueue(String number) =>
      _update(number, (o) => o.copyWith(status: OrderStatus.transit));

  /// The branch settles the day from its dashboard: it takes the cash the
  /// courier is holding and the returns, and records who did it and when. The
  /// app only reports this — there is deliberately no button for it.
  void settleDay({required String cashier}) {
    final lines = _orders.where(
      (o) =>
          o.status == OrderStatus.delivered &&
          !o.prepaid &&
          !_settledOrderNums.contains(o.num),
    );
    var cash = 0;
    var wallet = 0;
    var count = 0;
    for (final o in lines) {
      final paid = o.collected ?? o.cod ?? 0;
      cash += paid;
      wallet += paid > (o.cod ?? 0) ? paid - (o.cod ?? 0) : 0;
      count += 1;
      _settledOrderNums.add(o.num);
    }
    _settlement = SettlementReceipt(
      cashier: cashier,
      at: DateTime.now(),
      cash: cash,
      walletChange: wallet,
      orderCount: count,
    );
    _returnsHandedOver = true;
    notifyListeners();
  }

  /// A fresh day with nothing dispatched yet — the idle state. The simulator
  /// restarts from here.
  void startNewDay() {
    _clear();
    notifyListeners();
  }

  /// Reset the shift (used on logout) — back to the seeded mid-day state.
  void reset() {
    _clear();
    _seed();
    notifyListeners();
  }

  void _clear() {
    _carried.clear();
    _pending.clear();
    _orders = <Order>[];
    _batchOf.clear();
    _announcement = null;
    _returnsHandedOver = false;
    _settledOrderNums.clear();
    _settlement = null;
  }

  /// The demo opens mid-day: the first batch is in hand and partly delivered,
  /// which is the state a courier actually spends most of the day in.
  void _seed() {
    _carry(OrderBatch(id: sampleBatchOneId, orders: sampleOrders));
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

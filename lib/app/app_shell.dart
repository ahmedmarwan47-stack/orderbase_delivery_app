import 'package:flutter/material.dart';

import '../core/live_activity/live_activity_bridge.dart';
import '../core/utils/app_motion.dart';
import '../data/flow_order.dart';
import '../data/order.dart';
import 'shift_controller.dart';
import '../features/home/presentation/imports/home_imports.dart';
import '../features/notifications/presentation/imports/notifications_imports.dart';
import '../features/order_flow/presentation/imports/order_flow_imports.dart';
import '../features/pickup/presentation/imports/pickup_imports.dart';
import '../features/profile/presentation/imports/profile_imports.dart';
import '../features/queue/presentation/imports/queue_imports.dart';
import '../features/settlement/presentation/imports/settlement_imports.dart';
import '../widgets/bottom_nav.dart';

/// The signed-in app: a tabbed shell hosting the built screens and wiring the
/// Order Flow end-to-end. Shown by [AuthGate] (the real `/` entry point) once
/// the courier is logged in.
///
/// Tabs map to [NavTab]: home · orders · batches · settlement · account. The
/// last one is the courier's own profile (it keeps the DevGallery reachable for
/// screens that aren't in the nav yet, e.g. the standalone Result variants).
///
/// The order-detail flow (detail → handoff/fail/postpone sheets → result) is
/// pushed *over* the shell. The result screen's buttons pop the whole flow
/// back to the shell — "back to home" also switches to the Home tab.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell>
    with SingleTickerProviderStateMixin {
  NavTab _tab = NavTab.home;

  /// Drives a quick fade-in of the newly-selected tab. The [IndexedStack] stays
  /// in the tree (so every tab keeps its state); only the visible child is
  /// dissolved in on switch. Held at 1.0 while idle / under Reduce Motion.
  late final AnimationController _tabFade = AnimationController(
    vsync: this,
    duration: AppMotion.stamp,
    value: 1,
  );
  late final Animation<double> _tabFadeCurve = CurvedAnimation(
    parent: _tabFade,
    curve: AppMotion.ease,
  );

  /// The Orders tab IS the "today's orders" queue (search + 5 filters +
  /// postponed). The shell owns its controller so a Home KPI tap can preselect
  /// a filter and switch tabs; card taps open the flow *through* the shell.

  late final QueueViewController _ordersVc = QueueViewController(
    onSelectTab: _select,
    onOpenOrder: _openOrder,
    onOpenNotifications: _openNotifications,
  );

  @override
  void initState() {
    super.initState();
    // A tap on the Live Activity opens that order here (no-op on devices that
    // never show one).
    LiveActivityBridge.instance.onOpenOrder = _openOrderByNum;
    // Greet the courier with the dispatched batch once the shell is on screen —
    // informative, not a gate (see [_announceDispatch]).
    WidgetsBinding.instance.addPostFrameCallback((_) => _announceDispatch());
  }

  /// If a branch batch is waiting and hasn't been carried yet, pop the
  /// dismissible "new batch at the branch" sheet. Choosing "carry from branch"
  /// jumps to the Pickup tab; dismissing just leaves the batch waiting.
  Future<void> _announceDispatch() async {
    if (!mounted) return;
    final shift = ShiftController.instance;
    if (shift.accepted) return;
    final orders = shift.orders
        .where((o) => o.status == OrderStatus.transit)
        .map(orderToFlow)
        .toList();
    if (orders.isEmpty) return;
    final carry = await showPickupDispatchSheet(context, orders: orders);
    if (carry == true && mounted) _select(NavTab.pickup);
  }

  @override
  void dispose() {
    LiveActivityBridge.instance.onOpenOrder = null;
    _tabFade.dispose();
    _ordersVc.dispose();
    super.dispose();
  }

  void _select(NavTab t) {
    if (t == _tab) return;
    setState(() => _tab = t);
    // Cross-fade the incoming tab in; jump straight to it under Reduce Motion.
    if (AppMotion.reduced(context)) {
      _tabFade.value = 1;
    } else {
      _tabFade.forward(from: 0);
    }
  }

  void _openNotifications() => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => NotificationsScreen(
        onSelectTab: (t) {
          Navigator.of(context).pop();
          _select(t);
        },
        onOpenOrder: _openOrderByNum,
      ),
    ),
  );

  /// Push the order-detail flow for [order], wiring its Result screen back to
  /// the shell.
  void _openOrder(FlowOrder order) {
    void popToShell() => Navigator.of(context).popUntil((r) => r.isFirst);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OrderDetailScreen(
          order: order,
          onFinishToNext: popToShell,
          onFinishToHome: () {
            popToShell();
            _select(NavTab.home);
          },
          onSelectTab: (t) {
            popToShell();
            _select(t);
          },
        ),
      ),
    );
  }

  /// A tap on the Home hero card — open the current next-stop order.
  void _openNextStop() {
    final o = ShiftController.instance.nextStop;
    if (o != null) _openOrder(orderToFlow(o));
  }

  /// The Home hero's black button — hand the current order over without going
  /// through the detail screen first. It runs the *same* flow the detail's
  /// sticky bar runs (handoff sheet → COD collection → result), because there
  /// is only one way to close an order in this app.
  Future<void> _deliverNextStop() async {
    final o = ShiftController.instance.nextStop;
    if (o == null) return;
    void popToShell() => Navigator.of(context).popUntil((r) => r.isFirst);
    await OrderFlowController(
      orderNum: o.num,
      customer: o.name,
      onFinishToNext: popToShell,
      onFinishToHome: () {
        popToShell();
        _select(NavTab.home);
      },
    ).deliver(context, cod: o.cod != null && !o.prepaid, due: o.cod ?? 0);
  }

  /// A notification tap — open the order it refers to (resolved against the
  /// shift by number; no-op if that order isn't in this shift).
  void _openOrderByNum(String orderNum) {
    final o = ShiftController.instance.orderByNum('#$orderNum');
    if (o != null) _openOrder(orderToFlow(o));
  }

  /// A Home KPI tile → the Orders tab with that slice preselected.
  void _openOrdersFilter(QueueFilter f) {
    _ordersVc.closeSearch();
    _ordersVc.selectFilter(f);
    _select(NavTab.orders);
  }

  /// Home "collected today" KPI → the Settlement tab.
  void _openSettlement() => _select(NavTab.settlement);

  /// The unified header's search (from any tab) → the Orders tab, in search mode.
  void _openOrdersSearch() {
    _ordersVc.openSearch();
    _select(NavTab.orders);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: FadeTransition(
        opacity: _tabFadeCurve,
        child: IndexedStack(
          index: _tab.index,
          children: [
            HomeScreen(
              onSelectTab: _select,
              onOpenOrder: _openNextStop,
              onDeliverOrder: _deliverNextStop,
              onOpenOrdersFilter: _openOrdersFilter,
              onOpenSettlement: _openSettlement,
              onOpenNotifications: _openNotifications,
              onOpenSearch: _openOrdersSearch,
            ),
            QueueScreen(controller: _ordersVc),
            PickupScreen(
              onSelectTab: _select,
              onOpenNotifications: _openNotifications,
              onOpenSearch: _openOrdersSearch,
              onConfirm: () {
                // Carrying from the Pickup tab collects everything waiting at
                // the branch: the day's first batch, plus any dispatched since.
                // Later batches join the route, so the totals grow.
                final shift = ShiftController.instance;
                shift.acceptBatch();
                shift.carryPendingBatch();
                _select(NavTab.home);
              },
            ),
            SettlementScreen(
              onSelectTab: _select,
              onOpenNotifications: _openNotifications,
              onOpenSearch: _openOrdersSearch,
            ),
            ProfileScreen(
              onSelectTab: _select,
              onOpenNotifications: _openNotifications,
              onOpenSearch: _openOrdersSearch,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../core/live_activity/live_activity_bridge.dart';
import '../core/live_activity/live_activity_service.dart';
import '../core/utils/app_motion.dart';
import '../data/flow_order.dart';
import '../data/order.dart';
import '../features/home/presentation/imports/home_imports.dart';
import '../features/notifications/presentation/imports/notifications_imports.dart';
import '../features/order_flow/presentation/imports/order_flow_imports.dart';
import '../features/pickup/presentation/imports/pickup_imports.dart';
import '../features/profile/presentation/imports/profile_imports.dart';
import '../features/queue/presentation/imports/queue_imports.dart';
import '../features/settlement/presentation/imports/settlement_imports.dart';
import '../theme/colors.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav.dart';
import 'shift_controller.dart';
import 'shift_simulator.dart';

/// The signed-in app: a tabbed shell hosting the built screens and wiring the
/// Order Flow end-to-end. Shown by [AuthGate] (the real `/` entry point) once
/// the courier is logged in.
///
/// Four tabs map to [NavTab]: home · orders · settlement · account. A fifth
/// page, notifications, lives in the same frame: opening it swaps the body
/// under the unified header while the header and tab bar stay where they are,
/// and no tab is highlighted.
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

  /// Notifications is a page, not a tab — while it is up the tab bar shows no
  /// selection and the header's bell reads as "close".
  bool _notifications = false;

  /// Drives a quick fade-in of the newly-selected page. The [IndexedStack]
  /// stays in the tree (so every page keeps its state); only the visible child
  /// is dissolved in on switch. Held at 1.0 while idle / under Reduce Motion.
  late final AnimationController _pageFade = AnimationController(
    vsync: this,
    duration: AppMotion.stamp,
    value: 1,
  );
  late final Animation<double> _pageFadeCurve = CurvedAnimation(
    parent: _pageFade,
    curve: AppMotion.ease,
  );

  /// The Orders tab IS the day's batches (search + 5 filters + postponed).
  /// The shell owns its controller so a Home KPI tap can preselect a filter
  /// and switch tabs; row taps open the flow *through* the shell.
  late final QueueViewController _ordersVc = QueueViewController(
    onSelectTab: _select,
    onOpenOrder: _openOrder,
    onOpenNotifications: _toggleNotifications,
  );

  /// The branch's side of the day — dispatches batches, settles at the end.
  late final ShiftSimulator _simulator = ShiftSimulator(
    shift: ShiftController.instance,
    notifications: NotificationsStore.instance,
  );

  @override
  void initState() {
    super.initState();
    // A tap on the Live Activity opens that order here (no-op on devices that
    // never show one).
    LiveActivityBridge.instance.onOpenOrder = _openOrderByNum;
    ShiftController.instance.addListener(_onShiftChanged);
    _simulator.start();
    // A batch may already be waiting when the shell appears.
    WidgetsBinding.instance.addPostFrameCallback((_) => _announceDispatch());
  }

  @override
  void dispose() {
    LiveActivityBridge.instance.onOpenOrder = null;
    ShiftController.instance.removeListener(_onShiftChanged);
    _simulator.dispose();
    _pageFade.dispose();
    _ordersVc.dispose();
    super.dispose();
  }

  void _onShiftChanged() => _announceDispatch();

  /// A batch has just been dispatched: raise the mid-flight sheet exactly once.
  /// It is informative, not a gate — «عرض الدفعة» jumps to the Orders tab,
  /// «لاحقًا» leaves the batch waiting (the header chip keeps pointing at it).
  Future<void> _announceDispatch() async {
    if (!mounted) return;
    final batch = ShiftController.instance.takeAnnouncement();
    if (batch == null) return;
    final view = await showPickupDispatchSheet(
      context,
      batch: batch,
      branch: ShiftController.instance.branchName,
    );
    if (view == true && mounted) _openPendingBatch();
  }

  void _fadeIn() {
    if (AppMotion.reduced(context)) {
      _pageFade.value = 1;
    } else {
      _pageFade.forward(from: 0);
    }
  }

  void _select(NavTab t) {
    if (t == _tab && !_notifications) return;
    setState(() {
      _tab = t;
      _notifications = false;
    });
    _fadeIn();
  }

  /// The header bell: open notifications over the current tab, or, when
  /// already open, go back to that tab.
  void _toggleNotifications() {
    setState(() => _notifications = !_notifications);
    _fadeIn();
  }

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

  /// The hero's call tile — dial the current customer (a no-op where there is
  /// no dialer, e.g. the web build).
  void _callNextStop() {
    final phone = ShiftController.instance.nextStop?.phone;
    if (phone != null && phone.isNotEmpty) {
      LiveActivityService.instance.dial(phone);
    }
  }

  /// «اتصال بالفرع» on the expected-at-branch card.
  void _callBranch() =>
      LiveActivityService.instance.dial(ShiftController.instance.branchPhone);

  /// A notification tap — open the order it refers to (resolved against the
  /// shift by number; no-op if that order isn't in this shift).
  void _openOrderByNum(String orderNum) {
    final o = ShiftController.instance.orderByNum('#$orderNum');
    if (o != null) _openOrder(orderToFlow(o));
  }

  /// A Home KPI cell → the Orders tab with that slice preselected.
  void _openOrdersFilter(QueueFilter f) {
    _ordersVc.closeSearch();
    _ordersVc.selectFilter(f);
    _select(NavTab.orders);
  }

  /// The dispatch sheet's «عرض الدفعة» and Home's «دفعة جديدة في انتظارك» row
  /// → the Orders tab, filters cleared so the waiting batch is at the top.
  void _openPendingBatch() {
    _ordersVc.closeSearch();
    _ordersVc.clearFilter();
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
        opacity: _pageFadeCurve,
        child: IndexedStack(
          index: _notifications ? NavTab.values.length : _tab.index,
          children: [
            HomeScreen(
              onSelectTab: _select,
              onOpenOrder: _openNextStop,
              onDeliverOrder: _deliverNextStop,
              onCallCustomer: _callNextStop,
              onCallBranch: _callBranch,
              onOpenOrdersFilter: _openOrdersFilter,
              onOpenSettlement: _openSettlement,
              onOpenPendingBatch: _openPendingBatch,
              onOpenNotifications: _toggleNotifications,
              onOpenSearch: _openOrdersSearch,
              onStartNewDay: _simulator.restart,
            ),
            QueueScreen(controller: _ordersVc),
            SettlementScreen(
              onSelectTab: _select,
              onOpenNotifications: _toggleNotifications,
              onOpenSearch: _openOrdersSearch,
            ),
            ProfileScreen(
              onSelectTab: _select,
              onOpenNotifications: _toggleNotifications,
              onOpenSearch: _openOrdersSearch,
              onStartNewDay: _simulator.restart,
              onSettleDay: _simulator.settleNow,
            ),
            _NotificationsPage(
              onSelectTab: _select,
              onClose: _toggleNotifications,
              onOpenOrder: _openOrderByNum,
              onOpenSearch: _openOrdersSearch,
            ),
          ],
        ),
      ),
    );
  }
}

/// Notifications inside the tab frame: the same unified header (bell inverted,
/// acting as "close"), the feed, and the tab bar with nothing selected.
class _NotificationsPage extends StatelessWidget {
  const _NotificationsPage({
    required this.onSelectTab,
    required this.onClose,
    required this.onOpenOrder,
    this.onOpenSearch,
  });

  final ValueChanged<NavTab> onSelectTab;
  final VoidCallback onClose;
  final ValueChanged<String> onOpenOrder;
  final VoidCallback? onOpenSearch;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppHeader(
              onSearch: onOpenSearch,
              onOpenNotifications: onClose,
              notificationsActive: true,
            ),
            Expanded(
              child: NotificationsScreen(
                embedded: true,
                onOpenOrder: onOpenOrder,
              ),
            ),
            BottomNav(active: null, onTap: onSelectTab),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../core/utils/app_motion.dart';
import '../core/widgets/app_assets.dart';
import '../core/widgets/icon_widget.dart';
import '../data/flow_order.dart';
import '../data/order.dart';
import '../dev/dev_gallery.dart';
import 'shift_controller.dart';
import '../features/auth/presentation/imports/auth_imports.dart';
import '../features/failure_states/presentation/imports/failure_states_imports.dart';
import '../features/home/presentation/imports/home_imports.dart';
import '../features/notifications/presentation/imports/notifications_imports.dart';
import '../features/order_flow/presentation/imports/order_flow_imports.dart';
import '../features/pickup/presentation/imports/pickup_imports.dart';
import '../features/queue/presentation/imports/queue_imports.dart';
import '../features/settlement/presentation/imports/settlement_imports.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../widgets/bottom_nav.dart';

/// The signed-in app: a tabbed shell hosting the built screens and wiring the
/// Order Flow end-to-end. Shown by [AuthGate] (the real `/` entry point) once
/// the courier is logged in.
///
/// Tabs map to [NavTab]: **Home** and **Orders** are real screens; the
/// **notifications** / **more** tabs are placeholders until those screens are
/// built (the *more* tab keeps the DevGallery reachable for testing screens
/// that aren't in the nav yet, e.g. Pickup and the standalone Result variants).
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
  late final Animation<double> _tabFadeCurve =
      CurvedAnimation(parent: _tabFade, curve: AppMotion.ease);

  /// The Orders tab IS the "today's orders" queue (search + 5 filters +
  /// postponed). The shell owns its controller so a Home KPI tap can preselect
  /// a filter and switch tabs; card taps open the flow *through* the shell.
  late final QueueViewController _ordersVc = QueueViewController(
    onSelectTab: _select,
    onOpenOrder: _openOrder,
  );

  @override
  void dispose() {
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

  /// Home hero "عرض الطلب" — open the current next-stop order.
  void _openNextStop() {
    final o = ShiftController.instance.nextStop;
    if (o != null) _openOrder(orderToFlow(o));
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
              onOpenOrdersFilter: _openOrdersFilter,
              onOpenSettlement: _openSettlement,
              onOpenNotifications: _openNotifications,
            ),
            QueueScreen(controller: _ordersVc),
            PickupScreen(
              onSelectTab: _select,
              onConfirm: () => _select(NavTab.home),
            ),
            SettlementScreen(onSelectTab: _select),
            _MoreTab(onSelectTab: _select),
          ],
        ),
      ),
    );
  }
}

/// The **More** tab — a real menu linking the built-but-not-tabbed screens
/// (settlement, returns, pickup, account) plus the DevGallery, so everything is
/// reachable from the running app rather than only through dev tooling.
class _MoreTab extends StatelessWidget {
  const _MoreTab({required this.onSelectTab});

  final ValueChanged<NavTab> onSelectTab;

  void _push(BuildContext context, Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.s20, AppSpacing.s12,
                    AppSpacing.s20, AppSpacing.s16),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text('المزيد',
                      style: AppTypography.size20.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary)),
                ),
              ),
              Expanded(
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
                  children: [
                    _MoreRow(
                        icon: AppAssets.svg.box,
                        label: 'مرتجعات للفرع',
                        onTap: () => _push(context, const ReturnsListScreen())),
                    _MoreRow(
                        icon: AppAssets.svg.user,
                        label: 'الحساب وكلمة المرور',
                        onTap: () =>
                            _push(context, const ChangePasswordScreen())),
                    _MoreRow(
                        icon: AppAssets.svg.more,
                        label: 'كل الشاشات (Dev)',
                        onTap: () => _push(context, const DevGallery())),
                  ],
                ),
              ),
              BottomNav(
                  active: NavTab.more,
                  notificationsBadge: true,
                  onTap: onSelectTab),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreRow extends StatelessWidget {
  const _MoreRow(
      {required this.icon, required this.label, required this.onTap});

  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s12),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(12)),
                  child: Center(
                      child: IconWidget(
                          icon: icon,
                          color: AppColors.textPrimary,
                          height: 20,
                          width: 20)),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Text(label,
                      style: AppTypography.size16.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                ),
                IconWidget(
                    icon: AppAssets.svg.chevronLeft,
                    color: AppColors.textSecondary,
                    height: 18,
                    width: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

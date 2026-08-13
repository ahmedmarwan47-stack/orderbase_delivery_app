import 'package:flutter/material.dart';

import '../core/widgets/app_assets.dart';
import '../core/widgets/icon_widget.dart';
import '../data/flow_order.dart';
import '../dev/dev_gallery.dart';
import '../features/auth/presentation/imports/auth_imports.dart';
import '../features/failure_states/presentation/imports/failure_states_imports.dart';
import '../features/home/presentation/imports/home_imports.dart';
import '../features/order_flow/presentation/imports/order_flow_imports.dart';
import '../features/orders/presentation/imports/orders_imports.dart';
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

class _AppShellState extends State<AppShell> {
  NavTab _tab = NavTab.home;

  void _select(NavTab t) => setState(() => _tab = t);

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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: IndexedStack(
        index: _tab.index,
        children: [
          HomeScreen(
            onSelectTab: _select,
            onOpenOrder: () => _openOrder(sampleFlowOrders.first),
          ),
          OrdersListScreen(onSelectTab: _select, onOpenOrder: _openOrder),
          _PlaceholderTab(
              tab: NavTab.notifications,
              title: 'الاشعارات',
              onSelectTab: _select),
          _MoreTab(onSelectTab: _select),
        ],
      ),
    );
  }
}

/// A minimal "coming soon" tab that still carries the shared bottom nav so the
/// user can navigate back out. On the *more* tab it also exposes the DevGallery.
class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({
    required this.tab,
    required this.title,
    required this.onSelectTab,
  });

  final NavTab tab;
  final String title;
  final ValueChanged<NavTab> onSelectTab;

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
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title,
                          style: AppTypography.size20.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: AppSpacing.s8),
                      Text('قريبًا',
                          style: AppTypography.size14
                              .copyWith(color: AppColors.textTertiary)),
                    ],
                  ),
                ),
              ),
              BottomNav(
                  active: tab, notificationsBadge: true, onTap: onSelectTab),
            ],
          ),
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
                      style: AppTypography.size24.copyWith(
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
                        icon: AppAssets.svg.orders,
                        label: 'طلبات اليوم',
                        onTap: () => _push(context, const QueueScreen())),
                    _MoreRow(
                        icon: AppAssets.svg.cash,
                        label: 'تسوية نهاية اليوم',
                        onTap: () => _push(context, const SettlementScreen())),
                    _MoreRow(
                        icon: AppAssets.svg.box,
                        label: 'مرتجعات للفرع',
                        onTap: () => _push(context, const ReturnsListScreen())),
                    _MoreRow(
                        icon: AppAssets.svg.note,
                        label: 'استلام من الفرع',
                        onTap: () => _push(context, const PickupScreen())),
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

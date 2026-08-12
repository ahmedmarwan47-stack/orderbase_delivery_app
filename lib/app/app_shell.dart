import 'package:flutter/material.dart';

import '../dev/dev_gallery.dart';
import '../features/home/presentation/imports/home_imports.dart';
import '../features/order_flow/presentation/imports/order_flow_imports.dart';
import '../features/orders/presentation/imports/orders_imports.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../widgets/bottom_nav.dart';

/// The app's real entry point: a tabbed shell hosting the built screens and
/// wiring the Order Flow end-to-end.
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

  /// Push the order-detail flow, wiring its Result screen back to the shell.
  void _openOrder() {
    void popToShell() => Navigator.of(context).popUntil((r) => r.isFirst);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OrderDetailScreen(
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
          HomeScreen(onSelectTab: _select, onOpenOrder: _openOrder),
          OrdersListScreen(
              onSelectTab: _select, onOpenOrder: (_) => _openOrder()),
          _PlaceholderTab(
              tab: NavTab.notifications,
              title: 'الاشعارات',
              onSelectTab: _select),
          _PlaceholderTab(
              tab: NavTab.more,
              title: 'المزيد',
              onSelectTab: _select,
              showDevEntry: true),
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
    this.showDevEntry = false,
  });

  final NavTab tab;
  final String title;
  final ValueChanged<NavTab> onSelectTab;
  final bool showDevEntry;

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
                      if (showDevEntry) ...[
                        const SizedBox(height: AppSpacing.s24),
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const DevGallery())),
                          child: Text('الشاشات (Dev)',
                              style: AppTypography.size14.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary)),
                        ),
                      ],
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

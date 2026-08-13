part of '../imports/home_imports.dart';

/// Home / الرئيسية — design option 1a ("Airy": next-stop hero + 2×2 stats).
/// Ported from Home Directions.dc.html (#1a). Reads the live [ShiftController]
/// so the next-stop hero advances and the KPI tiles update as stops close.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.onSelectTab,
    this.onOpenOrder,
    this.onOpenOrdersFilter,
    this.onOpenSettlement,
  });

  /// Forwarded to the bottom nav so the app shell can switch tabs.
  final ValueChanged<NavTab>? onSelectTab;

  /// Opens the current next-stop order's detail ("عرض الطلب" on the hero).
  final VoidCallback? onOpenOrder;

  /// A KPI tile that maps to a slice of the Orders/Queue tab (in-progress /
  /// delivered / failed) — switches to that tab with the filter preselected.
  final void Function(QueueFilter)? onOpenOrdersFilter;

  /// The "collected today" KPI tile → end-of-day settlement.
  final VoidCallback? onOpenSettlement;

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
              const _HomeMerchantHeader(),
              Expanded(
                child: AnimatedBuilder(
                  animation: ShiftController.instance,
                  builder: (_, _) => SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _HomeNextStopCard(onViewOrder: onOpenOrder),
                        20.szH,
                        _HomeTodayStats(
                          onOpenOrdersFilter: onOpenOrdersFilter,
                          onOpenSettlement: onOpenSettlement,
                        ),
                      ],
                    ).paddingOnly(
                      left: AppPadding.pW20,
                      top: AppPadding.pH4,
                      right: AppPadding.pW20,
                      bottom: AppPadding.pH20,
                    ),
                  ),
                ),
              ),
              BottomNav(
                active: NavTab.home,
                notificationsBadge: true,
                onTap: onSelectTab,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

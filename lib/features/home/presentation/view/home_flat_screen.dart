part of '../imports/home_imports.dart';

/// Home / الرئيسية — design option 2a ("Flat": a clean, box-free next-stop
/// block over a boxed today-overview card, mirroring the single-order page).
/// Ported from Home Directions.dc.html (#2a). Static, so no ViewController.
class HomeFlatScreen extends StatelessWidget {
  const HomeFlatScreen({super.key, this.onSelectTab, this.onOpenOrder});

  final ValueChanged<NavTab>? onSelectTab;
  final VoidCallback? onOpenOrder;

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
              const _HomeFlatHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _HomeFlatNextStop(onViewOrder: onOpenOrder),
                      16.szH,
                      _HomeOverviewCard(
                        onTap: () => onSelectTab?.call(NavTab.orders),
                      ),
                    ],
                  ).paddingOnly(
                    left: AppPadding.pW20,
                    right: AppPadding.pW20,
                    bottom: AppPadding.pH20,
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

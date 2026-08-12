part of '../imports/home_imports.dart';

/// Home / الرئيسية — design option 1c ("Compact": a tight stat row and a route
/// card with a mini map plus the remaining-stops list).
/// Ported from Home Directions.dc.html (#1c). Static, so no ViewController.
class HomeCompactScreen extends StatelessWidget {
  const HomeCompactScreen({super.key, this.onSelectTab, this.onOpenOrder});

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
              const _HomeCompactHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _HomeCompactStatRow(),
                      16.szH,
                      _HomeRouteCard(onViewOrder: onOpenOrder),
                    ],
                  ).paddingOnly(
                    left: AppPadding.pW20,
                    top: AppPadding.pH4,
                    right: AppPadding.pW20,
                    bottom: AppPadding.pH16,
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

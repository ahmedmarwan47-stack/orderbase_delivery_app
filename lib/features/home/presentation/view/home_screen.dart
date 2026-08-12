part of '../imports/home_imports.dart';

/// Home / الرئيسية — design option 1a ("Airy": next-stop hero + 2×2 stats).
/// Ported from Home Directions.dc.html (#1a). Fully static, so no ViewController.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onSelectTab, this.onOpenOrder});

  /// Forwarded to the bottom nav so the app shell can switch tabs.
  final ValueChanged<NavTab>? onSelectTab;

  /// Opens the current order's detail ("عرض الطلب" button on the hero card).
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
              const _HomeMerchantHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _HomeNextStopCard(onViewOrder: onOpenOrder),
                      20.szH,
                      const _HomeTodayStats(),
                    ],
                  ).paddingOnly(
                    left: AppPadding.pW20,
                    top: AppPadding.pH4,
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

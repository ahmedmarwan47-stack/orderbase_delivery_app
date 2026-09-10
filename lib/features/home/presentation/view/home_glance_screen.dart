part of '../imports/home_imports.dart';

/// Home / الرئيسية — design option 1b ("Glance": online toggle, dark collection
/// banner, big-number stat strip, compact next-stop card).
/// Ported from Home Directions.dc.html (#1b). Static, so no ViewController.
class HomeGlanceScreen extends StatelessWidget {
  const HomeGlanceScreen({super.key, this.onSelectTab, this.onOpenOrder});

  final ValueChanged<NavTab>? onSelectTab;
  final VoidCallback? onOpenOrder;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        extendBody: true,
        bottomNavigationBar: BottomNav(
          active: NavTab.home,
          notificationsBadge: true,
          onTap: onSelectTab,
        ),
        body: SafeArea(
          // The header sliver carries the top inset (see AppHeaderSliver), so the
          // page passes under the status bar and the scroll-edge blur runs to the
          // top of the screen.
          top: false,
          bottom: false,
          child: CustomScrollView(
            slivers: [
              AppHeaderSliver(title: LocaleKeys.navHome.tr()),
              SliverToBoxAdapter(
                child:
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _HomeOnlineBar(),
                        16.szH,
                        const _HomeCollectionBanner(),
                        16.szH,
                        const _HomeStatStrip(),
                        16.szH,
                        _HomeNextStopCompactCard(onViewOrder: onOpenOrder),
                      ],
                    ).paddingOnly(
                      left: AppPadding.pW20,
                      top: AppPadding.pH4,
                      right: AppPadding.pW20,
                      bottom: BottomNav.reservedHeight(context),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

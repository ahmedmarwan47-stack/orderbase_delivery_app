part of '../imports/profile_imports.dart';

/// «الحساب» — the courier's own tab: who they are, then the handful of things
/// they can do about it.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.onSelectTab,
    this.onOpenNotifications,
    this.onOpenSearch,
    this.onStartNewDay,
    this.hostsTabBar = true,
  });

  final ValueChanged<NavTab> onSelectTab;
  final VoidCallback? onOpenNotifications;
  final VoidCallback? onOpenSearch;

  /// Dev-only: reset the simulated day so the whole flow can be run again.
  final VoidCallback? onStartNewDay;

  /// Standalone the page carries its own tab bar; inside the app shell the
  /// shell owns the one bar, so this is false there.
  final bool hostsTabBar;

  void _push(BuildContext context, Widget screen) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => screen));

  /// Ends the in-memory session; `AuthGate` listens to it and drops straight
  /// back to the login screen.
  void _logout(BuildContext context) {
    AuthSession.instance.logOut();
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        extendBody: true,
        bottomNavigationBar: hostsTabBar
            ? BottomNav(
                active: NavTab.profile,
                notificationsBadge: true,
                onTap: onSelectTab,
              )
            : null,
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              AppHeaderSliver(
                title: LocaleKeys.navProfile.tr(),
                onSearch: onOpenSearch,
                onOpenNotifications: onOpenNotifications,
              ),
              SliverPadding(
                padding: EdgeInsetsDirectional.only(
                  bottom: BottomNav.reservedHeight(context),
                ),
                sliver: SliverList.list(
                  children: [
                    const _ProfileIdentity(),
                    16.szH,
                    // «وضع الطريق» and its auto switch, on their own surface
                    // above the account rows: a setting the courier flips on
                    // the bike, not an account chore.
                    const _RoadModeGroup(),
                    16.szH,
                    // Rows on one surface, hairline-separated — the same flat
                    // list treatment the orders and batches now use.
                    _ProfileGroup(
                      children: [
                        _ProfileRow(
                          icon: AppAssets.svg.lock,
                          label: LocaleKeys.profileAccountPassword.tr(),
                          onTap: () =>
                              _push(context, const ChangePasswordScreen()),
                        ),
                        _ProfileRow(
                          icon: AppAssets.svg.more,
                          label: LocaleKeys.profileDevScreens.tr(),
                          onTap: () => _push(context, const DevGallery()),
                        ),
                        const _NavMaterialRow(),
                        if (onStartNewDay != null)
                          _ProfileRow(
                            icon: AppAssets.svg.box,
                            label: LocaleKeys.homeStartNewDay.tr(),
                            onTap: () {
                              onStartNewDay!();
                              onSelectTab(NavTab.home);
                            },
                          ),
                        _ProfileRow(
                          icon: AppAssets.svg.undo,
                          label: LocaleKeys.authLogout.tr(),
                          danger: true,
                          last: true,
                          onTap: () => _logout(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

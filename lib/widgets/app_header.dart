import 'package:flutter/material.dart';

import '../config/res/config_imports.dart';

/// The unified app header — an iOS-style large title that collapses on scroll.
///
/// It is a **sliver**: the first child of the page's [CustomScrollView], so the
/// title's size is driven by the page's own scroll offset rather than by a
/// controller wired up by hand. Expanded, the page name reads at 24/bold on the
/// page ground with nothing above it; scrolled, it shrinks into a compact bar
/// about the height of the old header, gains the surface fill and its hairline,
/// and the actions stay exactly where they were the whole way down.
///
/// The bar carries only the two actions — search and the bell — at the
/// leading-left, 44pt each. The branch name and the shift line that used to
/// live here moved into the pages that own them (Home states the branch above
/// its stat strip); a bar that repeats live figures the page beneath already
/// prints is a second source of truth for the same number.
class AppHeaderSliver extends StatelessWidget {
  const AppHeaderSliver({
    super.key,
    required this.title,
    this.onSearch,
    this.onOpenNotifications,
    this.notificationsBadge = true,
    this.notificationsActive = false,
    this.background = AppColors.background,
  });

  /// The page name — the large title, and the compact one it shrinks into.
  final String title;

  /// Opens search for this page (inline on Orders, a pushed search elsewhere).
  final VoidCallback? onSearch;

  /// Opens (or, when [notificationsActive], closes) the notifications page.
  final VoidCallback? onOpenNotifications;

  /// Shows the red dot on the bell.
  final bool notificationsBadge;

  /// The notifications page is what is on screen: the bell tile inverts to ink
  /// so the courier can see they are "in" it, and tapping it goes back.
  final bool notificationsActive;

  /// The page ground the header sits on while expanded. It lerps to
  /// [AppColors.surface] as the title collapses, so the bar separates itself
  /// from the content passing beneath it.
  final Color background;

  /// Collapsed height — the bar the title shrinks into. The 44pt action tiles
  /// sit centred in it, so this is what sets their breathing room: at 52 they
  /// had 4pt above and below and looked jammed against the hairline; 60 gives
  /// them 8, on the grid.
  static double get barHeight => AppSize.sH60;

  /// Expanded height. The title and the actions share ONE row: the design has
  /// no separate large-title band, so the header collapses by shrinking its
  /// title in place rather than by sliding a second row out of view.
  static double get largeTitleHeight => AppSize.sH66;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _AppHeaderDelegate(
        title: title,
        onSearch: onSearch,
        onOpenNotifications: onOpenNotifications,
        notificationsBadge: notificationsBadge,
        notificationsActive: notificationsActive,
        background: background,
        bar: barHeight,
        large: largeTitleHeight,
      ),
    );
  }
}

class _AppHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _AppHeaderDelegate({
    required this.title,
    required this.onSearch,
    required this.onOpenNotifications,
    required this.notificationsBadge,
    required this.notificationsActive,
    required this.background,
    required this.bar,
    required this.large,
  });

  final String title;
  final VoidCallback? onSearch;
  final VoidCallback? onOpenNotifications;
  final bool notificationsBadge;
  final bool notificationsActive;
  final Color background;
  final double bar;
  final double large;

  @override
  double get minExtent => bar;

  @override
  double get maxExtent => large;

  /// 0 at rest, 1 once the title has fully shrunk into the bar.
  double _t(double shrinkOffset) =>
      (shrinkOffset / (large - bar)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    final t = _t(shrinkOffset);
    final barColor = Color.lerp(background, AppColors.surface, t)!;
    // The title shrinks in place, 24 → 16, instead of a second row scrolling
    // away: the design puts the title and the actions on one line, so there is
    // no band to lose.
    final titleSize =
        FontSizeManager.s24 + (FontSizeManager.s16 - FontSizeManager.s24) * t;
    // The child MUST fill the extent the delegate was given: a sliver's
    // paintExtent is its child's measured height, so a self-sizing child
    // reports less than maxExtent and trips the geometry assertion.
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: barColor,
          border: Border(
            bottom: BorderSide(
              color: AppColors.borderHeader.withValues(alpha: t),
            ),
          ),
        ),
        child: Row(
          children: [
            // First child is trailing-right in RTL: the title.
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle().setMainTextColor.bold.copyWith(
                  fontSize: titleSize,
                ),
              ),
            ),
            8.szW,
            _HeaderActions(
              onSearch: onSearch,
              onOpenNotifications: onOpenNotifications,
              notificationsBadge: notificationsBadge,
              notificationsActive: notificationsActive,
            ),
          ],
        ).paddingOnlyDirectional(start: AppPadding.pW20, end: AppPadding.pW20),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _AppHeaderDelegate old) =>
      title != old.title ||
      background != old.background ||
      bar != old.bar ||
      large != old.large ||
      notificationsBadge != old.notificationsBadge ||
      notificationsActive != old.notificationsActive ||
      (onSearch == null) != (old.onSearch == null) ||
      (onOpenNotifications == null) != (old.onOpenNotifications == null);
}

/// The bell and the search tile, in that reading order — leading-left in RTL.
class _HeaderActions extends StatelessWidget {
  const _HeaderActions({
    required this.onSearch,
    required this.onOpenNotifications,
    required this.notificationsBadge,
    required this.notificationsActive,
  });

  final VoidCallback? onSearch;
  final VoidCallback? onOpenNotifications;
  final bool notificationsBadge;
  final bool notificationsActive;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onOpenNotifications != null) ...[
          _HeaderAction(
            icon: AppAssets.svg.bell,
            label: notificationsActive
                ? LocaleKeys.a11yBack.tr()
                : LocaleKeys.navNotifications.tr(),
            badge: notificationsBadge && !notificationsActive,
            active: notificationsActive,
            onTap: onOpenNotifications!,
          ),
          8.szW,
        ],
        if (onSearch != null)
          _HeaderAction(
            icon: AppAssets.svg.search,
            label: LocaleKeys.a11ySearch.tr(),
            onTap: onSearch!,
          ),
      ],
    );
  }
}

/// A 44pt white icon tile (hairline border, ink glyph) with an optional red
/// notification dot — the shared header action look, at the tap-target floor.
/// [active] inverts it to ink-on-white → white-on-ink.
class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.icon,
    required this.onTap,
    this.label,
    this.badge = false,
    this.active = false,
  });

  final String icon;
  final VoidCallback onTap;
  final String? label;
  final bool badge;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final Widget tile = AnimatedContainer(
      duration: AppMotion.stamp,
      curve: AppMotion.ease,
      width: AppSize.sW44,
      height: AppSize.sH44,
      decoration: BoxDecoration(
        color: active ? AppColors.inkFill : AppColors.surface,
        borderRadius: BorderRadius.circular(AppCircular.r12),
        border: Border.all(
          color: active ? AppColors.inkFill : AppColors.iconButtonBorder,
        ),
      ),
      child: Center(
        child: IconWidget(
          icon: icon,
          color: active ? AppColors.surface : AppColors.textPrimary,
          height: AppSize.sH20,
          width: AppSize.sW20,
        ),
      ),
    );
    return Semantics(
      button: true,
      label: label,
      selected: active,
      child:
          (badge
                  ? Stack(
                      clipBehavior: Clip.none,
                      children: [
                        tile,
                        Positioned(
                          top: 2.h,
                          right: 2.w,
                          child: Container(
                            width: 8.w,
                            height: 8.h,
                            decoration: BoxDecoration(
                              color: AppColors.brand,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.surface,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : tile)
              .onClick(onTap: onTap),
    );
  }
}

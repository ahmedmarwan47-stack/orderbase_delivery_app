import 'package:flutter/material.dart';

import '../config/res/config_imports.dart';
import 'home_indicator.dart';

enum NavTab { home, orders, notifications, more }

/// Shared bottom tab bar used across screens. The active tab renders in the
/// brand-red accent; the rest are muted. The notifications tab can show a red
/// dot. Includes the home-indicator bar beneath it, as in the mockups.
class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
    required this.active,
    this.notificationsBadge = false,
    this.onTap,
  });

  final NavTab active;
  final bool notificationsBadge;
  final ValueChanged<NavTab>? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.borderHeader)),
            ),
            padding: EdgeInsets.fromLTRB(
              AppPadding.pW16,
              AppPadding.pH12,
              AppPadding.pW16,
              AppPadding.pH8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _item(NavTab.home, AppAssets.svg.home, LocaleKeys.navHome.tr()),
                _item(NavTab.orders, AppAssets.svg.orders,
                    LocaleKeys.navOrders.tr()),
                _item(NavTab.notifications, AppAssets.svg.bell,
                    LocaleKeys.navNotifications.tr(),
                    badge: notificationsBadge),
                _item(NavTab.more, AppAssets.svg.more, LocaleKeys.navMore.tr()),
              ],
            ),
          ),
          const HomeIndicator(),
        ],
      ),
    );
  }

  Widget _item(NavTab tab, String icon, String label, {bool badge = false}) {
    final isActive = tab == active;
    final color = isActive ? AppColors.dangerAccent : AppColors.textSecondary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconWidget(
              icon: icon,
              color: color,
              height: 23.h, // 23px glyph — no matching AppSize token
              width: 23.w,
            ),
            if (badge)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 7.w, // 7px badge dot — no matching AppSize token
                  height: 7.h,
                  decoration: BoxDecoration(
                    color: AppColors.brand,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
        4.szH,
        Text(
          label,
          style: (isActive
                  ? const TextStyle().semiBold
                  : const TextStyle().regular)
              .s12
              .setColor(color),
        ),
      ],
    ).onClick(onTap: onTap == null ? null : () => onTap!(tab));
  }
}

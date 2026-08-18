import 'package:flutter/material.dart';

import '../app/shift_controller.dart';
import '../config/res/config_imports.dart';
import 'home_indicator.dart';

enum NavTab { home, orders, pickup, settlement, more }

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
                _item(NavTab.home, AppAssets.svg.home, LocaleKeys.navHome.tr(),
                    activeIcon: AppAssets.svg.homeFilled),
                _item(NavTab.orders, AppAssets.svg.orders,
                    LocaleKeys.navOrders.tr(),
                    activeIcon: AppAssets.svg.ordersFilled),
                _item(NavTab.pickup, AppAssets.svg.store,
                    LocaleKeys.navPickup.tr(),
                    // Red dot only while there's still a batch to carry from the
                    // branch (cleared once picked up / accepted).
                    badge: !ShiftController.instance.accepted &&
                        ShiftController.instance.inProgress > 0),
                _item(NavTab.settlement, AppAssets.svg.wallet,
                    LocaleKeys.navSettlement.tr()),
                _item(NavTab.more, AppAssets.svg.more, LocaleKeys.navMore.tr(),
                    activeIcon: AppAssets.svg.moreFilled),
              ],
            ),
          ),
          const HomeIndicator(),
        ],
      ),
    );
  }

  Widget _item(NavTab tab, String icon, String label,
      {String? activeIcon, bool badge = false}) {
    final isActive = tab == active;
    final color = isActive ? AppColors.dangerAccent : AppColors.textSecondary;
    // Active tab renders the filled (solid) glyph; inactive keeps the stroke
    // one. Both are still recolored via IconWidget's srcIn filter.
    final displayIcon = isActive ? (activeIcon ?? icon) : icon;
    return MergeSemantics(
      child: Semantics(
        button: true,
        selected: isActive,
        child: _itemBody(tab, displayIcon, label, color, isActive, badge),
      ),
    );
  }

  Widget _itemBody(NavTab tab, String icon, String label, Color color,
      bool isActive, bool badge) {
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

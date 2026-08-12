import 'package:flutter/material.dart';

import '../icons/app_icon.dart';
import '../theme/colors.dart';
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _item(NavTab.home, AppIconName.home, 'الرئيسية'),
                _item(NavTab.orders, AppIconName.orders, 'الطلبات'),
                _item(NavTab.notifications, AppIconName.bell, 'الاشعارات',
                    badge: notificationsBadge),
                _item(NavTab.more, AppIconName.more, 'المزيد'),
              ],
            ),
          ),
          const HomeIndicator(),
        ],
      ),
    );
  }

  Widget _item(NavTab tab, AppIconName icon, String label, {bool badge = false}) {
    final isActive = tab == active;
    final color = isActive ? AppColors.dangerAccent : AppColors.textSecondary;
    return GestureDetector(
      onTap: onTap == null ? null : () => onTap!(tab),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AppIcon(icon, color: color, size: 23),
              if (badge)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: AppColors.brand,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

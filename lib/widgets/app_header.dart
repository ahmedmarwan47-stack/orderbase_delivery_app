import 'package:flutter/material.dart';

import '../app/shift_controller.dart';
import '../config/res/config_imports.dart';
import '../data/order.dart';

/// The unified app header — a solid white bar with a hairline bottom, showing
/// the live shift status (deliveries left + cash to collect) on the trailing
/// side and the search / notifications actions on the leading side.
///
/// Shared by every tab page so the header reads identically across the app;
/// page-specific content (titles, filters, branch identity, …) lives in the
/// page body beneath it. Each action is optional — it only renders when its
/// callback is supplied. Rebuilds with [ShiftController] so the numbers stay
/// current as stops close.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    this.onSearch,
    this.onOpenNotifications,
    this.notificationsBadge = true,
  });

  /// Opens search for this page (inline on Orders, a pushed search elsewhere).
  final VoidCallback? onSearch;

  /// Opens the notifications screen (the bell).
  final VoidCallback? onOpenNotifications;

  /// Shows the red dot on the bell.
  final bool notificationsBadge;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ShiftController.instance,
      builder: (context, _) {
        final shift = ShiftController.instance;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  bottom: BorderSide(color: AppColors.borderHeader),
                ),
              ),
              child:
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LocaleKeys.homeShiftRemaining.tr(
                                namedArgs: {
                                  'count': arabicDigits(shift.inProgress),
                                },
                              ),
                              style: const TextStyle()
                                  .setMainTextColor
                                  .s14
                                  .semiBold,
                            ),
                            4.szH,
                            Text(
                              LocaleKeys.homeShiftToCollect.tr(
                                namedArgs: {
                                  'amount': formatThousands(shift.toCollectEgp),
                                },
                              ),
                              style: const TextStyle()
                                  .setSecondaryColor
                                  .s12
                                  .medium,
                            ),
                          ],
                        ),
                      ),
                      12.szW,
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (onOpenNotifications != null) ...[
                            _HeaderAction(
                              icon: AppAssets.svg.bell,
                              label: LocaleKeys.navNotifications.tr(),
                              badge: notificationsBadge,
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
                      ),
                    ],
                  ).paddingOnly(
                    left: AppPadding.pW20,
                    top: AppPadding.pH12,
                    right: AppPadding.pW20,
                    bottom: AppPadding.pH16,
                  ),
            ),
            // Breathing room between the header bar and the page content.
            SizedBox(height: AppPadding.pH8),
          ],
        );
      },
    );
  }
}

/// A 40pt white icon tile (hairline border, ink glyph) with an optional red
/// notification dot — the shared header action look.
class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.icon,
    required this.onTap,
    this.label,
    this.badge = false,
  });

  final String icon;
  final VoidCallback onTap;
  final String? label;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    final Widget tile = Container(
      width: AppSize.sH40,
      height: AppSize.sH40,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppCircular.r12),
        border: Border.all(color: AppColors.iconButtonBorder),
      ),
      child: Center(
        child: IconWidget(
          icon: icon,
          color: AppColors.textPrimary,
          height: AppSize.sH20,
          width: AppSize.sW20,
        ),
      ),
    );
    return Semantics(
      button: true,
      label: label,
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

part of '../imports/home_imports.dart';

/// Top header — a live shift snapshot (deliveries left + cash to collect) on the
/// right, and the notifications + search actions on the left. Rebuilds with the
/// shift so the numbers stay current as stops close.
class _HomeMerchantHeader extends StatelessWidget {
  const _HomeMerchantHeader({this.onOpenNotifications, this.scrolled = false});

  /// Opens the notifications screen (the bell moved here off the tab bar).
  final VoidCallback? onOpenNotifications;

  /// True once the page has scrolled under the header — the header then fades
  /// in its surface background + hairline (transparent while at the top).
  final bool scrolled;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ShiftController.instance,
      builder: (context, _) {
        final shift = ShiftController.instance;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            // Fade the SAME white in/out (transparent-white, never transparent-
            // black) so the transition never flashes a dark tint.
            color: AppColors.surface.withValues(alpha: scrolled ? 1 : 0),
            border: Border(
              bottom: BorderSide(
                color: AppColors.borderHeader
                    .withValues(alpha: scrolled ? 1 : 0),
              ),
            ),
          ),
          child: Row(
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
                      namedArgs: {'count': arabicDigits(shift.inProgress)},
                    ),
                    style: const TextStyle().setMainTextColor.s16.bold,
                  ),
                  4.szH,
                  Text(
                    LocaleKeys.homeShiftToCollect.tr(
                      namedArgs: {'amount': formatThousands(shift.toCollectEgp)},
                    ),
                    style: const TextStyle().setSecondaryColor.s14.regular,
                  ),
                ],
              ),
            ),
            12.szW,
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  button: true,
                  label: LocaleKeys.navNotifications.tr(),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _HomeSquareIconButton(
                        icon: AppAssets.svg.bell,
                        iconColor: AppColors.textPrimary,
                        size: AppSize.sH40,
                        iconSize: AppSize.sH20,
                        background: AppColors.surface,
                        border: AppColors.iconButtonBorder,
                      ),
                      Positioned(
                        top: 2.h,
                        right: 2.w,
                        child: Container(
                          width: 8.w,
                          height: 8.h,
                          decoration: BoxDecoration(
                            color: AppColors.brand,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: AppColors.surface, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ).onClick(onTap: onOpenNotifications),
                ),
                8.szW,
                Semantics(
                  button: true,
                  label: LocaleKeys.a11ySearch.tr(),
                  child: _HomeSquareIconButton(
                    icon: AppAssets.svg.search,
                    iconColor: AppColors.textPrimary,
                    size: AppSize.sH40,
                    iconSize: AppSize.sH20,
                    background: AppColors.surface,
                    border: AppColors.iconButtonBorder,
                  ).onClick(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            const QueueScreen(startSearching: true),
                      ),
                    ),
                  ),
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
        );
      },
    );
  }
}

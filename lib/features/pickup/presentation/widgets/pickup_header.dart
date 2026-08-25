part of '../imports/pickup_imports.dart';

/// Pickup header: a back button (standalone only), the branch identity (logo +
/// name; the page-name title shows in standalone only), and a banner summarising
/// how many orders are ready to collect in one action. Transparent at the top of
/// the scroll and fades in its surface background + hairline once scrolled.
class _PickupHeader extends StatelessWidget {
  const _PickupHeader({
    required this.count,
    this.showBack = true,
    this.scrolled = false,
  });
  final int count;

  /// Standalone mode: shows the back button + the big page-name title. Hidden
  /// when Pickup is a shell tab (a root tab has nowhere to go back, and the tab
  /// bar already names the page).
  final bool showBack;

  /// True once the page has scrolled under the header — the header then fades
  /// in its surface background + hairline (transparent while at the top).
  final bool scrolled;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        // Fade the SAME white in/out (transparent-white, never transparent-
        // black) so the transition never flashes a dark tint.
        color: AppColors.surface.withValues(alpha: scrolled ? 1 : 0),
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderHeader.withValues(alpha: scrolled ? 1 : 0),
          ),
        ),
      ),
      child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  if (showBack) ...[const HeaderBackButton(), 12.szW],
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppCircular.r12),
                    child: IconWidget(
                      icon: AppAssets.img.saleSucre,
                      height: AppSize.sH40,
                      width: AppSize.sW40,
                    ),
                  ),
                  12.szW,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showBack) ...[
                        Text(
                          LocaleKeys.pickupTitle.tr(),
                          style: const TextStyle().setSecondaryColor.s12.medium,
                        ),
                        4.szH,
                      ],
                      Text(
                        LocaleKeys.pickupMerchant.tr(),
                        style: const TextStyle().setMainTextColor.s14.semiBold,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ).paddingOnlyDirectional(
            start: AppPadding.pW20,
            end: AppPadding.pW20,
            top: AppPadding.pH12,
            bottom: AppPadding.pH16,
          ),
    );
  }
}

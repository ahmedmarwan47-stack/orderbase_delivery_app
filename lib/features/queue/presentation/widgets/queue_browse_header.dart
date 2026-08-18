part of '../imports/queue_imports.dart';

/// Browse header (1b/1d): count subtitle + search button, then the filter chips.
/// The page-name title is dropped here — this is the Orders *tab*, already named
/// by the tab bar. The header is transparent while pinned and fades in its
/// surface background + hairline once the browse list scrolls beneath it.
class _QueueBrowseHeader extends StatelessWidget {
  const _QueueBrowseHeader({required this.vc});
  final QueueViewController vc;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.borderHeader)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Fixed 56pt row (iOS large-title convention): title + search.
          SizedBox(
            height: 56.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    LocaleKeys.queueSubtitle.tr(
                        namedArgs: {'count': arabicDigits(vc.active.length)}),
                    style: const TextStyle().setMainTextColor.s16.extraBold,
                  ),
                ),
                12.szW,
                _SquareIconButton(
                  icon: AppAssets.svg.search,
                  onTap: vc.openSearch,
                  size: AppSize.sH40,
                  label: LocaleKeys.a11ySearch.tr(),
                ),
              ],
            ),
          ).paddingOnlyDirectional(start: AppPadding.pW20, end: AppPadding.pW20),
          12.szH,
          // Chips run edge-to-edge (their own internal padding) so an off-screen
          // chip bleeds past the edge, signalling there's more to scroll.
          _QueueFilterChips(vc: vc),
        ],
      ).paddingOnly(top: AppPadding.pH8, bottom: AppPadding.pH16),
    );
  }
}

/// Reused square icon button (search / back) — white tile + hairline border,
/// matching the home header icons and the shared back tile (one icon-button look).
class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({
    required this.icon,
    required this.onTap,
    required this.size,
    this.label,
  });
  final String icon;
  final VoidCallback onTap;
  final double size;
  final String? label;

  @override
  Widget build(BuildContext context) {
    // Guarantee a >=44pt tap area even when the visual tile is smaller.
    return Semantics(
      button: true,
      label: label,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 44.w, minHeight: 44.h),
        child: Center(
          child: Container(
            width: size,
            height: size,
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
          ),
        ),
      ).onClick(onTap: onTap),
    );
  }
}

part of '../imports/queue_imports.dart';

/// Browse header (1b/1d): title + count + search button, then the filter chips.
class _QueueBrowseHeader extends StatelessWidget {
  const _QueueBrowseHeader({required this.vc});
  final QueueViewController vc;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.borderHeader)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Fixed 56pt title row (iOS large-title convention).
          SizedBox(
            height: 56.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.queueTitle.tr(),
                      style: const TextStyle().setMainTextColor.s16.extraBold,
                    ),
                    4.szH,
                    Text(
                      LocaleKeys.queueSubtitle.tr(
                          namedArgs: {'count': arabicDigits(vc.active.length)}),
                      style: const TextStyle().setSecondaryColor.s14.regular,
                    ),
                  ],
                ),
                _SquareIconButton(
                  icon: AppAssets.svg.search,
                  onTap: vc.openSearch,
                  size: AppSize.sH44,
                  label: LocaleKeys.a11ySearch.tr(),
                ),
              ],
            ),
          ),
          12.szH,
          _QueueFilterChips(vc: vc),
        ],
      ).paddingOnlyDirectional(
        start: AppPadding.pW20,
        end: AppPadding.pW20,
        top: AppPadding.pH8,
        bottom: AppPadding.pH16,
      ),
    );
  }
}

/// Reused square icon button (search / back). Neutral muted tile.
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
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppCircular.r12),
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

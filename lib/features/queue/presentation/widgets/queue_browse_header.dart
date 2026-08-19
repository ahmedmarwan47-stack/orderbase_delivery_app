part of '../imports/queue_imports.dart';

/// Browse sub-head (1b/1d): the "date · N orders" heading, then the filter
/// chips — placed in the page body, directly beneath the unified [AppHeader]
/// (search now lives in that header). Sits on the page ground (no bar/border).
class _QueueBrowseHeader extends StatelessWidget {
  const _QueueBrowseHeader({required this.vc});
  final QueueViewController vc;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          LocaleKeys.queueSubtitle.tr(
            namedArgs: {'count': arabicDigits(vc.active.length)},
          ),
          style: const TextStyle().setMainTextColor.s14.bold,
        ).paddingOnlyDirectional(start: AppPadding.pW20, end: AppPadding.pW20),
        12.szH,
        // Chips run edge-to-edge (their own internal padding) so an off-screen
        // chip bleeds past the edge, signalling there's more to scroll.
        _QueueFilterChips(vc: vc),
      ],
    ).paddingOnly(top: AppPadding.pH16, bottom: AppPadding.pH8);
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

part of '../imports/queue_imports.dart';

/// Browse sub-head (1b/1d): the "date · N orders" heading, and — only on a day
/// that actually went wrong — the exception row. Placed in the page body,
/// directly beneath the unified [AppHeader] (search lives in that header).
/// Sits on the page ground (no bar/border).
///
/// The filter chips that used to sit here are gone: they restated counts the
/// batch headers already carry one row below, and the fourth chip was clipped
/// off the screen edge. Filters themselves live on (Home's KPI cells still
/// drive them, and [_FilterResultsBar] clears them) — only the row went.
class _QueueBrowseHeader extends StatelessWidget {
  const _QueueBrowseHeader({required this.vc});
  final QueueViewController vc;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<QueueFilter>(
      valueListenable: vc.filter,
      // Hidden once the courier is already looking at the exceptions — the
      // filter bar says so, and the row would offer a trip to where they are.
      builder: (_, filter, _) {
        final show = vc.hasExceptions && filter != QueueFilter.exceptions;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              LocaleKeys.queueSubtitle.tr(
                namedArgs: {
                  'count': arabicDigits(vc.active.length),
                  'batches': arabicDigits(vc.batchCount),
                },
              ),
              style: const TextStyle().setMainTextColor.s14.bold,
            ).paddingOnlyDirectional(
              start: AppPadding.pW20,
              end: AppPadding.pW20,
            ),
            if (show) ...[
              12.szH,
              _QueueExceptionsRow(
                returns: vc.returnedCount,
                postponed: vc.postponedCount,
                onView: vc.showExceptions,
              ).paddingOnlyDirectional(
                start: AppPadding.pW20,
                end: AppPadding.pW20,
              ),
            ],
          ],
        ).paddingOnly(top: AppPadding.pH16, bottom: AppPadding.pH8);
      },
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

part of '../imports/queue_imports.dart';

/// The one line above the batch cards that reports what did not go to plan:
/// «٣ مرتجعات · ٢ مؤجلة» with «عرض» at the end. It replaced the filter chip
/// row, which restated counts the batch headers already carry.
///
/// It is not a permanent fixture — a day with nothing wrong never renders it,
/// so the row appearing *is* the signal. Only the non-zero halves are named:
/// «٠ مؤجلة» would be a fact nobody needs.
class _QueueExceptionsRow extends StatelessWidget {
  const _QueueExceptionsRow({
    required this.returns,
    required this.postponed,
    required this.onView,
  });

  final int returns;
  final int postponed;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final counts = [
      if (returns > 0)
        LocaleKeys.queueExceptionsReturns.tr(
          namedArgs: {'count': arabicDigits(returns)},
        ),
      if (postponed > 0)
        LocaleKeys.queueExceptionsPostponed.tr(
          namedArgs: {'count': arabicDigits(postponed)},
        ),
    ].join(' · ');

    return Semantics(
      button: true,
      child: Container(
        // The row is short; the constraint keeps the target ≥44pt.
        constraints: BoxConstraints(minHeight: AppSize.sH44),
        decoration: BoxDecoration(
          color: AppColors.failedBg,
          borderRadius: BorderRadius.circular(AppCircular.r12),
          border: Border.all(color: AppColors.failedBorder),
        ),
        child:
            Row(
              children: [
                IconWidget(
                  icon: AppAssets.svg.alert,
                  color: AppColors.failedText,
                  height: AppSize.sH16,
                  width: AppSize.sW16,
                ),
                8.szW,
                Expanded(
                  child: Text(
                    counts,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle()
                        .setColor(AppColors.failedText)
                        .s12
                        .semiBold
                        .tabular,
                  ),
                ),
                8.szW,
                Text(
                  LocaleKeys.queueExceptionsView.tr(),
                  style: const TextStyle()
                      .setColor(AppColors.failedText)
                      .s12
                      .bold,
                ),
                4.szW,
                IconWidget(
                  icon: AppAssets.svg.chevronLeft,
                  color: AppColors.failedText,
                  height: AppSize.sH14,
                  width: AppSize.sW14,
                ),
              ],
            ).paddingSymmetric(
              horizontal: AppPadding.pW12,
              vertical: AppPadding.pH8,
            ),
      ),
    ).onClick(onTap: onView);
  }
}

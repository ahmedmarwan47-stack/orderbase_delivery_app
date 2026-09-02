part of '../imports/home_imports.dart';

/// The day's four numbers as one strip under the hero: in progress, delivered,
/// failed, cash collected. It replaced a 2×2 grid of tiles so the hero *and*
/// the numbers fit on screen without a scroll — the courier asked for both
/// upfront, with the hero still the biggest thing on the page.
///
/// Each cell taps through to what it summarises (an Orders filter, or the
/// settlement). The cash cell is slate, like every money surface, and turns
/// red when the cash in hand is over the branch's limit — the strip is the
/// only place on Home that alarm shows, because the figure itself going red
/// says it without a banner repeating it.
class _HomeStatRow extends StatelessWidget {
  const _HomeStatRow({this.onOpenOrdersFilter, this.onOpenSettlement});

  final void Function(QueueFilter)? onOpenOrdersFilter;
  final VoidCallback? onOpenSettlement;

  static String _pad(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final shift = ShiftController.instance;
    final over = shift.overCashLimit;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppCircular.r18), // radii exempt
        border: Border.all(color: AppColors.borderCardFaint),
        boxShadow: AppShadows.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: _StatCell(
                value: _pad(shift.inProgress),
                label: LocaleKeys.filterTransit.tr(),
                onTap: () => onOpenOrdersFilter?.call(QueueFilter.transit),
              ),
            ),
            const _CellRule(),
            Expanded(
              flex: 3,
              child: _StatCell(
                value: _pad(shift.deliveredCount),
                label: LocaleKeys.filterDelivered.tr(),
                onTap: () => onOpenOrdersFilter?.call(QueueFilter.delivered),
              ),
            ),
            const _CellRule(),
            Expanded(
              flex: 3,
              child: _StatCell(
                value: _pad(shift.failedCount),
                label: LocaleKeys.homeStatFailedShort.tr(),
                onTap: () => onOpenOrdersFilter?.call(QueueFilter.failed),
              ),
            ),
            Expanded(
              flex: 4,
              child: _StatCell(
                value: formatThousands(shift.collectedEgp),
                suffix: LocaleKeys.homeEgp.tr(),
                label: over
                    ? LocaleKeys.homeStatOverLimit.tr()
                    : LocaleKeys.homeCollectionShort.tr(),
                // Slate for money; the one non-failure red in the app when
                // the courier is carrying more than the branch allows.
                background: over ? AppColors.failedText : AppColors.paymentCardBg,
                valueColor: AppColors.surface,
                labelColor: over
                    ? AppColors.overLimitLabel
                    : AppColors.paymentLabel,
                onTap: onOpenSettlement,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One cell: the number, its unit when it is money, the label under it.
class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.value,
    required this.label,
    this.suffix,
    this.background,
    this.valueColor = AppColors.textPrimary,
    this.labelColor = AppColors.textSecondary,
    this.onTap,
  });

  final String value;
  final String label;
  final String? suffix;
  final Color? background;
  final Color valueColor;
  final Color labelColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: '$value ${suffix ?? ''} $label'.trim(),
      child: AnimatedContainer(
        duration: AppMotion.fill,
        curve: AppMotion.ease,
        color: background,
        padding: EdgeInsets.symmetric(
          horizontal: AppPadding.pW4,
          vertical: AppPadding.pH12,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text.rich(
              TextSpan(
                text: value,
                style: const TextStyle()
                    .setColor(valueColor)
                    .s20
                    .bold
                    .tabular
                    .withHeight(1),
                children: suffix == null
                    ? null
                    : [
                        TextSpan(
                          text: ' $suffix',
                          style: const TextStyle()
                              .setColor(valueColor)
                              .s12
                              .semiBold,
                        ),
                      ],
              ),
              textDirection: TextDirection.ltr,
              maxLines: 1,
            ),
            6.szH,
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle().setColor(labelColor).s12.regular,
            ),
          ],
        ),
      ).onClick(onTap: onTap),
    );
  }
}

/// Hairline between the count cells.
class _CellRule extends StatelessWidget {
  const _CellRule();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.w,
      margin: EdgeInsets.symmetric(vertical: AppMargin.mH12),
      color: AppColors.borderHeader,
    );
  }
}

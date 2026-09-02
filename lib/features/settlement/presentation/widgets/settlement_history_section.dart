part of '../imports/settlement_imports.dart';

/// «الأيام السابقة» — the last seven days as flat rows: the day, what was
/// settled, how many batches and orders, and the settled pill. A row opens
/// the day read-only in the same page shape as today.
class _HistorySection extends StatelessWidget {
  const _HistorySection();

  @override
  Widget build(BuildContext context) {
    final days = sampleSettlementHistory;
    if (days.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          LocaleKeys.settlementHistoryTitle.tr(),
          style: const TextStyle().setMainTextColor.s16.semiBold,
        ),
        4.szH,
        for (final (i, day) in days.indexed)
          _HistoryRow(day: day, daysAgo: i + 1, last: i == days.length - 1),
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.day,
    required this.daysAgo,
    this.last = false,
  });
  final SettlementData day;
  final int daysAgo;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final name = daysAgo == 1
        ? LocaleKeys.settlementYesterday.tr()
        : weekdayArabic(day.date);
    return Semantics(
      button: true,
      child:
          DecoratedBox(
            decoration: BoxDecoration(
              border: last
                  ? null
                  : const Border(
                      bottom: BorderSide(color: AppColors.borderDefault),
                    ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: name,
                              style: const TextStyle()
                                  .setMainTextColor
                                  .s14
                                  .semiBold,
                            ),
                            TextSpan(
                              text: '  ${day.dateLabel}',
                              style: const TextStyle()
                                  .setSecondaryColor
                                  .s12
                                  .regular,
                            ),
                          ],
                        ),
                      ),
                      4.szH,
                      Text(
                        LocaleKeys.settlementHistoryMeta.tr(
                          namedArgs: {
                            'cash': formatThousands(day.cashTotal),
                            'batches': arabicDigits(day.carriedBatchCount),
                            'orders': arabicDigits(day.orderCount),
                          },
                        ),
                        style: const TextStyle()
                            .setSecondaryColor
                            .s12
                            .regular
                            .tabular,
                      ),
                    ],
                  ),
                ),
                8.szW,
                const _StatusPill(status: SettlementStatus.settled),
                8.szW,
                IconWidget(
                  icon: AppAssets.svg.chevronLeft,
                  color: AppColors.textSecondary,
                  height: AppSize.sH16,
                  width: AppSize.sW16,
                ),
              ],
            ).paddingSymmetric(vertical: AppPadding.pH12),
          ).onClick(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => SettlementDayScreen(day: day),
              ),
            ),
          ),
    );
  }
}

/// «حصيلة اليوم» — the day in orders, sitting under the money.
///
/// The cash card answers "how much"; this answers "out of what". Everything
/// dispatched, how much of it was handed over, and how much came back —
/// the three counts a cashier reconciles against the cash before signing it
/// off, and the same three whether the day is live or read back from history.
class _DayTotals extends StatelessWidget {
  const _DayTotals({required this.data});
  final SettlementData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppCircular.r16),
        border: Border.all(color: AppColors.borderCard),
        boxShadow: AppShadows.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _TotalCell(
                value: arabicDigits(data.orderCount),
                label: LocaleKeys.settlementTotalsOrders.tr(),
              ),
            ),
            const _TotalRule(),
            Expanded(
              child: _TotalCell(
                value: arabicDigits(data.deliveredCount),
                label: LocaleKeys.settlementTotalsDelivered.tr(),
              ),
            ),
            const _TotalRule(),
            Expanded(
              child: _TotalCell(
                value: arabicDigits(data.returnCount),
                label: LocaleKeys.settlementTotalsReturns.tr(),
                // Returns are the only one of the three that is a problem,
                // so it is the only one that carries the failure colour.
                valueColor: data.returnCount > 0
                    ? AppColors.failedText
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One count in the day's tally.
class _TotalCell extends StatelessWidget {
  const _TotalCell({
    required this.value,
    required this.label,
    this.valueColor = AppColors.textPrimary,
  });

  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.pW8,
        vertical: AppPadding.pH12,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle()
                .setColor(valueColor)
                .s20
                .bold
                .tabular
                .withHeight(1),
          ),
          6.szH,
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle().setSecondaryColor.s12.regular,
          ),
        ],
      ),
    );
  }
}

/// Hairline between the counts.
class _TotalRule extends StatelessWidget {
  const _TotalRule();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.w,
      margin: EdgeInsets.symmetric(vertical: AppMargin.mH12),
      color: AppColors.borderHeader,
    );
  }
}

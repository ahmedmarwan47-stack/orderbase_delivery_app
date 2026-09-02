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
            child:
                Row(
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

part of '../imports/settlement_imports.dart';

/// The dark "cash in hand" card — the heaviest object on the screen. Muted
/// label over the one big white figure, and (when [showBreakdown]) a 3-column
/// breakdown under a hairline: order value, wallet change, batches.
///
/// A warm near-black gradient per the Figma settlement frame — no icon tile,
/// no suffix games: the figure is the card. Red the moment the cash in hand is
/// over the branch's limit, with the limit spelled out under the figure. On a
/// settled day the label reads «النقدية المُسلّمة» instead.
class _CashInHandCard extends StatelessWidget {
  const _CashInHandCard({required this.data, this.showBreakdown = true});
  final SettlementData data;
  final bool showBreakdown;

  @override
  Widget build(BuildContext context) {
    final over =
        !data.isSettled && data.cashTotal > ShiftController.cashThresholdEgp;
    final labelColor = over ? AppColors.overLimitLabel : AppColors.paymentLabel;
    return AnimatedContainer(
      duration: AppMotion.fill,
      curve: AppMotion.ease,
      decoration: BoxDecoration(
        color: over ? AppColors.failedText : null,
        gradient: over
            ? null
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.cashCardTop, AppColors.cashCardBottom],
              ),
        borderRadius: BorderRadius.circular(AppCircular.r20),
        boxShadow: AppShadows.moneyCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            (data.isSettled
                    ? LocaleKeys.settlementSummaryDelivered
                    : LocaleKeys.settlementCashInHand)
                .tr(),
            style: const TextStyle().setColor(labelColor).s12.medium,
          ),
          8.szH,
          Text(
            '${formatThousands(data.cashTotal)} '
            '${LocaleKeys.settlementCurrency.tr()}',
            // LTR so the digits lead the unit; end-aligned so the figure
            // hangs off the same right edge as its label.
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.end,
            style: const TextStyle().setWhite.s28.bold.tabular,
          ),
          if (over) ...[
            6.szH,
            Text(
              LocaleKeys.settlementOverLimit.tr(
                namedArgs: {
                  'limit': formatThousands(ShiftController.cashThresholdEgp),
                },
              ),
              style: const TextStyle()
                  .setColor(AppColors.overLimitLabel)
                  .s12
                  .semiBold,
            ),
          ],
          if (showBreakdown) ...[
            16.szH,
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.cashCardHairline,
            ),
            12.szH,
            Row(
              children: [
                Expanded(
                  child: _BreakdownCol(
                    label: LocaleKeys.settlementBreakdownOrders.tr(),
                    value: '${formatThousands(data.ordersTotal)} جم',
                    labelColor: labelColor,
                  ),
                ),
                Expanded(
                  child: _BreakdownCol(
                    label: LocaleKeys.settlementBreakdownWallet.tr(),
                    value: '${formatThousands(data.walletTotal)} جم',
                    labelColor: labelColor,
                  ),
                ),
                Expanded(
                  child: _BreakdownCol(
                    label: LocaleKeys.settlementBreakdownBatches.tr(),
                    value: arabicDigits(data.carriedBatchCount),
                    labelColor: labelColor,
                  ),
                ),
              ],
            ),
          ],
        ],
      ).paddingAll(AppPadding.pH24),
    );
  }
}

/// One column of the dark card's breakdown row — muted label over a value.
class _BreakdownCol extends StatelessWidget {
  const _BreakdownCol({
    required this.label,
    required this.value,
    this.labelColor = AppColors.paymentLabel,
  });
  final String label;
  final String value;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle().setColor(labelColor).s12.regular),
        4.szH,
        Text(
          value,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.start,
          style: const TextStyle().setColor(AppColors.surface).s14.bold.tabular,
        ),
      ],
    );
  }
}

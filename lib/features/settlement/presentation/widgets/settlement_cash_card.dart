part of '../imports/settlement_imports.dart';

/// The dark "cash in hand" card — the heaviest object on the screen. Muted
/// label, a big extra-bold total with a lighter "جم" suffix, a translucent-white
/// icon tile holding a cash-bright glyph, and (when [showBreakdown]) a
/// 3-column breakdown under a hairline: order value, wallet change, batches.
///
/// Slate, like every money surface — and red the moment the cash in hand is
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
        color: over ? AppColors.failedText : AppColors.paymentCardBg,
        borderRadius: BorderRadius.circular(AppCircular.r20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (data.isSettled
                              ? LocaleKeys.settlementSummaryDelivered
                              : LocaleKeys.settlementCashInHand)
                          .tr(),
                      style: const TextStyle()
                          .setColor(labelColor)
                          .s14
                          .regular,
                    ),
                    8.szH,
                    Row(
                      textBaseline: TextBaseline.alphabetic,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          formatThousands(data.cashTotal),
                          textDirection: TextDirection.ltr,
                          style: const TextStyle().setWhite.s24.bold.tabular,
                        ),
                        6.szW,
                        Text(
                          LocaleKeys.settlementCurrency.tr(),
                          style: const TextStyle()
                              .setColor(
                                over
                                    ? AppColors.overLimitLabel
                                    : AppColors.paymentSuffix,
                              )
                              .s16
                              .semiBold,
                        ),
                      ],
                    ),
                    if (over) ...[
                      6.szH,
                      Text(
                        LocaleKeys.settlementOverLimit.tr(
                          namedArgs: {
                            'limit': formatThousands(
                              ShiftController.cashThresholdEgp,
                            ),
                          },
                        ),
                        style: const TextStyle()
                            .setColor(AppColors.overLimitLabel)
                            .s12
                            .semiBold,
                      ),
                    ],
                  ],
                ),
              ),
              12.szW,
              Container(
                width: AppSize.sW48,
                height: AppSize.sH48,
                decoration: BoxDecoration(
                  color: AppColors.paymentTile,
                  borderRadius: BorderRadius.circular(AppCircular.r16),
                ),
                child: Center(
                  child: IconWidget(
                    icon: over ? AppAssets.svg.alert : AppAssets.svg.cash,
                    color: AppColors.cashBright,
                    height: AppSize.sH24,
                    width: AppSize.sW24,
                  ),
                ),
              ),
            ],
          ),
          if (showBreakdown) ...[
            16.szH,
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.darkCardHairline,
            ),
            16.szH,
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
                    valueColor: over
                        ? AppColors.surface
                        : AppColors.walletAmberOnDark,
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
      ).paddingSymmetric(
        horizontal: AppPadding.pW20,
        vertical: AppPadding.pH20,
      ),
    );
  }
}

/// One column of the dark card's breakdown row — muted label over a value.
class _BreakdownCol extends StatelessWidget {
  const _BreakdownCol({
    required this.label,
    required this.value,
    this.valueColor,
    this.labelColor = AppColors.paymentLabel,
  });
  final String label;
  final String value;
  final Color? valueColor;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle().setColor(labelColor).s12.regular),
        6.szH,
        Text(
          value,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.start,
          style: const TextStyle()
              .setColor(valueColor ?? AppColors.surface)
              .s16
              .bold
              .tabular,
        ),
      ],
    );
  }
}

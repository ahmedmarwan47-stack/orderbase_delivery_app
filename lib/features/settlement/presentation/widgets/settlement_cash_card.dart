part of '../imports/settlement_imports.dart';

/// The dark "cash in hand" card — the heaviest object on the screen. Muted
/// label, a big extra-bold total with a lighter "جم" suffix, a translucent-white
/// icon tile holding a cash-bright glyph, and (when [SettlementController.showBreakdown]
/// is true) a 3-column breakdown under a hairline.
class _CashInHandCard extends StatelessWidget {
  const _CashInHandCard({required this.vc});
  final SettlementController vc;

  @override
  Widget build(BuildContext context) {
    final data = vc.data;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.paymentCardBg,
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
                      LocaleKeys.settlementCashInHand.tr(),
                      style: const TextStyle()
                          .setColor(AppColors.paymentLabel)
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
                          style: const TextStyle()
                              .setWhite
                              .s24 // was s28 — big-font trim sweep
                              .bold
                              .tabular,
                        ),
                        6.szW,
                        Text(
                          LocaleKeys.settlementCurrency.tr(),
                          style: const TextStyle()
                              .setColor(AppColors.paymentSuffix)
                              .s16
                              .semiBold,
                        ),
                      ],
                    ),
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
                    icon: AppAssets.svg.cash,
                    color: AppColors.cashBright,
                    height: AppSize.sH24,
                    width: AppSize.sW24,
                  ),
                ),
              ),
            ],
          ),
          ValueListenableBuilder<bool>(
            valueListenable: vc.showBreakdown,
            builder: (_, show, _) {
              if (!show) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  16.szH,
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.darkCardHairline,
                  ),
                  16.szH,
                  Row(
                    // Bottom-align so the values line up even when one label
                    // («عدد الطلبات النقدية») wraps to two lines.
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: _BreakdownCol(
                          label: LocaleKeys.settlementBreakdownOrders.tr(),
                          value: '${formatThousands(data.ordersTotal)} جم',
                        ),
                      ),
                      Expanded(
                        child: _BreakdownCol(
                          label: LocaleKeys.settlementBreakdownWallet.tr(),
                          value: '${formatThousands(data.walletTotal)} جم',
                          valueColor: AppColors.walletAmberOnDark,
                        ),
                      ),
                      Expanded(
                        child: _BreakdownCol(
                          label: LocaleKeys.settlementBreakdownCount.tr(),
                          value: formatThousands(data.rowCount),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
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
  });
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle().setColor(AppColors.paymentLabel).s12.regular,
        ),
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

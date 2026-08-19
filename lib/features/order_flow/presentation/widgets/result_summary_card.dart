part of '../imports/order_flow_imports.dart';

/// The outcome summary card — order number, customer, and a variant-specific
/// final row (collected cash + wallet change / reason / new time).
class _ResultSummaryCard extends StatelessWidget {
  const _ResultSummaryCard({
    required this.kind,
    required this.orderNum,
    required this.customer,
    required this.codAmount,
    required this.showWalletChange,
    required this.walletChange,
    required this.reasonLabel,
    required this.postponeDisplay,
  });

  final ResultKind kind;
  final String orderNum;
  final String customer;
  final String codAmount;
  final bool showWalletChange;
  final String walletChange;
  final String reasonLabel;
  final String postponeDisplay;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppCircular.r16),
        border: Border.all(color: AppColors.borderHeader),
      ),
      child: Column(
        children: [
          _ResultRow(
            label: LocaleKeys.resultOrderNumLabel.tr(),
            value: orderNum,
            valueLtr: true,
            valueWeight: FontWeightManager.bold,
          ),
          12.szH,
          _ResultRow(
            label: LocaleKeys.resultCustomerLabel.tr(),
            value: customer,
            valueLtr: true,
          ),
          ..._variantRows(),
        ],
      ).paddingAll(AppPadding.pH16),
    );
  }

  List<Widget> _variantRows() {
    switch (kind) {
      case ResultKind.delivered:
        return [
          _ResultRow(
            topDivider: true,
            label: LocaleKeys.resultCollectedLabel.tr(),
            value: codAmount,
            valueColor: AppColors.deliveredText,
            valueBig: true,
            valueWeight: FontWeightManager.bold,
            tabular: true,
          ),
          if (showWalletChange) ...[
            12.szH,
            _ResultRow(
              label: LocaleKeys.resultWalletLabel.tr(),
              value: walletChange,
              valueColor: AppColors.postponedText,
              tabular: true,
            ),
          ],
        ];
      case ResultKind.failed:
        return [
          _ResultRow(
            topDivider: true,
            label: LocaleKeys.resultReasonLabel.tr(),
            value: reasonLabel,
            valueColor: AppColors.dangerAccent,
          ),
        ];
      case ResultKind.postponed:
        return [
          _ResultRow(
            topDivider: true,
            label: LocaleKeys.resultNewTimeLabel.tr(),
            value: postponeDisplay,
            valueColor: AppColors.postponedText,
          ),
        ];
    }
  }
}

/// A single label/value row inside the summary card. [topDivider] adds the
/// hairline + spacing that separates the variant row from the rows above.
class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.label,
    required this.value,
    this.valueColor = AppColors.textPrimary,
    this.valueBig = false,
    this.valueWeight = FontWeightManager.semiBold,
    this.valueLtr = false,
    this.tabular = false,
    this.topDivider = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool valueBig;
  final FontWeight valueWeight;
  final bool valueLtr;
  final bool tabular;
  final bool topDivider;

  @override
  Widget build(BuildContext context) {
    var valueStyle = const TextStyle().setColor(valueColor).copyWith(
          fontSize: valueBig ? FontSizeManager.s16 : FontSizeManager.s14,
          fontWeight: valueWeight,
        );
    if (tabular) valueStyle = valueStyle.tabular;

    final row = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle().setSecondaryColor.s14.regular),
        Text(
          value,
          textDirection: valueLtr ? TextDirection.ltr : null,
          style: valueStyle,
        ),
      ],
    );

    if (!topDivider) return row;

    return Container(
      margin: EdgeInsets.only(top: AppMargin.mH12),
      padding: EdgeInsets.only(top: AppPadding.pH12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.summaryDivider)),
      ),
      child: row,
    );
  }
}

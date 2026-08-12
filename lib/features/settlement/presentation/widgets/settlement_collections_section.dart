part of '../imports/settlement_imports.dart';

/// "تحصيلات اليوم" — the section header plus the white card listing each cash
/// order (number + name, collected amount, order value, and a wallet-change pill
/// when the courier collected more than the order value).
class _CollectionsSection extends StatelessWidget {
  const _CollectionsSection({required this.data});
  final SettlementData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              LocaleKeys.settlementCollectionsTitle.tr(),
              style: const TextStyle().setMainTextColor.s16.bold,
            ),
            Text(
              LocaleKeys.settlementCollectionsHint.tr(),
              style: const TextStyle().setHintColor.s12.regular,
            ),
          ],
        ),
        12.szH,
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppCircular.r16),
            border: Border.all(color: AppColors.borderCard),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < data.lines.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.surfaceSubtle,
                  ),
                _CollectionRow(line: data.lines[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// One order line inside the collections card.
class _CollectionRow extends StatelessWidget {
  const _CollectionRow({required this.line});
  final SettlementLine line;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    line.num,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle().setMainTextColor.s14.extraBold,
                  ),
                  8.szW,
                  Flexible(
                    child: Text(
                      line.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle().setMainTextColor.s14.semiBold,
                    ),
                  ),
                ],
              ),
            ),
            12.szW,
            Row(
              textBaseline: TextBaseline.alphabetic,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatThousands(line.paid),
                  textDirection: TextDirection.ltr,
                  style:
                      const TextStyle().setMainTextColor.s16.extraBold.tabular,
                ),
                4.szW,
                Text(
                  LocaleKeys.settlementCurrency.tr(),
                  style: const TextStyle().setSecondaryColor.s12.bold,
                ),
              ],
            ),
          ],
        ),
        8.szH,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              LocaleKeys.settlementOrderValue
                  .tr(namedArgs: {'value': formatThousands(line.order)}),
              style: const TextStyle().setHintColor.s12.regular,
            ),
            if (line.hasWallet) _WalletPill(amount: line.wallet),
          ],
        ),
      ],
    ).paddingAll(AppPadding.pW16);
  }
}

/// Small amber pill: "فكة {change} جم" with a wallet glyph — shown on a line
/// whose collected cash exceeded the order value.
class _WalletPill extends StatelessWidget {
  const _WalletPill({required this.amount});
  final int amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.postponedBg,
        borderRadius: BorderRadius.circular(AppCircular.r8),
        border: Border.all(color: AppColors.postponedBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconWidget(
            icon: AppAssets.svg.wallet,
            color: AppColors.postponedText,
            height: AppSize.sH14,
            width: AppSize.sW14,
          ),
          6.szW,
          Text(
            LocaleKeys.settlementWalletChange
                .tr(namedArgs: {'amount': formatThousands(amount)}),
            style: const TextStyle().setColor(AppColors.postponedText).s12.bold,
          ),
        ],
      ).paddingSymmetric(horizontal: AppPadding.pW8, vertical: AppPadding.pH4),
    );
  }
}

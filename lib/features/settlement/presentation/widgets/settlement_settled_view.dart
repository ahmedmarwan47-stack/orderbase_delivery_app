part of '../imports/settlement_imports.dart';

/// State B — SETTLED ("تمت التسوية"): a full white confirmation screen. Green
/// badge, headline, a plain-language summary, the delivered/wallet summary card,
/// the now-zero balance card, and an ink "back home" button that reopens (reset).
class _SettlementSettledView extends StatelessWidget {
  const _SettlementSettledView({required this.vc});
  final SettlementController vc;

  @override
  Widget build(BuildContext context) {
    final data = vc.data;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppPadding.pW20,
                  vertical: AppPadding.pH24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    32.szH,
                    const _SettledBadge(),
                    20.szH,
                    Text(
                      LocaleKeys.settlementSettledTitle.tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle().setMainTextColor.s24.extraBold,
                    ),
                    12.szH,
                    Text(
                      LocaleKeys.settlementSettledBody.tr(namedArgs: {
                        'cash': formatThousands(data.cashTotal),
                        'count': formatThousands(data.rowCount),
                      }),
                      textAlign: TextAlign.center,
                      style: const TextStyle()
                          .setSecondaryColor
                          .s14
                          .regular
                          .withHeight(1.6),
                    ),
                    24.szH,
                    _SummaryCard(data: data),
                    12.szH,
                    const _BalanceCard(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppPadding.pW20,
                vertical: AppPadding.pH12,
              ),
              child: _BackHomeButton(onTap: vc.reset),
            ),
            const HomeIndicator(),
          ],
        ),
      ),
    );
  }
}

/// 96px green circle with a large green check.
class _SettledBadge extends StatelessWidget {
  const _SettledBadge();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 96.w, // 96px success badge — no matching AppSize token
        height: AppSize.sH96,
        decoration: const BoxDecoration(
          color: AppColors.deliveredBg,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: IconWidget(
            icon: AppAssets.svg.check,
            color: AppColors.greenAccent,
            height: AppSize.sH52,
            width: 52.w, // 52px check glyph — no matching AppSize token
          ),
        ),
      ),
    );
  }
}

/// The delivered-cash / wallet-change summary, plus cashier and time.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.data});
  final SettlementData data;

  // Amber text for the wallet figure on a light surface (standard amber token).
  static const _walletAmber = AppColors.postponedText;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppCircular.r16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SummaryRow(
            label: LocaleKeys.settlementSummaryDelivered.tr(),
            value: '${formatThousands(data.cashTotal)} جم',
            valueColor: AppColors.deliveredText,
          ),
          12.szH,
          _SummaryRow(
            label: LocaleKeys.settlementSummaryWallet.tr(),
            value: '${formatThousands(data.walletTotal)} جم',
            valueColor: _walletAmber,
          ),
          16.szH,
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.summaryDivider,
          ),
          16.szH,
          _SummaryRow(
            icon: AppAssets.svg.user,
            label: LocaleKeys.settlementSummaryCashier.tr(),
            value: data.cashierName,
          ),
          12.szH,
          _SummaryRow(
            icon: AppAssets.svg.clock,
            label: LocaleKeys.settlementSummaryTime.tr(),
            value: LocaleKeys.settlementSummaryTimeValue.tr(),
          ),
        ],
      ).paddingAll(AppPadding.pW16),
    );
  }
}

/// One "label … value" row in the summary card, with an optional leading icon.
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
  });
  final String label;
  final String value;
  final String? icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              IconWidget(
                icon: icon!,
                color: AppColors.textSecondary,
                height: AppSize.sH16,
                width: AppSize.sW16,
              ),
              8.szW,
            ],
            Text(
              label,
              style: const TextStyle().setSecondaryColor.s14.regular,
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle()
              .setColor(valueColor ?? AppColors.textPrimary)
              .s14
              .bold,
        ),
      ],
    );
  }
}

/// The now-zero collection balance card, badged "closed".
class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppCircular.r16),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.settlementBalanceLabel.tr(),
                style: const TextStyle().setSecondaryColor.s12.regular,
              ),
              4.szH,
              Row(
                textBaseline: TextBaseline.alphabetic,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '0',
                    textDirection: TextDirection.ltr,
                    style:
                        const TextStyle().setMainTextColor.s24.extraBold.tabular,
                  ),
                  6.szW,
                  Text(
                    LocaleKeys.settlementCurrency.tr(),
                    style: const TextStyle().setSecondaryColor.s14.bold,
                  ),
                ],
              ),
            ],
          ),
          const _ClosedPill(),
        ],
      ).paddingAll(AppPadding.pW16),
    );
  }
}

/// Green "مُغلقة" (closed) pill.
class _ClosedPill extends StatelessWidget {
  const _ClosedPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.deliveredBg,
        borderRadius: BorderRadius.circular(AppCircular.r8),
        border: Border.all(color: AppColors.deliveredBorder),
      ),
      child: Text(
        LocaleKeys.settlementClosed.tr(),
        style: const TextStyle().setColor(AppColors.deliveredText).s12.bold,
      ).paddingSymmetric(horizontal: AppPadding.pW8, vertical: AppPadding.pH4),
    );
  }
}

/// Ink "back to home" button — reopens the settlement (SETTLED reset → OPEN).
class _BackHomeButton extends StatelessWidget {
  const _BackHomeButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: Container(
        height: AppSize.sH56,
        decoration: BoxDecoration(
          color: AppColors.inkFill,
          borderRadius: BorderRadius.circular(AppCircular.r16),
        ),
        alignment: Alignment.center,
        child: Text(
          LocaleKeys.settlementBackHome.tr(),
          style: const TextStyle().setWhite.s16.bold,
        ),
      ).onClick(onTap: onTap),
    );
  }
}

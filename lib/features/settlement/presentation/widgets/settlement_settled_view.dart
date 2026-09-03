part of '../imports/settlement_imports.dart';

/// State B — SETTLED ("تمت التسوية"): the branch has taken the cash. A slate
/// badge, headline, a plain-language summary, the delivered/wallet summary
/// card with cashier and time, the now-zero balance card, the day's batches
/// for the record, and the week before it. The ink button goes home — there
/// is nothing to reset, since the branch did the settling.
class _SettlementSettledView extends StatelessWidget {
  const _SettlementSettledView({
    required this.vc,
    required this.data,
    this.onSelectTab,
    this.onOpenNotifications,
    this.onOpenSearch,
  });
  final SettlementController vc;
  final SettlementData data;
  final ValueChanged<NavTab>? onSelectTab;
  final VoidCallback? onOpenNotifications;
  final VoidCallback? onOpenSearch;

  @override
  Widget build(BuildContext context) {
    final onSelectTab = this.onSelectTab;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: onSelectTab == null,
        child: Column(
          children: [
            if (onSelectTab != null)
              AppHeader(
                onSearch: onOpenSearch,
                onOpenNotifications: onOpenNotifications,
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppPadding.pW20,
                  vertical: AppPadding.pH24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    16.szH,
                    const _SettledBadge(),
                    20.szH,
                    Text(
                      LocaleKeys.settlementSettledTitle.tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle().setMainTextColor.s20.bold,
                    ),
                    12.szH,
                    Text(
                      LocaleKeys.settlementSettledBody.tr(
                        namedArgs: {
                          'cash': formatThousands(data.cashTotal),
                          'count': arabicDigits(data.rowCount),
                        },
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle().setSecondaryColor.s14.regular
                          .withHeight(1.5),
                    ),
                    24.szH,
                    _SummaryCard(data: data),
                    12.szH,
                    _DayTotals(data: data),
                    12.szH,
                    const _BalanceCard(),
                    24.szH,
                    _BatchesSection(data: data),
                    24.szH,
                    const _HistorySection(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppPadding.pW20,
                vertical: AppPadding.pH12,
              ),
              child: _BackHomeButton(
                onTap: onSelectTab == null
                    ? vc.reset
                    : () => onSelectTab(NavTab.home),
              ),
            ),
            if (onSelectTab != null)
              BottomNav(active: NavTab.settlement, onTap: onSelectTab)
            else
              const HomeIndicator(),
          ],
        ),
      ),
    );
  }
}

/// 96px slate circle with a large white check. Deliberately slate (settlement's
/// own "cash" hue, matching the open-state cash card) — NOT green, so the
/// end-of-day "settled" screen never competes with the delivered-success state.
class _SettledBadge extends StatelessWidget {
  const _SettledBadge();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 96.w, // 96px success badge — no matching AppSize token
        height: AppSize.sH96,
        decoration: const BoxDecoration(
          color: AppColors.paymentCardBg,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: IconWidget(
            icon: AppAssets.svg.check,
            color: AppColors.surface,
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
    final at = data.settledAt;
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
            valueColor: AppColors.textPrimary,
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
            value: at == null
                ? LocaleKeys.settlementSummaryTimeValue.tr()
                : formatClockArabic(at),
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
            Text(label, style: const TextStyle().setSecondaryColor.s14.regular),
          ],
        ),
        Text(
          value,
          style: const TextStyle()
              .setColor(valueColor ?? AppColors.textPrimary)
              .s14
              .semiBold,
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
                    style: const TextStyle().setMainTextColor.s20.bold.tabular,
                  ),
                  6.szW,
                  Text(
                    LocaleKeys.settlementCurrency.tr(),
                    style: const TextStyle().setSecondaryColor.s14.semiBold,
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

/// Neutral «مُغلقة» (closed) pill on the balance card — grey, not green, so it
/// doesn't echo the delivered-success status.
class _ClosedPill extends StatelessWidget {
  const _ClosedPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppCircular.r8),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Text(
        LocaleKeys.settlementClosed.tr(),
        style: const TextStyle().setColor(AppColors.textSecondary).s12.semiBold,
      ).paddingSymmetric(horizontal: AppPadding.pW8, vertical: AppPadding.pH4),
    );
  }
}

/// Ink "back to home" button.
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
          style: const TextStyle().setWhite.s14.semiBold,
        ),
      ).onClick(onTap: onTap),
    );
  }
}

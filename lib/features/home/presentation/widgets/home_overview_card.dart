part of '../imports/home_imports.dart';

/// Boxed "today's overview" card (2a) — a tappable summary (→ Orders) with a
/// collection banner and a three-up mini stat row.
class _HomeOverviewCard extends StatelessWidget {
  const _HomeOverviewCard({this.onTap});

  final VoidCallback? onTap;

  // 0 4px 16px -10px rgba(0,0,0,.18)
  static const _cardShadow = [
    BoxShadow(
      color: AppColors.softDropShadow,
      offset: Offset(0, 4),
      blurRadius: 16,
      spreadRadius: -10,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppCircular.r20),
        border: Border.all(color: AppColors.flatDivider),
        boxShadow: _cardShadow,
      ),
      padding: EdgeInsets.all(AppPadding.pW12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LocaleKeys.homeTodayOverview.tr(),
                style: const TextStyle().setColor(AppColors.flatMuted).s14.bold,
              ),
              IconWidget(
                icon: AppAssets.svg.chevronLeft,
                color: AppColors.flatMutedDot,
                height: AppSize.sH18,
                width: AppSize.sW18,
              ),
            ],
          ).paddingSymmetric(horizontal: AppPadding.pW4),
          16.szH,
          _banner(),
          16.szH,
          _statsRow(),
        ],
      ),
    ).onClick(onTap: onTap);
  }

  Widget _banner() => Container(
        decoration: BoxDecoration(
          color: AppColors.flatBannerBg,
          borderRadius: BorderRadius.circular(AppCircular.r16),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppPadding.pW20,
          vertical: AppPadding.pH16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.homeTotalCollectedToday.tr(),
                  style: const TextStyle().setColor(AppColors.flatBlack).s12.regular,
                ),
                4.szH,
                Text.rich(
                  TextSpan(
                    text: '22,500',
                    style: const TextStyle()
                        .setColor(AppColors.flatBlack)
                        .s20 // was s24 — big-font trim sweep
                        .extraBold
                        .tabular
                        .withHeight(1),
                    children: [
                      TextSpan(
                        text: ' ${LocaleKeys.homeEgp.tr()}',
                        style: const TextStyle()
                            .setColor(AppColors.paymentSuffix)
                            .s14
                            .bold,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              width: AppSize.sW48,
              height: AppSize.sH48,
              decoration: const BoxDecoration(
                color: AppColors.paymentTile,
                shape: BoxShape.circle,
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
      );

  Widget _statsRow() => Row(
        children: [
          Expanded(
            child: _stat('10', LocaleKeys.homeStatInProgress.tr(),
                AppColors.textPrimary),
          ),
          Expanded(
            child: _stat('05', LocaleKeys.homeStatDelivered.tr(),
                AppColors.greenAccent),
          ),
          Expanded(
            child: _stat(
                '02', LocaleKeys.homeStatFailed.tr(), AppColors.brand),
          ),
        ],
      ).paddingOnly(
        left: AppPadding.pW8,
        top: AppPadding.pH8,
        right: AppPadding.pW8,
      );

  Widget _stat(String value, String label, Color valueColor) => Column(
        children: [
          Text(
            value,
            style: const TextStyle()
                .setColor(valueColor)
                .s20
                .extraBold
                .tabular
                .withHeight(1),
          ),
          4.szH,
          Text(label, style: const TextStyle().setSecondaryColor.s12.regular),
        ],
      );
}

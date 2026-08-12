part of '../imports/home_imports.dart';

/// "Today's overview" — a 2×2 grid of stat cards.
class _HomeTodayStats extends StatelessWidget {
  const _HomeTodayStats();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.homeTodayOverview.tr(),
          style: const TextStyle().setTertiaryColor.s14.bold,
        ),
        12.szH,
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSize.sW12,
            children: [
              Expanded(
                child: _HomeStatCard(
                  icon: AppAssets.svg.bike,
                  iconColor: AppColors.textPrimary,
                  tile: AppColors.iconTileNeutral,
                  value: '10',
                  labelKey: LocaleKeys.homeStatInProgress,
                ),
              ),
              Expanded(
                child: _HomeStatCard(
                  icon: AppAssets.svg.check,
                  iconColor: AppColors.greenAccent,
                  tile: AppColors.deliveredBg,
                  value: '05',
                  labelKey: LocaleKeys.homeStatDelivered,
                ),
              ),
            ],
          ),
        ),
        12.szH,
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSize.sW12,
            children: [
              Expanded(
                child: _HomeStatCard(
                  icon: AppAssets.svg.fail,
                  iconColor: AppColors.brand,
                  tile: AppColors.failedBg,
                  value: '02',
                  labelKey: LocaleKeys.homeStatFailed,
                ),
              ),
              Expanded(
                child: _HomeStatCard(
                  icon: AppAssets.svg.cash,
                  iconColor: AppColors.greenAccent,
                  tile: AppColors.deliveredBg,
                  value: '22,500',
                  suffixKey: LocaleKeys.homeEgp,
                  valueColor: AppColors.greenAccent,
                  valueSize: FontSizeManager.s24,
                  labelKey: LocaleKeys.homeStatTotalCollected,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

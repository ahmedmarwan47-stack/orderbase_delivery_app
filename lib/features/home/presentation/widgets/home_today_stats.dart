part of '../imports/home_imports.dart';

/// "Today's overview" — a 2×2 grid of KPI tiles, each reading a live shift
/// counter and linking to the page it summarises (Orders slice / settlement).
class _HomeTodayStats extends StatelessWidget {
  const _HomeTodayStats({this.onOpenOrdersFilter, this.onOpenSettlement});

  final void Function(QueueFilter)? onOpenOrdersFilter;
  final VoidCallback? onOpenSettlement;

  static String _pad(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final shift = ShiftController.instance;
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
                  value: _pad(shift.inProgress),
                  labelKey: LocaleKeys.homeStatInProgress,
                  onTap: () => onOpenOrdersFilter?.call(QueueFilter.transit),
                ),
              ),
              Expanded(
                child: _HomeStatCard(
                  icon: AppAssets.svg.check,
                  iconColor: AppColors.greenAccent,
                  tile: AppColors.deliveredBg,
                  value: _pad(shift.deliveredCount),
                  labelKey: LocaleKeys.homeStatDelivered,
                  onTap: () => onOpenOrdersFilter?.call(QueueFilter.delivered),
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
                  value: _pad(shift.failedCount),
                  labelKey: LocaleKeys.homeStatFailed,
                  onTap: () => onOpenOrdersFilter?.call(QueueFilter.failed),
                ),
              ),
              Expanded(
                child: _HomeStatCard(
                  icon: AppAssets.svg.cash,
                  iconColor: AppColors.greenAccent,
                  tile: AppColors.deliveredBg,
                  value: formatThousands(shift.collectedEgp),
                  suffixKey: LocaleKeys.homeEgp,
                  valueColor: AppColors.greenAccent,
                  valueSize: FontSizeManager.s20,
                  labelKey: LocaleKeys.homeStatTotalCollected,
                  onTap: onOpenSettlement,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

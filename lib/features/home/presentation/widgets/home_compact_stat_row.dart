part of '../imports/home_imports.dart';

/// Compact stat row (1c) — three small white tiles plus a wide dark collection
/// tile, all in a single row.
class _HomeCompactStatRow extends StatelessWidget {
  const _HomeCompactStatRow();

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSize.sW8,
        children: [
          Expanded(
            child: _tile(
              icon: AppAssets.svg.bike,
              iconColor: AppColors.textPrimary,
              value: '10',
              valueColor: AppColors.textPrimary,
              label: LocaleKeys.homeStatInProgress.tr(),
            ),
          ),
          Expanded(
            child: _tile(
              icon: AppAssets.svg.check,
              iconColor: AppColors.greenAccent,
              value: '05',
              valueColor: AppColors.greenAccent,
              label: LocaleKeys.homeStatDelivered.tr(),
            ),
          ),
          Expanded(
            child: _tile(
              icon: AppAssets.svg.fail,
              iconColor: AppColors.brand,
              value: '02',
              valueColor: AppColors.brand,
              label: LocaleKeys.homeStatFailedShort.tr(),
            ),
          ),
          Expanded(flex: 3, child: _darkTile()),
        ],
      ),
    );
  }

  Widget _tile({
    required String icon,
    required Color iconColor,
    required String value,
    required Color valueColor,
    required String label,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppCircular.r14),
        border: Border.all(color: AppColors.borderCardFaint),
        boxShadow: AppShadows.card,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.pW8,
        vertical: AppPadding.pH12,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconWidget(
            icon: icon,
            color: iconColor,
            height: 17.h, // mockup glyph 17px
            width: 17.w,
          ),
          4.szH,
          Text(
            value,
            style: const TextStyle()
                .setColor(valueColor)
                .s18
                .bold
                .tabular
                .withHeight(1),
          ),
          4.szH,
          Text(label, style: const TextStyle().setSecondaryColor.s12.regular),
        ],
      ),
    );
  }

  Widget _darkTile() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inkFill,
        borderRadius: BorderRadius.circular(AppCircular.r14),
      ),
      padding: EdgeInsets.all(AppPadding.pW12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            LocaleKeys.homeCollectionShort.tr(),
            style: const TextStyle()
                .setColor(AppColors.darkTileLabel)
                .regular
                .copyWith(fontSize: 8.sp), // 8px, no token
          ),
          4.szH,
          Text(
            '22,500',
            style: const TextStyle()
                .setColor(AppColors.cashBright)
                .s18
                .bold
                .tabular
                .withHeight(1),
          ),
          4.szH,
          Text(
            LocaleKeys.homeEgp.tr(),
            style: const TextStyle()
                .setColor(AppColors.cashSuffixGreen)
                .s12
                .semiBold,
          ),
        ],
      ),
    );
  }
}

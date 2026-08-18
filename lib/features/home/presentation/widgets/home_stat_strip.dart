part of '../imports/home_imports.dart';

/// White three-cell stat strip with big glance numbers (Glance / 1b).
class _HomeStatStrip extends StatelessWidget {
  const _HomeStatStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppCircular.r20),
        border: Border.all(color: AppColors.borderCardFaint),
        boxShadow: AppShadows.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _cell(
                icon: AppAssets.svg.bike,
                iconColor: AppColors.textPrimary,
                value: '10',
                valueColor: AppColors.textPrimary,
                label: LocaleKeys.homeStatInProgress.tr(),
              ),
            ),
            _divider(),
            Expanded(
              child: _cell(
                icon: AppAssets.svg.check,
                iconColor: AppColors.greenAccent,
                value: '05',
                valueColor: AppColors.greenAccent,
                label: LocaleKeys.homeStatDelivered.tr(),
              ),
            ),
            _divider(),
            Expanded(
              child: _cell(
                icon: AppAssets.svg.fail,
                iconColor: AppColors.brand,
                value: '02',
                valueColor: AppColors.brand,
                label: LocaleKeys.homeStatFailedShort.tr(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(
        width: 1.w,
        margin: EdgeInsets.symmetric(vertical: AppMargin.mH12),
        color: AppColors.borderHeader,
      );

  Widget _cell({
    required String icon,
    required Color iconColor,
    required String value,
    required Color valueColor,
    required String label,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconWidget(icon: icon, color: iconColor, height: AppSize.sH20, width: AppSize.sW20),
        8.szH,
        Text(
          value,
          style: const TextStyle()
              .setColor(valueColor)
              .extraBold
              .tabular
              .withHeight(0.95)
              .copyWith(fontSize: 28.sp), // was 40px — big-font trim sweep
        ),
        8.szH,
        Text(label, style: const TextStyle().setSecondaryColor.s12.regular),
      ],
    ).paddingSymmetric(horizontal: AppPadding.pW8, vertical: AppPadding.pH16);
  }
}

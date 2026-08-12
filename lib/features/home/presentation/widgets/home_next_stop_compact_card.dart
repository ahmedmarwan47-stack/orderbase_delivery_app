part of '../imports/home_imports.dart';

/// Compact next-stop card used by the Glance layout (1b): header, progress,
/// customer line, meta, and a primary "view order" + call action.
class _HomeNextStopCompactCard extends StatelessWidget {
  const _HomeNextStopCompactCard({this.onViewOrder});

  final VoidCallback? onViewOrder;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppCircular.r20),
        border: Border.all(color: AppColors.borderCardFaint),
        boxShadow: AppShadows.heroCard,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.pW20,
        vertical: AppPadding.pH16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: AppSize.sW8,
                children: [
                  IconWidget(
                    icon: AppAssets.svg.nav,
                    color: AppColors.brand,
                    height: AppSize.sH18,
                    width: AppSize.sW18,
                  ),
                  Text(
                    LocaleKeys.homeNextStop.tr(),
                    style: const TextStyle().setMainTextColor.s14.bold,
                  ),
                ],
              ),
              _HomeStopCountPill(),
            ],
          ),
          12.szH,
          _HomeProgressBar(segHeight: AppSize.sH6, gap: AppSize.sW8),
          12.szH,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.homeCustomerName.tr(),
                      style: const TextStyle().setMainTextColor.s16.bold,
                    ),
                    4.szH,
                    Text(
                      LocaleKeys.homeCustomerAddress.tr(),
                      style: const TextStyle().setTertiaryColor.s12.regular,
                    ),
                  ],
                ),
              ),
              8.szW,
              _codPill(LocaleKeys.homeCodShort.tr()),
            ],
          ),
          12.szH,
          _metaRow(),
          16.szH,
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50.h, // mockup 50px (off the 4px grid)
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.inkFill,
                      borderRadius: BorderRadius.circular(AppCircular.r14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          LocaleKeys.homeViewOrder.tr(),
                          style: const TextStyle().setWhite.s16.bold,
                        ),
                        8.szW,
                        IconWidget(
                          icon: AppAssets.svg.chevronLeft,
                          color: AppColors.surface,
                          height: AppSize.sH18,
                          width: AppSize.sW18,
                        ),
                      ],
                    ),
                  ),
                ).onClick(onTap: onViewOrder),
              ),
              12.szW,
              _HomeSquareIconButton(
                icon: AppAssets.svg.phone,
                iconColor: AppColors.brand,
                size: 50.h, // mockup 50px
                iconSize: AppSize.sH20,
                radius: AppCircular.r14,
                background: AppColors.surface,
                border: AppColors.brand,
                borderWidth: 1.5,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _codPill(String text) => Container(
        decoration: BoxDecoration(
          color: AppColors.heroCodPillBg,
          borderRadius: BorderRadius.circular(AppCircular.r8),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppPadding.pW12,
          vertical: AppPadding.pH4,
        ),
        child: Text(
          text,
          style: const TextStyle().setColor(AppColors.postponedText).s12.bold,
        ),
      );

  Widget _metaRow() => Row(
        children: [
          IconWidget(
            icon: AppAssets.svg.clock,
            color: AppColors.textTertiary,
            height: 15.h, // mockup glyph 15px
            width: 15.w,
          ),
          4.szW,
          Text(
            LocaleKeys.homeEtaMinutes.tr(namedArgs: {'mins': '15'}),
            style: const TextStyle().setTertiaryColor.s12.regular,
          ),
          12.szW,
          _dot(),
          12.szW,
          Text(
            LocaleKeys.homeDistanceKm.tr(namedArgs: {'dist': '1.2'}),
            style: const TextStyle().setTertiaryColor.s12.regular.tabular,
          ),
          12.szW,
          _dot(),
          12.szW,
          Text(
            LocaleKeys.homeOrderNo.tr(namedArgs: {'num': '89289'}),
            style: const TextStyle().setTertiaryColor.s12.regular.tabular,
          ),
        ],
      );

  Widget _dot() => Container(
        width: 3.w, // 3px separator dot (off the 4px grid)
        height: 3.h,
        decoration: const BoxDecoration(
          color: AppColors.textSecondary,
          shape: BoxShape.circle,
        ),
      );
}

/// The red "station 2 of 5" pill reused across the home variants.
class _HomeStopCountPill extends StatelessWidget {
  const _HomeStopCountPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.failedBg,
        borderRadius: BorderRadius.circular(AppCircular.r20),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.pW12,
        vertical: AppPadding.pH4,
      ),
      child: Text(
        LocaleKeys.homeStopCount.tr(namedArgs: {'current': '2', 'total': '5'}),
        style: const TextStyle().setColor(AppColors.stopCountText).s12.semiBold,
      ),
    );
  }
}

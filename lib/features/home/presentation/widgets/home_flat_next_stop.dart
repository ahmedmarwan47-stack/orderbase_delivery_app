part of '../imports/home_imports.dart';

/// Flat next-stop block (2a) — no card chrome: header, progress, a rounded map,
/// customer details, actions, then the remaining-stops list separated by
/// hairlines (matches the single-order page's clean style).
class _HomeFlatNextStop extends StatelessWidget {
  const _HomeFlatNextStop({this.onViewOrder});

  final VoidCallback? onViewOrder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: AppSize.sW8,
              children: [
                IconWidget(
                  icon: AppAssets.svg.nav,
                  color: AppColors.brand,
                  height: AppSize.sH16,
                  width: AppSize.sW16,
                ),
                Text(
                  LocaleKeys.homeNextStop.tr(),
                  style: const TextStyle().setColor(AppColors.flatMuted).s14.bold,
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppCircular.r20),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: AppPadding.pW12,
                vertical: AppPadding.pH4,
              ),
              child: Text(
                LocaleKeys.homeStopCount
                    .tr(namedArgs: {'current': '2', 'total': '5'}),
                style: const TextStyle().setTertiaryColor.s12.bold,
              ),
            ),
          ],
        ).paddingOnly(top: AppPadding.pH4, bottom: AppPadding.pH12),
        // progress
        _HomeProgressBar(segHeight: AppSize.sH4, gap: AppSize.sW4)
            .paddingOnly(bottom: AppPadding.pH16),
        // map
        MapView(
          height: 104.h, // mockup 104px
          borderRadius: AppCircular.r16,
          pinDiameter: 32,
          pinIconSize: 17,
        ),
        // info
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LocaleKeys.homeCustomerName.tr(),
                  style: const TextStyle().setMainTextColor.s20.extraBold,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.heroCodPillBg,
                    borderRadius: BorderRadius.circular(AppCircular.r20),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppPadding.pW12,
                    vertical: AppPadding.pH4,
                  ),
                  child: Text(
                    LocaleKeys.payCod.tr(),
                    style:
                        const TextStyle().setColor(AppColors.postponedText).s12.bold,
                  ),
                ),
              ],
            ),
            8.szH,
            Text(
              LocaleKeys.homeCustomerAddress.tr(),
              style: const TextStyle().setTertiaryColor.s14.regular.withHeight(1.5),
            ),
            8.szH,
            _metaRow(),
          ],
        ).paddingOnly(top: AppPadding.pH16),
        // actions
        Row(
          spacing: AppSize.sW8,
          children: [
            Expanded(
              child: SizedBox(
                height: AppSize.sH52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.flatBlack,
                    borderRadius: BorderRadius.circular(AppCircular.r26),
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
            _circleAction(AppAssets.svg.phone),
            _circleAction(AppAssets.svg.chat),
          ],
        ).paddingSymmetric(vertical: AppPadding.pH16),
        // divider
        Container(height: 1.h, color: AppColors.flatDivider),
        // remaining stops header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              LocaleKeys.homeRemainingStops.tr(),
              style: const TextStyle().setMainTextColor.s14.bold,
            ),
            Row(
              spacing: AppSize.sW4,
              children: [
                IconWidget(
                  icon: AppAssets.svg.nav,
                  color: AppColors.flatMuted,
                  height: AppSize.sH14,
                  width: AppSize.sW14,
                ),
                Text(
                  LocaleKeys.homeRemainingCount.tr(),
                  style: const TextStyle().setColor(AppColors.flatMuted).s12.regular,
                ),
              ],
            ),
          ],
        ).paddingOnly(top: AppPadding.pH16, bottom: AppPadding.pH4),
        // remaining stops list
        _HomeRemainingStopRow(
          index: '3',
          name: LocaleKeys.homeStop3Name.tr(),
          area: LocaleKeys.homeStop3Area.tr(),
          time: LocaleKeys.homeStop3Time.tr(),
          badgeSize: AppSize.sH40,
          badgeBg: AppColors.flatBadgeBg,
          badgeColor: AppColors.textTertiary,
          badgeCircle: true,
          nameSize: FontSizeManager.s14,
          nameWeight: FontWeightManager.bold,
          timeColor: AppColors.textPrimary,
          showDivider: true,
          verticalPadding: AppPadding.pH12,
        ),
        _HomeRemainingStopRow(
          index: '4',
          name: LocaleKeys.homeStop4Name.tr(),
          area: LocaleKeys.homeStop4Area.tr(),
          time: LocaleKeys.homeStop4Time.tr(),
          badgeSize: AppSize.sH40,
          badgeBg: AppColors.flatBadgeBg,
          badgeColor: AppColors.textTertiary,
          badgeCircle: true,
          nameSize: FontSizeManager.s14,
          nameWeight: FontWeightManager.bold,
          timeColor: AppColors.textPrimary,
          showDivider: false,
          verticalPadding: AppPadding.pH12,
        ),
      ],
    );
  }

  Widget _circleAction(String icon) => Container(
        width: 52.w, // mockup 52px (off the 4px grid)
        height: AppSize.sH52,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.flatDivider),
        ),
        child: Center(
          child: IconWidget(
            icon: icon,
            color: AppColors.textPrimary,
            height: AppSize.sH20,
            width: AppSize.sW20,
          ),
        ),
      );

  Widget _metaRow() => Row(
        children: [
          IconWidget(
            icon: AppAssets.svg.clock,
            color: AppColors.flatMuted,
            height: AppSize.sH14,
            width: AppSize.sW14,
          ),
          4.szW,
          Text(
            LocaleKeys.homeEtaMinutes.tr(namedArgs: {'mins': '15'}),
            style: const TextStyle().setColor(AppColors.flatMuted).s12.regular,
          ),
          8.szW,
          _dot(),
          8.szW,
          Text(
            LocaleKeys.homeDistanceKm.tr(namedArgs: {'dist': '1.2'}),
            style: const TextStyle().setColor(AppColors.flatMuted).s12.regular.tabular,
          ),
          8.szW,
          _dot(),
          8.szW,
          Text(
            LocaleKeys.homeOrderNo.tr(namedArgs: {'num': '89289'}),
            style: const TextStyle().setColor(AppColors.flatMuted).s12.regular.tabular,
          ),
        ],
      );

  Widget _dot() => Container(
        width: 3.w,
        height: 3.h,
        decoration: const BoxDecoration(
          color: AppColors.flatMutedDot,
          shape: BoxShape.circle,
        ),
      );
}

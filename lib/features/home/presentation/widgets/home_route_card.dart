part of '../imports/home_imports.dart';

/// Compact route card (1c) — next stop with a mini map, actions, and the
/// "remaining stops" list.
class _HomeRouteCard extends StatelessWidget {
  const _HomeRouteCard({this.onViewOrder});

  final VoidCallback? onViewOrder;

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
        border: Border.all(color: AppColors.borderCardFaint),
        boxShadow: _cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
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
                    height: 17.h,
                    width: 17.w,
                  ),
                  Text(
                    LocaleKeys.homeNextStop.tr(),
                    style: const TextStyle().setMainTextColor.s14.semiBold,
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.failedBg,
                  borderRadius: BorderRadius.circular(AppCircular.r20),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: AppPadding.pW8,
                  vertical: AppPadding.pH4,
                ),
                child: Text(
                  LocaleKeys.homeStopCount.tr(
                    namedArgs: {'current': '2', 'total': '5'},
                  ),
                  style: const TextStyle()
                      .setColor(AppColors.stopCountText)
                      .s12
                      .semiBold,
                ),
              ),
            ],
          ).paddingOnly(
            left: AppPadding.pW16,
            top: AppPadding.pH16,
            right: AppPadding.pW16,
            bottom: AppPadding.pH12,
          ),
          // progress
          _HomeProgressBar(segHeight: 5.h, gap: AppSize.sW4).paddingOnly(
            left: AppPadding.pW16,
            right: AppPadding.pW16,
            bottom: AppPadding.pH12,
          ),
          // mini map + details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSize.sW12,
            children: [
              Container(
                width: 78.w, // mockup 78px (off the 4px grid)
                height: 78.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppCircular.r14),
                  border: Border.all(color: AppColors.borderHeader),
                ),
                clipBehavior: Clip.antiAlias,
                child: MapView(height: 78.h, pinDiameter: 26, pinIconSize: 14),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          LocaleKeys.homeCustomerName.tr(),
                          style:
                              const TextStyle().setMainTextColor.s14.semiBold,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.heroCodPillBg,
                            borderRadius: BorderRadius.circular(AppCircular.r7),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: AppPadding.pW8,
                            vertical: AppPadding.pH4,
                          ),
                          child: Text(
                            LocaleKeys.homeCodShort.tr(),
                            style: const TextStyle()
                                .setColor(AppColors.postponedText)
                                .s12
                                .semiBold,
                          ),
                        ),
                      ],
                    ),
                    4.szH,
                    Text(
                      LocaleKeys.homeCustomerAddress.tr(),
                      style: const TextStyle().setTertiaryColor.s12.regular
                          .withHeight(1.45),
                    ),
                    4.szH,
                    _metaRow(),
                  ],
                ),
              ),
            ],
          ).paddingOnly(
            left: AppPadding.pW16,
            right: AppPadding.pW16,
            bottom: AppPadding.pH12,
          ),
          // actions
          Row(
            spacing: AppSize.sW8,
            children: [
              Expanded(
                child: SizedBox(
                  height: 46.h, // mockup 46px (off the 4px grid)
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.inkFill,
                      borderRadius: BorderRadius.circular(AppCircular.r13),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          LocaleKeys.homeViewOrder.tr(),
                          style: const TextStyle().setWhite.s14.semiBold,
                        ),
                        8.szW,
                        IconWidget(
                          icon: AppAssets.svg.chevronLeft,
                          color: AppColors.surface,
                          height: 17.h,
                          width: 17.w,
                        ),
                      ],
                    ),
                  ),
                ).onClick(onTap: onViewOrder),
              ),
              _HomeSquareIconButton(
                icon: AppAssets.svg.phone,
                iconColor: AppColors.brand,
                size: 46.h,
                iconSize: 19.h,
                radius: AppCircular.r13,
                background: AppColors.surface,
                border: AppColors.brand,
                borderWidth: 1.5,
              ),
              _HomeSquareIconButton(
                icon: AppAssets.svg.chat,
                iconColor: AppColors.greenAccent,
                size: 46.h,
                iconSize: 19.h,
                radius: AppCircular.r13,
                background: AppColors.deliveredBg,
                border: AppColors.deliveredBorder,
              ),
            ],
          ).paddingOnly(
            left: AppPadding.pW16,
            right: AppPadding.pW16,
            bottom: AppPadding.pH16,
          ),
          // remaining stops header
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.surfaceSubtle)),
            ),
            padding: EdgeInsets.only(
              left: AppPadding.pW16,
              top: AppPadding.pH12,
              right: AppPadding.pW16,
              bottom: AppPadding.pH8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LocaleKeys.homeRemainingStops.tr(),
                  style: const TextStyle().setTertiaryColor.s12.semiBold,
                ),
                Row(
                  spacing: AppSize.sW4,
                  children: [
                    IconWidget(
                      icon: AppAssets.svg.nav,
                      color: AppColors.textSecondary,
                      height: AppSize.sH14,
                      width: AppSize.sW14,
                    ),
                    Text(
                      LocaleKeys.homeRemainingCount.tr(),
                      style: const TextStyle().setSecondaryColor.s12.regular,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // remaining stops list
          Column(
            children: [
              _HomeRemainingStopRow(
                index: '3',
                name: LocaleKeys.homeStop3Name.tr(),
                area: LocaleKeys.homeStop3Area.tr(),
                time: LocaleKeys.homeStop3Time.tr(),
                badgeSize: 36.h,
                badgeBg: AppColors.iconTileNeutral,
                badgeColor: AppColors.textSecondary,
                badgeCircle: false,
                nameSize: FontSizeManager.s12,
                nameWeight: FontWeightManager.semiBold,
                timeColor: AppColors.dangerAccent,
                showDivider: true,
                verticalPadding: AppPadding.pH8,
              ),
              _HomeRemainingStopRow(
                index: '4',
                name: LocaleKeys.homeStop4Name.tr(),
                area: LocaleKeys.homeStop4Area.tr(),
                time: LocaleKeys.homeStop4Time.tr(),
                badgeSize: 36.h,
                badgeBg: AppColors.iconTileNeutral,
                badgeColor: AppColors.textSecondary,
                badgeCircle: false,
                nameSize: FontSizeManager.s12,
                nameWeight: FontWeightManager.semiBold,
                timeColor: AppColors.dangerAccent,
                showDivider: false,
                verticalPadding: AppPadding.pH8,
              ),
            ],
          ).paddingOnly(
            left: AppPadding.pW16,
            right: AppPadding.pW16,
            bottom: AppPadding.pH12,
          ),
        ],
      ),
    );
  }

  Widget _metaRow() => Row(
    children: [
      IconWidget(
        icon: AppAssets.svg.clock,
        color: AppColors.textTertiary,
        height: 13.h, // mockup glyph 13px
        width: 13.w,
      ),
      4.szW,
      Text(
        LocaleKeys.homeEtaShort.tr(),
        style: const TextStyle().setTertiaryColor.s12.regular,
      ),
      8.szW,
      _dot(),
      8.szW,
      Text(
        LocaleKeys.homeDistanceKm.tr(namedArgs: {'dist': '1.2'}),
        style: const TextStyle().setTertiaryColor.s12.regular.tabular,
      ),
      8.szW,
      _dot(),
      8.szW,
      Text(
        LocaleKeys.homeOrderNoShort.tr(),
        style: const TextStyle().setTertiaryColor.s12.regular.tabular,
      ),
    ],
  );

  Widget _dot() => Container(
    width: 3.w,
    height: 3.h,
    decoration: const BoxDecoration(
      color: AppColors.textSecondary,
      shape: BoxShape.circle,
    ),
  );
}

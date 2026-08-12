part of '../imports/home_imports.dart';

/// The next-stop hero card — progress, a map strip, the current order's
/// details, and the primary "view order" + call/chat actions.
class _HomeNextStopCard extends StatelessWidget {
  const _HomeNextStopCard({this.onViewOrder});

  final VoidCallback? onViewOrder;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppCircular.r22),
        border: Border.all(color: AppColors.borderCardFaint),
        boxShadow: AppShadows.heroCard,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── header: "next stop" + station count ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconWidget(
                    icon: AppAssets.svg.nav,
                    color: AppColors.brand,
                    height: AppSize.sH18,
                    width: AppSize.sW18,
                  ),
                  8.szW,
                  Text(
                    LocaleKeys.homeNextStop.tr(),
                    style: const TextStyle().setMainTextColor.s14.bold,
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.failedBg,
                  borderRadius: BorderRadius.circular(AppCircular.r20),
                ),
                child: Text(
                  LocaleKeys.homeStopCount
                      .tr(namedArgs: {'current': '2', 'total': '5'}),
                  style:
                      const TextStyle().setColor(AppColors.stopCountText).s12.semiBold,
                ).paddingSymmetric(
                  horizontal: AppPadding.pW12,
                  vertical: AppPadding.pH4,
                ),
              ),
            ],
          ).paddingOnly(
            left: AppPadding.pW20,
            top: AppPadding.pH16,
            right: AppPadding.pW20,
            bottom: AppPadding.pH12,
          ),
          // ── progress segments ──
          Row(
            spacing: AppSize.sW8,
            children: const [
              _HomeProgressSeg(AppColors.greenAccent),
              _HomeProgressSeg(AppColors.brand),
              _HomeProgressSeg(AppColors.borderDefault),
              _HomeProgressSeg(AppColors.borderDefault),
              _HomeProgressSeg(AppColors.borderDefault),
            ],
          ).paddingOnly(
            left: AppPadding.pW20,
            right: AppPadding.pW20,
            bottom: AppPadding.pH16,
          ),
          // ── map strip ──
          MapView(height: AppSize.sH96, showHairlines: true),
          // ── order info ──
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    LocaleKeys.homeOrderNo.tr(namedArgs: {'num': '89289'}),
                    style: const TextStyle().setMainTextColor.s16.bold.tabular,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.heroCodPillBg,
                      borderRadius: BorderRadius.circular(AppCircular.r8),
                    ),
                    child: Text(
                      LocaleKeys.payCod.tr(),
                      style:
                          const TextStyle().setColor(AppColors.postponedText).s12.bold,
                    ).paddingSymmetric(
                      horizontal: AppPadding.pW12,
                      vertical: AppPadding.pH4,
                    ),
                  ),
                ],
              ),
              8.szH,
              Text(
                LocaleKeys.homeCustomerName.tr(),
                style: const TextStyle().setMainTextColor.s18.bold,
              ),
              8.szH,
              Row(
                children: [
                  IconWidget(
                    icon: AppAssets.svg.pin,
                    color: AppColors.brand,
                    height: AppSize.sH16,
                    width: AppSize.sW16,
                  ),
                  8.szW,
                  Text(
                    LocaleKeys.homeCustomerAddress.tr(),
                    style: const TextStyle()
                        .setTertiaryColor
                        .s14
                        .regular
                        .withHeight(1.5),
                  ),
                ],
              ),
              8.szH,
              Row(
                children: [
                  Row(
                    children: [
                      IconWidget(
                        icon: AppAssets.svg.clock,
                        color: AppColors.textTertiary,
                        height: 15.h, // mockup glyph 15px (off the 4px grid)
                        width: 15.w,
                      ),
                      4.szW,
                      Text(
                        LocaleKeys.homeEtaMinutes.tr(namedArgs: {'mins': '15'}),
                        style: const TextStyle().setTertiaryColor.s12.regular,
                      ),
                    ],
                  ),
                  12.szW,
                  Container(
                    width: 3.w, // 3px separator dot (off the 4px grid)
                    height: 3.h,
                    decoration: const BoxDecoration(
                      color: AppColors.textSecondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  12.szW,
                  Text(
                    LocaleKeys.homeDistanceKm.tr(namedArgs: {'dist': '1.2'}),
                    style: const TextStyle().setTertiaryColor.s12.regular.tabular,
                  ),
                ],
              ),
            ],
          ).paddingOnly(
            left: AppPadding.pW20,
            top: AppPadding.pH16,
            right: AppPadding.pW20,
            bottom: AppPadding.pH4,
          ),
          // ── actions ──
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: AppSize.sH52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.inkFill,
                      borderRadius: BorderRadius.circular(AppCircular.r15), // radii exempt
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
                size: AppSize.sH52,
                iconSize: 21.h, // mockup glyph 21px (off the 4px grid)
                radius: AppCircular.r15,
                background: AppColors.surface,
                border: AppColors.brand,
                borderWidth: 1.5,
              ),
              12.szW,
              _HomeSquareIconButton(
                icon: AppAssets.svg.chat,
                iconColor: AppColors.greenAccent,
                size: AppSize.sH52,
                iconSize: 21.h,
                radius: AppCircular.r15,
                background: AppColors.deliveredBg,
                border: AppColors.deliveredBorder,
              ),
            ],
          ).paddingOnly(
            left: AppPadding.pW20,
            top: AppPadding.pH16,
            right: AppPadding.pW20,
            bottom: AppPadding.pH16,
          ),
        ],
      ),
    );
  }
}

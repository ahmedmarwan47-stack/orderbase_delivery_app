part of '../imports/home_imports.dart';

/// Flat top header (2a) — circular avatar, bold name, online status, and round
/// search + notifications buttons.
class _HomeFlatHeader extends StatelessWidget {
  const _HomeFlatHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            ClipOval(
              child: SvgPicture.asset(
                AppAssets.img.saleSucre,
                width: AppSize.sW48,
                height: AppSize.sH48,
              ),
            ),
            12.szW,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.homeCourierName.tr(),
                  style: const TextStyle().setMainTextColor.s18.extraBold,
                ),
                4.szH,
                Row(
                  spacing: AppSize.sW8,
                  children: [
                    Container(
                      width: AppSize.sW8,
                      height: AppSize.sH8,
                      decoration: const BoxDecoration(
                        color: AppColors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      LocaleKeys.homeOnline.tr(),
                      style: const TextStyle()
                          .setColor(AppColors.deliveredText)
                          .s12
                          .semiBold,
                    ),
                    Text(
                      '· ${LocaleKeys.homeMerchantName.tr()}',
                      style:
                          const TextStyle().setColor(AppColors.flatMuted).s12.regular,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        Row(
          spacing: AppSize.sW8,
          children: [
            _circleButton(icon: AppAssets.svg.search),
            _circleButton(icon: AppAssets.svg.bell, badge: true),
          ],
        ),
      ],
    ).paddingOnly(
      left: AppPadding.pW24,
      top: AppPadding.pH12,
      right: AppPadding.pW24,
      bottom: AppPadding.pH20,
    );
  }

  Widget _circleButton({required String icon, bool badge = false}) {
    final button = Container(
      width: AppSize.sW44,
      height: AppSize.sH44,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        boxShadow: AppShadows.card,
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
    if (!badge) return button;
    return Stack(
      children: [
        button,
        PositionedDirectional(
          top: AppPadding.pH8,
          end: AppPadding.pW8,
          child: Container(
            width: AppSize.sW8,
            height: AppSize.sH8,
            decoration: BoxDecoration(
              color: AppColors.brand,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.surface, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

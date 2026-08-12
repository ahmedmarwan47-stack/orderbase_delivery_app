part of '../imports/home_imports.dart';

/// Compact top header (1c) — larger avatar, smaller courier name, search button.
class _HomeCompactHeader extends StatelessWidget {
  const _HomeCompactHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppCircular.r12),
              child: SvgPicture.asset(
                AppAssets.img.saleSucre,
                width: 50.w, // mockup avatar 50px (off the 4px grid)
                height: 50.h,
              ),
            ),
            12.szW,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.homeCourierName.tr(),
                  style: const TextStyle().setMainTextColor.s14.bold,
                ),
                Text(
                  LocaleKeys.homeMerchantName.tr(),
                  style: const TextStyle().setSecondaryColor.s12.regular,
                ),
              ],
            ),
          ],
        ),
        _HomeSquareIconButton(
          icon: AppAssets.svg.search,
          iconColor: AppColors.textPrimary,
          size: 42.h, // mockup 42px (off the 4px grid)
          iconSize: AppSize.sH18,
          radius: AppCircular.r11,
          background: AppColors.surface,
          border: AppColors.iconButtonBorder,
        ),
      ],
    ).paddingOnly(
      left: AppPadding.pW20,
      top: AppPadding.pH12,
      right: AppPadding.pW20,
      bottom: AppPadding.pH12,
    );
  }
}

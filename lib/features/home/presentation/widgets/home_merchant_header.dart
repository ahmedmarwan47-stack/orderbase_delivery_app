part of '../imports/home_imports.dart';

/// Top header — merchant avatar + courier/merchant names, and a search button.
class _HomeMerchantHeader extends StatelessWidget {
  const _HomeMerchantHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppCircular.r13),
              child: SvgPicture.asset(
                AppAssets.img.saleSucre,
                width: 46.w, // mockup avatar (off the 4px grid — matched exactly)
                height: 46.h,
              ),
            ),
            12.szW,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.homeCourierName.tr(),
                  style: const TextStyle().setMainTextColor.s16.bold,
                ),
                4.szH,
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
          size: AppSize.sH40,
          iconSize: AppSize.sH20,
          background: AppColors.surface,
          border: AppColors.iconButtonBorder,
        ),
      ],
    ).paddingOnly(
      left: AppPadding.pW20,
      top: AppPadding.pH12,
      right: AppPadding.pW20,
      bottom: AppPadding.pH16,
    );
  }
}

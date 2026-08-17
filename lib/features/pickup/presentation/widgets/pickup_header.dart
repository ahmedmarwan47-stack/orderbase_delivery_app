part of '../imports/pickup_imports.dart';

/// Pickup header: a back link, the branch identity (logo + name), and a banner
/// summarising how many orders are ready to collect in one action.
class _PickupHeader extends StatelessWidget {
  const _PickupHeader({required this.count, this.showBack = true});
  final int count;

  /// Hidden when Pickup is a shell tab (a root tab has nowhere to go back).
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.borderHeader)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showBack) ...[
            Row(
              children: [
                IconWidget(
                  icon: AppAssets.svg.chevronRight,
                  color: AppColors.textTertiary,
                  height: AppSize.sH18,
                  width: AppSize.sW18,
                ),
                8.szW,
                Text(
                  LocaleKeys.back.tr(),
                  style: const TextStyle().setTertiaryColor.s14.semiBold,
                ),
              ],
            ).paddingSymmetric(vertical: AppPadding.pH8).onClick(
                  onTap: () => Navigator.of(context).maybePop(),
                ),
            12.szH,
          ],
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppCircular.r13),
                child: IconWidget(
                  icon: AppAssets.img.saleSucre,
                  height: AppSize.sH48,
                  width: AppSize.sW48,
                ),
              ),
              12.szW,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleKeys.pickupTitle.tr(),
                    style: const TextStyle().setMainTextColor.s18.extraBold,
                  ),
                  4.szH,
                  Text(
                    LocaleKeys.pickupMerchant.tr(),
                    style: const TextStyle().setSecondaryColor.s12.regular,
                  ),
                ],
              ),
            ],
          ),
          12.szH,
          _PickupBanner(count: count),
        ],
      ).paddingOnlyDirectional(
        start: AppPadding.pW20,
        end: AppPadding.pW20,
        top: AppPadding.pH8,
        bottom: AppPadding.pH16,
      ),
    );
  }
}

/// The amber "N orders ready to collect" callout under the branch identity.
class _PickupBanner extends StatelessWidget {
  const _PickupBanner({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.heroCodPillBg,
        borderRadius: BorderRadius.circular(AppCircular.r12),
        border: Border.all(color: AppColors.pickupBannerBorder),
      ),
      child: Row(
        children: [
          IconWidget(
            icon: AppAssets.svg.bag,
            color: AppColors.postponedText,
            height: AppSize.sH18,
            width: AppSize.sW18,
          ),
          8.szW,
          Expanded(
            child: Text(
              LocaleKeys.pickupBanner.tr(namedArgs: {'count': '$count'}),
              style: const TextStyle()
                  .setColor(AppColors.pickupBannerText)
                  .s14
                  .semiBold
                  .withHeight(1.5),
            ),
          ),
        ],
      ).paddingAll(AppPadding.pH12),
    );
  }
}

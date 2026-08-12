part of '../imports/queue_imports.dart';

/// Layout for the postponed list (1e): header + info banner + cards + nav.
class _PostponedBody extends StatelessWidget {
  const _PostponedBody({required this.orders, required this.onReturn});
  final ValueNotifier<List<Order>> orders;
  final void Function(Order) onReturn;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Order>>(
      valueListenable: orders,
      builder: (_, list, _) => Column(
        children: [
          _PostponedHeader(count: list.length),
          Expanded(
            child: ListView(
              padding: EdgeInsetsDirectional.only(
                start: AppPadding.pW20,
                end: AppPadding.pW20,
                top: AppPadding.pH16,
                bottom: AppPadding.pH20,
              ),
              children: [
                const _PostponedInfoBanner(),
                for (final o in list) ...[
                  12.szH,
                  _PostponedCard(order: o, onReturn: () => onReturn(o)),
                ],
              ],
            ),
          ),
          const BottomNav(active: NavTab.orders, notificationsBadge: true),
        ],
      ),
    );
  }
}

/// White header — back to orders, title, count subtitle.
class _PostponedHeader extends StatelessWidget {
  const _PostponedHeader({required this.count});
  final int count;

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
          Row(
            children: [
              IconWidget(
                icon: AppAssets.svg.chevronRight,
                color: AppColors.textTertiary,
                height: AppSize.sH18,
                width: AppSize.sW18,
              ),
              8.szW,
              Text(LocaleKeys.backToOrders.tr(),
                  style: const TextStyle().setTertiaryColor.s14.semiBold),
            ],
          ).paddingSymmetric(vertical: AppPadding.pH8).onClick(onTap: () => Modular.to.pop()),
          Text(LocaleKeys.postponedTitle.tr(),
              style: const TextStyle().setMainTextColor.s24.extraBold),
          4.szH,
          Text(
            LocaleKeys.postponedSubtitle
                .tr(namedArgs: {'count': arabicDigits(count)}),
            style: const TextStyle().setSecondaryColor.s14.regular,
          ),
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

/// Amber explainer banner at the top of the postponed list.
class _PostponedInfoBanner extends StatelessWidget {
  const _PostponedInfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.postponedBannerBg,
        borderRadius: BorderRadius.circular(AppCircular.r16),
        border: Border.all(color: AppColors.postponedBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconWidget(
            icon: AppAssets.svg.clock,
            color: AppColors.postponedText,
            height: AppSize.sH18,
            width: AppSize.sW18,
          ).paddingOnly(top: AppPadding.pH4),
          12.szW,
          Expanded(
            child: Text(
              LocaleKeys.postponedBanner.tr(),
              style: const TextStyle()
                  .setColor(AppColors.postponedTextStrong)
                  .s12
                  .regular
                  .withHeight(1.7),
            ),
          ),
        ],
      ).paddingAll(AppPadding.pH16),
    );
  }
}

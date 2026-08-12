part of '../imports/orders_imports.dart';

/// Header: title + date/count subtitle + search button, then the filter chips.
class _OrdersHeader extends StatelessWidget {
  const _OrdersHeader({required this.vc});
  final OrdersViewController vc;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleKeys.queueTitle.tr(),
                    style: const TextStyle().setMainTextColor.s24.extraBold,
                  ),
                  4.szH,
                  Text(
                    LocaleKeys.ordersSubtitle.tr(),
                    style: const TextStyle().setSecondaryColor.s14.regular,
                  ),
                ],
              ),
              const _SearchButton(),
            ],
          ),
          16.szH,
          _OrdersFilterChips(vc: vc),
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

/// Decorative muted search tile (matches the mockup — not wired to search yet).
class _SearchButton extends StatelessWidget {
  const _SearchButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSize.sW44,
      height: AppSize.sH44,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppCircular.r12),
      ),
      child: Center(
        child: IconWidget(
          icon: AppAssets.svg.search,
          color: AppColors.textPrimary,
          height: AppSize.sH20,
          width: AppSize.sW20,
        ),
      ),
    );
  }
}

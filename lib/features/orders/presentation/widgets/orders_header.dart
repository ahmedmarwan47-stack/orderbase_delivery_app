part of '../imports/orders_imports.dart';

/// Header bar: title + subtitle + a search button — matching the unified
/// [AppHeader] geometry (single row, 12/16 padding, 40pt tile). The filter
/// chips live in the page body beneath the bar (see [_OrdersBody]). The search
/// button opens the shared Queue search experience (pushed over this screen)
/// rather than an inline field.
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.queueTitle.tr(),
                style: const TextStyle().setMainTextColor.s14.semiBold,
              ),
              4.szH,
              Text(
                LocaleKeys.ordersSubtitle.tr(),
                style: const TextStyle().setSecondaryColor.s12.medium,
              ),
            ],
          ),
          _SearchButton(onTap: () => _openQueueSearch(context)),
        ],
      ).paddingOnlyDirectional(
        start: AppPadding.pW20,
        end: AppPadding.pW20,
        top: AppPadding.pH12,
        bottom: AppPadding.pH16,
      ),
    );
  }

  /// Push the Queue screen straight into its search state.
  void _openQueueSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const QueueScreen(startSearching: true),
      ),
    );
  }
}

/// Muted square icon tile — the search affordance. A 44pt tap area wraps the
/// 44pt visual so it's reliably hit.
class _SearchButton extends StatelessWidget {
  const _SearchButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: LocaleKeys.a11ySearch.tr(),
      child: Container(
        width: AppSize.sW40,
        height: AppSize.sH40,
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
      ).onClick(onTap: onTap),
    );
  }
}

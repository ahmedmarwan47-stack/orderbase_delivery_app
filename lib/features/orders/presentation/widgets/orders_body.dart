part of '../imports/orders_imports.dart';

/// Layout only — header, the filtered/searched card list (or a no-results
/// state), and the bottom nav.
class _OrdersBody extends StatelessWidget {
  const _OrdersBody({
    required this.vc,
    required this.onOpenOrder,
    required this.onSelectTab,
  });

  final OrdersViewController vc;
  final ValueChanged<FlowOrder>? onOpenOrder;
  final ValueChanged<NavTab>? onSelectTab;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _OrdersHeader(vc: vc),
        Expanded(
          // Rebuild on filter, search open/close, and every keystroke.
          child: ListenableBuilder(
            listenable: Listenable.merge([vc.filter, vc.searching, vc.query]),
            builder: (_, _) {
              final items = vc.visible;
              if (items.isEmpty) {
                return _NoResults(query: vc.searchController.text);
              }
              return ListView.separated(
                padding: EdgeInsetsDirectional.only(
                  start: AppPadding.pW20,
                  end: AppPadding.pW20,
                  top: AppPadding.pH16,
                  bottom: AppPadding.pH20,
                ),
                itemCount: items.length,
                separatorBuilder: (_, _) => 12.szH,
                itemBuilder: (_, i) => _OrderCard(
                  order: items[i],
                  onTap: () => onOpenOrder?.call(items[i]),
                ),
              );
            },
          ),
        ),
        BottomNav(
          active: NavTab.orders,
          notificationsBadge: true,
          onTap: onSelectTab,
        ),
      ],
    );
  }
}

/// Empty state shown when a search yields nothing.
class _NoResults extends StatelessWidget {
  const _NoResults({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconWidget(
            icon: AppAssets.svg.search,
            color: AppColors.textTertiary,
            height: 32.h,
            width: 32.w,
          ),
          16.szH,
          Text(
            LocaleKeys.noResultsTitle.tr(namedArgs: {'query': query}),
            textAlign: TextAlign.center,
            style: const TextStyle().setMainTextColor.s16.bold,
          ),
          8.szH,
          Text(
            LocaleKeys.noResultsDesc.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle().setSecondaryColor.s14.regular,
          ),
        ],
      ).paddingSymmetric(horizontal: AppPadding.pW20),
    );
  }
}

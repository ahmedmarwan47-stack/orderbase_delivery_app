part of '../imports/orders_imports.dart';

/// Layout only — header, the filtered card list, and the bottom nav.
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
          child: ValueListenableBuilder<OrdersFilter>(
            valueListenable: vc.filter,
            builder: (_, _, _) {
              final items = vc.visible;
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

part of '../imports/orders_imports.dart';

/// Layout only — header, the filtered card list, and the bottom nav.
class _OrdersBody extends StatelessWidget {
  const _OrdersBody({required this.vc, required this.onOpenOrder});

  final OrdersViewController vc;
  final ValueChanged<FlowOrder>? onOpenOrder;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _OrdersHeader(vc: vc),
        // Filter chips sit in the page body, directly beneath the header bar
        // (keeps the bar the same height as the unified AppHeader).
        _OrdersFilterChips(vc: vc).paddingOnlyDirectional(
          start: AppPadding.pW20,
          end: AppPadding.pW20,
          top: AppPadding.pH16,
          bottom: AppPadding.pH8,
        ),
        Expanded(
          // Rebuild when the active filter changes.
          child: ValueListenableBuilder<OrdersFilter>(
            valueListenable: vc.filter,
            builder: (_, _, _) {
              final items = vc.visible;
              return ListView.separated(
                padding: EdgeInsetsDirectional.only(
                  start: AppPadding.pW20,
                  end: AppPadding.pW20,
                  top: AppPadding.pH16,
                  // Clears the floating tab bar the list runs under.
                  bottom: BottomNav.reservedHeight(context),
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
      ],
    );
  }
}

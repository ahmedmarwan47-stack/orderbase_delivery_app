part of '../imports/orders_imports.dart';

/// Which slice of today's orders is shown.
enum OrdersFilter { all, active, done }

/// Ephemeral UI state for the Orders list — just the active filter. The header
/// search button hands off to the Queue search experience, so no live search
/// state lives here. No `setState`, no logic in the View. Counts + slices are
/// derived here so the widgets stay declarative.
class OrdersViewController {
  OrdersViewController({required this.orders})
      : filter = ValueNotifier(OrdersFilter.all);

  final List<FlowOrder> orders;
  final ValueNotifier<OrdersFilter> filter;

  /// Orders to show for the active filter (done + failed both count as "done").
  List<FlowOrder> get visible {
    return switch (filter.value) {
      OrdersFilter.all => orders,
      OrdersFilter.active =>
        orders.where((o) => o.state == FlowOrderState.active).toList(),
      OrdersFilter.done => orders
          .where((o) =>
              o.state == FlowOrderState.done ||
              o.state == FlowOrderState.failed)
          .toList(),
    };
  }

  int countFor(OrdersFilter f) => switch (f) {
        OrdersFilter.all => orders.length,
        OrdersFilter.active =>
          orders.where((o) => o.state == FlowOrderState.active).length,
        OrdersFilter.done => orders
            .where((o) =>
                o.state == FlowOrderState.done ||
                o.state == FlowOrderState.failed)
            .length,
      };

  String filterLabelKey(OrdersFilter f) => switch (f) {
        OrdersFilter.all => LocaleKeys.filterAll,
        OrdersFilter.active => LocaleKeys.ordersFilterActive,
        OrdersFilter.done => LocaleKeys.ordersFilterDone,
      };

  void selectFilter(OrdersFilter f) => filter.value = f;

  void dispose() {
    filter.dispose();
  }
}

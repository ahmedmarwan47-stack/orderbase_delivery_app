part of '../imports/orders_imports.dart';

/// Which slice of today's orders is shown.
enum OrdersFilter { all, active, done }

/// Ephemeral UI state for the Orders list — the active filter plus a real,
/// live search (query + open/closed). No `setState`, no logic in the View.
/// Counts + slices are derived here so the widgets stay declarative.
class OrdersViewController {
  OrdersViewController({required this.orders})
      : filter = ValueNotifier(OrdersFilter.all);

  final List<FlowOrder> orders;
  final ValueNotifier<OrdersFilter> filter;

  // ── search ──
  /// Backing controller for the header search field.
  final TextEditingController searchController = TextEditingController();

  /// Whether the search field is open (replaces the title row + chips).
  final ValueNotifier<bool> searching = ValueNotifier(false);

  /// The current normalized query (Arabic-Indic digits folded to Western so
  /// typing ٨٩ matches "#89…"). Drives the visible list while [searching].
  final ValueNotifier<String> query = ValueNotifier('');

  void openSearch() => searching.value = true;

  void onSearchChanged(String raw) => query.value = _normalize(raw);

  void clearSearch() {
    searchController.clear();
    query.value = '';
  }

  void closeSearch() {
    clearSearch();
    searching.value = false;
  }

  /// Fold Arabic-Indic digits to Western and trim, so number/name/street
  /// matching works regardless of keyboard.
  static String _normalize(String s) {
    const ar = '٠١٢٣٤٥٦٧٨٩';
    final buf = StringBuffer();
    for (final ch in s.trim().characters) {
      final i = ar.indexOf(ch);
      buf.write(i == -1 ? ch : '$i');
    }
    return buf.toString();
  }

  bool _matches(FlowOrder o, String q) {
    final hay = _normalize('${o.num} ${o.name} ${o.meta} ${o.address}')
        .toLowerCase();
    return hay.contains(q.toLowerCase());
  }

  /// Orders to show. While searching with a non-empty query, matches across
  /// number / name / area / street (ignoring the filter chips); otherwise the
  /// active filter applies (done + failed both count as "done").
  List<FlowOrder> get visible {
    if (searching.value && query.value.isNotEmpty) {
      return orders.where((o) => _matches(o, query.value)).toList();
    }
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
    searchController.dispose();
    searching.dispose();
    query.dispose();
  }
}

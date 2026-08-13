part of '../imports/queue_imports.dart';

/// Which slice of the active queue is shown. Postponed orders sit outside this
/// filter — they have their own list ([PostponedScreen]).
enum QueueFilter { all, transit, delivered, failed }

/// Ephemeral UI state for the Queue screen — search field, search/browse mode,
/// active filter, and the debounced query. No `setState`, no logic in the View.
class QueueViewController {
  QueueViewController({
    List<Order>? orders,
    this.onSelectTab,
    this.onOpenOrder,
    bool startSearching = false,
    String initialQuery = '',
    QueueFilter initialFilter = QueueFilter.all,
  })  : _staticOrders = orders,
        isSearching = ValueNotifier(startSearching),
        startedInSearch = startSearching,
        filter = ValueNotifier(initialFilter),
        query = ValueNotifier(initialQuery.trim()),
        searchController = TextEditingController(text: initialQuery) {
    _searchSub = _searchSubject
        .debounceTime(const Duration(milliseconds: 300))
        .distinct()
        .listen((q) => query.value = q.trim());
  }

  /// Static override (e.g. DevGallery's "cleared" set). When null, the queue
  /// reads the **live** shift orders, so deliveries/failures reflect instantly.
  final List<Order>? _staticOrders;

  /// Shell mode: forward bottom-nav taps and open the detail *through* the app
  /// shell (so the order flow pops back to the tab and mutates the shift).
  /// Both null on the standalone `/queue` route (opens detail directly).
  final void Function(NavTab)? onSelectTab;
  final void Function(FlowOrder)? onOpenOrder;

  List<Order> get orders => _staticOrders ?? ShiftController.instance.orders;

  /// True when the screen was opened directly into search mode (pushed as a
  /// route from Home/Orders). There's no browse mode to fall back to, so the
  /// search-header back button must pop the route instead of just exiting
  /// search. See [_QueueSearchHeader].
  final bool startedInSearch;

  final TextEditingController searchController;
  final ValueNotifier<bool> isSearching;
  final ValueNotifier<QueueFilter> filter;
  final ValueNotifier<String> query;

  final PublishSubject<String> _searchSubject = PublishSubject<String>();
  late final StreamSubscription<String> _searchSub;

  // ── slices ──
  List<Order> get postponed =>
      orders.where((o) => o.status == OrderStatus.postponed).toList();

  List<Order> get active =>
      orders.where((o) => o.status != OrderStatus.postponed).toList();

  int countFor(QueueFilter f) => switch (f) {
        QueueFilter.all => active.length,
        QueueFilter.transit =>
          active.where((o) => o.status == OrderStatus.transit).length,
        QueueFilter.delivered =>
          active.where((o) => o.status == OrderStatus.delivered).length,
        QueueFilter.failed =>
          active.where((o) => o.status == OrderStatus.failed).length,
      };

  List<Order> get filtered => switch (filter.value) {
        QueueFilter.all => active,
        QueueFilter.transit =>
          active.where((o) => o.status == OrderStatus.transit).toList(),
        QueueFilter.delivered =>
          active.where((o) => o.status == OrderStatus.delivered).toList(),
        QueueFilter.failed =>
          active.where((o) => o.status == OrderStatus.failed).toList(),
      };

  List<Order> get searchMatches =>
      orders.where((o) => matchKey(o) != null).toList();

  /// The LocaleKeys key describing why [o] matched the query (also the
  /// "does it match?" test — null means no match).
  String? matchKey(Order o) {
    // Arabic keyboards emit Eastern-Arabic digits (٠-٩); normalize to Western so
    // a typed order number matches (Flutter_Base "toEnglishNumbers" rule).
    final q = _toEnglishDigits(query.value.trim().toLowerCase());
    if (q.isEmpty) return null;
    if (o.num.toLowerCase().contains(q)) return LocaleKeys.matchNumber;
    if (o.name.toLowerCase().contains(q)) return LocaleKeys.matchName;
    if (o.area.toLowerCase().contains(q)) return LocaleKeys.matchArea;
    if (o.addr.toLowerCase().contains(q)) return LocaleKeys.matchStreet;
    return null;
  }

  String filterLabelKey(QueueFilter f) => switch (f) {
        QueueFilter.all => LocaleKeys.filterAll,
        QueueFilter.transit => LocaleKeys.filterTransit,
        QueueFilter.delivered => LocaleKeys.filterDelivered,
        QueueFilter.failed => LocaleKeys.filterFailed,
      };

  // ── handlers ──
  void openSearch() => isSearching.value = true;

  void closeSearch() {
    isSearching.value = false;
    clearSearch();
  }

  void onSearchChanged(String q) => _searchSubject.add(q);

  void clearSearch() {
    searchController.clear();
    _searchSubject.add('');
    query.value = '';
  }

  void selectFilter(QueueFilter f) => filter.value = f;

  void clearFilter() => filter.value = QueueFilter.all;

  void openPostponed() => Modular.to.pushNamed('/queue/postponed');

  /// Open the tapped order's detail. In shell mode this hands the built
  /// [FlowOrder] up to the shell (which pushes the flow over the tabs); on the
  /// standalone route it pushes the detail directly.
  void openOrder(BuildContext context, Order order) {
    final flow = _asFlowOrder(order);
    if (onOpenOrder != null) {
      onOpenOrder!(flow);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => OrderDetailScreen(order: flow)),
      );
    }
  }

  FlowOrder _asFlowOrder(Order o) => orderToFlow(o);

  String _toEnglishDigits(String s) {
    const eastern = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (var i = 0; i < 10; i++) {
      s = s.replaceAll(eastern[i], '$i');
    }
    return s;
  }

  void dispose() {
    searchController.dispose();
    isSearching.dispose();
    filter.dispose();
    query.dispose();
    _searchSub.cancel();
    _searchSubject.close();
  }
}

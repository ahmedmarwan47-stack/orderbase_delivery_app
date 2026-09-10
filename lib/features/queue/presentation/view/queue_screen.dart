part of '../imports/queue_imports.dart';

/// Queue — orders queue with search, filters, empty ("cleared") and no-results
/// states. Ported from Queue States.dc.html (1a–1d). The postponed list (1e) is
/// [PostponedScreen].
///
/// Two lifecycles:
///  * **Standalone** (`/queue` route, DevGallery) — the screen owns a
///    [QueueViewController]; opening an order pushes the detail directly.
///  * **Shell tab** — the app shell passes a [controller] it owns (so it can
///    drive the filter from a Home KPI tap) with `onSelectTab` / `onOpenOrder`
///    wired to switch tabs and push the order flow over the shell.
class QueueScreen extends StatefulWidget {
  const QueueScreen({
    super.key,
    this.controller,
    this.orders,
    this.startSearching = false,
    this.initialQuery = '',
    this.initialFilter = QueueFilter.all,
    this.onSelectTab,
    this.onOpenOrder,
    this.hostsTabBar = true,
  });

  /// Shell-owned controller. When null the screen creates (and disposes) its own.
  final QueueViewController? controller;

  /// Static override; DevGallery passes a "cleared" set to show 1d. Ignored
  /// when [controller] is supplied.
  final List<Order>? orders;
  final bool startSearching;
  final String initialQuery;
  final QueueFilter initialFilter;
  final ValueChanged<NavTab>? onSelectTab;
  final void Function(FlowOrder)? onOpenOrder;

  /// Standalone the page carries its own tab bar; inside the app shell the
  /// shell owns the one bar (and drops it while search takes the page over).
  final bool hostsTabBar;

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  QueueViewController? _own;
  QueueViewController get _vc => widget.controller ?? _own!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _own = QueueViewController(
        orders: widget.orders,
        onSelectTab: widget.onSelectTab,
        onOpenOrder: widget.onOpenOrder,
        startSearching: widget.startSearching,
        initialQuery: widget.initialQuery,
        initialFilter: widget.initialFilter,
      );
    }
  }

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ValueListenableBuilder<bool>(
        valueListenable: _vc.isSearching,
        // The bottom bar belongs to the Scaffold, not the body: `extendBody`
        // is what lets the browse list pass under the floating pill and give
        // its blur something to work on. Search has no tab bar — the field
        // takes the page over — so it only reserves the indicator strip.
        builder: (context, searching, _) => Scaffold(
          backgroundColor: AppColors.background,
          extendBody: !searching,
          bottomNavigationBar: searching
              ? const HomeIndicator()
              : widget.hostsTabBar
              ? BottomNav(
                  active: NavTab.orders,
                  notificationsBadge: true,
                  onTap: _vc.onSelectTab,
                )
              : null,
          body: SafeArea(
            // Browsing, the header sliver carries the top inset (the list
            // passes under the status bar, so the scroll-edge blur runs to
            // the top of the screen); the search header needs it here.
            top: searching,
            bottom: false,
            // Rebuild when the shift mutates (a delivered/failed order leaves
            // the active list) so the queue always reflects reality.
            child: AnimatedBuilder(
              animation: ShiftController.instance,
              builder: (_, _) => _QueueBody(vc: _vc, searching: searching),
            ),
          ),
        ),
      ),
    );
  }
}

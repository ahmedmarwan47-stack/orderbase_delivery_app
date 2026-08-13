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
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          // Rebuild when the shift mutates (a delivered/failed order leaves the
          // active list) so the queue always reflects reality.
          child: AnimatedBuilder(
            animation: ShiftController.instance,
            builder: (_, _) => _QueueBody(vc: _vc),
          ),
        ),
      ),
    );
  }
}

part of '../imports/queue_imports.dart';

/// Queue — orders queue with search, filters, empty ("cleared") and no-results
/// states. Ported from Queue States.dc.html (1a–1d). The postponed list (1e) is
/// [PostponedScreen]. The Screen owns the [QueueViewController] lifecycle.
class QueueScreen extends StatefulWidget {
  const QueueScreen({
    super.key,
    this.orders,
    this.startSearching = false,
    this.initialQuery = '',
  });

  /// Defaults to [sampleOrders]; DevGallery passes a "cleared" set to show 1d.
  final List<Order>? orders;
  final bool startSearching;
  final String initialQuery;

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  late final QueueViewController _vc = QueueViewController(
    orders: widget.orders ?? sampleOrders,
    startSearching: widget.startSearching,
    initialQuery: widget.initialQuery,
  );

  @override
  void dispose() {
    _vc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(bottom: false, child: _QueueBody(vc: _vc)),
      ),
    );
  }
}

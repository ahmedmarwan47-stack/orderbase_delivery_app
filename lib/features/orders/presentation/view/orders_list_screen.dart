part of '../imports/orders_imports.dart';

/// Orders list — first step of the Order Flow (Order Flow.dc.html, `isOrders`).
/// Header + filter chips + order cards. The filter is local UI state, owned by
/// [OrdersViewController]. The Screen owns the controller lifecycle.
class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key, this.onOpenOrder, this.onSelectTab});

  /// Called when an order card is tapped (opens the detail step).
  final ValueChanged<FlowOrder>? onOpenOrder;

  /// Forwarded to the bottom nav so the app shell can switch tabs.
  final ValueChanged<NavTab>? onSelectTab;

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  late final OrdersViewController _vc = OrdersViewController(
    orders: sampleFlowOrders,
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
        body: SafeArea(
          bottom: false,
          child: _OrdersBody(
            vc: _vc,
            onOpenOrder: widget.onOpenOrder,
            onSelectTab: widget.onSelectTab,
          ),
        ),
      ),
    );
  }
}

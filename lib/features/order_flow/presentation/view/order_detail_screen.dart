part of '../imports/order_flow_imports.dart';

/// Order detail — Order Flow step 2 (Order Flow.dc.html, `isOrder`).
/// The header order number, customer name, cash-card amount, address, items,
/// notes and timeline are all driven by [order] (see [FlowOrder]). Reached
/// via the '/order-detail' route.
class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({
    super.key,
    this.order,
    this.cod = true,
    this.onFinishToNext,
    this.onFinishToHome,
    this.onSelectTab,
  });

  /// The order to render. Optional so the '/order-detail' route and DevGallery
  /// can still open a stand-alone detail; falls back to [sampleFlowOrders].first.
  final FlowOrder? order;

  /// Whether this order collects cash on delivery. Prepaid orders show no cash
  /// card and skip COD collection at handoff. Only used as a fallback when no
  /// [order] is supplied (e.g. DevGallery's prepaid preview); when an [order]
  /// is given, its own `cod` flag drives the behaviour.
  final bool cod;

  /// Result screen's primary button ("continue route — next stop").
  final VoidCallback? onFinishToNext;

  /// Result screen's secondary button ("back to home").
  final VoidCallback? onFinishToHome;

  /// Bottom-nav taps (the app shell pops the flow and switches tab).
  final ValueChanged<NavTab>? onSelectTab;

  @override
  Widget build(BuildContext context) {
    final o = order ?? sampleFlowOrders.first;
    // When a real order is threaded, its own flag drives COD; otherwise fall
    // back to the [cod] param (DevGallery's stand-alone prepaid/COD previews).
    final isCod = order != null ? o.cod : cod;
    final controller = OrderFlowController(
      onFinishToNext: onFinishToNext,
      onFinishToHome: onFinishToHome,
      orderNum: o.num,
      customer: o.name,
    );
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _OrderDetailHeader(order: o),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _CustomerSection(name: o.name),
                      16.szH,
                      const _HDivider(),
                      16.szH,
                      _AddressSection(address: o.address),
                      16.szH,
                      const _HDivider(),
                      16.szH,
                      _ItemsSection(items: o.items),
                      16.szH,
                      if (o.note != null) ...[
                        _NotesCard(note: o.note!),
                        16.szH,
                      ],
                      if (isCod) ...[
                        _PaymentCard(amount: o.amount ?? ''),
                        16.szH,
                      ],
                      _FailButton(onTap: () => controller.fail(context)),
                      16.szH,
                      _Timeline(pickedTime: o.pickedTime, assignedTime: o.assignedTime),
                    ],
                  ).paddingOnly(
                    left: AppPadding.pW20,
                    right: AppPadding.pW20,
                    top: AppPadding.pH16,
                    bottom: AppPadding.pH20,
                  ),
                ),
              ),
              _DeliverBar(
                onDeliver: () => controller.deliver(
                  context,
                  cod: isCod,
                  due: o.codDue,
                ),
              ),
              BottomNav(
                active: NavTab.orders,
                notificationsBadge: true,
                onTap: onSelectTab,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

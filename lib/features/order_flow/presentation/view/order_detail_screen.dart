part of '../imports/order_flow_imports.dart';

/// Order detail — Order Flow step 2 (Order Flow.dc.html, `isOrder`).
/// The header order number, customer name, cash-card amount, address, items,
/// notes and timeline are all driven by [order] (see [FlowOrder]). Reached
/// via the '/order-detail' route.
class OrderDetailScreen extends StatefulWidget {
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
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final ScrollController _scroll = ScrollController();

  // The header is transparent at the top and gains its surface background once
  // the detail content scrolls beneath it.
  final ValueNotifier<bool> _scrolled = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    final v = _scroll.offset > 2;
    if (v != _scrolled.value) _scrolled.value = v;
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    _scrolled.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order ?? sampleFlowOrders.first;
    // When a real order is threaded, its own flag drives COD; otherwise fall
    // back to the [cod] param (DevGallery's stand-alone prepaid/COD previews).
    final isCod = widget.order != null ? o.cod : widget.cod;
    // Delivery actions only make sense while the order is still open — a closed
    // (delivered / failed) order hides the "not delivered" button and the
    // sticky "delivered" bar.
    final isOpen = o.state == FlowOrderState.active;
    final controller = OrderFlowController(
      onFinishToNext: widget.onFinishToNext,
      onFinishToHome: widget.onFinishToHome,
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
              ValueListenableBuilder<bool>(
                valueListenable: _scrolled,
                builder: (_, scrolled, _) =>
                    _OrderDetailHeader(order: o, scrolled: scrolled),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scroll,
                  child:
                      Column(
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
                          if (isOpen) ...[
                            _FailButton(
                              onTap: () => controller.fail(context, order: o),
                            ),
                            16.szH,
                          ],
                          _Timeline(
                            pickedTime: o.pickedTime,
                            assignedTime: o.assignedTime,
                          ),
                        ],
                      ).paddingOnly(
                        left: AppPadding.pW20,
                        right: AppPadding.pW20,
                        top: AppPadding.pH16,
                        bottom: AppPadding.pH20,
                      ),
                ),
              ),
              if (isOpen)
                _DeliverBar(
                  onDeliver: () =>
                      controller.deliver(context, cod: isCod, due: o.codDue),
                ),
              BottomNav(
                active: NavTab.orders,
                notificationsBadge: true,
                onTap: widget.onSelectTab,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

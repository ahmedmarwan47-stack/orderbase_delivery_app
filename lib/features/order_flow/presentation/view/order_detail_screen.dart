part of '../imports/order_flow_imports.dart';

/// Order detail — Order Flow step 2 (Order Flow.dc.html, `isOrder`).
/// A faithful static port of the designed detail for order #89289; the mockup
/// doesn't parametrize this view per order, so neither do we yet. Reached via
/// the '/order-detail' route.
class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({
    super.key,
    this.onFinishToNext,
    this.onFinishToHome,
    this.onSelectTab,
  });

  /// Result screen's primary button ("continue route — next stop").
  final VoidCallback? onFinishToNext;

  /// Result screen's secondary button ("back to home").
  final VoidCallback? onFinishToHome;

  /// Bottom-nav taps (the app shell pops the flow and switches tab).
  final ValueChanged<NavTab>? onSelectTab;

  @override
  Widget build(BuildContext context) {
    final controller = OrderFlowController(
      onFinishToNext: onFinishToNext,
      onFinishToHome: onFinishToHome,
    );
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const _OrderDetailHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _CustomerSection(),
                      16.szH,
                      const _HDivider(),
                      16.szH,
                      const _AddressSection(),
                      16.szH,
                      const _HDivider(),
                      16.szH,
                      const _ItemsSection(),
                      16.szH,
                      const _NotesCard(),
                      16.szH,
                      const _PaymentCard(),
                      16.szH,
                      _FailButton(onTap: () => controller.fail(context)),
                      16.szH,
                      const _Timeline(),
                    ],
                  ).paddingOnly(
                    left: AppPadding.pW20,
                    right: AppPadding.pW20,
                    top: AppPadding.pH16,
                    bottom: AppPadding.pH20,
                  ),
                ),
              ),
              _DeliverBar(onDeliver: () => controller.deliver(context)),
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

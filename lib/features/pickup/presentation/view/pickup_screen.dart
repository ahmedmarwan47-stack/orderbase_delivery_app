part of '../imports/pickup_imports.dart';

/// Pickup — Order Flow step 0 (Order Flow.dc.html, `isPickup`): collecting a
/// batch of ready orders from the branch, confirmed in one action. No tab bar;
/// it's a focused task screen with a sticky confirm bar. Fully static, so no
/// ViewController is needed.
class PickupScreen extends StatelessWidget {
  const PickupScreen({super.key, this.onConfirm});

  /// Confirms pickup (all orders → "in transit"). Wired to the flow later.
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    // The batch waiting at the branch = the shift's in-transit orders (the ones
    // still to deliver), so pickup shows the same orders as the rest of the app.
    final orders = ShiftController.instance.orders
        .where((o) => o.status == OrderStatus.transit)
        .map(orderToFlow)
        .toList()
      ..sort((a, b) => a.num.compareTo(b.num));
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _PickupHeader(count: orders.length),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsetsDirectional.only(
                    start: AppPadding.pW20,
                    end: AppPadding.pW20,
                    top: AppPadding.pH16,
                    bottom: AppPadding.pH20,
                  ),
                  itemCount: orders.length,
                  separatorBuilder: (_, _) => 12.szH,
                  itemBuilder: (_, i) => _PickupCard(order: orders[i]),
                ),
              ),
              _PickupConfirmBar(
                count: orders.length,
                // From the More menu there's no flow to advance into yet, so
                // confirming pops back rather than silently doing nothing.
                onConfirm: onConfirm ?? () => Navigator.of(context).maybePop(),
              ),
              const HomeIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

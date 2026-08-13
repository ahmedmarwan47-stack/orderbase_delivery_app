part of '../imports/pickup_imports.dart';

/// Pickup — Order Flow step 0 (Order Flow.dc.html, `isPickup`): collecting a
/// batch of ready orders from the branch, confirmed in one action. No tab bar;
/// it's a focused task screen with a sticky confirm bar. Fully static, so no
/// ViewController is needed.
class PickupScreen extends StatelessWidget {
  const PickupScreen({super.key, this.onConfirm});

  /// Confirms pickup (all orders → "in transit"). Wired to the flow later.
  final VoidCallback? onConfirm;

  /// Total time the entrance stagger is allowed to span across the whole batch.
  static const Duration _totalStagger = Duration(milliseconds: 300);

  /// Per-card lead-in: evenly spread across [_totalStagger] regardless of how
  /// many cards there are, so a long list never crawls in.
  static Duration _staggerDelay(int index, int count) {
    if (count <= 1) return Duration.zero;
    final step = _totalStagger.inMilliseconds / (count - 1);
    return Duration(milliseconds: (step * index).round());
  }

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
                  itemBuilder: (_, i) => _PickupCard(
                    order: orders[i],
                    // Index-based lead-in so the batch reads as a list dropping
                    // in top-to-bottom, but the TOTAL stagger is capped so a long
                    // list never crawls (~300ms across the whole batch).
                    entranceDelay: _staggerDelay(i, orders.length),
                  ),
                ),
              ),
              _PickupConfirmBar(
                count: orders.length,
                onConfirm: () {
                  // A decisive medium tap the instant the batch is accepted,
                  // just before the real accept/navigation runs.
                  AppHaptics.confirm();
                  // From the More menu there's no flow to advance into yet, so
                  // confirming pops back rather than silently doing nothing.
                  (onConfirm ?? () => Navigator.of(context).maybePop())();
                },
              ),
              const HomeIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

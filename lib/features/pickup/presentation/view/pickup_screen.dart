part of '../imports/pickup_imports.dart';

/// Pickup — Order Flow step 0 (Order Flow.dc.html, `isPickup`): collecting a
/// batch of ready orders from the branch, confirmed in one action. No tab bar;
/// it's a focused task screen with a sticky confirm bar. Fully static, so no
/// ViewController is needed.
class PickupScreen extends StatefulWidget {
  const PickupScreen({super.key, this.onConfirm, this.onSelectTab});

  /// Confirms pickup (all orders → "in transit"). Wired to the flow later.
  final VoidCallback? onConfirm;

  /// When provided the screen is a shell tab: it renders the shared bottom nav
  /// (instead of a bare home-indicator) so it behaves like a normal tab page.
  final ValueChanged<NavTab>? onSelectTab;

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
  State<PickupScreen> createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> {
  final ScrollController _scroll = ScrollController();

  // The header is transparent at the top and gains its surface background once
  // content scrolls beneath it.
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
    final onSelectTab = widget.onSelectTab;
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
              ValueListenableBuilder<bool>(
                valueListenable: _scrolled,
                builder: (_, scrolled, _) => _PickupHeader(
                  count: orders.length,
                  showBack: onSelectTab == null,
                  scrolled: scrolled,
                ),
              ),
              Expanded(
                child: ListView.separated(
                  controller: _scroll,
                  padding: EdgeInsetsDirectional.only(
                    start: AppPadding.pW20,
                    end: AppPadding.pW20,
                    top: AppPadding.pH16,
                    bottom: AppPadding.pH20,
                  ),
                  // +1 leading item = the "ready for pickup" banner, now on top
                  // of the orders (moved out of the header) so it scrolls away.
                  itemCount: orders.length + 1,
                  separatorBuilder: (_, _) => 12.szH,
                  itemBuilder: (_, i) {
                    if (i == 0) return _PickupBanner(count: orders.length);
                    final order = orders[i - 1];
                    return _PickupCard(
                      order: order,
                      // Index-based lead-in so the batch reads as a list dropping
                      // in top-to-bottom, but the TOTAL stagger is capped so a long
                      // list never crawls (~300ms across the whole batch).
                      entranceDelay:
                          PickupScreen._staggerDelay(i - 1, orders.length),
                    );
                  },
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
                  (widget.onConfirm ??
                      () => Navigator.of(context).maybePop())();
                },
              ),
              if (onSelectTab != null)
                BottomNav(active: NavTab.pickup, onTap: onSelectTab)
              else
                const HomeIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

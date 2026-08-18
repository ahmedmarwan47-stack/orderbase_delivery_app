part of '../imports/pickup_imports.dart';

/// Pickup — Order Flow step 0 (Order Flow.dc.html, `isPickup`): collecting a
/// batch of ready orders from the branch, confirmed in one action. No tab bar;
/// it's a focused task screen with a sticky confirm bar. Fully static, so no
/// ViewController is needed.
class PickupScreen extends StatefulWidget {
  const PickupScreen({
    super.key,
    this.onConfirm,
    this.onSelectTab,
    this.onOpenNotifications,
    this.onOpenSearch,
  });

  /// Confirms pickup (all orders → "in transit"). Wired to the flow later.
  final VoidCallback? onConfirm;

  /// When provided the screen is a shell tab: it renders the shared bottom nav
  /// (instead of a bare home-indicator) so it behaves like a normal tab page.
  final ValueChanged<NavTab>? onSelectTab;

  /// Unified-header actions (shell-tab mode).
  final VoidCallback? onOpenNotifications;
  final VoidCallback? onOpenSearch;

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

  /// Show the "confirm you carried the batch from the branch" bottom sheet,
  /// then (on confirm) run the real accept/navigation.
  Future<void> _carry(int count) async {
    final ok = await showAppSheet<bool>(
      context,
      child: _PickupCarrySheet(count: count),
    );
    if (ok != true || !mounted) return;
    AppHaptics.confirm();
    (widget.onConfirm ?? () => Navigator.of(context).maybePop())();
  }

  @override
  Widget build(BuildContext context) {
    final onSelectTab = widget.onSelectTab;
    // The batch waiting at the branch = the shift's in-transit orders (the ones
    // still to deliver), so pickup shows the same orders as the rest of the app.
    final orders =
        ShiftController.instance.orders
            .where((o) => o.status == OrderStatus.transit)
            .map(orderToFlow)
            .toList()
          ..sort((a, b) => a.num.compareTo(b.num));
    // Once the batch has been carried (accepted) there is nothing left at the
    // branch — the page becomes an empty state instead of the list + CTA.
    final carried = ShiftController.instance.accepted || orders.isEmpty;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Shell tab: just the unified header (branch identity dropped —
              // the header already carries the shift context). Standalone: the
              // branch identity keeps its back button + scroll-fade.
              if (onSelectTab != null)
                AppHeader(
                  onSearch: widget.onOpenSearch,
                  onOpenNotifications: widget.onOpenNotifications,
                )
              else
                ValueListenableBuilder<bool>(
                  valueListenable: _scrolled,
                  builder: (_, scrolled, _) => _PickupHeader(
                    count: carried ? 0 : orders.length,
                    showBack: true,
                    scrolled: scrolled,
                  ),
                ),
              if (carried)
                const Expanded(child: _PickupEmptyState())
              else ...[
                Expanded(
                  child: ListView.separated(
                    controller: _scroll,
                    padding: EdgeInsetsDirectional.only(
                      start: AppPadding.pW20,
                      end: AppPadding.pW20,
                      top: AppPadding.pH16,
                      bottom: AppPadding.pH20,
                    ),
                    // +1 leading item = the "ready for pickup" banner, on top of
                    // the orders (moved out of the header) so it scrolls away.
                    itemCount: orders.length + 1,
                    separatorBuilder: (_, _) => 12.szH,
                    itemBuilder: (_, i) {
                      if (i == 0) return _PickupBanner(count: orders.length);
                      final order = orders[i - 1];
                      return _PickupCard(
                        order: order,
                        entranceDelay: PickupScreen._staggerDelay(
                          i - 1,
                          orders.length,
                        ),
                      );
                    },
                  ),
                ),
                _PickupConfirmBar(
                  count: orders.length,
                  onConfirm: () => _carry(orders.length),
                ),
              ],
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

/// Empty state shown once the branch batch has been carried — the generated
/// illustration + a short reassurance that nothing is waiting at the branch.
class _PickupEmptyState extends StatelessWidget {
  const _PickupEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(AppAssets.img.pickupEmpty, width: 180.w, height: 180.w),
          8.szH,
          Text(
            LocaleKeys.pickupEmptyTitle.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle().setMainTextColor.s16.extraBold,
          ),
          8.szH,
          Text(
            LocaleKeys.pickupEmptyDesc.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle().setSecondaryColor.s14.regular.withHeight(
              1.5,
            ),
          ),
        ],
      ).paddingSymmetric(horizontal: AppPadding.pW32),
    );
  }
}

/// Confirmation bottom sheet for carrying the branch batch into the queue.
class _PickupCarrySheet extends StatelessWidget {
  const _PickupCarrySheet({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return SheetShell(
      title: LocaleKeys.pickupCarryTitle.tr(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            LocaleKeys.pickupCarryBody.tr(namedArgs: {'count': '$count'}),
            style: const TextStyle().setSecondaryColor.s14.regular.withHeight(
              1.5,
            ),
          ),
          20.szH,
          Container(
            height: AppSize.sH56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.inkFill,
              borderRadius: BorderRadius.circular(AppCircular.r15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconWidget(
                  icon: AppAssets.svg.check,
                  color: AppColors.surface,
                  height: AppSize.sH20,
                  width: AppSize.sW20,
                ),
                8.szW,
                Text(
                  LocaleKeys.pickupCarryConfirm.tr(),
                  style: const TextStyle().setWhite.s16.bold,
                ),
              ],
            ),
          ).onClick(onTap: () => Navigator.of(context).pop(true)),
          8.szH,
          Container(
            height: AppSize.sH52,
            alignment: Alignment.center,
            child: Text(
              LocaleKeys.pickupCarryCancel.tr(),
              style: const TextStyle().setSecondaryColor.s14.bold,
            ),
          ).onClick(onTap: () => Navigator.of(context).pop(false)),
        ],
      ),
    );
  }
}

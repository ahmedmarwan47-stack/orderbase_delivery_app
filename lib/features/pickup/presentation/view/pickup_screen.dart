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
    final shift = ShiftController.instance;
    // This tab is a view of BATCHES, not a flat order list: a courier can have
    // several waiting at the branch at once. Before the first is carried, the
    // day's own in-transit orders are that first batch, so it renders in the
    // same shape as every batch dispatched later.
    final batches = <OrderBatch>[
      if (!shift.accepted)
        OrderBatch(
          id: 'batch-1',
          orders: shift.orders
              .where((o) => o.status == OrderStatus.transit)
              .toList(),
        ),
      ...shift.pendingBatches,
    ]..removeWhere((b) => b.orders.isEmpty);
    final totalOrders = batches.fold<int>(0, (sum, b) => sum + b.count);
    // Nothing left at the branch — the page becomes an empty state.
    final carried = batches.isEmpty;
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
                    count: totalOrders,
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
                    // the batches (moved out of the header) so it scrolls away.
                    itemCount: batches.length + 1,
                    separatorBuilder: (_, _) => 16.szH,
                    itemBuilder: (_, i) {
                      if (i == 0) return _PickupBanner(count: totalOrders);
                      return _PickupBatchSection(
                        batch: batches[i - 1],
                        index: i,
                      );
                    },
                  ),
                ),
                _PickupConfirmBar(
                  count: totalOrders,
                  onConfirm: () => _carry(totalOrders),
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
          Image.asset(
            AppAssets.img.pickupEmpty,
            width: 220.w,
            height: 220.w,
            fit: BoxFit.contain,
          ),
          8.szH,
          Text(
            LocaleKeys.pickupEmptyTitle.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle().setMainTextColor.s16.bold,
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
                  height: AppSize.sH18,
                  width: AppSize.sW18,
                ),
                8.szW,
                Text(
                  LocaleKeys.pickupCarryConfirm.tr(),
                  style: const TextStyle().setWhite.s14.semiBold,
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
              style: const TextStyle().setSecondaryColor.s14.semiBold,
            ),
          ).onClick(onTap: () => Navigator.of(context).pop(false)),
        ],
      ),
    );
  }
}

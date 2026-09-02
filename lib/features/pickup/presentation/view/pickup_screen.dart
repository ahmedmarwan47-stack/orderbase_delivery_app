part of '../imports/pickup_imports.dart';

/// Pickup — the batches waiting at the branch, standalone (`/pickup` route,
/// DevGallery). In the app this view lives inside the Orders tab, where each
/// waiting batch is a section with its own carry button; this page is the
/// focused, everything-at-once version of the same act, with a sticky confirm
/// bar that carries every waiting batch together.
class PickupScreen extends StatefulWidget {
  const PickupScreen({super.key, this.onConfirm});

  /// Runs after the carry is confirmed. Defaults to popping the route.
  final VoidCallback? onConfirm;

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

  /// Confirm carrying everything waiting, batch by batch, then carry them.
  Future<void> _carryAll(List<OrderBatch> batches) async {
    final ok = await showCarryBatchSheet(
      context,
      batch: OrderBatch(
        id: batches.map((b) => b.id).join(' · '),
        orders: [for (final b in batches) ...b.orders],
      ),
    );
    if (ok != true || !mounted) return;
    AppHaptics.confirm();
    ShiftController.instance.carryAllPending();
    (widget.onConfirm ?? () => Navigator.of(context).maybePop())();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: AnimatedBuilder(
            animation: ShiftController.instance,
            builder: (context, _) {
              final batches = ShiftController.instance.pendingBatches;
              final totalOrders = batches.fold<int>(
                0,
                (sum, b) => sum + b.count,
              );
              return Column(
                children: [
                  ValueListenableBuilder<bool>(
                    valueListenable: _scrolled,
                    builder: (_, scrolled, _) => _PickupHeader(
                      count: totalOrders,
                      showBack: true,
                      scrolled: scrolled,
                    ),
                  ),
                  if (batches.isEmpty)
                    const Expanded(child: _PickupEmptyState())
                  else ...[
                    Expanded(
                      child: ListView.builder(
                        controller: _scroll,
                        padding: EdgeInsetsDirectional.only(
                          bottom: AppPadding.pH20,
                        ),
                        itemCount: batches.length,
                        itemBuilder: (_, i) => _PickupBatchSection(
                          batch: batches[i],
                          initiallyExpanded: i == 0,
                          last: i == batches.length - 1,
                        ),
                      ),
                    ),
                    _PickupConfirmBar(
                      count: totalOrders,
                      onConfirm: () => _carryAll(batches),
                    ),
                  ],
                  const HomeIndicator(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Empty state shown once every batch has been carried — the generated
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

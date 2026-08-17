part of '../imports/home_imports.dart';

/// Home / الرئيسية — design option 1a ("Airy": next-stop hero + 2×2 stats).
/// Ported from Home Directions.dc.html (#1a). Reads the live [ShiftController]
/// so the next-stop hero advances and the KPI tiles update as stops close.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.onSelectTab,
    this.onOpenOrder,
    this.onOpenOrdersFilter,
    this.onOpenSettlement,
    this.onOpenNotifications,
  });

  /// Forwarded to the bottom nav so the app shell can switch tabs.
  final ValueChanged<NavTab>? onSelectTab;

  /// Opens the notifications screen (the header bell).
  final VoidCallback? onOpenNotifications;

  /// Opens the current next-stop order's detail ("عرض الطلب" on the hero).
  final VoidCallback? onOpenOrder;

  /// A KPI tile that maps to a slice of the Orders/Queue tab (in-progress /
  /// delivered / failed) — switches to that tab with the filter preselected.
  final void Function(QueueFilter)? onOpenOrdersFilter;

  /// The "collected today" KPI tile → end-of-day settlement.
  final VoidCallback? onOpenSettlement;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scroll = ScrollController();

  // The header is transparent at the top and gains its surface background once
  // content scrolls beneath it (iOS large-title behaviour).
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
                builder: (_, scrolled, _) => _HomeMerchantHeader(
                  onOpenNotifications: widget.onOpenNotifications,
                  scrolled: scrolled,
                ),
              ),
              Expanded(
                child: AnimatedBuilder(
                  animation: ShiftController.instance,
                  builder: (_, _) => SingleChildScrollView(
                    controller: _scroll,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _HomeNextStopCard(onViewOrder: widget.onOpenOrder),
                        20.szH,
                        _HomeTodayStats(
                          onOpenOrdersFilter: widget.onOpenOrdersFilter,
                          onOpenSettlement: widget.onOpenSettlement,
                        ),
                      ],
                    ).paddingOnly(
                      left: AppPadding.pW20,
                      top: AppPadding.pH4,
                      right: AppPadding.pW20,
                      bottom: AppPadding.pH20,
                    ),
                  ),
                ),
              ),
              BottomNav(
                active: NavTab.home,
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

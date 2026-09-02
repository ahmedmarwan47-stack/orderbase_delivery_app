part of '../imports/home_imports.dart';

/// Force one of Home's states for a preview (DevGallery). Null reads the live
/// shift, which is what the app shell does.
enum HomePreview { idle, returning, settled }

/// Home / الرئيسية — the next order as a hero card, the day's four numbers
/// directly beneath it. Reads the live [ShiftController] so the hero advances
/// and the numbers update as stops close, and swaps the hero for a status card
/// when there is nothing to deliver: before the first batch, once everything
/// in hand is closed (expected back at the branch), and after the branch has
/// settled the day.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.onSelectTab,
    this.onOpenOrder,
    this.onDeliverOrder,
    this.onCallCustomer,
    this.onCallBranch,
    this.onOpenOrdersFilter,
    this.onOpenSettlement,
    this.onOpenPendingBatch,
    this.onOpenNotifications,
    this.onOpenSearch,
    this.onStartNewDay,
    this.preview,
  });

  /// Forwarded to the bottom nav so the app shell can switch tabs.
  final ValueChanged<NavTab>? onSelectTab;

  /// Opens the notifications page (the header bell).
  final VoidCallback? onOpenNotifications;

  /// Opens search (the header search icon) — routed to the Orders tab.
  final VoidCallback? onOpenSearch;

  /// Opens the current next-stop order's detail — the hero card taps through
  /// to it.
  final VoidCallback? onOpenOrder;

  /// Hands the current order over («تم تسليم الطلب» — the hero's black
  /// button): handoff sheet → COD collection when there is cash → result.
  final VoidCallback? onDeliverOrder;

  /// The hero's call tile — dials the current customer.
  final VoidCallback? onCallCustomer;

  /// «اتصال بالفرع» on the expected-at-branch card.
  final VoidCallback? onCallBranch;

  /// A KPI cell that maps to a slice of the Orders tab (in-progress /
  /// delivered / failed) — switches to that tab with the filter preselected.
  final void Function(QueueFilter)? onOpenOrdersFilter;

  /// The cash cell → settlement.
  final VoidCallback? onOpenSettlement;

  /// The status card's «دفعة جديدة في انتظارك» row → the Orders tab.
  final VoidCallback? onOpenPendingBatch;

  /// Dev-only: reset the simulated day from the settled card.
  final VoidCallback? onStartNewDay;

  /// Force a state for previews; null follows the live shift.
  final HomePreview? preview;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CourierStatus _status(ShiftController shift) => switch (widget.preview) {
    HomePreview.idle => CourierStatus.idle,
    HomePreview.returning => CourierStatus.returning,
    HomePreview.settled => CourierStatus.settled,
    null => shift.status,
  };

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
              AppHeader(
                onSearch: widget.onOpenSearch,
                onOpenNotifications: widget.onOpenNotifications,
              ),
              Expanded(
                child: AnimatedBuilder(
                  animation: ShiftController.instance,
                  builder: (_, _) {
                    final shift = ShiftController.instance;
                    final status = _status(shift);
                    return SingleChildScrollView(
                      child:
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (status == CourierStatus.onRoute &&
                                  shift.nextStop != null) ...[
                                _HomeNextStopCard(
                                  onViewOrder: widget.onOpenOrder,
                                  onDeliver: widget.onDeliverOrder,
                                  onCall: widget.onCallCustomer,
                                ),
                                // A batch dispatched mid-route is a reason to
                                // turn around now — those orders are not in
                                // the bag. The status card carries this row
                                // when the hero is gone; on route it sits
                                // under the hero instead of going unsaid.
                                if (shift.hasPendingBatch) ...[
                                  12.szH,
                                  _PendingBatchRow(
                                    onTap: widget.onOpenPendingBatch,
                                  ),
                                ],
                              ] else
                                _HomeStateCard(
                                  status: status,
                                  onCallBranch: widget.onCallBranch,
                                  onOpenPendingBatch: widget.onOpenPendingBatch,
                                  onStartNewDay: widget.onStartNewDay,
                                ),
                              16.szH,
                              // The day's numbers, right under the hero so
                              // both are on screen without a scroll.
                              _HomeStatRow(
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
                    );
                  },
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

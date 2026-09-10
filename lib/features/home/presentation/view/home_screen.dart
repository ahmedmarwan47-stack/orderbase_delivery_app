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
    this.hostsTabBar = true,
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

  /// The status card's «جولة جديدة في انتظارك» row → the Orders tab.
  final VoidCallback? onOpenPendingBatch;

  /// Dev-only: reset the simulated day from the settled card.
  final VoidCallback? onStartNewDay;

  /// Force a state for previews; null follows the live shift.
  final HomePreview? preview;

  /// Standalone (DevGallery, a route) the page carries its own tab bar; inside
  /// the app shell the shell owns the one bar, so this is false there.
  final bool hostsTabBar;

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
        // The page runs under the floating tab bar — that is what gives the
        // glass something to blur.
        extendBody: true,
        bottomNavigationBar: widget.hostsTabBar
            ? BottomNav(
                active: NavTab.home,
                notificationsBadge: true,
                onTap: widget.onSelectTab,
              )
            : null,
        body: SafeArea(
          // The header sliver carries the top inset (see AppHeaderSliver), so the
          // page passes under the status bar and the scroll-edge blur runs to the
          // top of the screen.
          top: false,
          bottom: false,
          child: CustomScrollView(
            slivers: [
              AppHeaderSliver(
                title: LocaleKeys.navHome.tr(),
                onSearch: widget.onOpenSearch,
                onOpenNotifications: widget.onOpenNotifications,
              ),
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    ShiftController.instance,
                    RoadMode.instance,
                  ]),
                  builder: (_, _) {
                    final shift = ShiftController.instance;
                    final status = _status(shift);
                    // There is an order to deliver: the hero, not a status
                    // card, occupies the top of the page.
                    final hasStop =
                        status == CourierStatus.onRoute &&
                        shift.nextStop != null;
                    // Built once, placed once — above the hero slot or below
                    // it, never both. Absent entirely until a number moves.
                    final stats = _HomeStatRow.hasAnyMetric(shift)
                        ? _HomeStatRow(
                            onOpenOrdersFilter: widget.onOpenOrdersFilter,
                            onOpenSettlement: widget.onOpenSettlement,
                          )
                        : null;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Which branch the courier is on today — it left the
                        // header when the header became a page title, and it
                        // belongs above the numbers it produced.
                        _HomeBranchLine(branch: shift.branchName),
                        12.szH,
                        // The day's numbers lead the page, always —
                        // the designer's call. They are still absent
                        // until one of them moves off zero.
                        if (stats != null) ...[stats, 20.szH],
                        if (hasStop) ...[
                          // The stop, in three parts. The batch and the
                          // distance it runs sit above the card; the
                          // card is the destination alone; the actions
                          // sit below it, on the page.
                          if (shift.currentBatch case final batch?) ...[
                            _HomeStopTripRow(
                              batch: batch,
                              current: shift.currentStopNumber,
                              total: shift.totalStops,
                              routeKm: batch.routeKm,
                            ),
                            8.szH,
                          ],
                          _HomeNextStopCard(onViewOrder: widget.onOpenOrder),
                          12.szH,
                          _HomeStopActions(
                            onDeliver: widget.onDeliverOrder,
                            onCall: widget.onCallCustomer,
                          ),
                          // A batch dispatched mid-route is a reason to
                          // turn around now — those orders are not in the
                          // bag. The status card carries this row when the
                          // hero is gone; on route it sits under the hero
                          // instead of going unsaid.
                          //
                          // The return time rides WITH it. On its own it is
                          // an orphan — a figure answering a question nobody
                          // asked. Beside a batch waiting at the branch it
                          // becomes the useful half: when the courier is
                          // expected there to collect it.
                          if (shift.hasPendingBatch) ...[
                            20.szH,
                            if (shift.currentBatch case final batch?) ...[
                              _HomeReturnEta(
                                returnEta: formatClockArabic(
                                  shift.returnEtaOf(batch),
                                ),
                              ),
                              12.szH,
                            ],
                            _PendingBatchRow(onTap: widget.onOpenPendingBatch),
                          ],
                        ] else
                          _HomeStateCard(
                            status: status,
                            onCallBranch: widget.onCallBranch,
                            onOpenPendingBatch: widget.onOpenPendingBatch,
                            onStartNewDay: widget.onStartNewDay,
                          ),
                      ],
                    ).paddingOnly(
                      left: AppPadding.pW16,
                      top: AppPadding.pH12,
                      right: AppPadding.pW16,
                      // Clears the floating tab bar the page runs under.
                      bottom: BottomNav.reservedHeight(context),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

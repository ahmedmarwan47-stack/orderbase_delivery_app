part of '../imports/settlement_imports.dart';

/// State A — OPEN / AWAITING: white header + scrolling paper body (the cash
/// card, the day's batches, returns handover, the locked note, the last seven
/// days) + bottom nav. There is no settle button: the status pill in the
/// header says where the day stands, and the branch moves it.
class _SettlementOpenView extends StatefulWidget {
  const _SettlementOpenView({
    required this.vc,
    required this.data,
    this.onSelectTab,
    this.onOpenNotifications,
    this.onOpenSearch,
  });
  final SettlementController vc;
  final SettlementData data;
  final ValueChanged<NavTab>? onSelectTab;
  final VoidCallback? onOpenNotifications;
  final VoidCallback? onOpenSearch;

  @override
  State<_SettlementOpenView> createState() => _SettlementOpenViewState();
}

class _SettlementOpenViewState extends State<_SettlementOpenView> {
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
    final data = widget.data;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: onSelectTab == null,
        child: Column(
          children: [
            // Shell tab: unified header on top, the date/branch + status pill
            // become a transparent sub-head. Standalone: keep back + fade.
            if (onSelectTab != null) ...[
              AppHeader(
                onSearch: widget.onOpenSearch,
                onOpenNotifications: widget.onOpenNotifications,
              ),
              _SettlementHeader(data: data, showBack: false, scrolled: false),
            ] else
              ValueListenableBuilder<bool>(
                valueListenable: _scrolled,
                builder: (_, scrolled, _) => _SettlementHeader(
                  data: data,
                  showBack: true,
                  scrolled: scrolled,
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scroll,
                padding: EdgeInsetsDirectional.only(
                  start: AppPadding.pW20,
                  end: AppPadding.pW20,
                  top: AppPadding.pH8,
                  bottom: AppPadding.pH24,
                ),
                child: ValueListenableBuilder<bool>(
                  valueListenable: widget.vc.showBreakdown,
                  builder: (_, breakdown, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _CashInHandCard(data: data, showBreakdown: breakdown),
                      12.szH,
                      // The money above, what produced it right beneath.
                      _DayTotals(data: data),
                      20.szH,
                      _BatchesSection(data: data),
                      // The parcels also going back to the branch — settling
                      // is one act, cash and returns together.
                      const _ReturnsSection(),
                      16.szH,
                      const _LockedNote(),
                      24.szH,
                      const _HistorySection(),
                    ],
                  ),
                ),
              ),
            ),
            if (onSelectTab != null)
              BottomNav(active: NavTab.settlement, onTap: onSelectTab),
          ],
        ),
      ),
    );
  }
}

/// White header: back button (standalone only), title (standalone only) +
/// the date · branch subtitle, and the status pill. Transparent at the top of
/// the scroll and fades in its surface background + hairline once scrolled.
class _SettlementHeader extends StatelessWidget {
  const _SettlementHeader({
    required this.data,
    this.showBack = true,
    this.scrolled = false,
  });

  final SettlementData data;

  /// Standalone mode: shows the back button + the big page-name title. Hidden
  /// when Settlement is a shell tab (a root tab has nowhere to go back, and the
  /// tab bar already names the page).
  final bool showBack;

  /// True once the page has scrolled under the header — the header then fades
  /// in its surface background + hairline (transparent while at the top).
  final bool scrolled;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        // Fade the SAME white in/out (transparent-white, never transparent-
        // black) so the transition never flashes a dark tint.
        color: AppColors.surface.withValues(alpha: scrolled ? 1 : 0),
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderHeader.withValues(alpha: scrolled ? 1 : 0),
          ),
        ),
      ),
      child:
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (showBack) ...[const HeaderBackButton(), 12.szW],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showBack) ...[
                      Text(
                        LocaleKeys.settlementTitle.tr(),
                        style: const TextStyle().setSecondaryColor.s12.medium,
                      ),
                      4.szH,
                    ],
                    Text(
                      LocaleKeys.settlementSubtitle.tr(
                        namedArgs: {
                          'date': data.dateLabel,
                          'branch': data.branch,
                        },
                      ),
                      style: const TextStyle().setMainTextColor.s14.semiBold,
                    ),
                  ],
                ),
              ),
              12.szW,
              _StatusPill(status: data.status),
            ],
          ).paddingOnlyDirectional(
            start: AppPadding.pW20,
            end: AppPadding.pW20,
            top: AppPadding.pH12,
            bottom: AppPadding.pH16,
          ),
    );
  }
}

/// The day's standing: amber «غير مُسوّاة» while delivering, blue «بانتظار
/// التسوية» once the courier is expected back, grey «مُسوّاة» when the branch
/// has taken the cash. Grey, not green — settlement is closure, not success.
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final SettlementStatus status;

  @override
  Widget build(BuildContext context) {
    final (String text, Color bg, Color fg) = switch (status) {
      SettlementStatus.open => (
        LocaleKeys.settlementNotSettled.tr(),
        AppColors.heroCodPillBg,
        AppColors.postponedText,
      ),
      SettlementStatus.awaiting => (
        LocaleKeys.settlementAwaiting.tr(),
        AppColors.transitPillBg,
        AppColors.transitBg,
      ),
      SettlementStatus.settled => (
        LocaleKeys.settlementSettledPill.tr(),
        AppColors.surfaceMuted,
        AppColors.textSecondary,
      ),
    };
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppCircular.r8),
      ),
      child: Text(
        text,
        style: const TextStyle().setColor(fg).s12.semiBold,
      ).paddingSymmetric(horizontal: AppPadding.pW8, vertical: AppPadding.pH4),
    );
  }
}

/// Who settled and when — shown under the cash card on a settled day.
class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({required this.data});
  final SettlementData data;

  @override
  Widget build(BuildContext context) {
    final at = data.settledAt;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppCircular.r16),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SummaryRow(
            icon: AppAssets.svg.user,
            label: LocaleKeys.settlementSummaryCashier.tr(),
            value: data.cashierName,
          ),
          if (at != null) ...[
            12.szH,
            _SummaryRow(
              icon: AppAssets.svg.clock,
              label: LocaleKeys.settlementSummaryTime.tr(),
              value: formatClockArabic(at),
            ),
          ],
        ],
      ).paddingAll(AppPadding.pW16),
    );
  }
}

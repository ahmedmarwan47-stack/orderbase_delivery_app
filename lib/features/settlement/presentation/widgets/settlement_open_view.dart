part of '../imports/settlement_imports.dart';

final ScrollController _tmpVerify = ScrollController(); // TEMP-VERIFY

/// State A — OPEN / AWAITING: one pinned bar + scrolling paper body (the day
/// sub-head, the cash card, the day's batches, returns handover, the locked
/// note, the last seven days) + bottom nav. There is no settle button: the
/// status pill in the sub-head says where the day stands, and the branch
/// moves it.
class _SettlementOpenView extends StatelessWidget {
  const _SettlementOpenView({
    required this.vc,
    required this.data,
    this.onSelectTab,
    this.onOpenNotifications,
    this.onOpenSearch,
    this.hostsTabBar = true,
  });
  final SettlementController vc;
  final SettlementData data;
  final ValueChanged<NavTab>? onSelectTab;
  final VoidCallback? onOpenNotifications;
  final VoidCallback? onOpenSearch;
  final bool hostsTabBar;

  @override
  Widget build(BuildContext context) {
    final onSelectTab = this.onSelectTab;
    final isTab = onSelectTab != null;
    final Widget body =
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SettlementHeader(data: data),
            ValueListenableBuilder<bool>(
              valueListenable: vc.showBreakdown,
              builder: (_, breakdown, _) =>
                  _CashInHandCard(data: data, showBreakdown: breakdown),
            ),
            12.szH,
            // The money above, what produced it right beneath.
            _BatchesSection(data: data),
            // The parcels also going back to the branch — settling is one act,
            // cash and returns together.
            const _ReturnsSection(),
            24.szH,
            const _HistorySection(),
          ],
        ).paddingOnlyDirectional(
          start: AppPadding.pW20,
          end: AppPadding.pW20,
          top: AppPadding.pH12,
          bottom: isTab ? BottomNav.reservedHeight(context) : AppPadding.pH24,
        );

    Future.delayed(const Duration(seconds: 3), () {
      // TEMP-VERIFY
      if (_tmpVerify.hasClients) _tmpVerify.jumpTo(160);
    });
    final Widget scroll = CustomScrollView(
      controller: _tmpVerify, // TEMP-VERIFY
      slivers: [
        // Exactly ONE pinned bar per mode: the collapsing page title as a
        // shell tab, the back bar when pushed. Everything else — the day's
        // identity included — belongs to the scroll.
        if (isTab)
          AppHeaderSliver(
            title: LocaleKeys.navSettlement.tr(),
            onSearch: onOpenSearch,
            onOpenNotifications: onOpenNotifications,
          ),
        SliverToBoxAdapter(child: body),
      ],
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: isTab,
      bottomNavigationBar: isTab && hostsTabBar
          ? BottomNav(active: NavTab.settlement, onTap: onSelectTab)
          : null,
      body: SafeArea(
        // As a tab the header sliver carries the top inset (the page passes
        // under the status bar, so the scroll-edge blur runs to the top of
        // the screen); pushed, the back bar needs it here.
        top: !isTab,
        bottom: !isTab,
        child: isTab
            ? scroll
            : Column(
                children: [
                  const _SettlementBackBar(),
                  Expanded(child: scroll),
                ],
              ),
      ),
    );
  }
}

/// The pinned bar for the pushed settlement pages — back button + page name,
/// matching the order-detail and returns headers. It is the only part of the
/// old header that may not scroll: everything else on this page is a fact to
/// read, this is the way out.
class _SettlementBackBar extends StatelessWidget {
  const _SettlementBackBar();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.borderHeader)),
      ),
      child:
          Row(
            children: [
              const HeaderBackButton(),
              12.szW,
              Expanded(
                child: Text(
                  LocaleKeys.settlementTitle.tr(),
                  style: const TextStyle().setMainTextColor.s14.semiBold,
                ),
              ),
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

/// The day's identity — «date · branch» and the status pill — as the first
/// thing in the scroll, not a bar above it. It states a fact about the day
/// rather than offering a control, so it has no claim on the viewport of a
/// page that is a long reconciliation list. It draws no band of its own and
/// carries no side padding: it lives inside the scroll view's own gutters.
class _SettlementHeader extends StatelessWidget {
  const _SettlementHeader({required this.data});

  final SettlementData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            LocaleKeys.settlementSubtitle.tr(
              namedArgs: {'date': data.dateLabel, 'branch': data.branch},
            ),
            style: const TextStyle().setMainTextColor.s14.semiBold,
          ),
        ),
        12.szW,
      ],
    ).paddingOnly(bottom: AppPadding.pH16);
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

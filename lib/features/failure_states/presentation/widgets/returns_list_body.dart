part of '../imports/failure_states_imports.dart';

/// Body of the returns list (1g): header + filter chips, the dark "returns to
/// branch" banner (the orders you actually returned via the failure flow), the
/// order cards, and the bottom nav. All driven by [ShiftController].
class _ReturnsListBody extends StatefulWidget {
  const _ReturnsListBody();

  @override
  State<_ReturnsListBody> createState() => _ReturnsListBodyState();
}

class _ReturnsListBodyState extends State<_ReturnsListBody> {
  final ScrollController _scroll = ScrollController();

  // The header is transparent at the top and gains its surface background once
  // the list scrolls beneath it (iOS large-title behaviour).
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
    return AnimatedBuilder(
      animation: ShiftController.instance,
      builder: (_, _) {
        final shift = ShiftController.instance;
        final returns = shift.returns;
        final orders = shift.orders;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: _scrolled,
              builder: (_, scrolled, _) =>
                  _ReturnsHeader(count: orders.length, scrolled: scrolled),
            ),
            Expanded(
              child: ListView.separated(
                controller: _scroll,
                padding: EdgeInsets.symmetric(
                  horizontal: AppPadding.pW20,
                  vertical: AppPadding.pH16,
                ),
                itemCount: orders.length + (returns.isNotEmpty ? 1 : 0),
                separatorBuilder: (_, _) => 12.szH,
                itemBuilder: (_, i) {
                  if (returns.isNotEmpty && i == 0) {
                    return _ReturnsBanner(returns: returns);
                  }
                  final order = orders[i - (returns.isNotEmpty ? 1 : 0)];
                  return _OrderMiniCard(order: order);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ReturnsHeader extends StatelessWidget {
  const _ReturnsHeader({required this.count, this.scrolled = false});
  final int count;

  /// True once the list has scrolled under the header — the header then fades
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
      padding: EdgeInsets.only(
        left: AppPadding.pW20,
        right: AppPadding.pW20,
        top: AppPadding.pH8,
        bottom: AppPadding.pH16,
      ),
      child: Row(
        children: [
          const HeaderBackButton(),
          12.szW,
          Text(LocaleKeys.failureOrders.tr(),
              style: const TextStyle().setMainTextColor.s20.extraBold),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppCircular.r8),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: AppPadding.pW12,
              vertical: AppPadding.pH4,
            ),
            child: Text('$count',
                style: const TextStyle().setSecondaryColor.s12.bold.tabular),
          ),
        ],
      ),
    );
  }
}

/// The dark "returns to branch" summary — one row per returned order.
class _ReturnsBanner extends StatelessWidget {
  const _ReturnsBanner({required this.returns});
  final List<Order> returns;

  @override
  Widget build(BuildContext context) {
    final totalPieces = returns.fold(0, (sum, o) => sum + o.pieces);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.paymentCardBg,
        borderRadius: BorderRadius.circular(AppCircular.r16),
      ),
      padding: EdgeInsets.all(AppPadding.pH16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconWidget(
                icon: FailureIcons.box,
                color: AppColors.surface,
                height: AppSize.sH20,
                width: AppSize.sW20,
              ),
              12.szW,
              Expanded(
                child: Text(LocaleKeys.failureReturnsToBranch.tr(),
                    style: const TextStyle().setWhite.s14.bold),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppCircular.r8),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: AppPadding.pW8,
                  vertical: AppPadding.pH4,
                ),
                child: Text('$totalPieces قطعة',
                    style: const TextStyle().setMainTextColor.s12.bold),
              ),
            ],
          ),
          for (final o in returns) ...[
            12.szH,
            _ReturnItemRow(
              orderNum: o.num,
              reason: o.reason ?? LocaleKeys.failureReasonOther.tr(),
              pieces: '${o.pieces} قطعة',
            ),
          ],
          12.szH,
          _OutlineButton(
            label: LocaleKeys.failureHandReturns.tr(),
            height: AppSize.sH48,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _ReturnItemRow extends StatelessWidget {
  const _ReturnItemRow({
    required this.orderNum,
    required this.reason,
    required this.pieces,
  });
  final String orderNum;
  final String reason;
  final String pieces;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCardRowBg,
        borderRadius: BorderRadius.circular(AppCircular.r12),
      ),
      padding: EdgeInsets.all(AppPadding.pH12),
      child: Row(
        children: [
          Text(
            orderNum,
            textDirection: TextDirection.ltr,
            style: const TextStyle().setWhite.s14.extraBold,
          ),
          12.szW,
          Expanded(
            child: Text(
              reason,
              style: const TextStyle().setColor(AppColors.mutedOnDark).s12.regular,
            ),
          ),
          Text(pieces, style: const TextStyle().setWhite.s12.bold),
        ],
      ),
    );
  }
}

/// A compact order row on the returns screen — status tile + number + pill +
/// customer/area, derived from the order's live status.
class _OrderMiniCard extends StatelessWidget {
  const _OrderMiniCard({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final (String icon, Color tileBg, Color tileIcon, String pillLabel,
            Color pillBg, Color pillFg) =
        switch (order.status) {
      OrderStatus.transit => (
          FailureIcons.nav,
          AppColors.transitPillBg,
          AppColors.transitBg,
          LocaleKeys.failureStatusInTransit.tr(),
          AppColors.transitPillBg,
          AppColors.transitBg,
        ),
      OrderStatus.postponed => (
          FailureIcons.clock,
          AppColors.heroCodPillBg,
          AppColors.postponedText,
          LocaleKeys.filterPostponed.tr(),
          AppColors.heroCodPillBg,
          AppColors.postponedText,
        ),
      OrderStatus.delivered => (
          FailureIcons.wallet,
          AppColors.deliveredBg,
          AppColors.deliveredText,
          LocaleKeys.failureStatusDelivered.tr(),
          AppColors.deliveredBg,
          AppColors.deliveredText,
        ),
      OrderStatus.failed => (
          FailureIcons.box,
          AppColors.failedBg,
          AppColors.failedText,
          LocaleKeys.failureStatusCouldNotDeliver.tr(),
          AppColors.failedBg,
          AppColors.failedText,
        ),
    };
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppCircular.r16),
        border: Border.all(color: AppColors.borderCardFaint),
      ),
      padding: EdgeInsets.all(AppPadding.pH16),
      child: Row(
        children: [
          Container(
            width: AppSize.sW40,
            height: AppSize.sH40,
            decoration: BoxDecoration(
              color: tileBg,
              borderRadius: BorderRadius.circular(AppCircular.r12),
            ),
            child: Center(
              child: IconWidget(
                icon: icon,
                color: tileIcon,
                height: AppSize.sH20,
                width: AppSize.sW20,
              ),
            ),
          ),
          12.szW,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      order.num,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle().setMainTextColor.s16.extraBold,
                    ),
                    8.szW,
                    _StatusPill(label: pillLabel, bg: pillBg, fg: pillFg),
                  ],
                ),
                4.szH,
                Text('${order.name} · ${order.area}',
                    style: const TextStyle().setSecondaryColor.s12.regular),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

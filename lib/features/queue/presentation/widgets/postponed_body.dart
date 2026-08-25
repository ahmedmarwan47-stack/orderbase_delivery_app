part of '../imports/queue_imports.dart';

/// Layout for the postponed list (1e): header + info banner + cards + nav.
///
/// Owns the scroll-reactive header state: the header is transparent while the
/// list is pinned at the top and fades in its surface + hairline once content
/// scrolls beneath it (matching the Home / browse-header behaviour).
class _PostponedBody extends StatefulWidget {
  const _PostponedBody({required this.orders, required this.onReturn});
  final ValueNotifier<List<Order>> orders;
  final void Function(Order) onReturn;

  @override
  State<_PostponedBody> createState() => _PostponedBodyState();
}

class _PostponedBodyState extends State<_PostponedBody> {
  final ScrollController _scroll = ScrollController();
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
    return ValueListenableBuilder<List<Order>>(
      valueListenable: widget.orders,
      builder: (context, list, _) => Column(
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: _scrolled,
            builder: (_, scrolled, _) =>
                _PostponedHeader(count: list.length, scrolled: scrolled),
          ),
          Expanded(
            child: _AnimatedPostponedList(
              orders: list,
              onReturn: widget.onReturn,
              reduced: AppMotion.reduced(context),
              scrollController: _scroll,
            ),
          ),
          const BottomNav(active: NavTab.orders, notificationsBadge: true),
        ],
      ),
    );
  }
}

/// The postponed cards, where returning an order to the queue collapses its row
/// on-screen (reusing [_CollapsibleRow]) instead of the card just vanishing —
/// this is the one place a stop leaves a *visible* list, so the row-departure
/// motion lands here. Rows are keyed by order number and diffed on update; a
/// returned order lingers marked `removing` until its collapse finishes, then is
/// pruned. Instant under Reduce Motion.
class _AnimatedPostponedList extends StatefulWidget {
  const _AnimatedPostponedList({
    required this.orders,
    required this.onReturn,
    required this.reduced,
    this.scrollController,
  });

  final List<Order> orders;
  final void Function(Order) onReturn;
  final bool reduced;

  /// Optional external controller (the standalone [PostponedScreen] passes one
  /// to drive its scroll-reactive header). Null for the inline postponed filter,
  /// which keeps its own default scrollable.
  final ScrollController? scrollController;

  @override
  State<_AnimatedPostponedList> createState() => _AnimatedPostponedListState();
}

class _AnimatedPostponedListState extends State<_AnimatedPostponedList> {
  final List<_QueueRow> _rows = [];

  @override
  void initState() {
    super.initState();
    _rows.addAll(widget.orders.map((o) => _QueueRow(o)));
  }

  @override
  void didUpdateWidget(covariant _AnimatedPostponedList old) {
    super.didUpdateWidget(old);
    final incoming = {for (final o in widget.orders) o.num: o};
    final seen = <String>{};
    final next = <_QueueRow>[];
    for (final row in _rows) {
      final fresh = incoming[row.order.num];
      if (fresh != null) {
        next.add(_QueueRow(fresh));
        seen.add(fresh.num);
      } else if (!widget.reduced) {
        next.add(_QueueRow(row.order, removing: true));
      }
    }
    for (final o in widget.orders) {
      if (!seen.contains(o.num)) next.add(_QueueRow(o));
    }
    _rows
      ..clear()
      ..addAll(next);
  }

  void _prune(String orderNum) {
    if (!mounted) return;
    setState(
      () => _rows.removeWhere((r) => r.removing && r.order.num == orderNum),
    );
  }

  @override
  Widget build(BuildContext context) {
    final duration = widget.reduced ? Duration.zero : AppMotion.fill;
    // Same flat-list treatment as the main queue: rows edge to edge on the page,
    // hairlines instead of card outlines. The advisory banner keeps its own
    // shape — it is a note, not an order.
    return ListView(
      controller: widget.scrollController,
      padding: EdgeInsetsDirectional.only(bottom: AppPadding.pH20),
      children: [
        const _PostponedInfoBanner().paddingSymmetric(
          horizontal: AppPadding.pW20,
          vertical: AppPadding.pH16,
        ),
        for (final (i, row) in _rows.indexed)
          _CollapsibleRow(
            key: ValueKey(row.order.num),
            removing: row.removing,
            duration: duration,
            onRemoved: () => _prune(row.order.num),
            // A row that's collapsing away shouldn't take another tap.
            child: IgnorePointer(
              ignoring: row.removing,
              child: _PostponedCard(
                order: row.order,
                last: i == _rows.length - 1,
                onReturn: () => widget.onReturn(row.order),
              ),
            ),
          ),
      ],
    );
  }
}

/// Header — a back button leading the title + count subtitle. Transparent while
/// pinned, fading in its surface + hairline once the list scrolls beneath it.
class _PostponedHeader extends StatelessWidget {
  const _PostponedHeader({required this.count, this.scrolled = false});
  final int count;

  /// True once the postponed list has scrolled under the header.
  final bool scrolled;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
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
              const HeaderBackButton(),
              12.szW,
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.postponedTitle.tr(),
                      style: const TextStyle().setMainTextColor.s14.semiBold,
                    ),
                    4.szH,
                    Text(
                      LocaleKeys.postponedSubtitle.tr(
                        namedArgs: {'count': arabicDigits(count)},
                      ),
                      style: const TextStyle().setSecondaryColor.s12.medium,
                    ),
                  ],
                ),
              ),
            ],
          ).paddingOnlyDirectional(
            start: AppPadding.pW20,
            end: AppPadding.pW20,
            top: AppPadding.pH8,
            bottom: AppPadding.pH16,
          ),
    );
  }
}

/// Amber explainer banner at the top of the postponed list.
class _PostponedInfoBanner extends StatelessWidget {
  const _PostponedInfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.postponedBannerBg,
        borderRadius: BorderRadius.circular(AppCircular.r16),
        border: Border.all(color: AppColors.postponedBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconWidget(
            icon: AppAssets.svg.clock,
            color: AppColors.postponedText,
            height: AppSize.sH18,
            width: AppSize.sW18,
          ).paddingOnly(top: AppPadding.pH4),
          12.szW,
          Expanded(
            child: Text(
              LocaleKeys.postponedBanner.tr(),
              style: const TextStyle()
                  .setColor(AppColors.postponedTextStrong)
                  .s12
                  .regular
                  .withHeight(1.5),
            ),
          ),
        ],
      ).paddingAll(AppPadding.pH16),
    );
  }
}

part of '../imports/queue_imports.dart';

/// Layout for the postponed list (1e): header + info banner + cards + nav.
class _PostponedBody extends StatelessWidget {
  const _PostponedBody({required this.orders, required this.onReturn});
  final ValueNotifier<List<Order>> orders;
  final void Function(Order) onReturn;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Order>>(
      valueListenable: orders,
      builder: (context, list, _) => Column(
        children: [
          _PostponedHeader(count: list.length),
          Expanded(
            child: _AnimatedPostponedList(
              orders: list,
              onReturn: onReturn,
              reduced: AppMotion.reduced(context),
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
  });

  final List<Order> orders;
  final void Function(Order) onReturn;
  final bool reduced;

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
    setState(() =>
        _rows.removeWhere((r) => r.removing && r.order.num == orderNum));
  }

  @override
  Widget build(BuildContext context) {
    final duration = widget.reduced ? Duration.zero : AppMotion.fill;
    return ListView(
      padding: EdgeInsetsDirectional.only(
        start: AppPadding.pW20,
        end: AppPadding.pW20,
        top: AppPadding.pH16,
        bottom: AppPadding.pH20,
      ),
      children: [
        const _PostponedInfoBanner(),
        for (final row in _rows)
          _CollapsibleRow(
            key: ValueKey(row.order.num),
            removing: row.removing,
            duration: duration,
            onRemoved: () => _prune(row.order.num),
            child: Padding(
              padding: EdgeInsetsDirectional.only(top: AppPadding.pH12),
              // A row that's collapsing away shouldn't take another tap.
              child: IgnorePointer(
                ignoring: row.removing,
                child: _PostponedCard(
                  order: row.order,
                  onReturn: () => widget.onReturn(row.order),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// White header — back to orders, title, count subtitle.
class _PostponedHeader extends StatelessWidget {
  const _PostponedHeader({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.borderHeader)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconWidget(
                icon: AppAssets.svg.chevronRight,
                color: AppColors.textTertiary,
                height: AppSize.sH18,
                width: AppSize.sW18,
              ),
              8.szW,
              Text(LocaleKeys.backToOrders.tr(),
                  style: const TextStyle().setTertiaryColor.s14.semiBold),
            ],
          ).paddingSymmetric(vertical: AppPadding.pH8).onClick(onTap: () => Modular.to.pop()),
          Text(LocaleKeys.postponedTitle.tr(),
              style: const TextStyle().setMainTextColor.s20.extraBold),
          4.szH,
          Text(
            LocaleKeys.postponedSubtitle
                .tr(namedArgs: {'count': arabicDigits(count)}),
            style: const TextStyle().setSecondaryColor.s14.regular,
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

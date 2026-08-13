part of '../imports/queue_imports.dart';

/// Layout only — adaptive header + body + footer, switching on search vs browse.
class _QueueBody extends StatelessWidget {
  const _QueueBody({required this.vc});
  final QueueViewController vc;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: vc.isSearching,
      builder: (_, searching, _) => Column(
        children: [
          searching ? _QueueSearchHeader(vc: vc) : _QueueBrowseHeader(vc: vc),
          Expanded(
            child:
                searching ? _QueueSearchResults(vc: vc) : _QueueBrowseList(vc: vc),
          ),
          if (searching)
            const HomeIndicator()
          else
            BottomNav(
              active: NavTab.orders,
              notificationsBadge: true,
              onTap: vc.onSelectTab,
            ),
        ],
      ),
    );
  }
}

/// Browsing (1b): filtered list, or the cleared empty state (1d) when empty.
///
/// State changes are made legible with motion (all Reduce-Motion-safe):
///  * **Filter cross-fade (#5)** — swapping the active filter (or crossing to
///    the empty state) cross-fades between sets via an [AnimatedSwitcher] keyed
///    by the filter + empty-ness, instead of a hard cut.
///  * **Row removal (#4)** — when an order leaves the *current* filter (e.g. it
///    gets delivered while "في الطريق" is active) its row collapses + fades out
///    via [_AnimatedQueueList], so the list settles instead of jumping.
class _QueueBrowseList extends StatelessWidget {
  const _QueueBrowseList({required this.vc});
  final QueueViewController vc;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<QueueFilter>(
      valueListenable: vc.filter,
      builder: (context, filter, _) {
        final reduced = AppMotion.reduced(context);
        final items = vc.filtered;
        final showBar = filter != QueueFilter.all;

        final Widget content = items.isEmpty
            ? _QueueClearState(vc: vc)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showBar)
                    _FilterResultsBar(vc: vc, filter: filter, count: items.length)
                        .paddingOnly(top: AppPadding.pH16, bottom: AppPadding.pH12),
                  Expanded(
                    child: _AnimatedQueueList(
                      orders: items,
                      vc: vc,
                      reduced: reduced,
                      padding: EdgeInsetsDirectional.only(
                        start: AppPadding.pW20,
                        end: AppPadding.pW20,
                        top: showBar ? 0 : AppPadding.pH16,
                        bottom: AppPadding.pH20,
                      ),
                    ),
                  ),
                ],
              );

        return AnimatedSwitcher(
          duration: reduced ? Duration.zero : AppMotion.fill,
          switchInCurve: AppMotion.ease,
          switchOutCurve: AppMotion.ease,
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          // Same filter + same empty-ness ⇒ same key ⇒ AnimatedSwitcher updates
          // in place (no cross-fade), letting _AnimatedQueueList animate the row
          // that left. A different filter, or crossing to/from empty, cross-fades.
          child: KeyedSubtree(
            key: ValueKey('${filter.name}:${items.isEmpty}'),
            child: content,
          ),
        );
      },
    );
  }
}

/// One display row in [_AnimatedQueueList] — the live [Order] plus whether it's
/// currently collapsing out (it left the filter but hasn't finished animating).
class _QueueRow {
  const _QueueRow(this.order, {this.removing = false});
  final Order order;
  final bool removing;
}

/// A robust, implicit animated list: rows are keyed by the stable order number,
/// so it can never desync the way raw [AnimatedList] index bookkeeping can.
///
/// When an order disappears from [orders] its row is kept in place, marked
/// [_QueueRow.removing], and [_CollapsibleRow] collapses + fades it before it's
/// pruned. Under Reduce Motion departures are dropped instantly (no tracking).
class _AnimatedQueueList extends StatefulWidget {
  const _AnimatedQueueList({
    required this.orders,
    required this.vc,
    required this.padding,
    required this.reduced,
  });

  final List<Order> orders;
  final QueueViewController vc;
  final EdgeInsetsGeometry padding;
  final bool reduced;

  @override
  State<_AnimatedQueueList> createState() => _AnimatedQueueListState();
}

class _AnimatedQueueListState extends State<_AnimatedQueueList> {
  /// Rows in visual order. Departed rows linger here (removing: true) until
  /// their collapse finishes and [_prune] drops them.
  final List<_QueueRow> _rows = [];

  @override
  void initState() {
    super.initState();
    _rows.addAll(widget.orders.map((o) => _QueueRow(o)));
  }

  @override
  void didUpdateWidget(covariant _AnimatedQueueList old) {
    super.didUpdateWidget(old);
    _sync();
  }

  /// Diff [widget.orders] against the current display order by order number:
  /// survivors keep their slot (with refreshed data), departures stay put and
  /// start collapsing, genuine new arrivals are appended.
  void _sync() {
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
      // Reduce Motion: skip departed rows entirely (instant removal).
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

  /// Pull-to-refresh re-checks today's orders. The queue reads live, in-memory
  /// shift state, so there's nothing to fetch yet — the gesture re-reads and
  /// settles; it becomes a real sync when the data layer goes async.
  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final duration = widget.reduced ? Duration.zero : AppMotion.fill;
    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppColors.brand,
      backgroundColor: AppColors.surface,
      child: ListView(
        // Always scrollable so the pull works even with a short list.
        physics: const AlwaysScrollableScrollPhysics(),
        padding: widget.padding,
        children: [
          for (final row in _rows)
            _CollapsibleRow(
              key: ValueKey(row.order.num),
              removing: row.removing,
              duration: duration,
              onRemoved: () => _prune(row.order.num),
              child: Padding(
                padding: EdgeInsetsDirectional.only(bottom: AppPadding.pH12),
                child: _QueueCard(
                  order: row.order,
                  onTap: () => widget.vc.openOrder(context, row.order),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Wraps a row so removal reads as a collapse + fade rather than a jump. Driven
/// by one implicit [TweenAnimationBuilder] value (1 → 0 when removing) that both
/// scales the height (via [Align.heightFactor]) and fades the content; [onEnd]
/// prunes the row once it's gone. Duration is [Duration.zero] under Reduce
/// Motion, so it collapses instantly.
class _CollapsibleRow extends StatelessWidget {
  const _CollapsibleRow({
    super.key,
    required this.removing,
    required this.duration,
    required this.onRemoved,
    required this.child,
  });

  final bool removing;
  final Duration duration;
  final VoidCallback onRemoved;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1, end: removing ? 0 : 1),
      duration: duration,
      curve: AppMotion.ease,
      onEnd: removing ? onRemoved : null,
      child: child,
      builder: (context, t, child) {
        final v = t.clamp(0.0, 1.0);
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: v,
            child: Opacity(opacity: v, child: child),
          ),
        );
      },
    );
  }
}

/// Searching (1a / 1c): live results, no-results, or the empty prompt.
class _QueueSearchResults extends StatelessWidget {
  const _QueueSearchResults({required this.vc});
  final QueueViewController vc;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: vc.query,
      builder: (_, query, _) {
        if (query.trim().isEmpty) return const _QueueSearchPrompt();
        final matches = vc.searchMatches;
        if (matches.isEmpty) return _QueueNoResults(vc: vc, query: query);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SearchResultsCountBar(count: matches.length, total: vc.orders.length)
                .paddingOnly(top: AppPadding.pH16, bottom: AppPadding.pH12),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsetsDirectional.only(
                  start: AppPadding.pW20,
                  end: AppPadding.pW20,
                  bottom: AppPadding.pH20,
                ),
                itemCount: matches.length,
                separatorBuilder: (_, _) => 12.szH,
                itemBuilder: (context, i) => _SearchResultCard(
                  order: matches[i],
                  query: query,
                  reasonKey: vc.matchKey(matches[i]),
                  onTap: () => vc.openOrder(context, matches[i]),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// "N results of M orders · sorted by nearest delivery time".
class _SearchResultsCountBar extends StatelessWidget {
  const _SearchResultsCountBar({required this.count, required this.total});
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          LocaleKeys.searchResultsCount.tr(
            namedArgs: {'count': arabicDigits(count), 'total': arabicDigits(total)},
          ),
          style: const TextStyle().setSecondaryColor.s12.bold,
        ),
        Text(
          LocaleKeys.searchSorted.tr(),
          style: const TextStyle().setHintColor.s12.regular,
        ),
      ],
    ).paddingSymmetric(horizontal: AppPadding.pW20);
  }
}

/// "N orders · `filter` · clear filter" (shown when a filter ≠ all is active).
class _FilterResultsBar extends StatelessWidget {
  const _FilterResultsBar({required this.vc, required this.filter, required this.count});
  final QueueViewController vc;
  final QueueFilter filter;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          LocaleKeys.filterResultsCount.tr(namedArgs: {
            'count': arabicDigits(count),
            'label': vc.filterLabelKey(filter).tr(),
          }),
          style: const TextStyle().setSecondaryColor.s12.bold,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconWidget(
              icon: AppAssets.svg.x,
              color: AppColors.dangerAccent,
              height: AppSize.sH14,
              width: AppSize.sW14,
            ),
            4.szW,
            Text(
              LocaleKeys.clearFilter.tr(),
              style: const TextStyle().setColor(AppColors.dangerAccent).s12.bold,
            ),
          ],
        ).onClick(onTap: vc.clearFilter),
      ],
    ).paddingSymmetric(horizontal: AppPadding.pW20);
  }
}

/// Western → Eastern-Arabic digits for counts shown in Arabic copy.
String arabicDigits(Object value) {
  const eastern = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  var s = value.toString();
  for (var i = 0; i < 10; i++) {
    s = s.replaceAll('$i', eastern[i]);
  }
  return s;
}

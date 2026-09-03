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
          // The unified app header (shift status + search + bell) tops every
          // page. In search mode the search bar takes over, so it's hidden then.
          if (!searching)
            AppHeader(
              onSearch: vc.openSearch,
              onOpenNotifications: vc.onOpenNotifications,
            ),
          searching ? _QueueSearchHeader(vc: vc) : _QueueBrowseHeader(vc: vc),
          Expanded(
            child: searching
                ? _QueueSearchResults(vc: vc)
                : _QueueBrowseList(vc: vc),
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

        // Postponed is filtered inline: the rich postponed cards (return time,
        // reason, "return to queue") render in place instead of a separate page.
        final Widget content;
        if (filter == QueueFilter.postponed) {
          content = items.isEmpty
              ? const _QueuePostponedEmpty()
              : _AnimatedPostponedList(
                  orders: items,
                  reduced: reduced,
                  onReturn: (o) {
                    vc.returnOrderToQueue(o);
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(
                            LocaleKeys.returnedToQueue.tr(
                              namedArgs: {'num': o.num},
                            ),
                          ),
                        ),
                      );
                  },
                );
        } else {
          final showBar = filter != QueueFilter.all;
          final groups = vc.batchGroups;
          content = groups.isEmpty
              ? _QueueClearState(vc: vc)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (showBar)
                      _FilterResultsBar(
                        vc: vc,
                        filter: filter,
                        count: items.length,
                      ).paddingOnly(
                        top: AppPadding.pH16,
                        bottom: AppPadding.pH12,
                      ),
                    Expanded(
                      // The day as batch sections. Rows carry their own side
                      // padding, so the list itself is edge to edge.
                      child: _QueueBatchList(groups: groups, vc: vc),
                    ),
                  ],
                );
        }

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
            _SearchResultsCountBar(
              count: matches.length,
              total: vc.orders.length,
            ).paddingOnly(top: AppPadding.pH16, bottom: AppPadding.pH12),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsetsDirectional.only(bottom: AppPadding.pH20),
                itemCount: matches.length,
                itemBuilder: (context, i) => _SearchResultCard(
                  order: matches[i],
                  query: query,
                  reasonKey: vc.matchKey(matches[i]),
                  last: i == matches.length - 1,
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
            namedArgs: {
              'count': arabicDigits(count),
              'total': arabicDigits(total),
            },
          ),
          style: const TextStyle().setSecondaryColor.s12.semiBold,
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
  const _FilterResultsBar({
    required this.vc,
    required this.filter,
    required this.count,
  });
  final QueueViewController vc;
  final QueueFilter filter;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          LocaleKeys.filterResultsCount.tr(
            namedArgs: {
              'count': arabicDigits(count),
              'label': vc.filterLabelKey(filter).tr(),
            },
          ),
          style: const TextStyle().setSecondaryColor.s12.semiBold,
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
              style: const TextStyle()
                  .setColor(AppColors.dangerAccent)
                  .s12
                  .semiBold,
            ),
          ],
        ).onClick(onTap: vc.clearFilter),
      ],
    ).paddingSymmetric(horizontal: AppPadding.pW20);
  }
}

/// Empty state for the postponed filter — no orders currently postponed.
class _QueuePostponedEmpty extends StatelessWidget {
  const _QueuePostponedEmpty();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: _EmptyBadge(
                  bg: AppColors.postponedBg,
                  icon: AppAssets.svg.clock,
                  iconColor: AppColors.postponedText,
                ),
              ),
              24.szH,
              Text(
                LocaleKeys.postponedEmptyTitle.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle().setMainTextColor.s20.bold,
              ),
              8.szH,
              Text(
                LocaleKeys.postponedEmptyDesc.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle().setSecondaryColor.s14.regular
                    .withHeight(1.5),
              ),
            ],
          ).paddingOnlyDirectional(
            start: AppPadding.pW32,
            end: AppPadding.pW32,
            top: AppPadding.pH64,
            bottom: AppPadding.pH24,
          ),
    );
  }
}

// arabicDigits moved to lib/data/order.dart (shared with the app header).

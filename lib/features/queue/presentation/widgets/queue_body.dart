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
            const BottomNav(active: NavTab.orders, notificationsBadge: true),
        ],
      ),
    );
  }
}

/// Browsing (1b): filtered list, or the cleared empty state (1d) when empty.
class _QueueBrowseList extends StatelessWidget {
  const _QueueBrowseList({required this.vc});
  final QueueViewController vc;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<QueueFilter>(
      valueListenable: vc.filter,
      builder: (_, filter, _) {
        final items = vc.filtered;
        if (items.isEmpty) return _QueueClearState(vc: vc);
        final showBar = filter != QueueFilter.all;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showBar)
              _FilterResultsBar(vc: vc, filter: filter, count: items.length)
                  .paddingOnly(top: AppPadding.pH16, bottom: AppPadding.pH12),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsetsDirectional.only(
                  start: AppPadding.pW20,
                  end: AppPadding.pW20,
                  top: showBar ? 0 : AppPadding.pH16,
                  bottom: AppPadding.pH20,
                ),
                itemCount: items.length,
                separatorBuilder: (_, _) => 12.szH,
                itemBuilder: (_, i) => _QueueCard(order: items[i], onTap: vc.openOrder),
              ),
            ),
          ],
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
        if (query.trim().isEmpty) {
          return Center(
            child: Text(
              LocaleKeys.searchPrompt.tr(),
              style: const TextStyle().setHintColor.s14.regular,
            ),
          );
        }
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
                itemBuilder: (_, i) => _SearchResultCard(
                  order: matches[i],
                  query: query,
                  reasonKey: vc.matchKey(matches[i]),
                  onTap: vc.openOrder,
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

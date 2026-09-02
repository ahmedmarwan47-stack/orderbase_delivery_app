part of '../imports/queue_imports.dart';

/// The flat row every Orders-tab list is built from.
///
/// The tab used to be a stack of rounded white cards floating on the page: a
/// box inside a box, with the screen's padding wrapped around each card's own
/// padding. A queue is a list, so it is drawn as one — rows run edge to edge
/// straight on the page and a hairline is all that separates them. No fill of
/// their own either: a white sheet under the rows was the card outline back
/// again, one size larger. That buys back ~40px of width per row and lets the
/// eye run straight down the column instead of stepping over eight outlines.
class _ListRow extends StatelessWidget {
  const _ListRow({required this.child, required this.last, this.onTap});

  final Widget child;

  /// Last row in its list — no trailing hairline, so the list ends cleanly.
  final bool last;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = DecoratedBox(
      decoration: BoxDecoration(
        border: last
            ? null
            // borderDefault, a shade darker than the header hairline: this rule
            // has to read on the warm page background, not on white.
            : const Border(bottom: BorderSide(color: AppColors.borderDefault)),
      ),
      child: child.paddingSymmetric(
        horizontal: AppPadding.pW20,
        vertical: AppPadding.pH16,
      ),
    );
    return onTap == null ? row : row.onClick(onTap: onTap);
  }
}

/// Merchant image tile (rounded, cover).
class _MerchantThumb extends StatelessWidget {
  const _MerchantThumb({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppCircular.r12),
        image: DecorationImage(
          image: AssetImage(AppAssets.img.fudgeCake),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

/// Search result card (1a) — compact, with a status badge, match tag, and the
/// matched query highlighted in the address.
class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({
    required this.order,
    required this.query,
    required this.reasonKey,
    required this.onTap,
    this.last = false,
  });
  final Order order;
  final String query;
  final String? reasonKey;
  final VoidCallback onTap;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final isTransit = order.status == OrderStatus.transit;
    return _ListRow(
      last: last,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: AppSize.sW8,
                  runSpacing: AppSize.sH8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      order.num,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle().setMainTextColor.s16.bold,
                    ),
                    // Match the main queue card: payment type only, no status
                    // pill — so no badge reappears when filtering/searching.
                    _PayLabel(prepaid: order.prepaid),
                  ],
                ),
              ),
              if (reasonKey != null) ...[
                8.szW,
                _MatchTag(labelKey: reasonKey!),
              ],
            ],
          ),
          8.szH,
          Text(
            order.name,
            style: const TextStyle().setMainTextColor.s18.semiBold,
          ),
          4.szH,
          _highlighted(
            LocaleKeys.addrArea.tr(
              namedArgs: {'addr': order.addr, 'area': order.area},
            ),
            query,
            const TextStyle().setHintColor.s14.regular.withHeight(1.5),
          ),
          if (isTransit && order.due != null) ...[
            12.szH,
            _PromisedCodRow(order: order),
          ] else if (order.status == OrderStatus.postponed) ...[
            8.szH,
            Text(
              LocaleKeys.outsideActive.tr(),
              style: const TextStyle()
                  .setColor(AppColors.postponedText)
                  .s12
                  .regular
                  .withHeight(1.5),
            ),
          ],
        ],
      ),
    );
  }

  Widget _highlighted(String text, String query, TextStyle base) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return Text(text, style: base);
    final lc = text.toLowerCase();
    final spans = <TextSpan>[];
    var i = 0;
    while (true) {
      final idx = lc.indexOf(q, i);
      if (idx < 0) {
        spans.add(TextSpan(text: text.substring(i)));
        break;
      }
      if (idx > i) spans.add(TextSpan(text: text.substring(i, idx)));
      spans.add(
        TextSpan(
          text: text.substring(idx, idx + q.length),
          style: base.copyWith(
            backgroundColor: AppColors.markBg,
            color: AppColors.markText,
          ),
        ),
      );
      i = idx + q.length;
    }
    return Text.rich(TextSpan(style: base, children: spans));
  }
}

/// Grey "why it matched" tag.
class _MatchTag extends StatelessWidget {
  const _MatchTag({required this.labelKey});
  final String labelKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppCircular.r8),
      ),
      child: Text(
        labelKey.tr(),
        style: const TextStyle().setSecondaryColor.s12.semiBold,
      ).paddingSymmetric(horizontal: AppPadding.pW8, vertical: AppPadding.pH4),
    );
  }
}

/// Promised-time + collect-amount divider row inside a transit result card.
class _PromisedCodRow extends StatelessWidget {
  const _PromisedCodRow({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.itemDivider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconWidget(
                icon: AppAssets.svg.clock,
                color: AppColors.textSecondary,
                height: AppSize.sH16,
                width: AppSize.sW16,
              ),
              8.szW,
              Text(
                LocaleKeys.promisedAt.tr(namedArgs: {'time': order.due ?? ''}),
                style: const TextStyle().setTertiaryColor.s12.semiBold,
              ),
            ],
          ),
          if (order.cod != null)
            Text(
              LocaleKeys.collectEgp.tr(
                namedArgs: {'amount': formatThousands(order.cod!)},
              ),
              style: const TextStyle()
                  .setColor(AppColors.failedText)
                  .s12
                  .semiBold,
            ),
        ],
      ).paddingOnly(top: AppPadding.pH12),
    );
  }
}

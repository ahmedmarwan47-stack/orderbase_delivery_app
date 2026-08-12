part of '../imports/queue_imports.dart';

/// Queue card (1b) — merchant thumb, number, pay/status, name, promised time,
/// area·distance, and a COD row when cash is due.
class _QueueCard extends StatelessWidget {
  const _QueueCard({required this.order, required this.onTap});
  final Order order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isTransit = order.status == OrderStatus.transit;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppCircular.r16),
        border: Border.all(color: AppColors.borderCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _MerchantThumb(size: AppSize.sH88),
              16.szW,
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
                        if (isTransit)
                          _PayLabel(prepaid: order.prepaid)
                        else
                          _StatusBadge(status: order.status, returns: order.returns),
                      ],
                    ),
                    4.szH,
                    Text(order.name, style: const TextStyle().setMainTextColor.s18.bold),
                    if (isTransit && order.due != null) ...[
                      4.szH,
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconWidget(
                            icon: AppAssets.svg.clock,
                            color: AppColors.textSecondary,
                            height: AppSize.sH14,
                            width: AppSize.sW14,
                          ),
                          4.szW,
                          Text(
                            LocaleKeys.promisedAt.tr(namedArgs: {'time': order.due!}),
                            style: const TextStyle().setTertiaryColor.s12.bold,
                          ),
                        ],
                      ),
                    ],
                    4.szH,
                    Text(
                      order.dist != null
                          ? LocaleKeys.areaDistance
                              .tr(namedArgs: {'area': order.area, 'dist': order.dist!})
                          : order.area,
                      style: const TextStyle().setHintColor.s14.regular,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (order.cod != null) ...[
            12.szH,
            _CodRow(amount: order.cod!),
          ],
        ],
      ).paddingAll(AppPadding.pH16),
    ).onClick(onTap: onTap);
  }
}

/// The "cash to collect" divider row.
class _CodRow extends StatelessWidget {
  const _CodRow({required this.amount});
  final int amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.itemDivider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(LocaleKeys.codRequired.tr(),
              style: const TextStyle().setSecondaryColor.s12.regular),
          Text(
            LocaleKeys.amountEgp.tr(namedArgs: {'amount': formatThousands(amount)}),
            style: const TextStyle().setMainTextColor.s16.extraBold.tabular,
          ),
        ],
      ).paddingOnly(top: AppPadding.pH12),
    );
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
  });
  final Order order;
  final String query;
  final String? reasonKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isTransit = order.status == OrderStatus.transit;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppCircular.r16),
        border: Border.all(color: AppColors.borderCard),
      ),
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
                      style: const TextStyle().setMainTextColor.s16.extraBold,
                    ),
                    _StatusBadge(status: order.status, returns: order.returns),
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
          Text(order.name, style: const TextStyle().setMainTextColor.s18.bold),
          4.szH,
          _highlighted(
            LocaleKeys.addrArea.tr(namedArgs: {'addr': order.addr, 'area': order.area}),
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
              style: const TextStyle().setColor(AppColors.postponedText).s12.regular.withHeight(1.7),
            ),
          ],
        ],
      ).paddingAll(AppPadding.pH16),
    ).onClick(onTap: onTap);
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
      spans.add(TextSpan(
        text: text.substring(idx, idx + q.length),
        style: base.copyWith(
            backgroundColor: AppColors.markBg, color: AppColors.markText),
      ));
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
      child: Text(labelKey.tr(), style: const TextStyle().setSecondaryColor.s12.bold)
          .paddingSymmetric(horizontal: AppPadding.pW8, vertical: AppPadding.pH4),
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
                style: const TextStyle().setTertiaryColor.s12.bold,
              ),
            ],
          ),
          if (order.cod != null)
            Text(
              LocaleKeys.collectEgp
                  .tr(namedArgs: {'amount': formatThousands(order.cod!)}),
              style: const TextStyle().setColor(AppColors.failedText).s12.bold,
            ),
        ],
      ).paddingOnly(top: AppPadding.pH12),
    );
  }
}

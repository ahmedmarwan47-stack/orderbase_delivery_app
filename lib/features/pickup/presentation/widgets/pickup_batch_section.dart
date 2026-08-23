part of '../imports/pickup_imports.dart';

/// One dispatched batch, as its own group: a label, what it holds, then the
/// orders as compact rows.
///
/// The Pickup tab is a view of *batches* — a courier can be holding several at
/// once — so a batch stays visibly one thing rather than dissolving into a flat
/// list where you cannot tell which orders arrived together.
class _PickupBatchSection extends StatelessWidget {
  const _PickupBatchSection({
    required this.batch,
    required this.index,
  });

  final OrderBatch batch;

  /// 1-based position, used for the "الدفعة ٢" label.
  final int index;

  @override
  Widget build(BuildContext context) {
    final orders = [...batch.orders]..sort((a, b) => a.num.compareTo(b.num));
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppCircular.r18),
        border: Border.all(color: AppColors.borderCardFaint),
      ),
      padding: EdgeInsetsDirectional.all(AppPadding.pW12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                LocaleKeys.pickupBatchLabel.tr(namedArgs: {'n': '$index'}),
                style: const TextStyle().setMainTextColor.s14.bold,
              ),
              const Spacer(),
              // Only the cash total is picked out — black and a step heavier —
              // so the figure reads at a glance while the words around it stay
              // quiet. Split on the substituted number so it works in either
              // locale without a second string.
              Builder(
                builder: (_) {
                  final cash = formatThousands(batch.codTotal);
                  final meta = LocaleKeys.pickupBatchMeta.tr(
                    namedArgs: {'count': '${batch.count}', 'cash': cash},
                  );
                  final at = meta.indexOf(cash);
                  final quiet = const TextStyle().setSecondaryColor.s12.regular;
                  if (at < 0) return Text(meta, style: quiet);
                  return Text.rich(
                    TextSpan(
                      style: quiet,
                      children: [
                        TextSpan(text: meta.substring(0, at)),
                        TextSpan(
                          text: cash,
                          style: const TextStyle()
                              .setColor(AppColors.flatBlack)
                              .s12
                              .semiBold,
                        ),
                        TextSpan(text: meta.substring(at + cash.length)),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          12.szH,
          for (final order in orders) ...[
            _PickupOrderRow(order: orderToFlow(order)),
            if (order != orders.last) 8.szH,
          ],
        ],
      ),
    );
  }
}

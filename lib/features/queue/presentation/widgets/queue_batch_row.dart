part of '../imports/queue_imports.dart';

/// One order inside a batch section — the batch row, one step richer than the
/// pickup version: number and cash pill (or the outcome badge once closed),
/// name · area · pieces, and the promised time while the order is still out.
/// Flat, like every list in the app: a hairline between rows, indented under
/// the batch header so the rows read as its children. Tapping opens the order.
class _QueueBatchRow extends StatelessWidget {
  const _QueueBatchRow({
    required this.order,
    required this.onTap,
    this.pending = false,
    this.last = false,
  });

  final Order order;
  final VoidCallback onTap;

  /// The order is still at the branch (its batch has not been carried).
  final bool pending;

  /// Last row of its batch — drops the trailing hairline.
  final bool last;

  @override
  Widget build(BuildContext context) {
    final isTransit = order.status == OrderStatus.transit;
    final meta = [
      order.name,
      order.area,
      if (order.pieces > 0)
        LocaleKeys.queuePieces.tr(
          namedArgs: {'count': arabicDigits(order.pieces)},
        ),
    ].join(' · ');

    final Widget row = Container(
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: AppColors.borderDefault)),
      ),
      padding: EdgeInsetsDirectional.only(
        start: AppPadding.pW32,
        end: AppPadding.pW20,
        top: AppPadding.pH12,
        bottom: AppPadding.pH12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                order.num,
                textDirection: TextDirection.ltr,
                style: const TextStyle().setMainTextColor.s14.bold.tabular,
              ),
              8.szW,
              // Payment while the order is out; its outcome once it is closed,
              // so a dimmed row says *why* it is dimmed.
              if (isTransit)
                _PayPillSmall(prepaid: order.prepaid, amount: order.cod)
              else
                _StatusBadge(status: order.status, returns: order.returns),
            ],
          ),
          4.szH,
          Text(
            meta,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle().setSecondaryColor.s12.regular,
          ),
          if (isTransit && !pending && order.due != null) ...[
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
                  style: const TextStyle().setTertiaryColor.s12.regular,
                ),
              ],
            ),
          ],
        ],
      ),
    );
    final tappable = row.onClick(onTap: onTap);
    // Closed orders are de-emphasised — the badge says why.
    return isTransit ? tappable : Opacity(opacity: 0.6, child: tappable);
  }
}

/// The filled cash / prepaid pill on a batch row — the figure alone on a COD
/// order (an amount can only mean cash on delivery), «مدفوع» on a prepaid one.
class _PayPillSmall extends StatelessWidget {
  const _PayPillSmall({required this.prepaid, this.amount});
  final bool prepaid;
  final int? amount;

  @override
  Widget build(BuildContext context) {
    final cod = !prepaid;
    final label = cod && amount != null
        ? LocaleKeys.amountEgp.tr(
            namedArgs: {'amount': formatThousands(amount!)},
          )
        : cod
        ? LocaleKeys.payCod.tr()
        : LocaleKeys.pickupPayPaid.tr();
    return Container(
      decoration: BoxDecoration(
        color: cod ? AppColors.heroCodPillBg : AppColors.deliveredBg,
        borderRadius: BorderRadius.circular(AppCircular.r7),
      ),
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: AppPadding.pW8,
        vertical: AppPadding.pH4,
      ),
      child: Text(
        label,
        style: const TextStyle()
            .setColor(cod ? AppColors.postponedText : AppColors.deliveredText)
            .s12
            .semiBold
            .tabular,
      ),
    );
  }
}

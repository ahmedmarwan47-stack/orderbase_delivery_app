part of '../imports/pickup_imports.dart';

/// One order as a compact row: number, pay pill, cash due, then name + area.
///
/// Shared deliberately — the dispatch sheet and the Pickup tab are both
/// "here is a batch waiting at the branch", so they show a batch the same way.
class _PickupOrderRow extends StatelessWidget {
  const _PickupOrderRow({required this.order});
  final FlowOrder order;

  @override
  Widget build(BuildContext context) {
    // Cash figure where there is one, the prepaid label where there is not —
    // the amount already says the order is cash on delivery.
    final payLabel = order.cod && order.amount != null
        ? LocaleKeys.amountEgp.tr(namedArgs: {'amount': order.amount!})
        : order.cod
        ? LocaleKeys.payCod.tr()
        : LocaleKeys.pickupPayPaid.tr();
    final payFg = order.cod ? AppColors.postponedText : AppColors.deliveredText;
    final payBg = order.cod ? AppColors.heroCodPillBg : AppColors.deliveredBg;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppCircular.r12),
      ),
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: AppPadding.pW12,
        vertical: AppPadding.pH8,
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
                style: const TextStyle().setMainTextColor.s14.bold,
              ),
              8.szW,
              Container(
                decoration: BoxDecoration(
                  color: payBg,
                  borderRadius: BorderRadius.circular(AppCircular.r7),
                ),
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: AppPadding.pW8,
                  vertical: AppPadding.pH4,
                ),
                child: Text(
                  payLabel,
                  style: const TextStyle().setColor(payFg).s12.semiBold,
                ),
              ),
            ],
          ),
          4.szH,
          Text(
            '${order.name} · ${order.meta}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle().setSecondaryColor.s12.regular,
          ),
        ],
      ),
    );
  }
}

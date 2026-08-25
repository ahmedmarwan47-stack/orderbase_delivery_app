part of '../imports/pickup_imports.dart';

/// One order as a compact row: number, pay pill, cash due, then name + area.
///
/// Shared deliberately — the dispatch sheet and the Pickup tab are both
/// "here is a batch waiting at the branch", so they show a batch the same way.
/// Flat, like every other list in the app: a hairline between rows instead of a
/// filled tile per order.
class _PickupOrderRow extends StatelessWidget {
  const _PickupOrderRow({
    required this.order,
    this.last = false,
    this.inset = true,
  });
  final FlowOrder order;

  /// Last row of its batch — drops the trailing hairline.
  final bool last;

  /// Applies the row's own side padding, indented under the batch header. The
  /// dispatch sheet turns it off — [SheetShell] already pads its body, and a
  /// second inset there would be the nested padding this list just shed.
  final bool inset;

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
        border: last
            // borderDefault, not the near-invisible itemDivider: this rule has
            // to read on the warm page background, not on white.
            ? null
            : const Border(bottom: BorderSide(color: AppColors.borderDefault)),
      ),
      padding: EdgeInsetsDirectional.only(
        // Indented past the batch header's label, so the rows read as its
        // children rather than as siblings of it.
        start: inset ? AppPadding.pW32 : 0,
        end: inset ? AppPadding.pW20 : 0,
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

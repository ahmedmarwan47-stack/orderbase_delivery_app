part of '../imports/pickup_imports.dart';

/// Announce a freshly dispatched branch batch *without forcing the courier to
/// act on it*. Shown once when the app opens with an un-carried batch: it lists
/// the waiting orders (compact rows) and offers to jump to Pickup, but is fully
/// dismissible (scrim tap / drag down / "later") so the courier can keep working
/// and carry the batch whenever they want. Resolves to `true` only if they chose
/// to carry now.
Future<bool?> showPickupDispatchSheet(
  BuildContext context, {
  required List<FlowOrder> orders,
}) {
  return showAppSheet<bool>(
    context,
    child: _PickupDispatchSheet(orders: orders),
  );
}

class _PickupDispatchSheet extends StatelessWidget {
  const _PickupDispatchSheet({required this.orders});
  final List<FlowOrder> orders;

  @override
  Widget build(BuildContext context) {
    return SheetShell(
      title: LocaleKeys.pickupDispatchTitle.tr(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            LocaleKeys.pickupDispatchBanner.tr(
              namedArgs: {'count': '${orders.length}'},
            ),
            style: const TextStyle().setSecondaryColor.s14.regular,
          ),
          12.szH,
          // The waiting orders as compact rows — the pickup list in miniature.
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSize.sH8,
            children: [for (final o in orders) _DispatchOrderRow(order: o)],
          ),
          16.szH,
          Text(
            LocaleKeys.pickupDispatchBody.tr(),
            style: const TextStyle().setTertiaryColor.s12.regular.withHeight(
              1.5,
            ),
          ),
          16.szH,
          // Primary: go carry now → opens Pickup (the full carry flow).
          Container(
            height: AppSize.sH56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.inkFill,
              borderRadius: BorderRadius.circular(AppCircular.r15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconWidget(
                  icon: AppAssets.svg.bag,
                  color: AppColors.surface,
                  height: AppSize.sH18,
                  width: AppSize.sW18,
                ),
                8.szW,
                Text(
                  LocaleKeys.pickupDispatchCarry.tr(),
                  style: const TextStyle().setWhite.s14.semiBold,
                ),
              ],
            ),
          ).onClick(onTap: () => Navigator.of(context).pop(true)),
          8.szH,
          // Secondary: dismiss — nothing is forced, the batch stays waiting.
          Container(
            height: AppSize.sH52,
            alignment: Alignment.center,
            child: Text(
              LocaleKeys.pickupDispatchLater.tr(),
              style: const TextStyle().setSecondaryColor.s14.semiBold,
            ),
          ).onClick(onTap: () => Navigator.of(context).pop(false)),
        ],
      ),
    );
  }
}

/// A single waiting order in miniature: order number + pay pill on top, customer
/// name · area beneath — the pickup card stripped to a slim, thumbnail-less row.
class _DispatchOrderRow extends StatelessWidget {
  const _DispatchOrderRow({required this.order});
  final FlowOrder order;

  @override
  Widget build(BuildContext context) {
    final payLabel = order.cod
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

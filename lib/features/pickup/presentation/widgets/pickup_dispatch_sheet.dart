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
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final o in orders)
                _PickupOrderRow(order: o, last: o == orders.last, inset: false),
            ],
          ),
          16.szH,
          Text(
            LocaleKeys.pickupDispatchBody.tr(),
            style: const TextStyle().setTertiaryColor.s12.regular.withHeight(
              1.5,
            ),
          ),
          16.szH,
          // Informational only: this sheet just tells the courier a batch has
          // been dispatched. Acknowledging closes it — the actual "carried from
          // branch" confirmation lives on the Pickup («الاستلام») tab, so this is
          // no longer one of the carry-confirmation steps.
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
                  icon: AppAssets.svg.check,
                  color: AppColors.surface,
                  height: AppSize.sH18,
                  width: AppSize.sW18,
                ),
                8.szW,
                Text(
                  LocaleKeys.pickupDispatchSeen.tr(),
                  style: const TextStyle().setWhite.s14.semiBold,
                ),
              ],
            ),
          ).onClick(onTap: () => Navigator.of(context).pop(false)),
        ],
      ),
    );
  }
}

/// A single waiting order in miniature: order number + pay pill on top, customer
/// name · area beneath — the pickup card stripped to a slim, thumbnail-less row.

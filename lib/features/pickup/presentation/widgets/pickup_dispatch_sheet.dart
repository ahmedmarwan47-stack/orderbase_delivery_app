part of '../imports/pickup_imports.dart';

/// Announce a freshly dispatched batch *without forcing the courier to act on
/// it*. Raised mid-flight by the shell the moment the branch dispatches: it
/// names the batch, sizes it up (orders · cash · km), lists the waiting orders
/// as compact rows, and offers to jump to it on the Orders tab. Fully
/// dismissible (scrim tap / drag down / «لاحقًا») so the courier can finish
/// the order in hand first. Resolves to `true` only if they chose to view it.
Future<bool?> showPickupDispatchSheet(
  BuildContext context, {
  required OrderBatch batch,
  required String branch,
}) {
  return showAppSheet<bool>(
    context,
    child: _PickupDispatchSheet(batch: batch, branch: branch),
  );
}

class _PickupDispatchSheet extends StatelessWidget {
  const _PickupDispatchSheet({required this.batch, required this.branch});
  final OrderBatch batch;
  final String branch;

  @override
  Widget build(BuildContext context) {
    final orders = batch.orders.map(orderToFlow).toList();
    return SheetShell(
      title: LocaleKeys.pickupDispatchTitle.tr(namedArgs: {'id': batch.id}),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            LocaleKeys.pickupDispatchMeta.tr(
              namedArgs: {
                'count': arabicDigits(batch.count),
                'cash': formatThousands(batch.codTotal),
                'km': formatKmArabic(batch.routeKm),
                'branch': branch,
              },
            ),
            style: const TextStyle().setSecondaryColor.s12.regular,
          ),
          12.szH,
          // The waiting orders as compact rows — the batch list in miniature.
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
                  icon: AppAssets.svg.orders,
                  color: AppColors.surface,
                  height: AppSize.sH18,
                  width: AppSize.sW18,
                ),
                8.szW,
                Text(
                  LocaleKeys.pickupDispatchView.tr(),
                  style: const TextStyle().setWhite.s14.semiBold,
                ),
              ],
            ),
          ).onClick(onTap: () => Navigator.of(context).pop(true)),
          8.szH,
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

/// Confirm that the courier physically carried [batch] out of the branch.
/// Raised from the Orders tab's waiting-batch section (and the standalone
/// pickup page). Resolves to `true` on confirm.
Future<bool?> showCarryBatchSheet(
  BuildContext context, {
  required OrderBatch batch,
}) {
  return showAppSheet<bool>(
    context,
    child: _PickupCarrySheet(batch: batch),
  );
}

class _PickupCarrySheet extends StatelessWidget {
  const _PickupCarrySheet({required this.batch});
  final OrderBatch batch;

  @override
  Widget build(BuildContext context) {
    return SheetShell(
      title: LocaleKeys.pickupCarryTitle.tr(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            LocaleKeys.pickupCarryBody.tr(
              namedArgs: {'id': batch.id, 'count': arabicDigits(batch.count)},
            ),
            style: const TextStyle().setSecondaryColor.s14.regular.withHeight(
              1.5,
            ),
          ),
          20.szH,
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
                  LocaleKeys.pickupCarryConfirm.tr(),
                  style: const TextStyle().setWhite.s14.semiBold,
                ),
              ],
            ),
          ).onClick(onTap: () => Navigator.of(context).pop(true)),
          8.szH,
          Container(
            height: AppSize.sH52,
            alignment: Alignment.center,
            child: Text(
              LocaleKeys.pickupCarryCancel.tr(),
              style: const TextStyle().setSecondaryColor.s14.semiBold,
            ),
          ).onClick(onTap: () => Navigator.of(context).pop(false)),
        ],
      ),
    );
  }
}

part of '../imports/home_imports.dart';

/// Shows the old one-segment-per-order progress bar. **Off**: replaced, not
/// deleted — [_HomeStopProgress] and its tooltip are intact behind this flag.
const bool kShowStopSegments = false;

/// Shows the origin → destination leg bar under the batch line. **Off**: it
/// carried the per-stop ETA, which the courier asked to lose, and repeated
/// what the map strip shows. [_HomeRouteLeg] is kept intact behind this flag.
const bool kShowRouteLeg = false;

/// The next-order hero card, in the order a courier reads it at a glance:
///
///  1. **The batch line** — which batch, where in it, and how the trip ends
///     (return time to the branch, trip kilometres, a tooltip on what those
///     mean).
///  2. **The destination, bold** — area and street on one line at one weight,
///     then the door (building · floor · apartment) a step quieter.
///  3. **The map strip** with the open-in-Maps badge. Per-stop distance and
///     ETA are gone on purpose: Maps answers both better.
///  4. **One quiet meta row** — customer, order number, then a matched pair of
///     chips: a note badge when the customer left instructions, and the cash
///     pill. Plus the promised time, a deadline rather than an estimate.
///  5. **Two actions** — «تم تسليم الطلب» and call. WhatsApp lives on the
///     detail, which the whole card opens.
class _HomeNextStopCard extends StatelessWidget {
  const _HomeNextStopCard({this.onViewOrder});

  /// Opens the current order's detail — the whole card taps through to it.
  final VoidCallback? onViewOrder;

  @override
  Widget build(BuildContext context) {
    final shift = ShiftController.instance;
    final order = shift.nextStop;
    if (order == null) return const SizedBox.shrink();
    final isCod = order.cod != null && !order.prepaid;
    // Road mode: one type step up, taller controls, a shorter map to pay for
    // it, and a firmer outline. See [RoadMode].
    final road = RoadMode.instance.on;

    // Only read when the legacy segment bar is on.
    final closed = shift.routeStops
        .where(
          (s) =>
              s.status == OrderStatus.delivered ||
              s.status == OrderStatus.failed,
        )
        .toList();
    final upcoming = shift.routeStops
        .where((s) => s.status == OrderStatus.transit && s.num != order.num)
        .toList();
    final orderedStops = [...closed, order, ...upcoming];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppCircular.r16),
        border: road
            ? Border.all(color: AppColors.borderDefault, width: 2)
            : Border.all(color: AppColors.borderCardFaint),
        boxShadow: AppShadows.heroCard,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. the destination ──
              // The batch line and the trip facts now sit above this card,
              // and the actions below it: what is left inside is only the
              // place the courier is going.
              // Area and street sit on ONE line at ONE weight and size: they
              // are a single fact ("where am I going"), and setting the area
              // three steps louder than its own street invented a hierarchy
              // that isn't in the address. It wraps rather than shrinking.
              Text(
                '${order.area} · ${order.addr}',
                // 16 — the hero slot's one headline size, shared with the
                // idle / returning / settled titles that take its place.
                style: const TextStyle().setMainTextColor.s16.semiBold
                    .road(road)
                    .withHeight(1.4),
              ),
              4.szH,
              // The door beneath, quieter — the last thing you read, at the
              // door, and the only part that isn't on the map.
              Text(
                order.addrDetail ?? '',
                style: const TextStyle().setTertiaryColor.s14.medium
                    .road(road)
                    .withHeight(1.5),
              ),
            ],
          ),
          12.szH,
          if (kShowStopSegments)
            _HomeStopProgress(stops: orderedStops, current: order)
          else if (kShowRouteLeg)
            _HomeRouteLeg(origin: shift.legOrigin, destination: order.place),
          // ── 3. map strip ──
          // The map gives back the height the type takes: Maps is the map's
          // job, the strip only confirms the pin.
          MapView(
            height: road ? AppSize.sH96 : AppSize.sH120,
            borderRadius: AppCircular.r12,
            destinationLabel: order.fullAddress,
          ),
          12.szH,
          // ── 4. meta ──
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: order.name,
                            style: const TextStyle()
                                .setMainTextColor
                                .s14
                                .semiBold
                                .road(road),
                          ),
                          const TextSpan(text: '  '),
                          TextSpan(
                            text: order.num,
                            style: const TextStyle()
                                .setSecondaryColor
                                .s14
                                .semiBold
                                .tabular
                                .road(road),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  8.szW,
                  // The note badge and the cash pill are one group, sized as
                  // one: IntrinsicHeight + stretch makes the badge exactly as
                  // tall as the pill beside it, so the row reads as two chips
                  // rather than a chip and a dot.
                  IntrinsicHeight(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (order.note != null) ...[
                          _NotePill(road: road),
                          6.szW,
                        ],
                        _PayPill(
                          isCod: isCod,
                          amount: isCod ? order.cod : null,
                          road: road,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ).paddingAll(AppPadding.pW16),
      // The whole card opens the order. Everything inside that handles its own
      // tap — the deliver button, call, the open-in-Maps badge, the tooltip —
      // still wins the gesture arena, so only the "dead" areas fall through.
    ).onClick(onTap: onViewOrder);
  }
}

/// The COD / prepaid pill in the hero's meta row.
///
/// On a cash order the pill carries the figure the courier has to collect —
/// the amount IS the payment type, so «الدفع عند الاستلام» beside it is noise.
/// Prepaid has no figure, so there the label is the whole message.
class _PayPill extends StatelessWidget {
  const _PayPill({required this.isCod, this.amount, this.road = false});
  final bool isCod;

  /// Road mode: the figure one type step up.
  final bool road;

  /// Cash due in EGP. Null on a prepaid order, where there is nothing to show.
  final int? amount;

  @override
  Widget build(BuildContext context) {
    final text = amount != null
        ? LocaleKeys.amountEgp.tr(
            namedArgs: {'amount': formatThousands(amount!)},
          )
        : (isCod ? LocaleKeys.payCod : LocaleKeys.payPrepaid).tr();
    return Container(
      decoration: BoxDecoration(
        color: isCod ? AppColors.heroCodPillBg : AppColors.deliveredBg,
        borderRadius: BorderRadius.circular(AppCircular.r8),
      ),
      child: Text(
        text,
        style: const TextStyle()
            .setColor(isCod ? AppColors.postponedText : AppColors.deliveredText)
            .s14
            .bold
            .tabular
            .road(road),
      ).paddingSymmetric(horizontal: AppPadding.pW8, vertical: AppPadding.pH4),
    );
  }
}

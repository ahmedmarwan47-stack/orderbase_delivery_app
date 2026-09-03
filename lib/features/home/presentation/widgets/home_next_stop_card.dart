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
  const _HomeNextStopCard({this.onViewOrder, this.onDeliver, this.onCall});

  /// Opens the current order's detail — the whole card taps through to it.
  final VoidCallback? onViewOrder;

  /// Marks the order handed over (handoff sheet → COD collection → result).
  final VoidCallback? onDeliver;

  /// Dials the customer.
  final VoidCallback? onCall;

  @override
  Widget build(BuildContext context) {
    final shift = ShiftController.instance;
    final order = shift.nextStop;
    if (order == null) return const SizedBox.shrink();
    final batch = shift.currentBatch;
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
        borderRadius: BorderRadius.circular(AppCircular.r22),
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
              // ── 1. the batch line ──
              if (batch != null)
                _HomeBatchLine(
                  batch: batch,
                  current: shift.currentStopNumber,
                  total: shift.totalStops,
                  returnEta: formatClockArabic(shift.returnEtaOf(batch)),
                  routeKm: batch.routeKm,
                ),
              12.szH,
              // ── 2. the destination ──
              // Area and street sit on ONE line at ONE weight and size: they
              // are a single fact ("where am I going"), and setting the area
              // three steps louder than its own street invented a hierarchy
              // that isn't in the address. It wraps rather than shrinking.
              Text(
                '${order.area} · ${order.addr}',
                // 16 — the hero slot's one headline size, shared with the
                // idle / returning / settled titles that take its place.
                style: const TextStyle().setMainTextColor.s16.bold
                    .road(road)
                    .withHeight(1.4),
              ),
              4.szH,
              // The door beneath, quieter — the last thing you read, at the
              // door, and the only part that isn't on the map.
              Text(
                order.addrDetail ?? '',
                style: const TextStyle().setTertiaryColor.s14.regular
                    .road(road)
                    .withHeight(1.5),
              ),
            ],
          ).paddingOnly(
            left: AppPadding.pW20,
            top: AppPadding.pH16,
            right: AppPadding.pW20,
            bottom: AppPadding.pH12,
          ),
          if (kShowStopSegments)
            _HomeStopProgress(stops: orderedStops, current: order)
          else if (kShowRouteLeg)
            _HomeRouteLeg(origin: shift.legOrigin, destination: order.place),
          // ── 3. map strip ──
          // The map gives back the height the type takes: Maps is the map's
          // job, the strip only confirms the pin.
          MapView(
            height: road ? AppSize.sH96 : AppSize.sH120,
            showHairlines: true,
            destinationLabel: order.fullAddress,
          ),
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
                                .s12
                                .regular
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
              if (order.due != null) ...[
                4.szH,
                Text(
                  LocaleKeys.promisedAt.tr(namedArgs: {'time': order.due!}),
                  style: const TextStyle().setSecondaryColor.s12.regular.road(
                    road,
                  ),
                ),
              ],
            ],
          ).paddingOnly(
            left: AppPadding.pW20,
            top: AppPadding.pH12,
            right: AppPadding.pW20,
            bottom: AppPadding.pH4,
          ),
          // ── 5. actions ──
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: road ? AppSize.sH64 : AppSize.sH52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.inkFill,
                      borderRadius: BorderRadius.circular(
                        AppCircular.r15,
                      ), // radii exempt
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
                        Flexible(
                          child: Text(
                            LocaleKeys.homeDeliver.tr(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle().setWhite.s14.semiBold.road(
                              road,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).onClick(onTap: onDeliver),
              ),
              12.szW,
              // Neutral tile (ink glyph, white fill, hairline) matching the
              // header actions — kept off the status hues so call never
              // reads as the failed-red / delivered-green states.
              Semantics(
                button: true,
                label: LocaleKeys.orderDetailCall.tr(),
                child: _HomeSquareIconButton(
                  icon: AppAssets.svg.phone,
                  iconColor: AppColors.textPrimary,
                  size: road ? AppSize.sH64 : AppSize.sH52,
                  iconSize: road ? AppSize.sH24 : 21.h, // mockup glyph 21px
                  radius: AppCircular.r15,
                  background: AppColors.surface,
                  border: AppColors.iconButtonBorder,
                ).onClick(onTap: onCall),
              ),
            ],
          ).paddingOnly(
            left: AppPadding.pW20,
            top: AppPadding.pH12,
            right: AppPadding.pW20,
            bottom: AppPadding.pH16,
          ),
        ],
      ),
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
            .s12
            .semiBold
            .tabular
            .road(road),
      ).paddingSymmetric(horizontal: AppPadding.pW8, vertical: AppPadding.pH4),
    );
  }
}

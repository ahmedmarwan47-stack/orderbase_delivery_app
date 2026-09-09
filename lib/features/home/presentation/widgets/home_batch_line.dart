part of '../imports/home_imports.dart';

/// «عودة للفرع ~٥:٤٠ م» — the return half of the trip line.
///
/// Both halves still come from the one `home_return_line` string, which
/// composes them around the app's «·». Rendering it without the distance and
/// taking the part before the separator leaves the wording — and every
/// translation of it — owned by the json, while letting each fact carry its
/// own glyph. Shared by the stacked line ([_HomeBatchLine], still used by the
/// returning card) and the split layout the hero now uses.
String homeReturnText(String returnEta) => LocaleKeys.homeReturnLine
    .tr(namedArgs: {'time': returnEta, 'km': ''})
    .split('·')
    .first
    .trim();

/// The trip row that sits ABOVE the hero card.
///
/// The batch and the courier's place in it lead the line; the distance and its
/// ⓘ sit at the far end. Splitting them to opposite ends is what lets the row
/// read as two separate facts without a separator between them — and it keeps
/// the card beneath free to be only the destination.
class _HomeStopTripRow extends StatelessWidget {
  const _HomeStopTripRow({
    required this.batch,
    required this.current,
    required this.total,
    required this.routeKm,
  });

  final OrderBatch batch;
  final int current;
  final int total;
  final double routeKm;

  @override
  Widget build(BuildContext context) {
    final road = RoadMode.instance.on;
    final count = LocaleKeys.homeStopCount.tr(
      namedArgs: {
        'current': arabicDigits(current),
        'total': arabicDigits(total),
      },
    );
    return Row(
      children: [
        Expanded(
          child: Text.rich(
            TextSpan(
              style: const TextStyle().setSecondaryColor.s14.medium.road(
                road,
              ),
              children: [
                // The count leads, the batch ID trails (the Figma frame):
                // «الطلب ٥ من ٨ · B #7877». The ID is Latin + digits — its own
                // span keeps the RTL line from re-ordering «B #7877» around
                // the hash.
                TextSpan(text: '$count · '),
                TextSpan(
                  text: batch.id,
                  style: const TextStyle().setMainTextColor.s14.medium.tabular
                      .road(road),
                ),
              ],
            ),
            textDirection: TextDirection.rtl,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        8.szW,
        Text(
          formatKmArabic(routeKm),
          maxLines: 1,
          style: const TextStyle().setMainTextColor.s14.medium.tabular.road(
            road,
          ),
        ),
        // The ⓘ covers both figures but hangs off the distance — the end of
        // the line, and the fact a courier is least likely to read as a
        // promise without it.
        _HintDot(
          message: LocaleKeys.homeTripTooltip.tr(),
          label: LocaleKeys.homeTripTooltipLabel.tr(),
        ),
      ],
    );
  }
}

/// «🕐 عودة للفرع ~٥:٤٠ م» on its own line, below the stop's actions.
///
/// It sits beside the pending-batch row rather than inside the hero because it
/// is about the ride *after* the batch, not about the door in front of the
/// courier — the same reason the distance stays up top with the batch it
/// measures.
class _HomeReturnEta extends StatelessWidget {
  const _HomeReturnEta({required this.returnEta});

  final String returnEta;

  @override
  Widget build(BuildContext context) => _HomeTripFact(
    icon: AppAssets.svg.clock,
    text: homeReturnText(returnEta),
    road: RoadMode.instance.on,
    large: true,
  );
}

/// The hero's first line — the batch and how its trip ends.
///
/// Leading: «B #7877 · الطلب ٥ من ٨». Beneath it the trip row — two facts, each
/// behind its own glyph: 🕐 «عودة للفرع ~٥:٤٠ م» and ➤ «٣٤ كم», with a small ⓘ
/// on the distance. Tapping ⓘ floats a tooltip above it explaining what the two
/// figures mean: the time is the ride back to the branch after the last order,
/// not counting stops and handoffs; the kilometres are the whole batch trip
/// from the branch and back. Both are estimates from the orders' leg distances
/// until the backend gives real ones, and the tooltip is how the courier is
/// told not to read them as promises.
class _HomeBatchLine extends StatelessWidget {
  const _HomeBatchLine({
    required this.batch,
    required this.current,
    required this.total,
    required this.returnEta,
    required this.routeKm,
    this.done = false,
    this.showTrip = true,
  });

  final OrderBatch batch;

  /// 1-based stop the courier is on, and the batch's stop count.
  final int current;
  final int total;

  /// "٥:٤٠ م" — when they are expected back at the branch.
  final String returnEta;
  final double routeKm;

  /// The batch is complete: the count reads «اكتملت ٨ من ٨».
  final bool done;

  /// Show the «عودة للفرع ~٥:٤٠ م · ٣٤ كم» row and its ⓘ. Off once the batch
  /// is closed: the ride back is no longer an estimate about the route, it is
  /// the one thing the card is about, and it is stated there instead.
  final bool showTrip;

  /// «عودة للفرع ~٥:٤٠ م» — the return half of the trip line.
  ///
  /// Both halves still come from the one `home_return_line` string, which
  /// composes them around the app's «·». Rendering it without the distance and
  /// taking the part before the separator leaves the wording — and every
  /// translation of it — owned by the json, while letting each fact carry its
  /// own glyph here. The distance half is [formatKmArabic], which is where it
  /// was coming from anyway.
  String _returnText() => homeReturnText(returnEta);

  @override
  Widget build(BuildContext context) {
    final road = RoadMode.instance.on;
    final quiet = const TextStyle().setSecondaryColor.s14.semiBold.road(road);
    final count = done
        ? LocaleKeys.homeBatchDone.tr(
            namedArgs: {
              'done': arabicDigits(total),
              'total': arabicDigits(total),
            },
          )
        : LocaleKeys.homeStopCount.tr(
            namedArgs: {
              'current': arabicDigits(current),
              'total': arabicDigits(total),
            },
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text.rich(
          TextSpan(
            style: quiet,
            children: [
              // The ID is Latin + digits: isolate it so the RTL line does not
              // re-order «B #7877» around the hash.
              TextSpan(
                text: batch.id,
                style: const TextStyle().setMainTextColor.s14.bold.tabular.road(
                  road,
                ),
              ),
              TextSpan(text: ' · $count'),
            ],
          ),
          textDirection: TextDirection.rtl,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (showTrip) ...[
          4.szH,
          Row(
            children: [
              Flexible(
                child: _HomeTripFact(
                  icon: AppAssets.svg.clock,
                  text: _returnText(),
                  road: road,
                ),
              ),
              12.szW,
              _HomeTripFact(
                icon: AppAssets.svg.nav,
                text: formatKmArabic(routeKm),
                road: road,
              ),
              // The ⓘ covers both figures but hangs off the distance — the end
              // of the line, and the fact a courier is least likely to read as
              // a promise without it.
              _HintDot(
                message: LocaleKeys.homeTripTooltip.tr(),
                label: LocaleKeys.homeTripTooltipLabel.tr(),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// One fact on the trip row: a glyph, then the figure.
///
/// The glyph is what makes the two halves readable at a glance now that the
/// «·» between them is gone — a clock for the time the courier is due back, a
/// navigation arrow for the kilometres the batch runs. It is set in the line's
/// supporting colour rather than its black: the figures are what is read, the
/// glyph only says which figure it is.
class _HomeTripFact extends StatelessWidget {
  const _HomeTripFact({
    required this.icon,
    required this.text,
    this.road = false,
    this.large = false,
  });

  final String icon;
  final String text;

  /// Road mode: the glyph grows a step with the line's type.
  final bool road;

  /// The return ETA is set one step above the distance: it is the fact the
  /// courier plans the end of the round around.
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSize.sW4,
      children: [
        // The glyph takes the colour AND the box of the line beside it: same
        // ink, and a square the height of the text's line so the two share a
        // baseline instead of the icon floating small inside the row.
        IconWidget(
          icon: icon,
          color: AppColors.textPrimary,
          height: large ? AppSize.sH22 : AppSize.sH20,
          width: large ? AppSize.sW22 : AppSize.sW20,
        ),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            // Black, like the batch id above it: this is the line the courier
            // plans the rest of the batch around.
            style:
                (large
                        ? const TextStyle().setMainTextColor.s16
                        : const TextStyle().setMainTextColor.s14)
                    .medium
                    .tabular
                    .road(road)
                    // 1.4 — the frame's line height, and the glyph's box.
                    .withHeight(1.4),
          ),
        ),
      ],
    );
  }
}

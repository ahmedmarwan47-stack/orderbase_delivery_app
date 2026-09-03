part of '../imports/home_imports.dart';

/// The hero's first line — the batch and how its trip ends.
///
/// Leading: «B #7877 · الطلب ٥ من ٨». Beneath it: «عودة للفرع ~٥:٤٠ م · ٣٤ كم»
/// with a small ⓘ. Tapping ⓘ floats a tooltip above it explaining what the two
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

  @override
  Widget build(BuildContext context) {
    final road = RoadMode.instance.on;
    final quiet = const TextStyle().setSecondaryColor.s12.semiBold.road(road);
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
                style: const TextStyle().setMainTextColor.s12.bold.tabular.road(
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
                child: Text(
                  LocaleKeys.homeReturnLine.tr(
                    namedArgs: {
                      'time': returnEta,
                      'km': formatKmArabic(routeKm),
                    },
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  // Black, like the batch id above it: this is the line the
                  // courier plans the rest of the batch around.
                  style: const TextStyle().setMainTextColor.s12.regular.tabular
                      .road(road),
                ),
              ),
              6.szW,
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

part of '../imports/home_imports.dart';

/// The hero's first line — the batch and how its trip ends.
///
/// Leading: «B #7877 · الطلب ٥ من ٨». Beneath it: «عودة للفرع ~٥:٤٠ م · ٣٤ كم»
/// with a small ⓘ. Tapping ⓘ reveals what those two figures mean: the time is
/// the ride back to the branch after the last order, not counting stops and
/// handoffs; the kilometres are the whole batch trip from the branch and back.
/// Both are estimates from the orders' leg distances until the backend gives
/// real ones, and the note is how the courier is told not to read them as
/// promises.
///
/// The note **expands in place** rather than floating over the card. A popover
/// landed on top of the address — the one thing the courier came to the card
/// to read — so the explanation now pushes the card open under the line it
/// explains, and closes it again on a second tap.
class _HomeBatchLine extends StatefulWidget {
  const _HomeBatchLine({
    required this.batch,
    required this.current,
    required this.total,
    required this.returnEta,
    required this.routeKm,
    this.done = false,
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

  @override
  State<_HomeBatchLine> createState() => _HomeBatchLineState();
}

class _HomeBatchLineState extends State<_HomeBatchLine>
    with _InlineHintHost {
  @override
  Widget build(BuildContext context) {
    final quiet = const TextStyle().setSecondaryColor.s12.semiBold;
    final count = widget.done
        ? LocaleKeys.homeBatchDone.tr(
            namedArgs: {
              'done': arabicDigits(widget.total),
              'total': arabicDigits(widget.total),
            },
          )
        : LocaleKeys.homeStopCount.tr(
            namedArgs: {
              'current': arabicDigits(widget.current),
              'total': arabicDigits(widget.total),
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
                text: widget.batch.id,
                style: const TextStyle().setMainTextColor.s12.bold.tabular,
              ),
              TextSpan(text: ' · $count'),
            ],
          ),
          textDirection: TextDirection.rtl,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        4.szH,
        Row(
          children: [
            Flexible(
              child: Text(
                LocaleKeys.homeReturnLine.tr(
                  namedArgs: {
                    'time': widget.returnEta,
                    'km': formatKmArabic(widget.routeKm),
                  },
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle().setSecondaryColor.s12.regular.tabular,
              ),
            ),
            6.szW,
            _HintDot(
              open: hintOpen,
              onTap: toggleHint,
              label: LocaleKeys.homeTripTooltipLabel.tr(),
            ),
          ],
        ),
        _InlineHintNote(
          open: hintOpen,
          message: LocaleKeys.homeTripTooltip.tr(),
          onTap: toggleHint,
        ),
      ],
    );
  }
}

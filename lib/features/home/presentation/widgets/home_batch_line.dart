part of '../imports/home_imports.dart';

/// The hero's first line — the batch and how its trip ends.
///
/// Leading: «B #7877 · الطلب ٥ من ٨». Trailing: «عودة للفرع ~٥:٤٠ م · ٣٤ كم»
/// with a small ⓘ. Tapping ⓘ explains the two figures: the time is the ride
/// back to the branch after the last order, not counting stops and handoffs;
/// the kilometres are the whole batch trip from the branch and back. Both are
/// estimates from the orders' leg distances until the backend provides real
/// ones, and the tooltip is how the courier is told not to treat them as
/// promises.
class _HomeBatchLine extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final quiet = const TextStyle().setSecondaryColor.s12.semiBold;
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
                  namedArgs: {'time': returnEta, 'km': formatKmArabic(routeKm)},
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle().setSecondaryColor.s12.regular.tabular,
              ),
            ),
            6.szW,
            const _TripInfoTip(),
          ],
        ),
      ],
    );
  }
}

/// The ⓘ beside the trip line. A tap shows the explanation as an ink tooltip
/// anchored under it; it dismisses on its own after a few seconds.
///
/// Shown manually (`ensureTooltipVisible`) from our own tap handler rather
/// than through the tooltip's tap trigger: the hero card is itself tappable,
/// and an explicit inner recognizer is the reliable way to keep this tap from
/// falling through to it.
class _TripInfoTip extends StatefulWidget {
  const _TripInfoTip();

  @override
  State<_TripInfoTip> createState() => _TripInfoTipState();
}

class _TripInfoTipState extends State<_TripInfoTip> {
  final GlobalKey<TooltipState> _tip = GlobalKey<TooltipState>();

  void _show() {
    AppHaptics.tick();
    _tip.currentState?.ensureTooltipVisible();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      key: _tip,
      message: LocaleKeys.homeTripTooltip.tr(),
      triggerMode: TooltipTriggerMode.manual,
      preferBelow: true,
      showDuration: const Duration(seconds: 6),
      textAlign: TextAlign.right,
      margin: EdgeInsets.symmetric(horizontal: AppPadding.pW32),
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.pW12,
        vertical: AppPadding.pH8,
      ),
      decoration: BoxDecoration(
        color: AppColors.inkFill,
        borderRadius: BorderRadius.circular(AppCircular.r10),
      ),
      textStyle: const TextStyle().setWhite.s12.regular.withHeight(1.5),
      child: Semantics(
        button: true,
        label: LocaleKeys.homeTripTooltipLabel.tr(),
        child: GestureDetector(
          onTap: _show,
          behavior: HitTestBehavior.opaque,
          // The visual ring is 16pt; the hit area is padded out so it is
          // reliably tappable beside a line of text.
          child: Container(
            width: AppSize.sH28,
            height: AppSize.sH28,
            alignment: Alignment.center,
            child: Container(
              width: AppSize.sH16,
              height: AppSize.sH16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: Center(
                child: Text(
                  'i',
                  style: const TextStyle()
                      .setTertiaryColor
                      .s10
                      .bold
                      .withHeight(1)
                      .copyWith(fontFamily: 'sans-serif'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

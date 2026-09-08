part of '../imports/home_imports.dart';

/// Deliver and call, below the hero card rather than inside it.
///
/// They sit on the page because they act on the stop rather than describing
/// it: the card above is what the courier reads, this row is what they press.
/// Keeping them outside also means the card's own tap — which opens the order
/// — no longer has to lose the gesture arena to two controls sitting on top of
/// it.
class _HomeStopActions extends StatelessWidget {
  const _HomeStopActions({this.onDeliver, this.onCall});

  final VoidCallback? onDeliver;
  final VoidCallback? onCall;

  @override
  Widget build(BuildContext context) {
    // Road mode: taller controls, one type step up. See [RoadMode].
    final road = RoadMode.instance.on;
    return Row(
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
                      style: const TextStyle().setWhite.s14.bold.road(road),
                    ),
                  ),
                ],
              ),
            ),
          ).onClick(onTap: onDeliver),
        ),
        12.szW,
        // Neutral tile (ink glyph, white fill, hairline) matching the header
        // actions — kept off the status hues so call never reads as the
        // failed-red / delivered-green states.
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
    );
  }
}

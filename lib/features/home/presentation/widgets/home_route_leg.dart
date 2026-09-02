part of '../imports/home_imports.dart';

/// The hero's **current leg** — one bar with a place at each end and the travel
/// estimate beside it: `[origin] ——— [destination] · 12 دقيقة`.
///
/// It replaced the one-segment-per-order bar because a courier on the road is
/// running exactly one leg at a time, and what they need off a glance is *where
/// am I coming from, where am I going, how long*. The ends are dynamic: the
/// branch on the first order of a batch (they set out from it), then the door
/// they just left on every order after — see [ShiftController.legOrigin] — and
/// the destination is the customer's own address kind (apartment block or
/// villa), so the two ends genuinely differ from leg to leg.
class _HomeRouteLeg extends StatefulWidget {
  const _HomeRouteLeg({required this.origin, required this.destination});

  /// Where this leg starts — the branch, or the last door the courier closed.
  final PlaceKind origin;

  /// Where it ends — the current order's address kind.
  final PlaceKind destination;

  @override
  State<_HomeRouteLeg> createState() => _HomeRouteLegState();
}

class _HomeRouteLegState extends State<_HomeRouteLeg>
    with SingleTickerProviderStateMixin {
  /// Fills the track from the origin end to the destination end, then restarts —
  /// the leg reads as "under way" without pretending to know real progress
  /// (there is no GPS trace behind this yet).
  late final AnimationController _sweep = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _sweep.stop();
    } else if (!_sweep.isAnimating) {
      _sweep.repeat();
    }
  }

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = AppMotion.reduced(context);
    return Semantics(
      container: true,
      label:
          '${_placeLabel(widget.origin)} ← ${_placeLabel(widget.destination)}',
      excludeSemantics: true,
      child:
          Row(
            children: [
              _LegEnd(place: widget.origin, isDestination: false),
              8.szW,
              Expanded(
                child: reduced
                    ? const _LegTrack(fill: 1)
                    : AnimatedBuilder(
                        animation: _sweep,
                        builder: (context, _) => _LegTrack(
                          // Ease across the first 80% of the loop, hold full, restart.
                          fill: Curves.easeInOut.transform(
                            (_sweep.value / 0.8).clamp(0.0, 1.0),
                          ),
                        ),
                      ),
              ),
              8.szW,
              _LegEnd(place: widget.destination, isDestination: true),
            ],
          ).paddingOnlyDirectional(
            start: AppPadding.pW20,
            end: AppPadding.pW20,
            top: AppPadding.pH8,
            bottom: AppPadding.pH12,
          ),
    );
  }
}

/// One end of the leg. The destination is the emphasis — that is where the
/// courier is headed — so it takes the ink tile; the origin is behind them and
/// stays quiet.
class _LegEnd extends StatelessWidget {
  const _LegEnd({required this.place, required this.isDestination});

  final PlaceKind place;
  final bool isDestination;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSize.sW28,
      height: AppSize.sH28,
      decoration: BoxDecoration(
        color: isDestination ? AppColors.inkFill : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppCircular.r9), // radii exempt
      ),
      child: Center(
        child: IconWidget(
          icon: _placeIcon(place),
          color: isDestination ? AppColors.surface : AppColors.textTertiary,
          height: AppSize.sH16,
          width: AppSize.sW16,
        ),
      ),
    );
  }
}

/// The rail between the two ends: a faint track with an ink fill running from
/// the origin end toward the destination.
class _LegTrack extends StatelessWidget {
  const _LegTrack({required this.fill});

  /// 0 → 1, measured from the origin end.
  final double fill;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSize.sH6,
      child: Stack(
        children: [
          const Positioned.fill(child: _LegTrackBar(AppColors.borderDefault)),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FractionallySizedBox(
              widthFactor: fill.clamp(0.0, 1.0),
              child: const _LegTrackBar(AppColors.inkFill),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single rounded bar — the track, or the fill drawn over it.
class _LegTrackBar extends StatelessWidget {
  const _LegTrackBar(this.color);
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSize.sH6,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppCircular.r3), // radii exempt
      ),
    );
  }
}

String _placeIcon(PlaceKind place) => switch (place) {
  PlaceKind.branch => AppAssets.svg.store,
  PlaceKind.building => AppAssets.svg.building,
  PlaceKind.villa => AppAssets.svg.villa,
};

String _placeLabel(PlaceKind place) => switch (place) {
  PlaceKind.branch => LocaleKeys.homeLegBranch.tr(),
  PlaceKind.building => LocaleKeys.homeLegBuilding.tr(),
  PlaceKind.villa => LocaleKeys.homeLegVilla.tr(),
};

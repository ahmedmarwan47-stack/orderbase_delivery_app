import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../config/res/config_imports.dart';
import '../theme/shadows.dart';

/// Interactive map with a centered red pin. Used both as the short strip inside
/// the Home hero card and as the taller rounded map in the order detail.
///
/// Renders a real [FlutterMap] with OpenStreetMap raster tiles (pure-Dart, no
/// native plugin — keeps the iOS build CocoaPods-free). Rotation is disabled and
/// the pin sits at the map centre.
class MapView extends StatefulWidget {
  const MapView({
    super.key,
    required this.height,
    this.borderRadius = 0,
    this.showHairlines = false,
    this.pinDiameter = 36,
    this.pinIconSize = 19,
    this.pinVerticalAlignment = 0,
    this.center,
  });

  final double height;
  final double borderRadius;

  /// Draws top+bottom hairline borders instead of clipping to a radius
  /// (the Home strip look).
  final bool showHairlines;
  final double pinDiameter;
  final double pinIconSize;

  /// -1 top … 0 center … 1 bottom, matching the mockups' slightly-above-center
  /// pin placement.
  final double pinVerticalAlignment;

  /// Map focus point. Defaults to central Cairo.
  final LatLng? center;

  static const LatLng _defaultCenter = LatLng(30.0444, 31.2357);

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView>
    with SingleTickerProviderStateMixin {
  // A slow, continuous breath so the pin reads as a live GPS fix.
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  bool _reduced = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reduce Motion is a display setting, so re-evaluate whenever it changes:
    // animate only when motion is allowed, otherwise sit on the static pin.
    final reduced = AppMotion.reduced(context);
    if (reduced != _reduced || (!reduced && !_pulse.isAnimating)) {
      _reduced = reduced;
      if (reduced) {
        _pulse.stop();
      } else {
        _pulse.repeat();
      }
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LatLng focus = widget.center ?? MapView._defaultCenter;
    final double borderRadius = widget.borderRadius;
    final bool showHairlines = widget.showHairlines;
    final double pinDiameter = widget.pinDiameter;
    final double pinIconSize = widget.pinIconSize;

    Widget map = FlutterMap(
      options: MapOptions(
        initialCenter: focus,
        initialZoom: 15,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.orderbase.orderbaseDeliveryApp',
          // Gentle fade as each tile loads so the map reads as "finding
          // location", not a broken flash. Reduce Motion → tiles appear at once.
          tileDisplay: _reduced
              ? const TileDisplay.instantaneous()
              : TileDisplay.fadeIn(duration: AppMotion.fill),
        ),
      ],
    );

    if (borderRadius > 0) {
      map = ClipRRect(borderRadius: BorderRadius.circular(borderRadius), child: map);
    }

    final Widget pin = Container(
      width: pinDiameter,
      height: pinDiameter,
      decoration: BoxDecoration(
        color: AppColors.brand,
        shape: BoxShape.circle,
        boxShadow: AppShadows.pin,
      ),
      child: Center(
        child: IconWidget(
          icon: AppAssets.svg.pin,
          color: AppColors.surface,
          height: pinIconSize,
          width: pinIconSize,
        ),
      ),
    );

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          Positioned.fill(
            child: showHairlines
                ? DecoratedBox(
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppColors.surfaceSubtle),
                        bottom: BorderSide(color: AppColors.surfaceSubtle),
                      ),
                    ),
                    child: map,
                  )
                : map,
          ),
          Align(
            alignment: Alignment(0, widget.pinVerticalAlignment),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Live-location halo: a soft brand ring that swells and fades
                // out behind the pin. Sized off pinDiameter so it reads right on
                // both the small Home strip and the taller detail map.
                if (!_reduced)
                  _PinPulse(pulse: _pulse, pinDiameter: pinDiameter),
                pin,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The breathing ring drawn behind the pin: scales 1.0→1.8 and fades 0.35→0 on
/// each loop of [pulse]. Purely decorative, never intercepts pointer events.
class _PinPulse extends StatelessWidget {
  const _PinPulse({required this.pulse, required this.pinDiameter});

  final Animation<double> pulse;
  final double pinDiameter;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: pulse,
        builder: (context, _) {
          final double t = pulse.value;
          final double scale = 1.0 + 0.8 * t; // 1.0 → 1.8
          final double opacity = 0.35 * (1 - t); // 0.35 → 0
          return Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: pinDiameter,
                height: pinDiameter,
                decoration: const BoxDecoration(
                  color: AppColors.brand,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

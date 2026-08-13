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
class MapView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final LatLng focus = center ?? _defaultCenter;

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
        ),
      ],
    );

    if (borderRadius > 0) {
      map = ClipRRect(borderRadius: BorderRadius.circular(borderRadius), child: map);
    }

    return SizedBox(
      height: height,
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
            alignment: Alignment(0, pinVerticalAlignment),
            child: Container(
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
            ),
          ),
        ],
      ),
    );
  }
}

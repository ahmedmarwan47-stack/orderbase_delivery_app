import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../icons/app_icon.dart';
import '../theme/colors.dart';
import '../theme/shadows.dart';

/// Static decorative map with a centered red pin. Used both as the short strip
/// inside the Home hero card and as the taller rounded map in the order detail.
/// The map itself is a placeholder illustration — swapped for a real map later.
class MapView extends StatelessWidget {
  const MapView({
    super.key,
    required this.height,
    this.borderRadius = 0,
    this.showHairlines = false,
    this.pinDiameter = 36,
    this.pinIconSize = 19,
    this.pinVerticalAlignment = 0,
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

  @override
  Widget build(BuildContext context) {
    Widget map = SvgPicture.asset('assets/images/map_strip.svg', fit: BoxFit.cover);
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
                child: AppIcon(AppIconName.pin, color: Colors.white, size: pinIconSize),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

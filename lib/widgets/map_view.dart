import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';

import '../config/res/config_imports.dart';
import '../core/live_activity/external_links.dart';
import '../theme/shadows.dart';

/// Interactive map with a centered red pin. Used both as the short strip inside
/// the Home hero card and as the taller rounded map in the order detail.
///
/// Renders a real [FlutterMap] with OpenStreetMap raster tiles (pure-Dart, no
/// native plugin — keeps the iOS build CocoaPods-free). The pin sits at the map
/// centre.
///
/// The map is a **still preview** by default ([interactive] off): it holds its
/// frame on the order's address instead of panning under the courier's thumb.
/// That matters twice over — a map that drags inside a scrolling card fights
/// the scroll, and it would swallow the taps of the cards these strips sit in.
/// Real navigation is the open-in-Google-Maps badge's job, and that badge stays
/// live either way.
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
    this.destinationLabel,
    this.showOpenInMaps = true,
    this.interactive = false,
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

  /// Place name handed to Google Maps, so the courier lands on the destination
  /// by name rather than a bare coordinate. Falls back to lat/lng when absent.
  final String? destinationLabel;

  /// Lets the courier pan/zoom the map itself. Off everywhere in the app —
  /// see the class doc.
  final bool interactive;

  /// Shows the "open in Google Maps" badge. The map itself is a preview — real
  /// turn-by-turn belongs to a maps app, and the badge is what says so.
  final bool showOpenInMaps;

  static const LatLng _defaultCenter = LatLng(30.0444, 31.2357);

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> with SingleTickerProviderStateMixin {
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
        interactionOptions: InteractionOptions(
          flags: widget.interactive
              ? InteractiveFlag.all & ~InteractiveFlag.rotate
              : InteractiveFlag.none,
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
      map = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: map,
      );
    }

    // A still map is decoration, so it must not eat the gestures of whatever it
    // is embedded in — the Home hero is tappable through this strip.
    if (!widget.interactive) map = IgnorePointer(child: map);

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
          if (widget.showOpenInMaps)
            Positioned(
              bottom: AppPadding.pH8,
              left: AppPadding.pW8,
              child: _OpenInMapsBadge(
                focus: focus,
                label: widget.destinationLabel,
              ),
            ),
        ],
      ),
    );
  }
}

/// The small "open in Google Maps" chip that sits on the map.
///
/// Deliberately quiet and corner-anchored: the map is a preview of where the
/// order is, and this is the hand-off to an app that can actually navigate.
class _OpenInMapsBadge extends StatelessWidget {
  const _OpenInMapsBadge({required this.focus, this.label});

  final LatLng focus;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppCircular.r8),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppCircular.r8),
        onTap: () => ExternalLinks.openInGoogleMaps(
          lat: focus.latitude,
          lng: focus.longitude,
          label: label,
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: AppPadding.pW8,
            vertical: AppPadding.pH4,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // The real Google Maps mark, drawn as-is: it is a multi-colour
              // brand logo, so it deliberately bypasses IconWidget, which
              // recolours the app's monochrome icon set through a srcIn filter.
              SvgPicture.asset(
                'assets/brand/google_maps.svg',
                height: AppSize.sH16,
              ),
              4.szW,
              Text(
                LocaleKeys.mapOpenInGoogle.tr(),
                style: const TextStyle().setMainTextColor.s12.semiBold,
              ),
            ],
          ),
        ),
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

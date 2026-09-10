import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

/// The progressive blur under the unified header — the page dissolving into
/// the bar instead of hitting an edge, the way iOS 26's scroll edge and
/// Instagram's header do it.
///
/// The box it is given is the header's own extent (status-bar inset
/// included) plus [reach] below it. The blur is full down to [rampIn] above
/// the header's bottom edge and gone at the box's bottom, so the whole ramp
/// is one [rampIn] + [reach] run across the edge and nothing about it is a
/// line. [strength] scales everything — the header fades the effect in over
/// the first stretch of scrolling, since at rest the page's content sits
/// *below* the bar and a blur band reaching down from it would soften the
/// top of a page that has not moved.
///
/// **The ramp is a stack of the engine's own Gaussians**, [steps] of them:
/// the widest and softest first, each next one clipped a little shorter and
/// adding a little more blur, so the blur a pixel receives grows in steps
/// toward the top — each step small enough to pass for a slope — and the page
/// near the edge is *softly blurred*, not sharp under a haze. The page ground
/// is washed over it by a gradient that thins out down the same run. Nothing
/// here is a shader, so every tier renders it the same way; the caller
/// handles *opaque* — sun, gloves, high contrast — by not building this.
///
/// Three dead ends, so nobody walks them again. A hand-rolled ring-tap frost
/// in one backdrop shader leaves ring-shaped ghosts of the text beneath at
/// this radius. ONE engine Gaussian crossfaded into the sharp page down the
/// ramp (a fade shader composed over the blur) reads as a translucent strip
/// with sharp text showing through — the reference's edge is content getting
/// softer, which only a radius that falls with the pixel gives. And the same
/// stack with each band's edge feathered by that fade shader draws a ripple
/// at every band edge on Impeller (measured: the fade weight is right, the
/// band rect is right, and still the composed bands do not meet), where the
/// plain bands meet cleanly. A backdrop under a `ShaderMask` blurs nothing at
/// all, on Impeller as on Skia.
class HeaderBackdrop extends StatelessWidget {
  const HeaderBackdrop({super.key, required this.strength, required this.tint});

  /// 0 = nothing, 1 = the full effect.
  final double strength;

  /// The page ground washed over the blur, at [tintAlpha] when full.
  final Color tint;

  /// How far below the header the ramp reaches, and how far above the
  /// header's bottom edge the blur starts thinning.
  static const double reach = 56;
  static const double rampIn = 16;

  /// The Gaussian's sigma at the top of the ramp (logical px), the wash's
  /// alpha there, and in how many steps the ramp reaches them.
  static const double sigma = 14;
  static const double tintAlpha = 0.5;
  static const int steps = 8;

  @override
  Widget build(BuildContext context) {
    if (strength <= 0) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, c) {
        final h = c.maxHeight;
        const n = steps;
        final run = reach + rampIn;
        final full = sigma * strength;
        final fadeFrom = h - run;
        final a = tintAlpha * strength;
        // Blurs compose in quadrature: the sigma each step adds is what takes
        // the running total one step further up a straight ramp.
        var prev = 0.0;
        final bands = <Widget>[];
        for (var k = 1; k <= n; k++) {
          final total = full * k / n;
          final s = math.sqrt(total * total - prev * prev);
          prev = total;
          bands.add(
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: h - run * (k - 1) / n,
              // A BackdropFilter filters the whole ancestor clip, not just
              // its child: the ClipRect is what confines each step.
              child: ClipRect(
                child: BackdropFilter(
                  // Clamp, or the blur samples transparent past the clip and
                  // the band's bottom edge bleeds dark.
                  filter: ui.ImageFilter.blur(
                    sigmaX: s,
                    sigmaY: s,
                    tileMode: ui.TileMode.clamp,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          );
        }
        return Stack(
          clipBehavior: Clip.none,
          children: [
            ...bands,
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      tint.withValues(alpha: a),
                      tint.withValues(alpha: a),
                      tint.withValues(alpha: a * 0.5),
                      tint.withValues(alpha: 0),
                    ],
                    stops: [
                      0,
                      (fadeFrom / h).clamp(0.0, 1.0),
                      ((fadeFrom + run * 0.5) / h).clamp(0.0, 1.0),
                      1,
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

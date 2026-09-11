import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// The header's scroll-edge fade shader — loaded once at startup, gated at
/// runtime, exactly like [NavGlass]: `ImageFilter.shader` exists only on
/// Impeller, and a shader that fails to load leaves [ready] false so the
/// header falls back to hard-edged strips.
class HeaderBlur {
  HeaderBlur._();

  static ui.FragmentProgram? _program;

  static bool get ready => _program != null;

  static bool get supported => ready && ui.ImageFilter.isShaderFilterSupported;

  static Future<void> load() async {
    if (_program != null) return;
    try {
      _program = await ui.FragmentProgram.fromAsset(
        'assets/shaders/header_fade.frag',
      );
    } catch (_) {
      // Hard strips it is.
    }
  }

  static ui.FragmentShader shader() => _program!.fragmentShader();
}

/// Keeps the ladder's textures warm so a tap into a scrolled page does not
/// pay for them. Each zone of the ladder is a runtime-effect pass over the
/// whole padded screen with a full-screen texture behind it; a page that is
/// hidden renders none, the pool lets them go, and the first frame back
/// allocates them again — 30–90 ms of raster on the simulator, felt as the
/// lens stalling and then jumping (a time-based spring catches up in one
/// frame). This mounts one two-point strip at the ladder's top sigma with an
/// empty window (alpha 0 everywhere, so nothing shows), permanently, under
/// the whole app: the pipeline compiles once at launch under the login
/// screen and the largest texture stays in the pool. Measured: switches into
/// the ladder page went from 30–90 ms to 8–22 ms, for about a millisecond a
/// frame while anything animates (four strips, one per zone, took them to
/// 14–16 for three times the tax — not worth it on the older phones). Builds
/// nothing where the shader path is unsupported.
class HeaderBlurWarmUp extends StatefulWidget {
  const HeaderBlurWarmUp({super.key});

  @override
  State<HeaderBlurWarmUp> createState() => _HeaderBlurWarmUpState();
}

class _HeaderBlurWarmUpState extends State<HeaderBlurWarmUp> {
  final ui.FragmentShader? _shader = HeaderBlur.supported
      ? HeaderBlur.shader()
      : null;

  @override
  void dispose() {
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shader = _shader;
    if (shader == null) return const SizedBox.shrink();
    return IgnorePointer(
      child: SizedBox(
        width: 2,
        height: 2,
        child: ClipRect(
          child: _FadeFilter(
            shader: shader,
            sigma: HeaderBackdrop.sigma,
            // A window that starts past its own end: alpha 0 throughout.
            start: 2,
            fadeFrom: 2,
            fadeTo: 3,
            dpr: MediaQuery.devicePixelRatioOf(context),
            screen: MediaQuery.sizeOf(context),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

/// The progressive blur under the unified header — the page dissolving into
/// the bar instead of hitting an edge, the way iOS 26's scroll edge and
/// Instagram's header do it.
///
/// The box it is given is the header's own extent (status-bar inset
/// included) plus [reach] below it. The blur is full down to [rampIn] above
/// the header's bottom edge and gone at the box's bottom, so the ramp ends
/// *with* the bar. [strength] scales everything — the header fades the
/// effect in over the first stretch of scrolling, since at rest the page's
/// content sits *below* the bar and a blur reaching into it would soften a
/// page that has not moved.
///
/// **The ramp is a ladder of the engine's own Gaussians**: [steps] zones
/// down the run, zone j blurred at `sigma · j / steps`, the block above the
/// run at [sigma]. Each zone's blur is one `BackdropFilter` reading the page
/// once — the engine downsamples a large blur and resamples it back, and a
/// stack of overlapping bands that re-blurred the same pixels eight times
/// over left a grid on dark banners. Hard-edged, the zones show as stairs
/// wherever the page has a sharp horizontal edge (each zone smears it by a
/// different amount), so on Impeller every strip reaches one zone further
/// down and *fades out across it* — `header_fade.frag` composed over the
/// blur — which crossfades neighbouring blur levels into one slope
/// ([_Ladder]). Without shader filters (the web) the same zones keep their
/// hard edges ([_Strips]). The page ground is washed over by a gradient that
/// thins out down the same run. The caller handles *opaque* — sun, gloves,
/// high contrast — by not building this.
///
/// Dead ends, so nobody walks them again: a hand-rolled ring-tap frost in
/// one shader (ring-shaped ghosts of text at this radius); one Gaussian
/// crossfaded into the *sharp* page (a translucent strip with sharp text
/// showing through — the reference's edge is content getting softer); a stack
/// of overlapping bands (the grid above, and feathered, ripples besides); a
/// backdrop under a `ShaderMask` (blurs nothing, on Impeller as on Skia);
/// `BackdropGroup` (shares one *filtered result*, so it only serves
/// identical, non-overlapping filters).
class HeaderBackdrop extends StatelessWidget {
  const HeaderBackdrop({super.key, required this.strength, required this.tint});

  /// 0 = nothing, 1 = the full effect.
  final double strength;

  /// The page ground washed over the blur, at [tintAlpha] when full.
  final Color tint;

  /// How far below the header the ramp reaches, and how far above the
  /// header's bottom edge the blur starts thinning: the blur ends with the
  /// bar, the last few points only so the end is soft rather than a stop.
  static const double reach = 8;
  static const double rampIn = 40;

  /// The Gaussian's sigma at the top of the ramp (logical px), the wash's
  /// alpha there, and in how many zones the ramp climbs to them. Four, not
  /// eight: the ramp came out pixel-identical down the centre and within a
  /// few levels at the margins, and each zone is a backdrop readback plus a
  /// runtime-effect pass over the whole padded screen — the switch to a page
  /// whose ladder is live cost 100–200 ms of raster with eight, 5–20 with four
  /// (measured; a one-time 90 ms warm-up on the session's first ladder aside).
  static const double sigma = 14;
  static const double tintAlpha = 0.5;
  static const int steps = 4;

  @override
  Widget build(BuildContext context) {
    if (strength <= 0) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, c) {
        final h = c.maxHeight;
        final run = reach + rampIn;
        final a = tintAlpha * strength;
        final fadeFrom = h - run;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            if (HeaderBlur.supported)
              _Ladder(height: h, strength: strength)
            else
              _Strips(height: h, strength: strength),
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

/// Zone j (1 = the lowest) of the ramp in a box [h] tall: its top, its bottom
/// and its sigma. Zone [HeaderBackdrop.steps] is the block above the run.
({double top, double bottom, double sigma}) _zone(int j, double h, double s) {
  const n = HeaderBackdrop.steps;
  const run = HeaderBackdrop.reach + HeaderBackdrop.rampIn;
  return (
    top: j == n ? 0.0 : h - run * j / n,
    bottom: h - run * (j - 1) / n,
    sigma: HeaderBackdrop.sigma * s * j / n,
  );
}

/// Impeller: every zone's blur reaches one zone further down and fades out
/// across it, painted lowest first, so zone j shows zone j's level crossfading
/// up into zone j + 1's. Each strip's filter box is padded by three sigma
/// above and below its window and the shader masks that padding to nothing:
/// a blur composed this way pads a thin box with transparent black rather
/// than clamping, and the rows within a few sigma of the box's edges come
/// out dark.
class _Ladder extends StatefulWidget {
  const _Ladder({required this.height, required this.strength});

  final double height;
  final double strength;

  @override
  State<_Ladder> createState() => _LadderState();
}

class _LadderState extends State<_Ladder> {
  late final List<ui.FragmentShader> _shaders = List.generate(
    HeaderBackdrop.steps,
    (_) => HeaderBlur.shader(),
  );

  @override
  void dispose() {
    for (final s in _shaders) {
      s.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final screen = MediaQuery.sizeOf(context);
    final h = widget.height;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (var j = 1; j <= HeaderBackdrop.steps; j++)
          () {
            final z = _zone(j, h, widget.strength);
            // The window: this zone opaque, then a fade across the zone
            // below (the lowest fades across its own lower half, into the
            // page).
            final ownTop = z.top;
            final fadeFrom = j == 1 ? (z.top + z.bottom) / 2 : z.bottom;
            final fadeTo = j == 1 ? z.bottom : _zone(j - 1, h, 1).bottom;
            final pad = 2 * z.sigma + 2;
            final boxTop = math.max(0.0, ownTop - pad);
            final boxBottom = fadeTo + pad;
            final boxH = boxBottom - boxTop;
            return Positioned(
              left: 0,
              right: 0,
              top: boxTop,
              height: boxH,
              // A BackdropFilter filters the whole ancestor clip, not just
              // its child: the ClipRect is what confines each strip.
              child: ClipRect(
                child: _FadeFilter(
                  shader: _shaders[j - 1],
                  sigma: z.sigma,
                  start: (ownTop - boxTop) / boxH,
                  fadeFrom: (fadeFrom - boxTop) / boxH,
                  fadeTo: (fadeTo - boxTop) / boxH,
                  dpr: dpr,
                  screen: screen,
                  child: const SizedBox.expand(),
                ),
              ),
            );
          }(),
      ],
    );
  }
}

class _FadeFilter extends SingleChildRenderObjectWidget {
  const _FadeFilter({
    required this.shader,
    required this.sigma,
    required this.start,
    required this.fadeFrom,
    required this.fadeTo,
    required this.dpr,
    required this.screen,
    super.child,
  });

  final ui.FragmentShader shader;
  final double sigma;
  final double start;
  final double fadeFrom;
  final double fadeTo;
  final double dpr;
  final Size screen;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderFadeFilter(shader, sigma, start, fadeFrom, fadeTo, dpr, screen);

  @override
  void updateRenderObject(BuildContext context, _RenderFadeFilter r) {
    r
      ..sigma = sigma
      ..start = start
      ..fadeFrom = fadeFrom
      ..fadeTo = fadeTo
      ..dpr = dpr
      ..screen = screen;
  }
}

/// The twin of nav_glass.dart's `_RenderGlassFilter`: the filter is rebuilt
/// every paint so the strip's screen rect is the current one. The shader is
/// told that rect and the screen's size so it can place itself in the padded
/// texture the blur hands it (see the comment atop `header_fade.frag`).
class _RenderFadeFilter extends RenderProxyBox {
  _RenderFadeFilter(
    this._shader,
    this._sigma,
    this._start,
    this._fadeFrom,
    this._fadeTo,
    this._dpr,
    this._screen,
  );

  final ui.FragmentShader _shader;

  double _sigma;
  set sigma(double v) {
    if (v == _sigma) return;
    _sigma = v;
    markNeedsPaint();
  }

  double _start;
  set start(double v) {
    if (v == _start) return;
    _start = v;
    markNeedsPaint();
  }

  double _fadeFrom;
  set fadeFrom(double v) {
    if (v == _fadeFrom) return;
    _fadeFrom = v;
    markNeedsPaint();
  }

  double _fadeTo;
  set fadeTo(double v) {
    if (v == _fadeTo) return;
    _fadeTo = v;
    markNeedsPaint();
  }

  double _dpr;
  set dpr(double v) {
    if (v == _dpr) return;
    _dpr = v;
    markNeedsPaint();
  }

  Size _screen;
  set screen(Size v) {
    if (v == _screen) return;
    _screen = v;
    markNeedsPaint();
  }

  @override
  bool get alwaysNeedsCompositing => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    final origin = localToGlobal(Offset.zero);
    final d = _dpr;
    // Indices 0-1 (the input texture size) are the engine's to set.
    _shader
      ..setFloat(2, _screen.width * d)
      ..setFloat(3, _screen.height * d)
      ..setFloat(4, origin.dx * d)
      ..setFloat(5, origin.dy * d)
      ..setFloat(6, size.width * d)
      ..setFloat(7, size.height * d)
      ..setFloat(8, _start)
      ..setFloat(9, _fadeFrom)
      ..setFloat(10, _fadeTo);
    final layer = (this.layer as BackdropFilterLayer?) ?? BackdropFilterLayer();
    layer
      // The blur runs in the layer's own (logical) space; only the shader's
      // numbers are in texture pixels.
      ..filter = ui.ImageFilter.compose(
        outer: ui.ImageFilter.shader(_shader),
        inner: ui.ImageFilter.blur(
          sigmaX: _sigma,
          sigmaY: _sigma,
          tileMode: ui.TileMode.clamp,
        ),
      )
      ..blendMode = BlendMode.srcOver;
    this.layer = layer;
    context.pushLayer(layer, super.paint, offset);
  }
}

/// No shader filters (the web): the same zones with hard edges.
class _Strips extends StatelessWidget {
  const _Strips({required this.height, required this.strength});

  final double height;
  final double strength;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (var j = 1; j <= HeaderBackdrop.steps; j++)
          () {
            final z = _zone(j, height, strength);
            return Positioned(
              left: 0,
              right: 0,
              top: z.top,
              // A pixel of overlap, so rounding never opens a hairline.
              height: z.bottom - z.top + (j == 1 ? 0 : 1),
              child: ClipRect(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(
                    sigmaX: z.sigma,
                    sigmaY: z.sigma,
                    tileMode: ui.TileMode.clamp,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            );
          }(),
      ],
    );
  }
}

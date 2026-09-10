import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// The header's scroll-edge fade shader — loaded once at startup, gated at
/// runtime, exactly like [NavGlass]: `ImageFilter.shader` exists only on
/// Impeller, and a shader that fails to load leaves [ready] false so the
/// header falls back to its stacked-blur tier.
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
      // Stacked blur it is.
    }
  }

  static ui.FragmentShader shader() => _program!.fragmentShader();
}

/// The progressive blur under the unified header — the page dissolving into
/// the bar instead of hitting an edge, the way iOS 26's scroll edge and
/// Instagram's header do it.
///
/// The box it is given is the header's own extent plus [reach] below it; the
/// blur is full down to [rampIn] above the header's bottom edge and gone at
/// the box's bottom, so the whole fade is one [rampIn] + [reach] run across
/// the edge and nothing about it is a line. [strength] scales everything —
/// the header fades the effect in over the first stretch of scrolling, since
/// at rest the page's content sits *below* the bar and a blur band reaching
/// down from it would soften the top of a page that has not moved.
///
/// Two tiers. On Impeller, ONE backdrop filter: the engine's own two-pass
/// Gaussian, composed with `header_fade.frag`, which lets the blurred page thin
/// out down the ramp so the sharp page shows through where it ends — as smooth
/// as the references, since the blur is the engine's ([_FadeBand]). Elsewhere
/// (the web, non-Impeller devices) [steps] stacked backdrop blurs of growing
/// sigma, each clipped a little shorter than the one beneath it, under a
/// gradient wash ([_StackedBand]). The caller handles *opaque* — sun, gloves,
/// high contrast — by not building this at all.
///
/// (A Gaussian backdrop under a `ShaderMask` would be the obvious way and is
/// how a masked `UIVisualEffectView` works, but a backdrop inside a mask layer
/// is handed that layer's own, empty, contents — on Impeller as on Skia — so
/// it blurs nothing.)
class HeaderBackdrop extends StatelessWidget {
  const HeaderBackdrop({super.key, required this.strength, required this.tint});

  /// 0 = nothing, 1 = the full effect.
  final double strength;

  /// The page ground washed over the blur, at [tintAlpha] when full.
  final Color tint;

  /// How far below the header the band reaches, and how far above the
  /// header's bottom edge the blur starts thinning.
  static const double reach = 32;
  static const double rampIn = 16;

  /// The Gaussian's sigma at full strength (logical px) and the wash's alpha.
  static const double sigma = 12;
  static const double tintAlpha = 0.6;

  /// The stacked tier: how many steps the same sigma is reached in.
  static const int steps = 5;

  @override
  Widget build(BuildContext context) {
    if (strength <= 0) return const SizedBox.shrink();
    // A BackdropFilter filters the whole ancestor clip, not just its child:
    // the ClipRect confines it to this band.
    return ClipRect(
      child: HeaderBlur.supported
          ? _FadeBand(strength: strength, tint: tint)
          : _StackedBand(strength: strength, tint: tint),
    );
  }
}

/// Impeller: the engine's Gaussian blur of the backdrop, composed with the
/// fade shader as its outer half. The shader is told the band's screen rect
/// and the screen's size so it can work out which pixel space it was handed
/// (see the comment atop `header_fade.frag`).
class _FadeBand extends StatefulWidget {
  const _FadeBand({required this.strength, required this.tint});

  final double strength;
  final Color tint;

  @override
  State<_FadeBand> createState() => _FadeBandState();
}

class _FadeBandState extends State<_FadeBand> {
  late final ui.FragmentShader _shader = HeaderBlur.shader();

  @override
  void dispose() {
    _shader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _FadeFilter(
    shader: _shader,
    strength: widget.strength,
    tint: widget.tint,
    dpr: MediaQuery.devicePixelRatioOf(context),
    screen: MediaQuery.sizeOf(context),
    child: const SizedBox.expand(),
  );
}

class _FadeFilter extends SingleChildRenderObjectWidget {
  const _FadeFilter({
    required this.shader,
    required this.strength,
    required this.tint,
    required this.dpr,
    required this.screen,
    super.child,
  });

  final ui.FragmentShader shader;
  final double strength;
  final Color tint;
  final double dpr;
  final Size screen;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderFadeFilter(shader, strength, tint, dpr, screen);

  @override
  void updateRenderObject(BuildContext context, _RenderFadeFilter r) {
    r
      ..strength = strength
      ..tint = tint
      ..dpr = dpr
      ..screen = screen;
  }
}

/// The twin of nav_glass.dart's `_RenderGlassFilter`: the filter is rebuilt
/// every paint so the band's screen rect is the current one.
class _RenderFadeFilter extends RenderProxyBox {
  _RenderFadeFilter(
    this._shader,
    this._strength,
    this._tint,
    this._dpr,
    this._screen,
  );

  final ui.FragmentShader _shader;

  double _strength;
  set strength(double v) {
    if (v == _strength) return;
    _strength = v;
    markNeedsPaint();
  }

  Color _tint;
  set tint(Color v) {
    if (v == _tint) return;
    _tint = v;
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
    final s = _strength;
    final fadeFrom =
        (size.height - HeaderBackdrop.reach - HeaderBackdrop.rampIn) /
        size.height;
    // Indices 0-1 (the input texture size) are the engine's to set.
    _shader
      ..setFloat(2, _screen.width * d)
      ..setFloat(3, _screen.height * d)
      ..setFloat(4, origin.dx * d)
      ..setFloat(5, origin.dy * d)
      ..setFloat(6, size.width * d)
      ..setFloat(7, size.height * d)
      ..setFloat(8, fadeFrom.clamp(0.0, 1.0))
      ..setFloat(9, _tint.r)
      ..setFloat(10, _tint.g)
      ..setFloat(11, _tint.b)
      ..setFloat(12, HeaderBackdrop.tintAlpha * s);
    // The blur runs in the layer's own (logical) space; only the shader's
    // numbers are in texture pixels.
    final sigma = HeaderBackdrop.sigma * s;
    final layer = (this.layer as BackdropFilterLayer?) ?? BackdropFilterLayer();
    layer
      ..filter = ui.ImageFilter.compose(
        outer: ui.ImageFilter.shader(_shader),
        inner: ui.ImageFilter.blur(
          sigmaX: sigma,
          sigmaY: sigma,
          tileMode: ui.TileMode.clamp,
        ),
      )
      ..blendMode = BlendMode.srcOver;
    this.layer = layer;
    context.pushLayer(layer, super.paint, offset);
  }
}

/// The blur tier: [HeaderBackdrop.steps] backdrop blurs stacked from the
/// widest and softest to the narrowest and strongest, so the blur a pixel
/// receives grows in steps toward the top — each step small enough to pass
/// for a slope — under a wash that thins out over the same run.
class _StackedBand extends StatelessWidget {
  const _StackedBand({required this.strength, required this.tint});

  final double strength;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final h = c.maxHeight;
        final fadeLen = HeaderBackdrop.reach + HeaderBackdrop.rampIn;
        final fadeFrom = h - fadeLen;
        final full = HeaderBackdrop.sigma * strength;
        const n = HeaderBackdrop.steps;
        final children = <Widget>[];
        var prev = 0.0;
        for (var i = 0; i < n; i++) {
          // Blurs compose in quadrature: the sigma this step adds is what
          // takes the running total one step further up a straight ramp.
          final total = full * (i + 1) / n;
          final sigma = math.sqrt(total * total - prev * prev);
          prev = total;
          children.add(
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: h - fadeLen * i / n,
              child: ClipRect(
                child: BackdropFilter(
                  // Clamp, or the blur samples transparent past the clip and
                  // the band's bottom edge bleeds dark.
                  filter: ui.ImageFilter.blur(
                    sigmaX: sigma,
                    sigmaY: sigma,
                    tileMode: ui.TileMode.clamp,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          );
        }
        final a = HeaderBackdrop.tintAlpha * strength;
        children.add(
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    tint.withValues(alpha: a),
                    tint.withValues(alpha: a),
                    tint.withValues(alpha: 0),
                  ],
                  stops: [0, (fadeFrom / h).clamp(0.0, 1.0), 1],
                ),
              ),
            ),
          ),
        );
        return Stack(clipBehavior: Clip.none, children: children);
      },
    );
  }
}

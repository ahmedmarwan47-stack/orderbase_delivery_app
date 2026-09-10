import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'nav_bar_controller.dart';

/// The header's scroll-edge shader — loaded once at startup, gated at
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
        'assets/shaders/header_blur.frag',
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
/// Two tiers, resolved the way the tab bar resolves its material: *glass* —
/// `header_blur.frag`, one backdrop pass with the radius a function of the
/// pixel's place in the fade; *blur* — [steps] stacked backdrop blurs of
/// growing sigma, each clipped a little shorter than the one beneath it,
/// under a gradient wash. The web is always the second (no shader filters in
/// the browser engines). The caller handles *opaque* — sun, gloves, high
/// contrast — by not building this at all.
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

  /// The frost radius at full strength (logical px) and the wash's alpha.
  static const double blur = 16;
  static const double tintAlpha = 0.6;

  /// The blur tier: its sigma at full strength, in how many steps.
  static const double sigma = 7;
  static const int steps = 5;

  @override
  Widget build(BuildContext context) {
    if (strength <= 0) return const SizedBox.shrink();
    final glass =
        NavBarController.instance.effectiveMaterial == NavMaterial.glass &&
        HeaderBlur.supported;
    // A BackdropFilter filters the whole ancestor clip, not just its child:
    // the ClipRect confines it to this band.
    return ClipRect(
      child: glass
          ? _ShaderBand(
              strength: strength,
              tint: tint,
              dpr: MediaQuery.devicePixelRatioOf(context),
            )
          : _StackedBand(strength: strength, tint: tint),
    );
  }
}

class _ShaderBand extends StatefulWidget {
  const _ShaderBand({
    required this.strength,
    required this.tint,
    required this.dpr,
  });

  final double strength;
  final Color tint;
  final double dpr;

  @override
  State<_ShaderBand> createState() => _ShaderBandState();
}

class _ShaderBandState extends State<_ShaderBand> {
  late final ui.FragmentShader _shader = HeaderBlur.shader();

  @override
  void dispose() {
    _shader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _HeaderFilter(
    shader: _shader,
    strength: widget.strength,
    tint: widget.tint,
    dpr: widget.dpr,
    child: const SizedBox.expand(),
  );
}

class _HeaderFilter extends SingleChildRenderObjectWidget {
  const _HeaderFilter({
    required this.shader,
    required this.strength,
    required this.tint,
    required this.dpr,
    super.child,
  });

  final ui.FragmentShader shader;
  final double strength;
  final Color tint;
  final double dpr;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderHeaderFilter(shader, strength, tint, dpr);

  @override
  void updateRenderObject(BuildContext context, _RenderHeaderFilter r) {
    r
      ..strength = strength
      ..tint = tint
      ..dpr = dpr;
  }
}

/// The twin of nav_glass.dart's `_RenderGlassFilter`: a backdrop filter whose
/// shader is told the band's *screen* rect at every paint, because the engine
/// hands a backdrop shader the whole screen, not the widget's clip.
class _RenderHeaderFilter extends RenderProxyBox {
  _RenderHeaderFilter(this._shader, this._strength, this._tint, this._dpr);

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

  @override
  bool get alwaysNeedsCompositing => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    final origin = localToGlobal(Offset.zero);
    final d = _dpr;
    final s = _strength;
    final fadeFrom = size.height - HeaderBackdrop.reach - HeaderBackdrop.rampIn;
    // Indices 0-1 (the texture size) are the engine's to set.
    _shader
      ..setFloat(2, origin.dx * d)
      ..setFloat(3, origin.dy * d)
      ..setFloat(4, size.width * d)
      ..setFloat(5, size.height * d)
      ..setFloat(6, (origin.dy + fadeFrom) * d)
      ..setFloat(7, HeaderBackdrop.blur * s * d)
      ..setFloat(8, _tint.r)
      ..setFloat(9, _tint.g)
      ..setFloat(10, _tint.b)
      ..setFloat(11, HeaderBackdrop.tintAlpha * s);
    final layer = (this.layer as BackdropFilterLayer?) ?? BackdropFilterLayer();
    layer
      ..filter = ui.ImageFilter.shader(_shader)
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

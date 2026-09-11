import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// The glass shader — loaded once at startup, gated at runtime.
///
/// `ImageFilter.shader` only exists on Impeller (iOS, and Android where the
/// device runs it); everywhere else [supported] is false and the bar falls
/// back to its blur tier. Loading never throws into the app: a missing or
/// uncompilable shader simply leaves [ready] false.
///
/// Call [load] before the first frame (`await LiquidGlass.load()` in `main`)
/// or the bar starts on the blur tier and stays there until it rebuilds.
class LiquidGlass {
  LiquidGlass._();

  static ui.FragmentProgram? _program;

  static bool get ready => _program != null;

  /// The glass tier can render on this device right now.
  static bool get supported => ready && ui.ImageFilter.isShaderFilterSupported;

  static Future<void> load() async {
    if (_program != null) return;
    try {
      _program = await ui.FragmentProgram.fromAsset(
        'packages/liquid_tab_bar/assets/shaders/nav_glass.frag',
      );
    } catch (_) {
      // Blur tier it is.
    }
  }

  static ui.FragmentShader shader() => _program!.fragmentShader();
}

/// One glass material — every knob the shader exposes, in logical pixels.
/// Two presets: [bar] is the tab bar itself, [lens] the selection highlight
/// that rides inside it.
class GlassStyle {
  const GlassStyle({
    required this.rim,
    required this.curve,
    required this.depth,
    required this.dispersion,
    required this.blur,
    required this.saturation,
    required this.tint,
    required this.specular,
    required this.light,
    required this.edgeDark,
    this.shadow = 0,
    this.shadowBlur = 0,
    this.shadowOffset = Offset.zero,
  });

  /// The bar: measured against the iOS 26 tab bar over a white page — a
  /// near-clear frost with the lensing confined to a thin rim, lit from the
  /// top-left (the lit edge is the brighter one there), a faint shadow that
  /// falls mostly downward.
  static const bar = GlassStyle(
    rim: 7,
    curve: 0.9,
    depth: 6,
    dispersion: 0.08,
    blur: 14,
    saturation: 1.25,
    tint: Color(0x94FFFFFF),
    specular: 0.42,
    light: Offset(-0.55, -0.85),
    edgeDark: 0.035,
    shadow: 0.07,
    shadowBlur: 14,
    shadowOffset: Offset(0, 3),
  );

  /// The selection lens: no frost of its own (it sits on glass already), a
  /// neutral 7% shade — iOS 26's has no colour of its own; the tint comes from
  /// the glyph on it — and a stronger, narrower bend so it visibly lenses the
  /// labels it slides across.
  static const lens = GlassStyle(
    rim: 10,
    curve: 1.2,
    depth: 5,
    dispersion: 0.12,
    blur: 0,
    saturation: 1,
    tint: Color(0x12000000),
    specular: 0.14,
    light: Offset(-0.55, -0.85),
    edgeDark: 0.03,
  );

  /// Width of the lensing rim.
  final double rim;

  /// How steeply the rim's surface tilts.
  final double curve;

  /// Refraction displacement at the rim.
  final double depth;

  /// Chromatic dispersion — how far red and blue are bent apart at the rim.
  /// This is the soap-bubble fringe; the bar keeps it near zero, the lens
  /// opens it with its speed.
  final double dispersion;

  /// Frost radius; 0 is clear glass.
  final double blur;

  /// Saturation multiplier on what shows through.
  final double saturation;

  /// Straight-alpha tint laid over the sampled page.
  final Color tint;

  /// Rim light strength.
  final double specular;

  /// Light direction, in the surface's own xy.
  final Offset light;

  /// Rim shade on the side facing away from the light.
  final double edgeDark;

  /// Drop shadow alpha; 0 for none.
  final double shadow;
  final double shadowBlur;
  final Offset shadowOffset;

  /// The same glass with another [dispersion] and [specular] — what the lens
  /// becomes under a dragging finger. Hands back this very instance when
  /// nothing changes, so a repaint is only asked for when the glass differs.
  GlassStyle copyWith({double? dispersion, double? specular}) {
    final d = dispersion ?? this.dispersion;
    final s = specular ?? this.specular;
    if (d == this.dispersion && s == this.specular) return this;
    return GlassStyle(
      rim: rim,
      curve: curve,
      depth: depth,
      dispersion: d,
      blur: blur,
      saturation: saturation,
      tint: tint,
      specular: s,
      light: light,
      edgeDark: edgeDark,
      shadow: shadow,
      shadowBlur: shadowBlur,
      shadowOffset: shadowOffset,
    );
  }
}

/// A capsule of [style] glass, [size] big with [radius] corners, rendered as a
/// backdrop filter over whatever is painted beneath it. The widget is [pad]
/// larger than the capsule on every side — that is the drop shadow's room;
/// outside the capsule the shader hands the page back untouched.
///
/// The shader is told where the capsule is in *screen* pixels, measured at
/// paint time, because the engine gives a backdrop shader the whole screen as
/// its input rather than the widget's own clip (see the comment atop
/// `nav_glass.frag`). That breaks inside a save layer whose bounds are not
/// the screen (an `Opacity` or `ShaderMask` ancestor) — never wrap it in one.
/// Only build it when [LiquidGlass.supported] is true.
class GlassSurface extends StatefulWidget {
  const GlassSurface({
    super.key,
    required this.size,
    required this.radius,
    required this.pad,
    required this.style,
  });

  final Size size;
  final double radius;
  final double pad;
  final GlassStyle style;

  @override
  State<GlassSurface> createState() => _GlassSurfaceState();
}

class _GlassSurfaceState extends State<GlassSurface> {
  late final ui.FragmentShader _shader = LiquidGlass.shader();

  @override
  void dispose() {
    _shader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A BackdropFilter filters the whole ancestor clip, not just its child:
    // the ClipRect is what confines it to this padded box.
    return SizedBox(
      width: widget.size.width + 2 * widget.pad,
      height: widget.size.height + 2 * widget.pad,
      child: ClipRect(
        child: _GlassFilter(
          shader: _shader,
          style: widget.style,
          radius: widget.radius,
          pad: widget.pad,
          dpr: MediaQuery.devicePixelRatioOf(context),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _GlassFilter extends SingleChildRenderObjectWidget {
  const _GlassFilter({
    required this.shader,
    required this.style,
    required this.radius,
    required this.pad,
    required this.dpr,
    super.child,
  });

  final ui.FragmentShader shader;
  final GlassStyle style;
  final double radius;
  final double pad;
  final double dpr;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderGlassFilter(shader, style, radius, pad, dpr);

  @override
  void updateRenderObject(BuildContext context, _RenderGlassFilter r) {
    r
      ..style = style
      ..radius = radius
      ..pad = pad
      ..dpr = dpr;
  }
}

/// [RenderBackdropFilter]'s shape, with the filter rebuilt every paint so the
/// capsule's screen rect and the style's numbers are the current ones.
class _RenderGlassFilter extends RenderProxyBox {
  _RenderGlassFilter(
    this._shader,
    this._style,
    this._radius,
    this._pad,
    this._dpr,
  );

  final ui.FragmentShader _shader;

  GlassStyle _style;
  set style(GlassStyle v) {
    if (identical(v, _style)) return;
    _style = v;
    markNeedsPaint();
  }

  double _radius;
  set radius(double v) {
    if (v == _radius) return;
    _radius = v;
    markNeedsPaint();
  }

  double _pad;
  set pad(double v) {
    if (v == _pad) return;
    _pad = v;
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
    final s = _style;
    // Indices 0-1 (the texture size) are the engine's to set.
    _shader
      ..setFloat(2, (origin.dx + _pad) * d)
      ..setFloat(3, (origin.dy + _pad) * d)
      ..setFloat(4, (size.width - 2 * _pad) * d)
      ..setFloat(5, (size.height - 2 * _pad) * d)
      ..setFloat(6, _radius * d)
      ..setFloat(7, s.rim * d)
      ..setFloat(8, s.curve)
      ..setFloat(9, s.depth * d)
      ..setFloat(10, s.dispersion)
      ..setFloat(11, s.blur * d)
      ..setFloat(12, s.saturation)
      ..setFloat(13, s.tint.r)
      ..setFloat(14, s.tint.g)
      ..setFloat(15, s.tint.b)
      ..setFloat(16, s.tint.a)
      ..setFloat(17, s.specular)
      ..setFloat(18, s.light.dx)
      ..setFloat(19, s.light.dy)
      ..setFloat(20, s.edgeDark)
      ..setFloat(21, s.shadow)
      ..setFloat(22, s.shadowBlur * d)
      ..setFloat(23, s.shadowOffset.dx * d)
      ..setFloat(24, s.shadowOffset.dy * d);
    final layer = (this.layer as BackdropFilterLayer?) ?? BackdropFilterLayer();
    layer
      ..filter = ui.ImageFilter.shader(_shader)
      ..blendMode = BlendMode.srcOver;
    this.layer = layer;
    context.pushLayer(layer, super.paint, offset);
  }
}

/// The shader's lighting, painted — for the blur tier, which has the frost
/// and the tint but no shader to light the rim. Nothing here refracts (that
/// needs the backdrop, which only Impeller hands a shader); what it gives back
/// is the rest of what makes the capsule read as glass: the hairline of light
/// along the lit edge, the soft band of rim light inside it, the whisper of
/// shade on the far side. Numbers come from the same [GlassStyle] the shader
/// uses, so the two tiers agree on where the light is and how strong.
///
/// Paint it INSIDE the capsule's clip, over the frost and the sheen.
class GlassLightPainter extends CustomPainter {
  const GlassLightPainter({
    required this.style,
    required this.radius,
    this.fringeWarm = const Color(0xFFFFB347),
    this.fringeCool = const Color(0xFF4DA3FF),
  });

  final GlassStyle style;
  final double radius;

  /// The two threads the hairline splits into while the glass disperses.
  final Color fringeWarm;
  final Color fringeCool;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = Radius.circular(radius);
    // The gradient runs from the lit edge to the far one, along the light.
    final l = style.light;
    final len = l.distance == 0 ? 1.0 : l.distance;
    final begin = Alignment(l.dx / len, l.dy / len);
    final end = Alignment(-l.dx / len, -l.dy / len);
    final lit = (style.specular * 1.4).clamp(0.0, 1.0);
    final dark = (style.edgeDark * 1.5).clamp(0.0, 1.0);

    // The rim band: as wide as the shader's rim, softened, strongest where
    // the edge faces the light and gone before the middle.
    final band = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = style.rim
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, style.rim * 0.5)
      ..shader = LinearGradient(
        begin: begin,
        end: end,
        colors: [
          const Color(0xFFFFFFFF).withValues(alpha: lit * 0.35),
          const Color(0x00FFFFFF),
        ],
        stops: const [0.0, 0.55],
      ).createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(style.rim / 2), r),
      band,
    );

    // The hairline: one pixel of light along the lit edge, a hint of shade
    // along the far one.
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..shader = LinearGradient(
        begin: begin,
        end: end,
        colors: [
          const Color(0xFFFFFFFF).withValues(alpha: lit),
          const Color(0xFFFFFFFF).withValues(alpha: lit * 0.5),
          const Color(0x00FFFFFF),
          const Color(0xFF000000).withValues(alpha: dark),
        ],
        stops: const [0.0, 0.3, 0.6, 1.0],
      ).createShader(rect);
    canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(0.5), r), line);

    // Dispersing — a finger dragging the lens — the hairline splits into a
    // warm thread on the edge and a cool one just inside it: this tier's
    // share of the fringe the shader shows, since it cannot bend the page.
    // Nothing at rest; [GlassStyle.lens]'s resting dispersion is below the
    // threshold.
    final k = ((style.dispersion - 0.2) / 0.6).clamp(0.0, 1.0);
    if (k > 0) {
      Paint thread(Color c, double alpha) => Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..shader = LinearGradient(
          begin: begin,
          end: end,
          colors: [c.withValues(alpha: alpha), c.withValues(alpha: 0)],
          stops: const [0.0, 0.55],
        ).createShader(rect);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.deflate(0.5), r),
        thread(fringeWarm, lit * k),
      );
      final inset = 0.5 + 1.5 * k;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          rect.deflate(inset),
          Radius.circular(radius - inset),
        ),
        thread(fringeCool, lit * 0.8 * k),
      );
    }
  }

  @override
  bool shouldRepaint(GlassLightPainter old) =>
      old.style != style ||
      old.radius != radius ||
      old.fringeWarm != fringeWarm ||
      old.fringeCool != fringeCool;
}

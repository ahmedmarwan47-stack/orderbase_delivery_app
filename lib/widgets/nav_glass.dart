import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// The tab bar's glass shader — loaded once at startup, gated at runtime.
///
/// `ImageFilter.shader` only exists on Impeller (iOS, and Android where the
/// device runs it); everywhere else [supported] is false and the bar falls
/// back to its blur tier. Loading never throws into the app: a missing or
/// uncompilable shader simply leaves [ready] false.
class NavGlass {
  NavGlass._();

  static ui.FragmentProgram? _program;

  static bool get ready => _program != null;

  /// The glass tier can render on this device right now.
  static bool get supported => ready && ui.ImageFilter.isShaderFilterSupported;

  static Future<void> load() async {
    if (_program != null) return;
    try {
      _program = await ui.FragmentProgram.fromAsset(
        'assets/shaders/nav_glass.frag',
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
    specular: 0.55,
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
    specular: 0.35,
    light: Offset(-0.55, -0.85),
    edgeDark: 0.05,
  );

  final double rim;
  final double curve;
  final double depth;
  final double dispersion;
  final double blur;
  final double saturation;
  final Color tint;
  final double specular;
  final Offset light;
  final double edgeDark;
  final double shadow;
  final double shadowBlur;
  final Offset shadowOffset;
}

/// A capsule of [style] glass, [size] big with [radius] corners, rendered as a
/// backdrop filter over whatever is painted beneath it. The widget is [pad]
/// larger than the capsule on every side — that is the drop shadow's room;
/// outside the capsule the shader hands the page back untouched.
///
/// The shader is told where the capsule is in *screen* pixels, measured at
/// paint time, because the engine gives a backdrop shader the whole screen as
/// its input rather than the widget's own clip (see the comment atop
/// `nav_glass.frag`). Only build it when [NavGlass.supported] is true.
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
  late final ui.FragmentShader _shader = NavGlass.shader();

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
  _RenderGlassFilter(this._shader, this._style, this._radius, this._pad, this._dpr);

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

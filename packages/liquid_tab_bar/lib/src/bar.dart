import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'controller.dart';
import 'glass.dart';
import 'theme.dart';

/// The floating tab bar — built to iOS 26's own numbers and manners, so an
/// app's bar and the system apps beside it behave as one.
///
/// **Geometry** was measured off the real iOS 26 bar (Files on an iPhone 17
/// Pro): 62pt tall and 21pt off the screen edge (64 and 20 here, on a 4px
/// grid), `n × 86 + 16` wide and capped at the screen less 2 × 20, the
/// selection lens a slot + 8 wide and the bar − 8 tall. Everything is in
/// absolute logical pixels — iOS does not scale its bar with the screen, so
/// neither does this.
///
/// **Material** comes in three tiers, picked by [LiquidTabBarController]:
/// *glass* (the refraction shader — lensing at the rim, a top-left light,
/// dispersion, frost, its own shadow), *blur* (backdrop blur + saturation
/// under the same tint, with the shader's rim light painted on, for devices
/// without Impeller or that the frame governor stepped down), and *opaque* —
/// a solid pill, no backdrop at all — which `MediaQuery.highContrast` and
/// [forceOpaque] force regardless.
///
/// **Manners**: scrolling down folds the bar into a pill holding only the
/// selected tab, scrolling up opens it; the lens slides between tabs on a
/// spring and stretches with its own speed; a finger can press and scrub
/// along the bar, the lens glued to it with a tick at every tab, and release
/// to choose. While it moves the lens disperses light like a soap bubble —
/// the glyphs and labels its rim crosses split into a warm copy and a cool
/// one, and a thin-film band lies along its edge. All of it jumps straight to
/// the end state under Reduce Motion.
///
/// **It only works because the page passes underneath it.** Put it in
/// `Scaffold(extendBody: true)`'s `bottomNavigationBar` slot and give the
/// scrollable [reservedHeight] of bottom padding. Prefer ONE bar over every
/// tab page (a shell with an `IndexedStack`), so [selectedIndex] changes on
/// this widget and the lens slides from the old tab to the new one.
///
/// [selectedIndex] is null on pages that are not a tab: nothing is
/// highlighted and there is nothing to fold into.
class LiquidTabBar extends StatefulWidget {
  const LiquidTabBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    this.onSelected,
    this.controller,
    this.theme = const LiquidTabBarTheme(),
    this.forceOpaque = false,
    this.haptic = HapticFeedback.selectionClick,
  }) : assert(items.length > 0);

  final List<LiquidTabItem> items;
  final int? selectedIndex;
  final ValueChanged<int>? onSelected;

  /// Fold state and material; [LiquidTabBarController.shared] when null.
  final LiquidTabBarController? controller;

  final LiquidTabBarTheme theme;

  /// Draw the opaque tier whatever the controller says — an app's own
  /// high-visibility mode, say.
  final bool forceOpaque;

  /// Fired every time a scrubbing finger crosses into another tab. Null for
  /// silence.
  final VoidCallback? haptic;

  /// The bar's height when open (iOS: 62).
  static const double barHeight = 64;

  static const double _slotWidth = 86;
  static const double _barPadding = 8;
  static const double _sideMargin = 20; // iOS: 21
  static const double _gapNotch = 20; // iOS: 21 above the screen edge
  static const double _gapFlat = 12;
  static const double _lensOverhang = 8;
  static const double _lensInset = 4;
  static const double _pillWidth = 76;
  static const double _glassPad = 24; // room for the shadow and rim sampling
  static const double _iconSize = 23;
  static const double _labelHeight = 17;
  static const double _iconLabelGap = 4;

  /// The lens's dispersion — the soap-bubble fringe at its rim. A whisper at
  /// rest ([GlassStyle.lens]), more under a pressed finger, and wide open as
  /// the finger drags it: full at [_fringeFullSpeed] slots per second, the
  /// pace of a brisk scrub, with the rim light brightening to
  /// [_fringeSpecular] alongside so the fringe has something to ride on.
  static const double _fringePressed = 0.5;
  static const double _fringeMoving = 0.95;
  static const double _fringeSpecular = 0.36;
  static const double _fringeFullSpeed = 3;

  /// How far a finger travels along the bar before a press is a scrub.
  static const double _scrubSlop = 6;

  /// Where the glyph's centre sits when the bar is open.
  static const double _iconCenterY =
      (barHeight - (_iconSize + _iconLabelGap + _labelHeight)) / 2 +
          _iconSize / 2;

  /// Vertical space the bar occupies at the bottom of a page — the pill, the
  /// gap it floats above the screen edge, and a little breathing room over
  /// it. Every scrollable behind the bar needs this much bottom padding, or
  /// its last row hides under the pill forever.
  ///
  /// Inside a `Scaffold(extendBody: true)` body the framework already hands
  /// down a MediaQuery whose bottom padding is the *measured* height of
  /// everything in the `bottomNavigationBar` slot, so that wins when it is
  /// the larger of the two.
  static double reservedHeight(BuildContext context) => math.max(
        barHeight + _bottomGap(context) + 12,
        MediaQuery.paddingOf(context).bottom,
      );

  /// How far the pill floats above the screen edge: iOS puts it 21pt up on a
  /// home-indicator phone — below the safe area, not above it.
  static double _bottomGap(BuildContext context) =>
      MediaQuery.viewPaddingOf(context).bottom > 0 ? _gapNotch : _gapFlat;

  @override
  State<LiquidTabBar> createState() => _LiquidTabBarState();
}

class _LiquidTabBarState extends State<LiquidTabBar>
    with TickerProviderStateMixin {
  LiquidTabBarController get _nav =>
      widget.controller ?? LiquidTabBarController.shared;
  LiquidTabBarController? _listening;

  /// 0 = open, 1 = folded into the pill. Unbounded so the spring may
  /// overshoot a hair either side.
  late final AnimationController _fold = AnimationController.unbounded(
    vsync: this,
    value: _nav.minimized ? 1 : 0,
  );

  /// The lens's position in visual slots (0 = the leftmost slot).
  late final AnimationController _lens = AnimationController.unbounded(
    vsync: this,
    value: (_visualSlot(widget.selectedIndex) ?? 0).toDouble(),
  );

  bool _pressed = false;
  bool _scrubbing = false;

  /// Where the finger landed; null once it has lifted.
  Offset? _down;

  /// The finger's speed along the bar while scrubbing, in slots per second,
  /// and the short relaxation that lets the stretch it drives ease off once
  /// the finger stops — a lens that stays stretched under a still finger
  /// reads as stuck.
  double _fingerVelocity = 0;
  int? _fingerAt;
  late final AnimationController _relax = AnimationController(
    vsync: this,
    duration: widget.theme.relax,
    value: 1,
  );

  /// The visual slot under the finger while scrubbing — a tick every time it
  /// changes.
  int? _hover;

  @override
  void initState() {
    super.initState();
    _listen();
  }

  void _listen() {
    final c = _nav;
    if (identical(c, _listening)) return;
    _listening?.removeListener(_onNav);
    c.addListener(_onNav);
    _listening = c;
  }

  @override
  void didUpdateWidget(LiquidTabBar old) {
    super.didUpdateWidget(old);
    _listen();
    _relax.duration = widget.theme.relax;
    if (old.selectedIndex != widget.selectedIndex && !_scrubbing) {
      final v = _visualSlot(widget.selectedIndex);
      if (v != null) _spring(_lens, v.toDouble());
    }
  }

  @override
  void dispose() {
    _listening?.removeListener(_onNav);
    _fold.dispose();
    _lens.dispose();
    _relax.dispose();
    super.dispose();
  }

  void _onNav() => _spring(_fold, _nav.minimized ? 1 : 0);

  bool get _reduced => MediaQuery.disableAnimationsOf(context);

  /// Drive [c] to [target] on the theme's spring, carrying whatever velocity
  /// it has — an interrupted fold reverses mid-air instead of snapping.
  void _spring(AnimationController c, double target, {double? velocity}) {
    if (!mounted) return;
    if (_reduced) {
      c.value = target;
      return;
    }
    if (!c.isAnimating && (c.value - target).abs() < 0.0005) return;
    c.animateWith(
      SpringSimulation(
        widget.theme.spring,
        c.value,
        target,
        velocity ?? c.velocity,
      ),
    );
  }

  bool get _rtl => Directionality.of(context) == TextDirection.rtl;
  int get _n => widget.items.length;

  /// A tab's slot counted from the left, whatever the reading direction.
  int? _visualSlot(int? i) => i == null ? null : (_rtl ? _n - 1 - i : i);

  int _indexAtVisual(int v) => _rtl ? _n - 1 - v : v;

  _Geometry _geometry(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final barW = math.min(
      _n * LiquidTabBar._slotWidth + 2 * LiquidTabBar._barPadding,
      w - 2 * LiquidTabBar._sideMargin,
    );
    final slotW = (barW - 2 * LiquidTabBar._barPadding) / _n;
    final left = (w - barW) / 2;
    final expanded = Rect.fromLTWH(left, 0, barW, LiquidTabBar.barHeight);
    // The folded pill is the lens with the bar shrunk around it, parked at
    // the leading edge — where the first tab lives.
    final pillH = LiquidTabBar.barHeight - 2 * LiquidTabBar._lensInset;
    final pillLeft =
        _rtl ? expanded.right - LiquidTabBar._pillWidth : expanded.left;
    final pill = Rect.fromLTWH(
      pillLeft,
      LiquidTabBar._lensInset,
      LiquidTabBar._pillWidth,
      pillH,
    );
    return _Geometry(expanded: expanded, pill: pill, slotW: slotW);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_nav, _fold, _lens, _relax]),
      builder: (context, _) => _bar(context),
    );
  }

  Widget _bar(BuildContext context) {
    final g = _geometry(context);
    final gap = LiquidTabBar._bottomGap(context);
    final opaque = MediaQuery.highContrastOf(context) ||
        widget.forceOpaque ||
        _nav.effectiveMaterial == LiquidTabBarMaterial.opaque;
    final material =
        opaque ? LiquidTabBarMaterial.opaque : _nav.effectiveMaterial;
    // A page with no tab selected has nothing to fold into.
    final t = widget.selectedIndex == null ? 0.0 : _fold.value;
    final rect = Rect.lerp(g.expanded, g.pill, t)!;
    final radius = rect.height / 2;
    final pad =
        material == LiquidTabBarMaterial.glass ? LiquidTabBar._glassPad : 0.0;

    return SizedBox(
      height: LiquidTabBar.barHeight + gap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // The surface and its shadow — free to paint past the box.
          Positioned(
            left: rect.left - pad,
            top: rect.top - pad,
            width: rect.width + 2 * pad,
            height: rect.height + 2 * pad,
            child: IgnorePointer(
              child: _surface(material, rect.size, radius, pad),
            ),
          ),
          // What sits on the glass, clipped to the capsule.
          Positioned.fromRect(
            rect: rect,
            child: IgnorePointer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: _content(g, rect, t, material),
              ),
            ),
          ),
          Positioned.fromRect(rect: rect, child: _touch(g, rect, t)),
        ],
      ),
    );
  }

  Widget _surface(
    LiquidTabBarMaterial m,
    Size size,
    double radius,
    double pad,
  ) {
    final th = widget.theme;
    final r = BorderRadius.circular(radius);
    switch (m) {
      case LiquidTabBarMaterial.glass:
        return GlassSurface(
          size: size,
          radius: radius,
          pad: pad,
          style: th.barGlass,
        );
      case LiquidTabBarMaterial.blur:
      case LiquidTabBarMaterial.auto:
        return DecoratedBox(
          decoration: BoxDecoration(borderRadius: r, boxShadow: th.shadow),
          child: ClipRRect(
            borderRadius: r,
            child: BackdropFilter(
              filter: _frost,
              child: DecoratedBox(
                decoration: BoxDecoration(color: th.glassTint, borderRadius: r),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [th.sheenTop, th.sheenBottom],
                    ),
                    borderRadius: r,
                    border: Border.all(color: th.glassEdge),
                  ),
                  // The shader's rim light, painted: without it the blur
                  // tier is a frosted slab next to the glass tier's capsule.
                  child: CustomPaint(
                    painter: GlassLightPainter(
                      style: th.barGlass,
                      radius: radius,
                      fringeWarm: th.fringeWarm,
                      fringeCool: th.fringeCool,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
          ),
        );
      case LiquidTabBarMaterial.opaque:
        return DecoratedBox(
          decoration: BoxDecoration(
            color: th.opaqueSurface,
            borderRadius: r,
            border: Border.all(color: th.opaqueEdge),
            boxShadow: th.shadow,
          ),
          child: const SizedBox.expand(),
        );
    }
  }

  /// The blur tier's material: blur, then saturate — Apple's own order — at
  /// the frost and saturation the shader uses. [ui.TileMode.clamp] matters:
  /// without it the blur samples transparent black past the clip and the
  /// pill's edges bleed dark.
  static final ui.ImageFilter _frost = ui.ImageFilter.compose(
    outer: const ColorFilter.matrix(_saturate),
    inner: ui.ImageFilter.blur(
      sigmaX: 5,
      sigmaY: 5,
      tileMode: ui.TileMode.clamp,
    ),
  );

  /// Saturation ×1.25 about the Rec. 709 luminance axis.
  static const List<double> _saturate = <double>[
    1.19685, -0.17880, -0.01805, 0, 0, //
    -0.05315, 1.07120, -0.01805, 0, 0, //
    -0.05315, -0.17880, 1.23195, 0, 0, //
    0, 0, 0, 1, 0, //
  ];

  /// The glyphs, the labels and the lens, laid out in the capsule's own
  /// coordinates. As the bar folds ([t] → 1) everything slides so the selected
  /// glyph lands in the pill's centre while the rest fades and shrinks away.
  Widget _content(_Geometry g, Rect rect, double t, LiquidTabBarMaterial m) {
    final th = widget.theme;
    final tt = t.clamp(0.0, 1.0);
    final fade = (1 - tt) * (1 - tt);
    final activeV = _visualSlot(widget.selectedIndex);
    final shift = activeV == null
        ? 0.0
        : t * (g.pill.center.dx - g.slotCenterX(activeV.toDouble()));
    final iconCy =
        ui.lerpDouble(LiquidTabBar._iconCenterY, g.pill.center.dy, t)! -
            rect.top;
    final labelTop = LiquidTabBar._iconCenterY +
        LiquidTabBar._iconSize / 2 +
        LiquidTabBar._iconLabelGap -
        rect.top;
    final children = <Widget>[];

    for (var i = 0; i < _n; i++) {
      final item = widget.items[i];
      final v = _visualSlot(i)!;
      final selected = i == widget.selectedIndex;
      final cx = g.slotCenterX(v.toDouble()) - rect.left + shift;
      final color = selected ? th.activeColor : th.inactiveColor;
      Widget glyph = SizedBox(
        width: LiquidTabBar._iconSize,
        height: LiquidTabBar._iconSize,
        child: item.iconBuilder(color, selected),
      );
      if (item.badge) {
        glyph = Stack(
          clipBehavior: Clip.none,
          children: [
            glyph,
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: th.badgeColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: th.badgeBorder, width: 1.5),
                ),
              ),
            ),
          ],
        );
      }
      Widget text = Text(
        item.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: th.labelStyle.copyWith(
          fontSize: th.labelStyle.fontSize ?? 12,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          color: color,
        ),
      );
      // The selected glyph is the one thing that survives the fold; its label
      // and every other tab go with the bar.
      if (fade < 1) text = Opacity(opacity: fade, child: text);
      Widget slot = Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: g.slotW / 2 - LiquidTabBar._iconSize / 2,
            top: iconCy - LiquidTabBar._iconSize / 2,
            width: LiquidTabBar._iconSize,
            height: LiquidTabBar._iconSize,
            child: glyph,
          ),
          Positioned(
            left: 0,
            top: labelTop,
            width: g.slotW,
            height: LiquidTabBar._labelHeight,
            child: Center(child: text),
          ),
        ],
      );
      if (!selected && fade < 1) {
        slot = Opacity(
          opacity: fade,
          child: Transform.scale(scale: 1 - 0.15 * tt, child: slot),
        );
      }
      children.add(
        Positioned(
          left: cx - g.slotW / 2,
          top: 0,
          width: g.slotW,
          height: LiquidTabBar.barHeight,
          child: Semantics(
            button: true,
            selected: selected,
            label: item.label,
            onTap: () => widget.onSelected?.call(i),
            child: slot,
          ),
        ),
      );
    }

    // The lens rides above the glyphs so it bends the ones it slides across.
    // Its speed stretches it along the way; a press swells it under the
    // finger; the fold dissolves it into the pill.
    if (activeV != null && fade > 0) {
      final v = _lens.value;
      final speed = _lensVelocity.abs();
      final stretch = (speed * 0.055).clamp(0.0, 0.45);
      final press = _pressed ? 1.06 : 1.0;
      // The fringe comes and goes with the stretch, so the bubble's colour
      // and its liquid shape read as one thing happening.
      final motion = (speed / LiquidTabBar._fringeFullSpeed).clamp(0.0, 1.0);
      final style = th.lensGlass.copyWith(
        dispersion: ui.lerpDouble(
          _pressed ? LiquidTabBar._fringePressed : th.lensGlass.dispersion,
          LiquidTabBar._fringeMoving,
          motion,
        ),
        specular: ui.lerpDouble(
          th.lensGlass.specular,
          LiquidTabBar._fringeSpecular,
          motion,
        ),
      );
      final lw = (g.slotW + LiquidTabBar._lensOverhang) * (1 + stretch) * press;
      final lh = (LiquidTabBar.barHeight - 2 * LiquidTabBar._lensInset) *
          (1 - stretch * 0.3) *
          press;
      final cx = g.slotCenterX(v) - rect.left + shift;
      final cy = LiquidTabBar.barHeight / 2 - rect.top;
      final lensPad = m == LiquidTabBarMaterial.glass ? 6.0 : 0.0;
      children.add(
        Positioned(
          left: cx - lw / 2 - lensPad,
          top: cy - lh / 2 - lensPad,
          width: lw + 2 * lensPad,
          height: lh + 2 * lensPad,
          child: Opacity(
            opacity: fade,
            child: _lensSurface(m, Size(lw, lh), lensPad, style),
          ),
        ),
      );
    }

    return Stack(clipBehavior: Clip.none, children: children);
  }

  Widget _lensSurface(
    LiquidTabBarMaterial m,
    Size size,
    double pad,
    GlassStyle style,
  ) {
    if (m == LiquidTabBarMaterial.glass) {
      return GlassSurface(
        size: size,
        radius: size.height / 2,
        pad: pad,
        style: style,
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: widget.theme.lensTint,
        borderRadius: BorderRadius.circular(size.height / 2),
      ),
      child: CustomPaint(
        painter: GlassLightPainter(
          style: style,
          radius: size.height / 2,
          fringeWarm: widget.theme.fringeWarm,
          fringeCool: widget.theme.fringeCool,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }

  /// Touch, over the whole capsule — raw pointer events, not a gesture
  /// recognizer: a recognizer waits out the touch slop (18pt of travel)
  /// before it calls a drag a drag, and that wait is a beat where the lens
  /// sits still under a finger already moving. The bar sits in the
  /// Scaffold's own slot, never inside a scrollable, so there is no arena to
  /// be polite in.
  ///
  /// A press is a **tap** until the finger has travelled [_scrubSlop]: down
  /// swells the lens, up chooses the tab under it and the lens springs there
  /// from wherever it is. Past the slop it is a **scrub**: the lens glues to
  /// the finger from that point on, and release chooses the tab under it
  /// carrying the finger's speed. The slop is a third of a recognizer's — a
  /// real scrub crosses it inside a frame — but it is there: without it the
  /// pixel of wobble in a tap (every mouse click has one) teleports the lens
  /// to the pointer and parks it there until release. A finger that wanders
  /// far off the bar is a cancel; folded, up opens the bar.
  Widget _touch(_Geometry g, Rect rect, double t) {
    final folded = t > 0.5;
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (e) {
        if (folded) return;
        _down = e.localPosition;
        _scrubbing = false;
        _fingerVelocity = 0;
        _fingerAt = null;
        _hover = _visualAt(g, rect, e.localPosition.dx);
        setState(() => _pressed = true);
      },
      onPointerMove: (e) {
        if (folded || _down == null) return;
        if (!_scrubbing) {
          if ((e.localPosition.dx - _down!.dx).abs() <
              LiquidTabBar._scrubSlop) {
            return;
          }
          _scrubbing = true;
          _fingerAt = DateTime.now().microsecondsSinceEpoch;
        }
        _follow(g, rect, e.localPosition.dx);
      },
      onPointerUp: (e) {
        if (folded) {
          _nav.expand();
          return;
        }
        if (_down == null) return;
        _down = null;
        final dy = e.localPosition.dy;
        if (dy < -rect.height || dy > 2 * rect.height) {
          _scrubbing = false;
          _cancel();
          return;
        }
        if (_scrubbing) {
          final carried = _lensVelocity;
          _scrubbing = false;
          _choose(
            _hover ?? _visualAt(g, rect, e.localPosition.dx),
            velocity: carried,
          );
        } else {
          _choose(_visualAt(g, rect, e.localPosition.dx));
        }
        _release();
      },
      onPointerCancel: (_) {
        if (_down == null) return;
        _down = null;
        _scrubbing = false;
        _cancel();
      },
    );
  }

  /// The finger left without choosing: the lens goes home.
  void _cancel() {
    final v = _visualSlot(widget.selectedIndex);
    if (v != null) _spring(_lens, v.toDouble());
    _release();
  }

  double _slotsFrom(_Geometry g, Rect rect, double localX) =>
      (localX + rect.left - g.expanded.left - LiquidTabBar._barPadding) /
      g.slotW;

  int _visualAt(_Geometry g, Rect rect, double localX) =>
      _slotsFrom(g, rect, localX).floor().clamp(0, _n - 1);

  /// The lens under a scrubbing finger is glued to it — no spring, however
  /// stiff: a spring restarted on every pointer event trails the finger by
  /// its own settle time, and that trail reads as lag. The liquid feel comes
  /// from the stretch instead, driven by the finger's measured speed and
  /// relaxed over the theme's [LiquidTabBarTheme.relax] once it stops; the
  /// release carries that speed into the settling spring so a flick lands
  /// like a flick.
  void _follow(_Geometry g, Rect rect, double localX) {
    final v = _visualAt(g, rect, localX);
    if (v != _hover) {
      _hover = v;
      widget.haptic?.call();
    }
    final target = (_slotsFrom(g, rect, localX) - 0.5).clamp(-0.15, _n - 0.85);
    final now = DateTime.now().microsecondsSinceEpoch;
    final at = _fingerAt;
    // Samples closer than 4 ms apart are jitter, and a jitter's tiny dt turns
    // a pixel of travel into a hundred slots a second.
    if (at != null && now - at >= 4000) {
      final dt = (now - at) / 1e6;
      final sample = (target - _lens.value) / dt;
      // Two-sample smoothing: pointer timestamps are jittery, the stretch
      // must not be.
      _fingerVelocity = _fingerVelocity * 0.4 + sample * 0.6;
      _fingerAt = now;
    } else if (at == null) {
      _fingerAt = now;
    }
    _lens.stop();
    _lens.value = target;
    if (_reduced) {
      _relax.value = 1;
    } else {
      _relax.forward(from: 0);
    }
    setState(() {});
  }

  /// What the stretch and the release spring read: the finger's speed while
  /// scrubbing (fading as [_relax] runs), the lens's own otherwise.
  double get _lensVelocity =>
      _scrubbing ? _fingerVelocity * (1 - _relax.value) : _lens.velocity;

  void _choose(int v, {double? velocity}) {
    _spring(_lens, v.toDouble(), velocity: velocity);
    widget.onSelected?.call(_indexAtVisual(v));
  }

  void _release() {
    _hover = null;
    if (_pressed && mounted) setState(() => _pressed = false);
  }
}

/// The bar's frame for one screen width: the open capsule, the folded pill,
/// and the slot pitch between them.
class _Geometry {
  const _Geometry({
    required this.expanded,
    required this.pill,
    required this.slotW,
  });

  final Rect expanded;
  final Rect pill;
  final double slotW;

  /// Centre of visual slot [v] (fractional while the lens is in flight).
  double slotCenterX(double v) =>
      expanded.left + LiquidTabBar._barPadding + (v + 0.5) * slotW;
}

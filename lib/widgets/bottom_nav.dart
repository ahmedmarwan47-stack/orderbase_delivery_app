import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../app/road_mode.dart';
import '../app/shift_controller.dart';
import '../config/res/config_imports.dart';
import '../theme/shadows.dart';
import 'nav_bar_controller.dart';
import 'nav_glass.dart';

/// The four sections of the app. Batches and orders are one tab: a batch is
/// how orders arrive, so the Orders tab lists them grouped by batch.
enum NavTab { home, orders, settlement, profile }

/// The floating tab bar — built to iOS 26's own numbers and manners, so the
/// courier's phone and the system apps beside it behave as one.
///
/// **Geometry** was measured off the real iOS 26 bar (Files on an iPhone 17
/// Pro): 62pt tall and 21pt off the screen edge (64 and 20 here, on the 4px
/// grid), `n × 86 + 16` wide and capped at the screen less 2 × 20, the
/// selection lens a slot + 8 wide and the bar − 8 tall. Everything is in
/// absolute points — iOS does not scale its bar with the screen, so neither
/// does this; it is the one widget deliberately outside screenutil.
///
/// **Material** comes in three tiers, picked by [NavBarController]: *glass*
/// (the refraction shader in `nav_glass.frag` — lensing at the rim, a
/// top-left light, dispersion, frost, its own shadow), *blur* (backdrop blur
/// + saturation under the same tint, for devices without Impeller or that
/// the frame governor stepped down), and *opaque* — a solid pill, no backdrop
/// at all — which two gates force regardless: `MediaQuery.highContrast` (the
/// honest proxy for Reduce Transparency, which Flutter does not expose) and
/// [RoadMode], whose whole point is sun and gloves.
///
/// **Manners**: scrolling down folds the bar into a pill holding only the
/// selected tab, scrolling up opens it; the lens slides between tabs on a
/// spring and stretches with its own speed; a finger can press and scrub
/// along the bar, the lens following it with a tick at every tab, and release
/// to choose. All of it on [AppMotion.spring]; all of it jumping straight to
/// the end state under Reduce Motion.
///
/// **It only works because the page passes underneath it.** The host puts it
/// in `Scaffold(extendBody: true)`'s `bottomNavigationBar` slot and gives its
/// scrollable [reservedHeight] of bottom padding. In the app that host is the
/// shell — ONE bar over every tab page, so [active] changes on this widget and
/// the lens slides from the old tab to the new one; a page carries its own
/// copy only standalone (a route, the DevGallery, the pushed order detail).
///
/// [active] is null on pages that are not a tab — notifications, opened from
/// the header, sits inside the shell with no tab highlighted (and nothing to
/// fold into). The Orders tab carries a red dot while a batch waits at the
/// branch; that dot is the app's standing "something is waiting" signal, so
/// this widget watches [ShiftController] directly instead of depending on
/// its host to redraw.
class BottomNav extends StatefulWidget {
  const BottomNav({
    super.key,
    required this.active,
    this.notificationsBadge = false,
    this.onTap,
  });

  final NavTab? active;
  final bool notificationsBadge;
  final ValueChanged<NavTab>? onTap;

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
  static const double _fringePressed = 0.35;
  static const double _fringeMoving = 0.7;
  static const double _fringeSpecular = 0.3;
  static const double _fringeFullSpeed = 4;

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
  /// everything in the `bottomNavigationBar` slot — this pill plus any sticky
  /// action bar stacked with it — so prefer that when it is the larger of the
  /// two. Off that path (a hand-rolled Stack, or a call from above the
  /// Scaffold) the pill's own geometry is the answer.
  static double reservedHeight(BuildContext context) => math.max(
    barHeight + _bottomGap(context) + 12,
    MediaQuery.paddingOf(context).bottom,
  );

  /// How far the pill floats above the screen edge: iOS puts it 21pt up on a
  /// home-indicator phone — below the safe area, not above it.
  static double _bottomGap(BuildContext context) =>
      MediaQuery.viewPaddingOf(context).bottom > 0 ? _gapNotch : _gapFlat;

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> with TickerProviderStateMixin {
  final NavBarController _nav = NavBarController.instance;

  /// 0 = open, 1 = folded into the pill. Unbounded so the spring may
  /// overshoot a hair either side.
  late final AnimationController _fold = AnimationController.unbounded(
    vsync: this,
    value: _nav.minimized ? 1 : 0,
  );

  /// The lens's position in visual slots (0 = the leftmost slot).
  late final AnimationController _lens = AnimationController.unbounded(
    vsync: this,
    value: (_visualSlot(widget.active) ?? 0).toDouble(),
  );

  bool _pressed = false;
  bool _scrubbing = false;

  /// The finger's speed along the bar while scrubbing, in slots per second,
  /// and the short relaxation that lets the stretch it drives ease off once
  /// the finger stops — a lens that stays stretched under a still finger
  /// reads as stuck.
  double _fingerVelocity = 0;
  int? _fingerAt;
  late final AnimationController _relax = AnimationController(
    vsync: this,
    duration: AppMotion.tick,
    value: 1,
  );

  /// The visual slot under the finger while scrubbing — a tick every time it
  /// changes.
  int? _hover;

  @override
  void initState() {
    super.initState();
    _nav.addListener(_onNav);
  }

  @override
  void didUpdateWidget(BottomNav old) {
    super.didUpdateWidget(old);
    if (old.active != widget.active && !_scrubbing) {
      final v = _visualSlot(widget.active);
      if (v != null) _spring(_lens, v.toDouble(), AppMotion.spring);
    }
  }

  @override
  void dispose() {
    _nav.removeListener(_onNav);
    _fold.dispose();
    _lens.dispose();
    _relax.dispose();
    super.dispose();
  }

  void _onNav() => _spring(_fold, _nav.minimized ? 1 : 0, AppMotion.spring);

  /// Drive [c] to [target] on [spring], carrying whatever velocity it has —
  /// an interrupted fold reverses mid-air instead of snapping.
  void _spring(
    AnimationController c,
    double target,
    SpringDescription spring, {
    double? velocity,
  }) {
    if (!mounted) return;
    if (AppMotion.reduced(context)) {
      c.value = target;
      return;
    }
    if (!c.isAnimating && (c.value - target).abs() < 0.0005) return;
    c.animateWith(
      SpringSimulation(spring, c.value, target, velocity ?? c.velocity),
    );
  }

  bool get _rtl => Directionality.of(context) == TextDirection.rtl;
  int get _n => NavTab.values.length;

  /// A tab's slot counted from the left, whatever the reading direction.
  int? _visualSlot(NavTab? t) =>
      t == null ? null : (_rtl ? _n - 1 - t.index : t.index);

  NavTab _tabAtVisual(int v) => NavTab.values[_rtl ? _n - 1 - v : v];

  _Geometry _geometry(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final barW = math.min(
      _n * BottomNav._slotWidth + 2 * BottomNav._barPadding,
      w - 2 * BottomNav._sideMargin,
    );
    final slotW = (barW - 2 * BottomNav._barPadding) / _n;
    final left = (w - barW) / 2;
    final expanded = Rect.fromLTWH(left, 0, barW, BottomNav.barHeight);
    // The folded pill is the lens with the bar shrunk around it, parked at
    // the leading edge — where the first tab lives.
    final pillH = BottomNav.barHeight - 2 * BottomNav._lensInset;
    final pillLeft = _rtl
        ? expanded.right - BottomNav._pillWidth
        : expanded.left;
    final pill = Rect.fromLTWH(
      pillLeft,
      BottomNav._lensInset,
      BottomNav._pillWidth,
      pillH,
    );
    return _Geometry(expanded: expanded, pill: pill, slotW: slotW);
  }

  @override
  Widget build(BuildContext context) {
    // Listens to the shift itself rather than trusting the host page to
    // rebuild: the Orders badge is the ONLY signal that a batch is waiting at
    // the branch, and a batch can land while the courier is sitting still on
    // a tab that never rebuilds. Road mode and the controller decide the
    // material; the two springs drive the motion.
    return AnimatedBuilder(
      animation: Listenable.merge([
        ShiftController.instance,
        RoadMode.instance,
        _nav,
        _fold,
        _lens,
        _relax,
      ]),
      builder: (context, _) => _bar(context),
    );
  }

  Widget _bar(BuildContext context) {
    final g = _geometry(context);
    final gap = BottomNav._bottomGap(context);
    final opaque =
        MediaQuery.highContrastOf(context) ||
        RoadMode.instance.on ||
        _nav.effectiveMaterial == NavMaterial.opaque;
    final material = opaque ? NavMaterial.opaque : _nav.effectiveMaterial;
    // A page with no tab selected has nothing to fold into.
    final t = widget.active == null ? 0.0 : _fold.value;
    final rect = Rect.lerp(g.expanded, g.pill, t)!;
    final radius = rect.height / 2;
    final pad = material == NavMaterial.glass ? BottomNav._glassPad : 0.0;

    return SizedBox(
      height: BottomNav.barHeight + gap,
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

  Widget _surface(NavMaterial m, Size size, double radius, double pad) {
    final r = BorderRadius.circular(radius);
    switch (m) {
      case NavMaterial.glass:
        return GlassSurface(
          size: size,
          radius: radius,
          pad: pad,
          style: GlassStyle.bar,
        );
      case NavMaterial.blur:
      case NavMaterial.auto:
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: r,
            boxShadow: AppShadows.floatingBar,
          ),
          child: ClipRRect(
            borderRadius: r,
            child: BackdropFilter(
              filter: _frost,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.navGlassTint,
                  borderRadius: r,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: _sheen,
                    borderRadius: r,
                    border: Border.all(color: AppColors.navGlassEdge),
                  ),
                  // The shader's rim light, painted: without it the blur
                  // tier is a frosted slab next to the glass tier's capsule.
                  child: CustomPaint(
                    painter: GlassLightPainter(
                      style: GlassStyle.bar,
                      radius: radius,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
          ),
        );
      case NavMaterial.opaque:
        return DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: r,
            border: Border.all(color: AppColors.navOpaqueEdge),
            boxShadow: AppShadows.floatingBar,
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

  static const LinearGradient _sheen = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.navGlassSheenTop, AppColors.navGlassSheenBottom],
  );

  /// The glyphs, the labels and the lens, laid out in the capsule's own
  /// coordinates. As the bar folds ([t] → 1) everything slides so the selected
  /// glyph lands in the pill's centre while the rest fades and shrinks away.
  Widget _content(_Geometry g, Rect rect, double t, NavMaterial m) {
    final tt = t.clamp(0.0, 1.0);
    final fade = (1 - tt) * (1 - tt);
    final activeV = _visualSlot(widget.active);
    final shift = activeV == null
        ? 0.0
        : t * (g.pill.center.dx - g.slotCenterX(activeV.toDouble()));
    final iconCy =
        ui.lerpDouble(BottomNav._iconCenterY, g.pill.center.dy, t)! - rect.top;
    final labelTop =
        BottomNav._iconCenterY +
        BottomNav._iconSize / 2 +
        BottomNav._iconLabelGap -
        rect.top;
    final children = <Widget>[];

    for (final tab in NavTab.values) {
      final v = _visualSlot(tab)!;
      final selected = tab == widget.active;
      final cx = g.slotCenterX(v.toDouble()) - rect.left + shift;
      final color = selected ? AppColors.dangerAccent : AppColors.textPrimary;
      final label = _label(tab);
      Widget glyph = IconWidget(
        icon: selected ? _activeIcon(tab) : _icon(tab),
        color: color,
        height: BottomNav._iconSize,
        width: BottomNav._iconSize,
      );
      // Red dot while a batch is waiting to be carried from the branch — it
      // clears the moment the batch is in hand.
      if (tab == NavTab.orders && ShiftController.instance.hasPendingBatch) {
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
                  color: AppColors.brand,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 1.5),
                ),
              ),
            ),
          ],
        );
      }
      Widget text = Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style:
            (selected ? const TextStyle().semiBold : const TextStyle().regular)
                .s12
                .setColor(color),
      );
      // The selected glyph is the one thing that survives the fold; its label
      // and every other tab go with the bar.
      if (fade < 1) text = Opacity(opacity: fade, child: text);
      Widget item = Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: g.slotW / 2 - BottomNav._iconSize / 2,
            top: iconCy - BottomNav._iconSize / 2,
            width: BottomNav._iconSize,
            height: BottomNav._iconSize,
            child: glyph,
          ),
          Positioned(
            left: 0,
            top: labelTop,
            width: g.slotW,
            height: BottomNav._labelHeight,
            child: Center(child: text),
          ),
        ],
      );
      if (!selected && fade < 1) {
        item = Opacity(
          opacity: fade,
          child: Transform.scale(scale: 1 - 0.15 * tt, child: item),
        );
      }
      children.add(
        Positioned(
          left: cx - g.slotW / 2,
          top: 0,
          width: g.slotW,
          height: BottomNav.barHeight,
          child: Semantics(
            button: true,
            selected: selected,
            label: label,
            onTap: () => widget.onTap?.call(tab),
            child: item,
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
      final motion = (speed / BottomNav._fringeFullSpeed).clamp(0.0, 1.0);
      final style = GlassStyle.lens.copyWith(
        dispersion: ui.lerpDouble(
          _pressed ? BottomNav._fringePressed : GlassStyle.lens.dispersion,
          BottomNav._fringeMoving,
          motion,
        ),
        specular: ui.lerpDouble(
          GlassStyle.lens.specular,
          BottomNav._fringeSpecular,
          motion,
        ),
      );
      final lw = (g.slotW + BottomNav._lensOverhang) * (1 + stretch) * press;
      final lh =
          (BottomNav.barHeight - 2 * BottomNav._lensInset) *
          (1 - stretch * 0.3) *
          press;
      final cx = g.slotCenterX(v) - rect.left + shift;
      final cy = BottomNav.barHeight / 2 - rect.top;
      final lensPad = m == NavMaterial.glass ? 6.0 : 0.0;
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

  Widget _lensSurface(NavMaterial m, Size size, double pad, GlassStyle style) {
    if (m == NavMaterial.glass) {
      return GlassSurface(
        size: size,
        radius: size.height / 2,
        pad: pad,
        style: style,
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.navLensTint,
        borderRadius: BorderRadius.circular(size.height / 2),
      ),
      child: CustomPaint(
        painter: GlassLightPainter(style: style, radius: size.height / 2),
        child: const SizedBox.expand(),
      ),
    );
  }

  /// Touch, over the whole capsule. Open: a tap chooses the tab under it, a
  /// horizontal drag scrubs the lens along the bar and chooses on release.
  /// Folded: any tap opens the bar again.
  Widget _touch(_Geometry g, Rect rect, double t) {
    final folded = t > 0.5;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: folded ? null : (_) => setState(() => _pressed = true),
      onTapUp: (d) {
        if (folded) {
          _nav.expand();
          return;
        }
        _choose(_visualAt(g, rect, d.localPosition.dx));
        _release();
      },
      onTapCancel: _release,
      onHorizontalDragStart: folded
          ? null
          : (d) {
              _scrubbing = true;
              _pressed = true;
              _fingerVelocity = 0;
              _fingerAt = null;
              _follow(g, rect, d.localPosition.dx);
            },
      onHorizontalDragUpdate: folded
          ? null
          : (d) => _follow(g, rect, d.localPosition.dx),
      onHorizontalDragEnd: folded
          ? null
          : (_) {
              final v = _hover ?? _visualSlot(widget.active) ?? 0;
              final carried = _lensVelocity;
              _scrubbing = false;
              _choose(v, velocity: carried);
              _release();
            },
      onHorizontalDragCancel: () {
        _scrubbing = false;
        final v = _visualSlot(widget.active);
        if (v != null) _spring(_lens, v.toDouble(), AppMotion.spring);
        _release();
      },
    );
  }

  double _slotsFrom(_Geometry g, Rect rect, double localX) =>
      (localX + rect.left - g.expanded.left - BottomNav._barPadding) / g.slotW;

  int _visualAt(_Geometry g, Rect rect, double localX) =>
      _slotsFrom(g, rect, localX).floor().clamp(0, _n - 1);

  /// The lens under a scrubbing finger is glued to it — no spring, however
  /// stiff: a spring restarted on every pointer event trails the finger by
  /// its own settle time, and that trail is read as lag. The liquid feel
  /// comes from the stretch instead, driven by the finger's measured speed
  /// and relaxed over [AppMotion.tick] once it stops; the release carries
  /// that speed into the settling spring so a flick lands like a flick.
  void _follow(_Geometry g, Rect rect, double localX) {
    final v = _visualAt(g, rect, localX);
    if (v != _hover) {
      _hover = v;
      AppHaptics.tick();
    }
    final target = (_slotsFrom(g, rect, localX) - 0.5).clamp(-0.15, _n - 0.85);
    final now = DateTime.now().microsecondsSinceEpoch;
    final at = _fingerAt;
    if (at != null && now > at) {
      final dt = (now - at) / 1e6;
      final sample = (target - _lens.value) / dt;
      // Two-sample smoothing: pointer timestamps are jittery, the stretch
      // must not be.
      _fingerVelocity = _fingerVelocity * 0.4 + sample * 0.6;
    }
    _fingerAt = now;
    _lens.stop();
    _lens.value = target;
    if (AppMotion.reduced(context)) {
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
    _spring(_lens, v.toDouble(), AppMotion.spring, velocity: velocity);
    widget.onTap?.call(_tabAtVisual(v));
  }

  void _release() {
    _hover = null;
    if (_pressed && mounted) setState(() => _pressed = false);
  }

  String _label(NavTab t) => switch (t) {
    NavTab.home => LocaleKeys.navHome.tr(),
    NavTab.orders => LocaleKeys.navOrders.tr(),
    NavTab.settlement => LocaleKeys.navSettlement.tr(),
    NavTab.profile => LocaleKeys.navProfile.tr(),
  };

  String _icon(NavTab t) => switch (t) {
    NavTab.home => AppAssets.svg.home,
    NavTab.orders => AppAssets.svg.orders,
    NavTab.settlement => AppAssets.svg.wallet,
    NavTab.profile => AppAssets.svg.user,
  };

  /// The filled twin, for the selected tab only.
  String _activeIcon(NavTab t) => switch (t) {
    NavTab.home => AppAssets.svg.homeFilled,
    NavTab.orders => AppAssets.svg.ordersFilled,
    NavTab.settlement => AppAssets.svg.walletFilled,
    NavTab.profile => AppAssets.svg.userFilled,
  };
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
      expanded.left + BottomNav._barPadding + (v + 0.5) * slotW;
}

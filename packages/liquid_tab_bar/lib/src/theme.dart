import 'package:flutter/widgets.dart';

import 'glass.dart';

/// Builds a tab's glyph in [color]; [selected] is true for the active tab, so
/// a filled variant can stand in for the outline.
typedef LiquidTabIconBuilder = Widget Function(Color color, bool selected);

/// One tab of a [LiquidTabBar].
class LiquidTabItem {
  const LiquidTabItem({
    required this.label,
    required this.iconBuilder,
    this.badge = false,
  });

  /// A tab drawn with [IconData]: [icon] at rest, [activeIcon] (or [icon])
  /// when selected.
  LiquidTabItem.icon({
    required this.label,
    required IconData icon,
    IconData? activeIcon,
    this.badge = false,
  }) : iconBuilder = ((color, selected) => Icon(
              selected ? (activeIcon ?? icon) : icon,
              color: color,
              size: 23,
            ));

  final String label;
  final LiquidTabIconBuilder iconBuilder;

  /// A small dot on the glyph's top-trailing corner — "something is waiting".
  final bool badge;
}

/// Every colour and number a [LiquidTabBar] draws with. The defaults are the
/// white glass the bar was measured against iOS 26 with; an app usually sets
/// [activeColor], [inactiveColor] and [labelStyle] and leaves the rest.
class LiquidTabBarTheme {
  const LiquidTabBarTheme({
    this.activeColor = const Color(0xFF0A7AFF),
    this.inactiveColor = const Color(0xFF1A1919),
    this.labelStyle = const TextStyle(),
    this.glassTint = const Color(0x85FFFFFF),
    this.sheenTop = const Color(0x40FFFFFF),
    this.sheenBottom = const Color(0x00FFFFFF),
    this.glassEdge = const Color(0x99FFFFFF),
    this.opaqueSurface = const Color(0xFFFFFFFF),
    this.opaqueEdge = const Color(0xFFE6E5E2),
    this.lensTint = const Color(0x12000000),
    this.fringeWarm = const Color(0xFFFFB347),
    this.fringeCool = const Color(0xFF4DA3FF),
    this.badgeColor = const Color(0xFFE72B29),
    this.badgeBorder = const Color(0xFFFFFFFF),
    this.shadow = const [
      BoxShadow(
        color: Color(0x1A000000),
        offset: Offset(0, 3),
        blurRadius: 14,
      ),
    ],
    this.barGlass = GlassStyle.bar,
    this.lensGlass = GlassStyle.lens,
    this.spring = const SpringDescription(mass: 1, stiffness: 320, damping: 30),
    this.relax = const Duration(milliseconds: 120),
  });

  /// The selected tab's glyph and label; every other tab's.
  final Color activeColor;
  final Color inactiveColor;

  /// The labels' base style. The bar sets the colour and the weight (semibold
  /// selected, regular otherwise) and keeps the size when one is given —
  /// 12 logical px otherwise.
  final TextStyle labelStyle;

  /// The blur tier's tint, sheen and edge; the opaque tier's fill and edge.
  final Color glassTint;
  final Color sheenTop;
  final Color sheenBottom;
  final Color glassEdge;
  final Color opaqueSurface;
  final Color opaqueEdge;

  /// The lens's shade on the blur and opaque tiers (the glass tier takes it
  /// from [lensGlass]).
  final Color lensTint;

  /// The two threads the lens's rim light splits into while it disperses on
  /// the blur tier — its share of the soap-bubble fringe the shader shows.
  final Color fringeWarm;
  final Color fringeCool;

  /// The badge dot and its ring.
  final Color badgeColor;
  final Color badgeBorder;

  /// The drop shadow under the blur and opaque tiers (the glass tier casts
  /// its own from [barGlass]).
  final List<BoxShadow> shadow;

  /// The glass tier's two materials.
  final GlassStyle barGlass;
  final GlassStyle lensGlass;

  /// The one spring the fold and the lens run on (damping ratio .84, about
  /// 400 ms to rest), and how long the lens's stretch takes to ease off once
  /// a scrubbing finger stops.
  final SpringDescription spring;
  final Duration relax;
}

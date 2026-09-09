import 'package:flutter/widgets.dart';

/// Box shadows ported from the mockups' CSS. CSS `x y blur spread color` maps
/// to BoxShadow(offset: (x, y), blurRadius: blur, spreadRadius: spread).
/// Seeded from: Home 1a.
abstract final class AppShadows {
  /// Hero (next-stop) card: `0 6px 16px -7px rgba(0,0,0,.20)` — refined from the
  /// Home 1a frame (tighter and softer than the original 0 8 26 -14 / .22).
  static const heroCard = [
    BoxShadow(
      color: Color(0x33000000), // .20
      offset: Offset(0, 6),
      blurRadius: 16,
      spreadRadius: -7,
    ),
  ];

  /// Stat / list card: `0 1px 3px rgba(0,0,0,.05)`
  static const card = [
    BoxShadow(
      color: Color(0x0D000000), // .05
      offset: Offset(0, 1),
      blurRadius: 3,
    ),
  ];

  /// Home stat strip: a softer, wider lift than the list card —
  /// `0 1px 8px rgba(0,0,0,.08)` (Home 1a frame).
  static const statStrip = [
    BoxShadow(
      color: Color(0x14000000), // .08
      offset: Offset(0, 1),
      blurRadius: 8,
    ),
  ];

  /// Settlement money card: a deep lift so the slate card floats over the page —
  /// `0 24px 40px -8px rgba(0,0,0,.30)` (Settlement frame).
  static const moneyCard = [
    BoxShadow(
      color: Color(0x4D000000), // .30
      offset: Offset(0, 24),
      blurRadius: 40,
      spreadRadius: -8,
    ),
  ];

  /// Notifications batch hero banner: `0 8px 16px rgba(0,0,0,.16)`.
  static const heroBanner = [
    BoxShadow(
      color: Color(0x29000000), // .16
      offset: Offset(0, 8),
      blurRadius: 16,
    ),
  ];

  /// The floating tab bar (blur / opaque tiers; the glass tier draws its own
  /// inside the shader). Measured off iOS 26's bar over white: 6% black at the
  /// bottom edge, 3% at the top, gone within ~15pt — `0 3px 14px rgba(0,0,0,.10)`.
  static const floatingBar = [
    BoxShadow(
      color: Color(0x1A000000), // .10
      offset: Offset(0, 3),
      blurRadius: 14,
    ),
  ];

  /// Map pin marker: `0 4px 10px rgba(231,43,41,.4)`
  static const pin = [
    BoxShadow(
      color: Color(0x66E72B29), // brand @ .4
      offset: Offset(0, 4),
      blurRadius: 10,
    ),
  ];
}

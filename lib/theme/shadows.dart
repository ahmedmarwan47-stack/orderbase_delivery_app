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

  /// The floating tab bar — it has to read as detached from the page without
  /// casting a hard edge under a translucent material: `0 6px 20px -6px
  /// rgba(0,0,0,.20)` plus a tight contact shadow.
  static const floatingBar = [
    BoxShadow(
      color: Color(0x33000000), // .20
      offset: Offset(0, 6),
      blurRadius: 20,
      spreadRadius: -6,
    ),
    BoxShadow(
      color: Color(0x14000000), // .08
      offset: Offset(0, 1),
      blurRadius: 2,
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

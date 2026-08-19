import 'package:flutter/widgets.dart';

import '../../config/res/app_sizes.dart';
import '../../theme/colors.dart';

/// Text styling as a fluent chain — `const TextStyle().setMainTextColor.s14.semiBold`.
/// Size getters are screenutil-scaled (`.sp`); weights follow the standard
/// Flutter scale (`extraBold` = w800 for the mockup headings). Font family is
/// inherited from the theme (Noto Kufi Arabic).
extension TextStyleEx on TextStyle {
  // ── sizes ── (floor is 14px; 12px used occasionally for dense meta)
  TextStyle get s12 => copyWith(fontSize: FontSizeManager.s12);
  TextStyle get s14 => copyWith(fontSize: FontSizeManager.s14);
  TextStyle get s16 => copyWith(fontSize: FontSizeManager.s16);
  TextStyle get s18 => copyWith(fontSize: FontSizeManager.s18);
  TextStyle get s20 => copyWith(fontSize: FontSizeManager.s20);
  TextStyle get s24 => copyWith(fontSize: FontSizeManager.s24);
  TextStyle get s28 => copyWith(fontSize: FontSizeManager.s28);
  TextStyle get s36 => copyWith(fontSize: FontSizeManager.s36);

  // ── weights ──
  TextStyle get light => copyWith(fontWeight: FontWeightManager.light);
  TextStyle get regular => copyWith(fontWeight: FontWeightManager.regular);
  TextStyle get medium => copyWith(fontWeight: FontWeightManager.medium);
  TextStyle get semiBold => copyWith(fontWeight: FontWeightManager.semiBold);
  TextStyle get bold => copyWith(fontWeight: FontWeightManager.semiBold);
  TextStyle get extraBold => copyWith(fontWeight: FontWeightManager.bold);

  // ── colors (semantic — mapped to the mockup palette in AppColors) ──
  TextStyle setColor(Color color) => copyWith(color: color);
  TextStyle get setMainTextColor => copyWith(color: AppColors.textPrimary);
  TextStyle get setSecondaryColor => copyWith(color: AppColors.textSecondary);
  TextStyle get setTertiaryColor => copyWith(color: AppColors.textTertiary);
  TextStyle get setHintColor => copyWith(color: AppColors.textMuted);
  TextStyle get setWhite => copyWith(color: const Color(0xFFFFFFFF));

  // ── helpers ──
  TextStyle get tabular =>
      copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
  // Named `withHeight` (not `height`) — `TextStyle.height` is a field and would
  // otherwise shadow this extension.
  TextStyle withHeight(double h) => copyWith(height: h);
}

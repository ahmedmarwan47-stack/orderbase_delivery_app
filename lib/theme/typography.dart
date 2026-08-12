import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

/// Font sizes follow the 4-pixel rule: multiples of 4, with 14 and 18 as the
/// only exceptions (see /CLAUDE.md). Line heights below are a best-effort
/// scale (also on-grid) inferred from the few explicit `line-height` values
/// in the mockups — verify/correct against each screen as it's ported rather
/// than trusting these blindly.
///
/// Deliberately not baking `fontWeight` into named styles: the same size is
/// used at different weights depending on context in the mockups (e.g. 12px
/// at both 700 and 800). Call `.copyWith(fontWeight: ...)` at the use site.
abstract final class AppTypography {
  static TextStyle _style(double fontSize, double lineHeight) {
    return GoogleFonts.notoKufiArabic(
      fontSize: fontSize,
      height: lineHeight / fontSize,
      color: const Color(0xFF1A1919),
    );
  }

  static final size12 = _style(12, 20);
  static final size14 = _style(14, 20);
  static final size16 = _style(16, 24);
  static final size18 = _style(18, 28);
  static final size20 = _style(20, 28);
  static final size24 = _style(24, 32);
}

import 'package:flutter/widgets.dart';

/// Colors as they actually appear in the design project's `.dc.html` mockups —
/// not a designed-in-the-abstract palette. Grown one screen at a time; add new
/// values here (grouped by role) as new screens are ported, and reuse an
/// existing value instead of adding a near-duplicate if one already fits.
///
/// Seeded from: Queue States.dc.html
abstract final class AppColors {
  // Surfaces
  static const background = Color(0xFFF6F5F3);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF4F3F0); // chips, search field, icon buttons
  static const surfaceSubtle = Color(0xFFF1F0ED); // dividers, empty-state icon bg

  // Borders
  static const borderDefault = Color(0xFFE6E5E2); // card/button outline
  static const borderHeader = Color(0xFFEEEDEA); // header/bottom-nav hairline
  static const borderCard = Color(0x0D000000); // rgba(0,0,0,.05) card outline
  static const borderCardFaint = Color(0x0A000000); // rgba(0,0,0,.04) hero/stat card

  // Text
  static const textPrimary = Color(0xFF1A1919);
  static const textSecondary = Color(0xFF6B6B73);
  static const textTertiary = Color(0xFF52525B);
  static const textMuted = Color(0xFF8A7A72); // address lines, hints

  // Brand
  static const brand = Color(0xFFE72B29);

  // Status: in transit
  static const transitBg = Color(0xFF1F6FD6);
  static const transitText = Color(0xFFFFFFFF);

  // Status: delivered
  static const deliveredBg = Color(0xFFE9F6EE);
  static const deliveredText = Color(0xFF15803D);
  static const deliveredBorder = Color(0x3816A34A); // rgba(22,163,74,.22)

  // Positive green accent — progress bar, cash total, stat check/chat icons.
  // Brighter than deliveredText (#15803D); kept distinct on purpose.
  static const greenAccent = Color(0xFF16A34A);

  // Status: failed
  static const failedBg = Color(0xFFFDECEC);
  static const failedBorder = Color(0xFFF0C4C3);
  static const failedText = Color(0xFFB8120F);
  static const stopCountText = Color(0xFFB0201E); // "المحطة 2 من 5" pill text

  // Status: postponed (amber)
  static const postponedBg = Color(0xFFFEF6E4); // pill background
  static const postponedBannerBg = Color(0xFFFEFBF3); // banner/card background
  static const postponedBorder = Color(0xFFF3E6C8);
  static const postponedBorderStrong = Color(0xFFE6D6B4); // button outline variant
  static const postponedText = Color(0xFF9A5A00);
  static const postponedTextStrong = Color(0xFF6B4A12); // body copy on banner
  static const heroCodPillBg = Color(0xFFFBF0DE); // COD pill inside the hero card

  // Neutral icon-tile background (stat card "in progress" tile)
  static const iconTileNeutral = Color(0xFFF2F1EE);

  // Selected / high-emphasis fill (chips, primary buttons)
  static const inkFill = Color(0xFF1A1919);

  // Muted count text inside an unselected filter chip
  static const chipCountMuted = Color(0xFF9A9994);

  // Destructive accent (clear filter, active nav icon)
  static const dangerAccent = Color(0xFFC81E1C);

  // Search highlight
  static const markBg = Color(0xFFFFE9A8);
  static const markText = Color(0xFF5A4300);
}

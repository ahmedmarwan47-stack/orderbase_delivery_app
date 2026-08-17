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
  static const iconButtonBorder = Color(0x12000000); // rgba(0,0,0,.07) header search icon button (Home 1a)

  // Text
  static const textPrimary = Color(0xFF1A1919);
  static const textSecondary = Color(0xFF6B6B73);
  static const textTertiary = Color(0xFF52525B);
  static const textMuted = Color(0xFF7E6E65); // address lines, hints — AA on white (4.88:1)
  static const textBody = Color(0xFF3F3F46); // long-form address / body copy

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
  static const pickupBannerBorder = Color(0xFFF3DDB4); // "ready for pickup" banner
  static const pickupBannerText = Color(0xFF7A4E12); // "ready for pickup" banner copy

  // Neutral icon-tile background (stat card "in progress" tile)
  static const iconTileNeutral = Color(0xFFF2F1EE);

  // COD collection (COD Collection.dc.html, 2a): the "excess → wallet" accent —
  // brighter than the postponed ambers; borders the amount field and the
  // over-collected state.
  static const codExcessAmber = Color(0xFFE0AC4E);

  // Selected / high-emphasis fill (chips, primary buttons)
  static const inkFill = Color(0xFF1A1919);

  // Muted count text inside an unselected filter chip
  static const chipCountMuted = Color(0xFF9A9994);

  // Destructive accent (clear filter, active nav icon)
  static const dangerAccent = Color(0xFFC81E1C);

  // Search highlight
  static const markBg = Color(0xFFFFE9A8);
  static const markText = Color(0xFF5A4300);

  // Hairline dividers between list items (lighter than borderHeader)
  static const itemDivider = Color(0xFFF5F4F1);
  static const summaryDivider = Color(0xFFEAE9E5); // divider inside the result summary card

  // Cash / COD payment card — deep cash-green (NOT black; full black `inkFill`
  // is reserved for primary buttons so the two never compete).
  static const paymentCardBg = Color(0xFF4E6B60); // soft, low-impact muted green
  static const paymentLabel = Color(0xFFB7D9C4); // soft green label on the card
  static const paymentSuffix = Color(0xFFCDEBDA); // "جم" suffix on the card
  static const paymentTile = Color(0x26FFFFFF); // rgba(255,255,255,.15) icon tile
  static const cashBright = Color(0xFFEAFBF1); // near-white cash glyph on green

  // Timeline (order route)
  static const timelineRing = Color(0xFFF7D7D6); // ring around the active red dot
  static const timelineDotMuted = Color(0xFFC4C4C8); // upcoming/past gray dot

  // Bottom sheets (handoff / fail / postpone)
  static const scrim = Color(0x73141212); // rgba(20,18,18,.45) dimmed backdrop
  static const sheetGrabber = Color(0xFFE0DFDB); // the top drag handle
  static const dashedBorder = Color(0xFFD6D5D1); // photo-capture dashed border + switch-off track
  static const photoDashBg = Color(0xFFFAFAF9); // photo-capture dashed area
  static const photoTile = Color(0xFFF0EFEC); // camera icon tile
  static const photoGreenWash = Color(0x2416A34A); // rgba(22,163,74,.14) captured-photo overlay
  static const reasonRowBg = Color(0xFFF8F7F5); // unselected reason row
  static const reasonDotBorder = Color(0xFFCFCEC9); // unselected reason radio ring

  // Failure States (Failure States.dc.html) — the not-delivered flow.
  static const transitPillBg = Color(0xFFE7F0FB); // pale "في الطريق" pill / tile bg
  static const failWarnAmberBorder = Color(0xFFF0DFBC); // 1b "last nudge" warning card border
  static const failWarnAmberText = Color(0xFF7A4A00); // 1b warning body text
  static const failWarnRedBorder = Color(0xFFF5CFCE); // 1d mismatch warning card border
  static const failWarnRedText = Color(0xFF8E1512); // 1d mismatch warning body text
  static const retryNowSubtext = Color(0xFF4A6B55); // 1c retry-now green caption
  static const darkCardRowBg = Color(0xFF2A2927); // 1g return-item row on the dark card
  static const undoTrack = Color(0xFF3A3937); // 1f undo progress track (unfilled)
  static const mutedOnDark = Color(0xFFA3A29E); // warm muted text on dark cards (1f/1g)

  // Settlement (Settlement.dc.html) — dark "cash in hand" card details.
  static const darkCardHairline = Color(0x1FFFFFFF); // rgba(255,255,255,.12) breakdown divider on the dark card
  static const walletAmberOnDark = Color(0xFFF0B75A); // softer amber for the wallet figure on ink (brighter than codExcessAmber)

  // Home variants (Home Directions.dc.html 1b/1c/2a) — mockup hexes with no
  // existing token. Grown from the Glance/Compact/Flat explorations.
  static const flatMuted = Color(0xFF85847F); // Flat (2a) muted labels / meta
  static const flatBadgeBg = Color(0xFFEDECE8); // Flat (2a) numbered stop badge
  static const flatDivider = Color(0xFFE8E7E3); // Flat (2a) hairline dividers / circle button border
  static const flatBlack = Color(0xFF000000); // Flat (2a) pure-black primary button + banner text
  static const flatBannerBg = Color(0xFF898989); // Flat (2a) grey "today's overview" banner
  static const flatMutedDot = Color(0xFFC6C5C0); // Flat (2a) chevron + meta separator dot
  static const darkTileLabel = Color(0xFFCCCCD0); // Compact (1c) muted label on the dark collection tile
  static const cashSuffixGreen = Color(0xFF7BDDA3); // lighter green "جم" suffix on the dark cash banner/tile
  static const cashTileWash = Color(0x263BD07A); // rgba(59,208,122,.15) icon-tile wash on the dark cash banner
  static const onlineBarBorder = Color(0x4016A34A); // rgba(22,163,74,.25) "you're online" bar border (Glance 1b)
  static const onlineDotGlow = Color(0x2E16A34A); // rgba(22,163,74,.18) green online-dot glow (Glance 1b)
  static const softDropShadow = Color(0x2E000000); // rgba(0,0,0,.18) soft card drop shadow (Flat/Compact route cards)
  static const deepDropShadow = Color(0x80000000); // rgba(0,0,0,.5) deep drop shadow on the dark cash banner (Glance 1b)
}

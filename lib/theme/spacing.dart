/// The 4-pixel rule (from the design project's CLAUDE.md): every padding and
/// gap is a multiple of 4 — no exceptions for spacing (unlike font sizes,
/// which allow 14/18). Always use these constants instead of hardcoded
/// numbers so a stray 10 or 18 padding can't sneak in.
abstract final class AppSpacing {
  static const s0 = 0.0;
  static const s4 = 4.0;
  static const s8 = 8.0;
  static const s12 = 12.0;
  static const s16 = 16.0;
  static const s20 = 20.0;
  static const s24 = 24.0;
  static const s28 = 28.0;
  static const s32 = 32.0;
  static const s40 = 40.0;
  static const s48 = 48.0;
  static const s56 = 56.0;
  static const s64 = 64.0;
}

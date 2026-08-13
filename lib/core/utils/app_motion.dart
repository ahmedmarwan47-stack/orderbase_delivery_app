import 'package:flutter/widgets.dart';

/// One shared motion vocabulary so delight reads as a single system, not
/// scattered effects. Durations express distance/consequence (short = feedback,
/// long = the one authored focal moment); [ease] is the confident exponential
/// deceleration used for every arrival. Always gate authored motion on
/// [reduced] so the platform's Reduce Motion setting jumps straight to the
/// settled state.
class AppMotion {
  const AppMotion._();

  /// Immediate feedback (selection, chip fill).
  static const Duration tick = Duration(milliseconds: 120);

  /// A small control acknowledging a tap (press / stamp-in).
  static const Duration stamp = Duration(milliseconds: 200);

  /// A routine state change (segment fill, colour shift).
  static const Duration fill = Duration(milliseconds: 320);

  /// A card / object settling into place.
  static const Duration settle = Duration(milliseconds: 420);

  /// The one authored focal entrance (the cash count-up).
  static const Duration focal = Duration(milliseconds: 640);

  /// Confident natural deceleration — cubic-bezier(0.16, 1, 0.3, 1)-ish. No
  /// bounce/elastic by reflex.
  static const Curve ease = Curves.easeOutCubic;

  /// True when the platform asks to minimise motion; jump to the end state.
  static bool reduced(BuildContext context) =>
      MediaQuery.of(context).disableAnimations;
}

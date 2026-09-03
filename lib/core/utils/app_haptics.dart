import 'dart:async';

import 'package:flutter/services.dart';

/// Semantic haptic vocabulary for the courier's one-handed, eyes-off flow — the
/// courier *feels* a confirmation without looking. Thin wrapper over
/// [HapticFeedback]; every call is a no-op on devices without a haptic engine
/// (and on the Simulator), and iOS already honours the system haptic setting,
/// so these are always safe to fire.
class AppHaptics {
  const AppHaptics._();

  /// A discrete selection changed — filter chip, segmented pick.
  static void tick() => HapticFeedback.selectionClick();

  /// A light acknowledgement of a routine tap (call / WhatsApp / open map).
  static void tap() => HapticFeedback.lightImpact();

  /// A deliberate confirm was committed (stamp a stop, accept the batch).
  static void confirm() => HapticFeedback.mediumImpact();

  /// A positive outcome landed — delivered, cash collected.
  static void success() => HapticFeedback.heavyImpact();

  /// A negative-but-sanctioned outcome — a failed / returned delivery.
  static void warning() => HapticFeedback.heavyImpact();

  /// Something happened *to* the courier rather than by them — the branch
  /// dispatched a batch. A phone in a jacket pocket on a bike needs more than
  /// a sheet sliding up: two heavy knocks a beat apart, plus the system alert
  /// sound so the ear catches what the hand misses. The sound is a real
  /// system sound (no plugin, so the iOS build stays CocoaPods-free), it obeys
  /// the ring/silent switch, and is a no-op on Android, where the haptics
  /// still fire.
  static void attention() {
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.alert);
    Timer(const Duration(milliseconds: 160), HapticFeedback.heavyImpact);
  }
}

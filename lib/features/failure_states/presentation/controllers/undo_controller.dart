part of '../imports/failure_states_imports.dart';

/// Drives the undo countdown on the "logged" sheet (1f). Replicates the
/// mockup's `DCLogic` tick: one second per interval, and — since the mockup is
/// a live demo — it loops back to the full window when it reaches zero.
///
/// No `setState`: the sheet listens to [secondsLeft] via
/// [ValueListenableBuilder].
///
/// NB for integration: in production the undo affordance should expire (disable
/// the "تراجع" button) at zero rather than loop.
class UndoController {
  UndoController({this.total = 10}) : secondsLeft = ValueNotifier(total) {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final cur = secondsLeft.value;
      secondsLeft.value = cur <= 1 ? total : cur - 1;
    });
  }

  final int total;
  final ValueNotifier<int> secondsLeft;
  late final Timer _timer;

  /// Fraction of the window remaining (0..1) — the progress bar width.
  double fraction(int left) => (left / total).clamp(0.0, 1.0);

  void dispose() {
    _timer.cancel();
    secondsLeft.dispose();
  }
}

part of '../imports/settlement_imports.dart';

/// Which of the screen's two sub-views is showing.
enum SettlementStage { open, settled }

/// Ephemeral UI state for the Settlement screen — just the current [stage] and
/// whether the dark card shows its breakdown row. No `setState`, no logic in the
/// View. `settle()` closes the day (open → settled); `reset()` reopens it.
class SettlementController {
  SettlementController({
    required this.data,
    SettlementStage startStage = SettlementStage.open,
    bool showBreakdown = true,
  })  : stage = ValueNotifier(startStage),
        showBreakdown = ValueNotifier(showBreakdown);

  final SettlementData data;
  final ValueNotifier<SettlementStage> stage;

  /// Whether the dark cash card renders its 3-column breakdown row.
  final ValueNotifier<bool> showBreakdown;

  /// Hand the cash to the cashier — closes the collections queue.
  void settle() => stage.value = SettlementStage.settled;

  /// Reopen the settlement (SETTLED "reset" → OPEN).
  void reset() => stage.value = SettlementStage.open;

  void dispose() {
    stage.dispose();
    showBreakdown.dispose();
  }
}

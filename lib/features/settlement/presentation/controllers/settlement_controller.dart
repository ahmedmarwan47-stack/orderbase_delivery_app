part of '../imports/settlement_imports.dart';

/// Which of the screen's two sub-views is showing.
enum SettlementStage { open, settled }

/// Ephemeral UI state for the Settlement screen — just the current [stage] and
/// whether the dark card shows its breakdown row. No `setState`, no logic in the
/// View. `settle()` closes the day (open → settled); `reset()` reopens it.
class SettlementController {
  SettlementController({
    SettlementData? data,
    SettlementStage startStage = SettlementStage.open,
    bool showBreakdown = true,
  })  : _override = data,
        stage = ValueNotifier(startStage),
        showBreakdown = ValueNotifier(showBreakdown);

  /// Static override (DevGallery/preview). When null the data is recomputed
  /// live from today's shift on every read, so the settlement tab stays current
  /// as deliveries land (it used to be pushed fresh each time; as a persistent
  /// tab it must read live instead of snapshotting once at construction).
  final SettlementData? _override;

  SettlementData get data => _override ?? shiftSettlement;

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

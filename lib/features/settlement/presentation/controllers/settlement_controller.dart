part of '../imports/settlement_imports.dart';

/// Which of the screen's two sub-views is showing. In the app it follows the
/// shift (the branch settles, the view flips); the enum survives for previews
/// that pin one state.
enum SettlementStage { open, settled }

/// Ephemeral UI state for the Settlement screen — a preview override, the
/// pinned stage for that override, and whether the cash card shows its
/// breakdown row. No `setState`, no logic in the View.
class SettlementController {
  SettlementController({
    SettlementData? data,
    SettlementStage startStage = SettlementStage.open,
    bool showBreakdown = true,
  }) : _override = data,
       stage = ValueNotifier(startStage),
       showBreakdown = ValueNotifier(showBreakdown);

  /// Static override (DevGallery/preview). When null the data is recomputed
  /// live from today's shift on every read, so the tab stays current as
  /// deliveries land and as the branch settles.
  final SettlementData? _override;

  SettlementData get data {
    final o = _override;
    if (o == null) return shiftSettlement;
    return stage.value == SettlementStage.settled
        ? o.copyWith(
            status: SettlementStatus.settled,
            settledAt: o.settledAt ?? DateTime.now(),
          )
        : o;
  }

  /// Preview-only: pins the settled view for an override.
  final ValueNotifier<SettlementStage> stage;

  /// Whether the dark cash card renders its 3-column breakdown row.
  final ValueNotifier<bool> showBreakdown;

  /// Preview-only: loop SETTLED back to OPEN.
  void reset() => stage.value = SettlementStage.open;

  void dispose() {
    stage.dispose();
    showBreakdown.dispose();
  }
}

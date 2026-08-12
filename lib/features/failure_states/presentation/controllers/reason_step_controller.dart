part of '../imports/failure_states_imports.dart';

/// Ephemeral state for the reason step (1a): which reason is selected. The
/// mockup pre-selects «العميل غير متواجد». No `setState` — the sheet listens
/// via [ValueListenableBuilder].
class ReasonStepController {
  ReasonStepController({FailureReason initial = FailureReason.notPresent})
      : selected = ValueNotifier(initial);

  final ValueNotifier<FailureReason> selected;

  void select(FailureReason reason) => selected.value = reason;

  void dispose() => selected.dispose();
}

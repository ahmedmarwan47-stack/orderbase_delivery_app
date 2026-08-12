part of '../imports/order_flow_imports.dart';

/// Ephemeral state for the fail sheet: the selected non-delivery reason index
/// (defaults to 0 — "العميل غير متواجد"), the mandatory note text, and a
/// derived [canSubmit] gate (needs a selected reason AND a non-empty note).
/// No `setState`.
class FailSheetController {
  FailSheetController() : selected = ValueNotifier(0) {
    note.addListener(_recompute);
    selected.addListener(_recompute);
  }

  final ValueNotifier<int> selected;

  /// The mandatory failure note (إلزامية).
  final TextEditingController note = TextEditingController();

  /// Whether the submit button may fire — a reason is selected and the note is
  /// non-empty.
  final ValueNotifier<bool> canSubmit = ValueNotifier(false);

  /// The non-delivery reason label keys, in display order.
  static const List<String> reasonKeys = [
    LocaleKeys.failReason1,
    LocaleKeys.failReason2,
    LocaleKeys.failReason3,
    LocaleKeys.failReason4,
    LocaleKeys.failReason5,
    LocaleKeys.failReason6,
  ];

  /// The localization key of the currently selected reason, or null if none.
  String? get selectedReasonKey =>
      (selected.value >= 0 && selected.value < reasonKeys.length)
          ? reasonKeys[selected.value]
          : null;

  void _recompute() =>
      canSubmit.value = selected.value >= 0 && note.text.trim().isNotEmpty;

  void select(int i) => selected.value = i;

  void dispose() {
    note.removeListener(_recompute);
    selected.removeListener(_recompute);
    note.dispose();
    selected.dispose();
    canSubmit.dispose();
  }
}

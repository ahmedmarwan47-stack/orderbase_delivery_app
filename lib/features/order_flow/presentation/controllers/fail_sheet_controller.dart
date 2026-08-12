part of '../imports/order_flow_imports.dart';

/// Ephemeral state for the fail sheet: the selected non-delivery reason index
/// (defaults to 0 — "العميل غير متواجد"). No `setState`.
class FailSheetController {
  FailSheetController() : selected = ValueNotifier(0);

  final ValueNotifier<int> selected;

  /// The non-delivery reason label keys, in display order.
  static const List<String> reasonKeys = [
    LocaleKeys.failReason1,
    LocaleKeys.failReason2,
    LocaleKeys.failReason3,
    LocaleKeys.failReason4,
    LocaleKeys.failReason5,
    LocaleKeys.failReason6,
  ];

  void select(int i) => selected.value = i;

  void dispose() => selected.dispose();
}

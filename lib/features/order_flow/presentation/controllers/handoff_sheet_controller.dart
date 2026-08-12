part of '../imports/order_flow_imports.dart';

/// Ephemeral state for the handoff sheet: whether the proof-of-delivery photo
/// has been captured. No `setState`. (Cash moved to the COD 2a flow.)
class HandoffSheetController {
  HandoffSheetController() : photo = ValueNotifier(false);

  final ValueNotifier<bool> photo;

  void capture() => photo.value = true;

  void dispose() {
    photo.dispose();
  }
}

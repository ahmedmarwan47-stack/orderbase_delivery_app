part of '../imports/order_flow_imports.dart';

/// Ephemeral state for the handoff sheet: whether the delivery photo has been
/// captured and whether the change goes to the wallet. No `setState`.
class HandoffSheetController {
  HandoffSheetController()
      : photo = ValueNotifier(false),
        wallet = ValueNotifier(true);

  final ValueNotifier<bool> photo;
  final ValueNotifier<bool> wallet;

  void capture() => photo.value = true;

  void toggleWallet() => wallet.value = !wallet.value;

  void dispose() {
    photo.dispose();
    wallet.dispose();
  }
}

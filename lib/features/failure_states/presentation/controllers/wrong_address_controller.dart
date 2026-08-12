part of '../imports/failure_states_imports.dart';

/// Ephemeral state for the wrong-address step (1c): the retry choice
/// (now / later) and, when later, which time slot is picked. Mirrors the
/// mockup's `addressRetry` prop (both / now / later).
class WrongAddressController {
  WrongAddressController({
    AddressRetry initial = AddressRetry.now,
    String? initialSlot,
  })  : retry = ValueNotifier(initial),
        slot = ValueNotifier(initialSlot);

  final ValueNotifier<AddressRetry> retry;
  final ValueNotifier<String?> slot;

  void chooseNow() {
    retry.value = AddressRetry.now;
    slot.value = null;
  }

  void chooseLater(String time) {
    retry.value = AddressRetry.later;
    slot.value = time;
  }

  void dispose() {
    retry.dispose();
    slot.dispose();
  }
}

part of '../imports/failure_states_imports.dart';

/// The courier's choice on the wrong-address step (1c), single-select.
enum WrongAddressChoice {
  /// «حاول مرة أخرى» — the corrected address is used for an immediate re-attempt;
  /// the order stays active (→ [FailureResolution.retryNow]).
  tryAgain,

  /// «الإرجاع للفرع» — the pieces go back to the branch
  /// (→ [FailureResolution.returnedToBranch]).
  returnToBranch,
}

/// Ephemeral state for the wrong-address step (1c): the editable corrected
/// address the courier types, plus the single-select outcome choice.
class WrongAddressController {
  WrongAddressController({
    required String correctedAddress,
    WrongAddressChoice initial = WrongAddressChoice.tryAgain,
  }) : address = TextEditingController(text: correctedAddress),
       choice = ValueNotifier(initial);

  /// The corrected address the courier edits (RTL, prefilled).
  final TextEditingController address;

  /// The currently selected outcome choice.
  final ValueNotifier<WrongAddressChoice> choice;

  void choose(WrongAddressChoice value) => choice.value = value;

  void dispose() {
    address.dispose();
    choice.dispose();
  }
}

part of '../imports/cod_imports.dart';

/// A snapshot of the collected amount versus the order value, plus every derived
/// figure the entry sheet renders. Pure value type — no Flutter deps. Built from
/// the amount field's raw text (digits + grouping commas) and the order [due].
class CodAmount {
  CodAmount({required String raw, required this.due})
    : amount = int.tryParse(raw.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
      isEmpty = raw.replaceAll(RegExp(r'[^0-9]'), '').isEmpty;

  final int due;
  final int amount;
  final bool isEmpty;

  /// Cash collected above the order value — this is what goes to the wallet.
  int get extra => amount > due ? amount - due : 0;

  /// How much the courier is still short of the order value.
  int get short => amount < due ? due - amount : 0;

  bool get isShort => short > 0 && !isEmpty;
  bool get hasExtra => extra > 0;

  /// Delivery can only be confirmed once the full order value is collected.
  bool get canConfirm => short == 0 && amount > 0;
}

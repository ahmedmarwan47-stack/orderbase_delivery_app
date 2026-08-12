part of '../imports/cod_imports.dart';

/// The confirmed outcome of a COD collection: the exact cash the courier
/// collected and how much of it exceeds the order value (goes to the
/// customer's wallet).
class CodCollectionResult {
  const CodCollectionResult({required this.amount, required this.walletChange});

  final int amount;
  final int walletChange;
}

/// Runs the COD 2a collection flow over the current screen: keypad **entry** →
/// wallet **confirmation**. Returns the confirmed [CodCollectionResult] when
/// the courier confirms delivery, or `null` if they dismiss out of the flow.
///
/// [due] is the order value to collect; [orderNum] / [customerName] label the
/// sheet. "تعديل المبلغ" on the confirmation loops back to entry, prefilled.
Future<CodCollectionResult?> showCodCollectionSheet(
  BuildContext context, {
  required int due,
  required String orderNum,
  required String customerName,
}) async {
  var initial = '';
  while (true) {
    final amount = await showAppSheet<int>(
      context,
      child: _CodEntrySheet(
        due: due,
        orderNum: orderNum,
        customerName: customerName,
        initial: initial,
      ),
    );
    if (amount == null) return null; // dismissed the entry sheet
    if (!context.mounted) return null;

    final delivered = await showAppSheet<bool>(
      context,
      child: _CodConfirmSheet(due: due, amount: amount),
    );
    if (delivered == true) {
      return CodCollectionResult(
        amount: amount,
        walletChange: amount > due ? amount - due : 0,
      );
    }
    if (delivered == null) return null; // dismissed the confirm sheet
    // delivered == false → "تعديل المبلغ": reopen entry, prefilled.
    initial = amount.toString();
    if (!context.mounted) return null;
  }
}

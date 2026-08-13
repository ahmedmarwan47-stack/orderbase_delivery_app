part of '../imports/settlement_imports.dart';

/// One cash order in the end-of-day settlement. `paid` is what the courier
/// actually collected; `order` is the order's value. Any excess (`wallet`) was
/// change the courier kept for the customer's wallet. Pure value type.
class SettlementLine {
  const SettlementLine({
    required this.num,
    required this.name,
    required this.order,
    required this.paid,
  });

  /// Order number, e.g. `#89289` — always rendered LTR inside the RTL flow.
  final String num;
  final String name;

  /// The order's value in EGP.
  final int order;

  /// Cash actually collected in EGP (>= [order]).
  final int paid;

  /// Change owed to the customer's wallet — the amount collected above value.
  int get wallet => paid > order ? paid - order : 0;

  bool get hasWallet => wallet > 0;
}

/// The whole settlement snapshot — the lines plus every derived total the two
/// views render. Built once from [lines]; mirrors the mockup's DCLogic getters.
class SettlementData {
  const SettlementData({
    required this.lines,
    required this.cashierName,
  });

  final List<SettlementLine> lines;

  /// The cashier who receives the cash (shown on the SETTLED summary).
  final String cashierName;

  /// Total cash in hand = Σ paid (what the cashier receives).
  int get cashTotal => lines.fold(0, (sum, l) => sum + l.paid);

  /// Σ order value (the "قيمة الطلبات" breakdown figure).
  int get ordersTotal => lines.fold(0, (sum, l) => sum + l.order);

  /// Σ wallet change (the "فكة للمحفظة" breakdown figure).
  int get walletTotal => lines.fold(0, (sum, l) => sum + l.wallet);

  /// Number of cash orders in the settlement.
  int get rowCount => lines.length;
}

/// Sample data mirroring the mockup's own DCLogic `state` — kept identical so
/// the ported screen stays visually comparable to Settlement.dc.html.
/// Totals: cashTotal 3170, ordersTotal 3070, walletTotal 100, rowCount 4.
/// A getter (not a `const`) because the cashier name is localized at runtime via
/// `.tr()`; the lines list stays `const`. Customer names are sample data, not UI
/// chrome, so they are intentionally left as literals.
SettlementData get sampleSettlement => SettlementData(
      cashierName: LocaleKeys.settlementCashierDefault.tr(),
      lines: const [
        SettlementLine(num: '#89289', name: 'محمد حمدي', order: 1200, paid: 1250),
        SettlementLine(num: '#89285', name: 'منى خالد', order: 800, paid: 800),
        SettlementLine(num: '#89291', name: 'أحمد فؤاد', order: 450, paid: 500),
        SettlementLine(num: '#89272', name: 'ياسمين عادل', order: 620, paid: 620),
      ],
    );

/// Live settlement snapshot built from today's shift
/// ([ShiftController.instance.orders]) — the cash orders the courier actually
/// delivered. Only delivered, non-prepaid (COD) orders count toward the cash the
/// cashier receives; `order` is the order value and `paid` is the cash collected
/// (falling back to the order value when a specific figure wasn't recorded). Early
/// in a shift there are no delivered cash orders, so [SettlementData.lines] is
/// empty and every total derives to 0 — the views render that gracefully. The
/// cashier name is localized at runtime, matching [sampleSettlement].
SettlementData get shiftSettlement => SettlementData(
      cashierName: LocaleKeys.settlementCashierDefault.tr(),
      lines: ShiftController.instance.orders
          .where((o) => o.status == OrderStatus.delivered && !o.prepaid)
          .map((o) => SettlementLine(
                num: o.num,
                name: o.name,
                order: o.cod ?? 0,
                paid: o.collected ?? o.cod ?? 0,
              ))
          .toList(),
    );

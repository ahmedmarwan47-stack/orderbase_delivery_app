part of '../imports/order_flow_imports.dart';

/// Orchestrates the Order Flow state machine off the Order Detail screen:
/// the "delivered" bar opens the handoff sheet → delivered result; the
/// "not delivered" button opens the fail sheet → failed result, whose "تأجيل"
/// hands off to the postpone sheet → postponed result (postpone's back arrow
/// returns to the fail sheet). Holds no disposable state — pure navigation.
///
/// [orderNum] (with '#') and [customer] identify the order on the Result
/// screen; the sheets surface the real outcome (collected cash, fail reason,
/// re-attempt slot) which is threaded straight through to that screen.
class OrderFlowController {
  const OrderFlowController({
    this.onFinishToNext,
    this.onFinishToHome,
    this.orderNum = '#89289',
    this.customer = 'محمد حمدي',
  });

  /// Result screen's primary button ("continue route — next stop").
  final VoidCallback? onFinishToNext;

  /// Result screen's secondary button ("back to home").
  final VoidCallback? onFinishToHome;

  /// The order number (with '#') and customer name shown on the Result screen.
  final String orderNum;
  final String customer;

  void _openResult(
    BuildContext context,
    ResultKind kind, {
    String? codAmount,
    bool showWalletChange = false,
    String? walletChange,
    String? reasonLabel,
    String? postponeDisplay,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          kind: kind,
          orderNum: orderNum,
          customer: customer,
          codAmount: codAmount,
          showWalletChange: showWalletChange,
          walletChange: walletChange,
          reasonLabel: reasonLabel,
          postponeDisplay: postponeDisplay,
          onContinue: onFinishToNext,
          onHome: onFinishToHome,
        ),
      ),
    );
  }

  /// Delivery, payment-aware:
  /// - **prepaid** → handoff sheet (proof photo) → delivered result. No cash.
  /// - **COD** → handoff sheet (proof photo) → COD 2a collection → delivered.
  ///
  /// The COD collection flow currently reports only success/dismissal (it does
  /// not surface the exact cash collected or wallet change), so the delivered
  /// result shows the order's due amount as the collected total and omits the
  /// wallet-change row. See the follow-up note in the task report.
  Future<void> deliver(
    BuildContext context, {
    required bool cod,
    required int due,
  }) async {
    final photoOk = await showHandoffSheet(
      context,
      cod: cod,
      orderNum: orderNum,
      customerName: customer,
    );
    if (photoOk != true || !context.mounted) return;

    if (!cod) {
      _openResult(
        context,
        ResultKind.delivered,
        codAmount: LocaleKeys.payPrepaid.tr(),
      );
      return;
    }
    final collected = await showCodCollectionSheet(
      context,
      due: due,
      orderNum: orderNum.replaceAll('#', '').trim(),
      customerName: customer,
    );
    if (collected == true && context.mounted) {
      _openResult(
        context,
        ResultKind.delivered,
        codAmount: '${formatThousands(due)} ${LocaleKeys.orderDetailEgpSuffix.tr()}',
      );
    }
  }

  /// Fail sheet → failed result, or hand off to the postpone sheet →
  /// postponed result. The postpone sheet's back arrow returns to the fail
  /// sheet. The chosen reason/note and re-attempt slot are threaded into the
  /// result.
  Future<void> fail(BuildContext context) async {
    final outcome = await showFailSheet(context);
    if (!context.mounted || outcome == null) return;
    if (outcome.action == FailResult.failed) {
      _openResult(
        context,
        ResultKind.failed,
        reasonLabel: outcome.reasonLabel,
      );
      return;
    }
    // postpone
    final p = await showPostponeSheet(context);
    if (!context.mounted || p == null) return;
    if (p.action == PostponeResult.confirm) {
      _openResult(
        context,
        ResultKind.postponed,
        postponeDisplay: p.display,
      );
    } else if (p.action == PostponeResult.back) {
      fail(context); // reopen the fail sheet
    }
  }
}

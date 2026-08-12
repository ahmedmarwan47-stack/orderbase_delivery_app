part of '../imports/order_flow_imports.dart';

/// Orchestrates the Order Flow state machine off the Order Detail screen:
/// the "delivered" bar opens the handoff sheet → delivered result; the
/// "not delivered" button opens the Failure States flow → failed result (or,
/// when the customer asks to postpone, hands off to the postpone sheet →
/// postponed result; postpone's back arrow reopens the failure flow). Holds
/// no disposable state — pure navigation.
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
  /// - **COD** → handoff sheet (proof photo) → COD 2a collection → delivered,
  ///   with the real collected cash and any wallet change shown on the result.
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
    if (collected != null && context.mounted) {
      final hasWalletChange = collected.walletChange > 0;
      final unit = LocaleKeys.orderDetailEgpSuffix.tr();
      _openResult(
        context,
        ResultKind.delivered,
        codAmount: '${formatThousands(collected.amount)} $unit',
        showWalletChange: hasWalletChange,
        walletChange:
            hasWalletChange ? '+${formatThousands(collected.walletChange)} $unit' : null,
      );
    }
  }

  /// Not-delivered → the full Failure States flow (reason → per-reason step →
  /// return-to-branch → logged), mapped back onto the Order Flow outcomes:
  /// - **returned to branch** → failed result.
  /// - **postpone** (the customer asked to reschedule) → hands off to the
  ///   existing postpone sheet → postponed result; its back arrow reopens the
  ///   failure flow.
  /// - **retry now / retry later** (wrong address corrected, or traffic) →
  ///   the order stays active on Order Detail for re-attempt; no result.
  /// - dismissed at any step → no result.
  Future<void> fail(BuildContext context) async {
    final outcome = await showFailureFlow(context);
    if (!context.mounted || outcome == null) return;

    switch (outcome.resolution) {
      case FailureResolution.returnedToBranch:
        _openResult(
          context,
          ResultKind.failed,
          reasonLabel: outcome.reason?.label,
        );
        break;
      case FailureResolution.postpone:
        final p = await showPostponeSheet(context);
        if (!context.mounted || p == null) return;
        if (p.action == PostponeResult.confirm) {
          _openResult(
            context,
            ResultKind.postponed,
            postponeDisplay: p.display,
          );
        } else if (p.action == PostponeResult.back) {
          fail(context); // reopen the failure flow
        }
        break;
      case FailureResolution.retryNow:
      case FailureResolution.retryLater:
        // Retryable — the order stays in the active queue; nothing to show.
        break;
      case FailureResolution.cancelled:
        break;
    }
  }
}

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
      ShiftController.instance.markDelivered(orderNum, collected: 0);
      _openResult(
        context,
        ResultKind.delivered,
        codAmount: LocaleKeys.payPrepaid.tr(),
      );
      return;
    }
    // The island switches to its "collecting" face while the sheet is up; if
    // the courier backs out it goes straight back to the en-route face.
    await LiveActivityBridge.instance.setPhase(DeliveryPhase.collecting);
    final collected = await showCodCollectionSheet(
      context,
      due: due,
      orderNum: orderNum.replaceAll('#', '').trim(),
      customerName: customer,
    );
    if (collected == null) {
      await LiveActivityBridge.instance.setPhase(DeliveryPhase.enRoute);
      return;
    }
    if (context.mounted) {
      ShiftController.instance
          .markDelivered(orderNum, collected: collected.amount);
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
  ///
  /// [order] is threaded through so the failure sheets surface *this* order's
  /// customer / number / address (via [_failureContextFor]) instead of the
  /// packaged sample — mirroring how [deliver] receives its per-order data.
  Future<void> fail(BuildContext context, {required FlowOrder order}) async {
    final outcome =
        await showFailureFlow(context, context_: _failureContextFor(order));
    if (!context.mounted || outcome == null) return;

    switch (outcome.resolution) {
      case FailureResolution.returnedToBranch:
        ShiftController.instance
            .markFailed(orderNum, reason: outcome.reason?.label);
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
          ShiftController.instance.markPostponed(orderNum);
          _openResult(
            context,
            ResultKind.postponed,
            postponeDisplay: p.display,
          );
        } else if (p.action == PostponeResult.back) {
          fail(context, order: order); // reopen the failure flow
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

/// Maps the real [FlowOrder] onto the failure flow's [FailureContext] so the
/// not-delivered sheets show this order's own customer, number and address.
///
/// [FlowOrder] carries the number, name, address and a `meta` string
/// (`<area> · <pieces> قطعة`) — the area and piece count are parsed out of it.
/// Fields [FlowOrder] doesn't model (the address detail hint, the 1c corrected
/// address, the branch, logged contact attempts and the retry-later slots) fall
/// back to the shared [sampleFailureContext] values.
FailureContext _failureContextFor(FlowOrder order) {
  final sample = sampleFailureContext();
  final parts = order.meta.split('·');
  final area = parts.isNotEmpty ? parts.first.trim() : sample.area;
  final piecesLabel = parts.length > 1 ? parts[1].trim() : sample.piecesLabel;
  final pieces =
      int.tryParse(RegExp(r'\d+').firstMatch(piecesLabel)?.group(0) ?? '') ??
          sample.pieces;
  return FailureContext(
    orderNum: order.num,
    customer: order.name,
    area: area,
    address: order.address,
    addressDetail: sample.addressDetail,
    correctedAddress: sample.correctedAddress,
    pieces: pieces,
    piecesLabel: piecesLabel,
    branch: sample.branch,
    attempts: sample.attempts,
    laterSlots: sample.laterSlots,
  );
}

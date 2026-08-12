part of '../imports/order_flow_imports.dart';

/// Orchestrates the Order Flow state machine off the Order Detail screen:
/// the "delivered" bar opens the handoff sheet → delivered result; the
/// "not delivered" button opens the fail sheet → failed result, whose "تأجيل"
/// hands off to the postpone sheet → postponed result (postpone's back arrow
/// returns to the fail sheet). Holds no disposable state — pure navigation.
class OrderFlowController {
  const OrderFlowController({this.onFinishToNext, this.onFinishToHome});

  /// Result screen's primary button ("continue route — next stop").
  final VoidCallback? onFinishToNext;

  /// Result screen's secondary button ("back to home").
  final VoidCallback? onFinishToHome;

  void _openResult(BuildContext context, ResultKind kind) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          kind: kind,
          onContinue: onFinishToNext,
          onHome: onFinishToHome,
        ),
      ),
    );
  }

  /// Handoff sheet → delivered result.
  Future<void> deliver(BuildContext context) async {
    final ok = await showHandoffSheet(context);
    if (ok == true && context.mounted) {
      _openResult(context, ResultKind.delivered);
    }
  }

  /// Fail sheet → failed result, or hand off to the postpone sheet →
  /// postponed result. The postpone sheet's back arrow returns to the fail
  /// sheet.
  Future<void> fail(BuildContext context) async {
    final outcome = await showFailSheet(context);
    if (!context.mounted || outcome == null) return;
    if (outcome == FailResult.failed) {
      _openResult(context, ResultKind.failed);
      return;
    }
    // postpone
    final p = await showPostponeSheet(context);
    if (!context.mounted) return;
    if (p == PostponeResult.confirm) {
      _openResult(context, ResultKind.postponed);
    } else if (p == PostponeResult.back) {
      fail(context); // reopen the fail sheet
    }
  }
}

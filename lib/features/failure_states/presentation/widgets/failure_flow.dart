part of '../imports/failure_states_imports.dart';

/// Result of a second-step sheet (1b/1c/1d/1e): advance or go back to the
/// reason list.
enum SecondStepResult { next, back }

/// Runs the not-delivered flow end to end over the current screen, mirroring
/// the mockup's state machine:
///
///   reason (1a) → per-reason second step (1b/1c/1d) → return-to-branch (1e),
///   which logs the non-delivery immediately (no interim countdown sheet).
///
/// Retryable reasons (wrong address) resolve at their own step and skip 1e.
/// Returns the terminal [FailureOutcome], or `null` if fully dismissed.
///
/// This is the intended replacement for order_flow's single "fail sheet": that
/// sheet only picks a reason today; this drives the whole second step.
Future<FailureOutcome?> showFailureFlow(
  BuildContext context, {
  FailureContext? context_,
}) async {
  final ctx = context_ ?? sampleFailureContext();
  var initial = FailureReason.notPresent;

  while (true) {
    if (!context.mounted) return null;
    // ── 1a · reason ──
    final step = await showAppSheet<ReasonStepResult>(
      context,
      child: _ReasonSheet(ctx: ctx, initial: initial),
    );
    if (step == null) return null;
    if (step.postpone) {
      return const FailureOutcome(resolution: FailureResolution.postpone);
    }
    final reason = step.reason ?? FailureReason.notPresent;
    final note = step.note; // optional free-text, only for «سبب آخر»
    initial = reason;
    if (!context.mounted) return null;

    // ── retryable: wrong address (1c) resolves on its own ──
    if (reason == FailureReason.wrongAddress) {
      final r = await showAppSheet<Object?>(
        context,
        child: _WrongAddressSheet(ctx: ctx),
      );
      if (r == SecondStepResult.back) continue;
      if (r is WrongAddressResult) {
        return FailureOutcome(
          resolution: r.choice == WrongAddressChoice.tryAgain
              ? FailureResolution.retryNow
              : FailureResolution.returnedToBranch,
          reason: reason,
        );
      }
      return null; // dismissed
    }

    // ── final reasons + traffic: optional per-reason step, then the
    //    return-to-branch confirm. Traffic used to short-circuit to a silent
    //    retry; it now flows into the same confirm so the courier can *choose*
    //    to send the pieces back to the branch (or back out to keep retrying).
    if (reason == FailureReason.notPresent) {
      final r = await showAppSheet<SecondStepResult>(
        context,
        child: _NotPresentSheet(ctx: ctx),
      );
      if (r == null) return null;
      if (r == SecondStepResult.back) continue;
    } else if (reason == FailureReason.mismatch) {
      final r = await showAppSheet<SecondStepResult>(
        context,
        child: _ProductMismatchSheet(ctx: ctx),
      );
      if (r == null) return null;
      if (r == SecondStepResult.back) continue;
    }
    // refused / other / traffic: straight to the return-to-branch confirm.
    if (!context.mounted) return null;

    // ── return-to-branch confirm — the final step. Confirming logs the
    //    non-delivery immediately and hands back to the failed result screen
    //    (no interim countdown/undo sheet). ──
    final confirm = await showAppSheet<Object?>(
      context,
      child: _ReturnToBranchSheet(ctx: ctx, reason: reason),
    );
    if (confirm == SecondStepResult.back) continue;
    if (confirm != true) {
      // Dismissed. Traffic is retryable — keep the order active for another
      // attempt; the final reasons simply cancel.
      return reason == FailureReason.traffic
          ? const FailureOutcome(resolution: FailureResolution.retryNow)
          : null;
    }
    if (!context.mounted) return null;

    return FailureOutcome(
      resolution: FailureResolution.returnedToBranch,
      reason: reason,
      note: note,
    );
  }
}

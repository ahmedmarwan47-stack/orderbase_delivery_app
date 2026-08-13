part of '../imports/failure_states_imports.dart';

/// Result of a second-step sheet (1b/1c/1d/1e): advance or go back to the
/// reason list.
enum SecondStepResult { next, back }

/// Runs the not-delivered flow end to end over the current screen, mirroring
/// the mockup's state machine:
///
///   reason (1a) → per-reason second step (1b/1c/1d) → return-to-branch (1e)
///   → logged with undo (1f)
///
/// Retryable reasons (wrong address) resolve at their own step and skip 1e/1f.
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

    // ── retryable: traffic has no dedicated screen — retry now ──
    if (reason == FailureReason.traffic) {
      return FailureOutcome(
        resolution: FailureResolution.retryNow,
        reason: reason,
      );
    }

    // ── final reasons: optional per-reason step, then 1e → 1f ──
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
    // refused / other: straight to the return-to-branch confirm.
    if (!context.mounted) return null;

    // ── 1e · return-to-branch confirm ──
    final confirm = await showAppSheet<Object?>(
      context,
      child: _ReturnToBranchSheet(ctx: ctx, reason: reason),
    );
    if (confirm == SecondStepResult.back) continue;
    if (confirm != true) return null; // dismissed
    if (!context.mounted) return null;

    // ── 1f · logged with undo ──
    final logged = await showAppSheet<LoggedResult>(
      context,
      child: _LoggedSheet(ctx: ctx, reason: reason),
    );
    if (logged == LoggedResult.undo) {
      initial = reason;
      if (!context.mounted) return null;
      continue; // undo → back to the reason list
    }
    return FailureOutcome(
      resolution: FailureResolution.returnedToBranch,
      reason: reason,
    );
  }
}

part of '../imports/failure_states_imports.dart';

/// What a failure reason resolves to, shown as a small tag on each reason row
/// in the reason step (1a).
enum ReasonOutcome {
  /// «يرجع للفرع» — the pieces come back to the branch (a final reason).
  returnsToBranch,

  /// «قابل للإعادة» — the order stays in the route and can be retried.
  retryable,

  /// No tag (e.g. «سبب آخر»).
  none,
}

/// The six not-delivered reasons, in the order the mockup lists them (1a).
enum FailureReason {
  notPresent, // العميل غير متواجد        → 1b, returns to branch
  refused, // العميل رفض الاستلام         → returns to branch
  mismatch, // عدم تطابق المنتج          → 1d, returns to branch
  wrongAddress, // عنوان خاطئ            → 1c, retryable
  traffic, // زحام مروري أو تأخير        → retryable
  other, // سبب آخر
}

extension FailureReasonX on FailureReason {
  ReasonOutcome get outcome => switch (this) {
        FailureReason.notPresent => ReasonOutcome.returnsToBranch,
        FailureReason.refused => ReasonOutcome.returnsToBranch,
        FailureReason.mismatch => ReasonOutcome.returnsToBranch,
        FailureReason.wrongAddress => ReasonOutcome.retryable,
        FailureReason.traffic => ReasonOutcome.retryable,
        FailureReason.other => ReasonOutcome.none,
      };

  /// True for the three "final" reasons that funnel into the return-to-branch
  /// confirm screen (1e).
  bool get isFinal => outcome == ReasonOutcome.returnsToBranch;

  String get label => switch (this) {
        FailureReason.notPresent => LocaleKeys.failureReasonNotPresent.tr(),
        FailureReason.refused => LocaleKeys.failureReasonRefused.tr(),
        FailureReason.mismatch => LocaleKeys.failureReasonMismatch.tr(),
        FailureReason.wrongAddress => LocaleKeys.failureReasonWrongAddress.tr(),
        FailureReason.traffic => LocaleKeys.failureReasonTraffic.tr(),
        FailureReason.other => LocaleKeys.failureReasonOther.tr(),
      };
}

/// A single logged contact attempt (1b).
class ContactAttempt {
  const ContactAttempt({required this.icon, required this.label, required this.time});
  final String icon; // AppAssets.svg.*
  final String label;
  final String time; // "9:38"
}

/// The order under a failure flow — the fixed sample the mockup uses (#89289).
/// Kept inside the feature so this flow doesn't depend on the shared data layer
/// while it is being integrated.
class FailureContext {
  const FailureContext({
    required this.orderNum,
    required this.customer,
    required this.area,
    required this.address,
    required this.addressDetail,
    required this.correctedAddress,
    required this.pieces,
    required this.piecesLabel,
    required this.branch,
    required this.attempts,
    required this.laterSlots,
  });

  final String orderNum; // "#89289"
  final String customer; // "محمد حمدي"
  final String area; // "التجمع الخامس"
  final String address; // "٦ ش الفردوس، التجمع الخامس"
  final String addressDetail; // floor / apartment hint
  final String correctedAddress; // 1c corrected address
  final int pieces; // 2
  final String piecesLabel; // "٢ قطعة"
  final String branch; // "Sale Sucre — مدينة نصر"
  final List<ContactAttempt> attempts;
  final List<String> laterSlots; // retry-later time chips, e.g. ["12:30", ...]

  String get customerAndArea => '$customer · $area';
}

/// The mockup's fixed sample context (#89289).
FailureContext sampleFailureContext() => FailureContext(
      orderNum: '#89289',
      customer: 'محمد حمدي',
      area: 'التجمع الخامس',
      address: LocaleKeys.failureSampleAddress.tr(),
      addressDetail: LocaleKeys.failureSampleAddressDetail.tr(),
      correctedAddress: LocaleKeys.failureSampleCorrectedAddress.tr(),
      pieces: 2,
      piecesLabel: LocaleKeys.failureSamplePiecesLabel.tr(),
      branch: 'Sale Sucre — مدينة نصر',
      attempts: [
        ContactAttempt(
          icon: AppAssets.svg.phone,
          label: LocaleKeys.failureAttemptCallNoAnswer.tr(),
          time: '9:38',
        ),
        ContactAttempt(
          icon: AppAssets.svg.wa,
          label: LocaleKeys.failureAttemptWhatsappNoReply.tr(),
          time: '9:40',
        ),
      ],
      laterSlots: const ['12:30', '1:30', '2:30'],
    );

/// Which of the states the [FailureStatesHost] should open for preview.
enum FailureStatePreview {
  reason, // 1a
  notPresent, // 1b
  wrongAddress, // 1c
  productMismatch, // 1d
  returnToBranch, // 1e
}

/// The terminal outcome the flow hands back to its caller (e.g. order_flow).
class FailureOutcome {
  const FailureOutcome({required this.resolution, this.reason, this.note, this.retryTime});

  final FailureResolution resolution;
  final FailureReason? reason;
  final String? note;
  final String? retryTime; // set when resolution == retryLater
}

enum FailureResolution {
  /// Failure logged; pieces go back to the branch (1e → 1f).
  returnedToBranch,

  /// Wrong address corrected, retrying immediately (1c).
  retryNow,

  /// Wrong address corrected, deferred to a later slot today (1c).
  retryLater,

  /// The customer asked to postpone — hands off to the postpone flow.
  postpone,

  /// Dismissed without recording anything.
  cancelled,
}

part of '../imports/failure_states_imports.dart';

/// 1b · «العميل غير متواجد» — step 2 of 2 (a final reason). Logged contact
/// attempts, one last call/whatsapp nudge, and a mandatory note, then advance to
/// the return-to-branch confirm (1e). Attempts are required-but-not-blocking:
/// [gate] toggles a skip affordance vs a blocking hint.
class _NotPresentSheet extends StatefulWidget {
  const _NotPresentSheet({
    required this.ctx,
    this.gate = CallAttemptGate.skippable,
  });
  final FailureContext ctx;
  final CallAttemptGate gate;

  @override
  State<_NotPresentSheet> createState() => _NotPresentSheetState();
}

class _NotPresentSheetState extends State<_NotPresentSheet> {
  final _note = TextEditingController(
    text: LocaleKeys.failureNotPresentSampleNote.tr(),
  );

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skippable = widget.gate == CallAttemptGate.skippable;
    return _SheetScaffold(
      title: LocaleKeys.failureReasonNotPresent.tr(),
      stepCaption: LocaleKeys.failureStep2Final.tr(),
      onBack: () => Navigator.of(context).pop(SecondStepResult.back),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _lastNudgeCard(),
          16.szH,
          _FieldLabel(LocaleKeys.failureContactAttemptsLabel.tr(), strong: true),
          8.szH,
          for (final a in widget.ctx.attempts) ...[
            _AttemptRow(attempt: a),
            if (a != widget.ctx.attempts.last) 8.szH,
          ],
          16.szH,
          _FieldLabel(LocaleKeys.failureNoteMandatory.tr()),
          8.szH,
          _NoteField(controller: _note),
          20.szH,
          _PrimaryButton(
            label: LocaleKeys.failureNextReturnToBranch.tr(),
            leadingIcon: FailureIcons.box,
            onTap: () => Navigator.of(context).pop(SecondStepResult.next),
          ),
          if (skippable) ...[
            8.szH,
            _GhostButton(
              label: LocaleKeys.failureSkipContactAttempts.tr(),
              onTap: () => Navigator.of(context).pop(SecondStepResult.next),
            ),
          ] else ...[
            12.szH,
            Text(
              LocaleKeys.failureContactBlockingHint.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle().setSecondaryColor.s12.regular.withHeight(1.7),
            ),
          ],
        ],
      ),
    );
  }

  Widget _lastNudgeCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.heroCodPillBg,
        borderRadius: BorderRadius.circular(AppCircular.r16),
        border: Border.all(color: AppColors.failWarnAmberBorder),
      ),
      padding: EdgeInsets.all(AppPadding.pH16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconWidget(
                icon: FailureIcons.alert,
                color: AppColors.postponedText,
                height: AppSize.sH18,
                width: AppSize.sW18,
              ),
              8.szW,
              Expanded(
                child: Text(
                  LocaleKeys.failureLastNudgeWarning.tr(),
                  style: const TextStyle()
                      .setColor(AppColors.failWarnAmberText)
                      .s12
                      .regular
                      .withHeight(1.7),
                ),
              ),
            ],
          ),
          12.szH,
          Row(
            children: [
              Expanded(
                child: _ContactButton(
                  icon: FailureIcons.phone,
                  label: LocaleKeys.failureCall.tr(),
                ),
              ),
              8.szW,
              Expanded(
                child: _ContactButton(
                  icon: FailureIcons.whatsapp,
                  label: LocaleKeys.failureWhatsapp.tr(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({required this.icon, required this.label});
  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return _OutlineButton(
      label: label,
      leadingIcon: icon,
      borderColor: AppColors.postponedBorderStrong,
      borderWidth: 1.5,
      onTap: () {},
    );
  }
}

class _AttemptRow extends StatelessWidget {
  const _AttemptRow({required this.attempt});
  final ContactAttempt attempt;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.reasonRowBg,
        borderRadius: BorderRadius.circular(AppCircular.r13),
        border: Border.all(color: AppColors.borderHeader),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.pW16,
        vertical: AppPadding.pH12,
      ),
      child: Row(
        children: [
          IconWidget(
            icon: attempt.icon,
            color: AppColors.textTertiary,
            height: AppSize.sH18,
            width: AppSize.sW18,
          ),
          12.szW,
          Expanded(
            child: Text(
              attempt.label,
              style: const TextStyle().setMainTextColor.s14.semiBold,
            ),
          ),
          Text(
            attempt.time,
            textDirection: TextDirection.ltr,
            style: const TextStyle().setSecondaryColor.s12.regular.tabular,
          ),
        ],
      ),
    );
  }
}

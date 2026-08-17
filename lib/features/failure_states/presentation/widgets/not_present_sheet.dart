part of '../imports/failure_states_imports.dart';

/// 1b · «العميل غير متواجد» — step 2 of 2 (a final reason). One last
/// call/whatsapp nudge and a mandatory note, then advance to the
/// return-to-branch confirm (1e).
class _NotPresentSheet extends StatefulWidget {
  const _NotPresentSheet({required this.ctx});
  final FailureContext ctx;

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
    return _SheetScaffold(
      title: LocaleKeys.failureReasonNotPresent.tr(),
      stepCaption: LocaleKeys.failureStep2Final.tr(),
      onBack: () => Navigator.of(context).pop(SecondStepResult.back),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _lastNudgeCard(),
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
                      .withHeight(1.5),
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


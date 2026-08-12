part of '../imports/failure_states_imports.dart';

/// Result of the wrong-address step (1c): the corrected address is retried now
/// or deferred to [slot].
class WrongAddressResult {
  const WrongAddressResult({required this.retry, this.slot});
  final AddressRetry retry;
  final String? slot;
}

/// 1c · «عنوان خاطئ» — step 2 of 2 (retryable). The new address replaces the old
/// one; the courier chooses to retry now or defer to a later slot today. The
/// order is not closed either way.
class _WrongAddressSheet extends StatefulWidget {
  const _WrongAddressSheet({
    required this.ctx,
    this.initial = AddressRetry.now,
  });
  final FailureContext ctx;
  final AddressRetry initial;

  @override
  State<_WrongAddressSheet> createState() => _WrongAddressSheetState();
}

class _WrongAddressSheetState extends State<_WrongAddressSheet> {
  late final WrongAddressController _c = WrongAddressController(
    initial: widget.initial,
    initialSlot:
        widget.initial == AddressRetry.later ? widget.ctx.laterSlots.first : null,
  );
  final _note = TextEditingController(
    text: LocaleKeys.failureWrongAddressSampleNote.tr(),
  );

  @override
  void dispose() {
    _c.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetScaffold(
      title: LocaleKeys.failureReasonWrongAddress.tr(),
      stepCaption: LocaleKeys.failureStep2Retryable.tr(),
      onBack: () => Navigator.of(context).pop(SecondStepResult.back),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _oldAddressRow(),
          8.szH,
          _FieldLabel(LocaleKeys.failureCorrectAddressLabel.tr(), strong: true),
          8.szH,
          _correctedAddressBox(),
          8.szH,
          _FieldLabel(LocaleKeys.failureConfirmedByPhone.tr()),
          16.szH,
          _FieldLabel(LocaleKeys.failureAfterCorrection.tr(), strong: true),
          8.szH,
          AnimatedBuilder(
            animation: Listenable.merge([_c.retry, _c.slot]),
            builder: (context, _) {
              final now = _c.retry.value == AddressRetry.now;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _RetryNowRow(selected: now, onTap: _c.chooseNow),
                  8.szH,
                  _RetryLaterBlock(
                    selected: !now,
                    slots: widget.ctx.laterSlots,
                    selectedSlot: _c.slot.value,
                    onPick: _c.chooseLater,
                  ),
                ],
              );
            },
          ),
          16.szH,
          _FieldLabel(LocaleKeys.failureNoteMandatory.tr()),
          8.szH,
          _NoteField(controller: _note, minHeight: AppSize.sH48),
          12.szH,
          _PrimaryButton(
            label: LocaleKeys.failureUpdateAddressRetry.tr(),
            leadingIcon: FailureIcons.nav,
            onTap: () => Navigator.of(context).pop(
              WrongAddressResult(retry: _c.retry.value, slot: _c.slot.value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _oldAddressRow() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.reasonRowBg,
        borderRadius: BorderRadius.circular(AppCircular.r13),
        border: Border.all(color: AppColors.borderHeader),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.pW16,
        vertical: AppPadding.pH8,
      ),
      child: Row(
        children: [
          IconWidget(
            icon: FailureIcons.pin,
            color: AppColors.chipCountMuted,
            height: AppSize.sH18,
            width: AppSize.sW18,
          ),
          12.szW,
          Expanded(
            child: Text(
              widget.ctx.address,
              style: const TextStyle()
                  .setColor(AppColors.chipCountMuted)
                  .s14
                  .regular
                  .copyWith(decoration: TextDecoration.lineThrough),
            ),
          ),
        ],
      ),
    );
  }

  Widget _correctedAddressBox() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppCircular.r13),
        border: Border.all(color: AppColors.textPrimary, width: 1.5),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.pW16,
        vertical: AppPadding.pH12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconWidget(
            icon: FailureIcons.pin,
            color: AppColors.textPrimary,
            height: AppSize.sH18,
            width: AppSize.sW18,
          ),
          12.szW,
          Expanded(
            child: Text(
              widget.ctx.correctedAddress,
              style: const TextStyle().setMainTextColor.s14.semiBold.withHeight(1.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _RetryNowRow extends StatelessWidget {
  const _RetryNowRow({required this.selected, required this.onTap});
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: selected ? AppColors.deliveredBg : AppColors.reasonRowBg,
        borderRadius: BorderRadius.circular(AppCircular.r14),
        border: Border.all(
          color: selected ? AppColors.greenAccent : AppColors.borderHeader,
          width: 1.5,
        ),
      ),
      padding: EdgeInsets.all(AppPadding.pH16),
      child: Row(
        children: [
          _RadioDot(selected: selected, color: AppColors.greenAccent),
          12.szW,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(LocaleKeys.failureRetryNow.tr(),
                    style: const TextStyle().setMainTextColor.s14.bold),
                4.szH,
                Text(
                  LocaleKeys.failureRetryNowCaption.tr(),
                  style: const TextStyle()
                      .setColor(AppColors.retryNowSubtext)
                      .s12
                      .regular,
                ),
              ],
            ),
          ),
        ],
      ),
    ).onClick(onTap: onTap);
  }
}

class _RetryLaterBlock extends StatelessWidget {
  const _RetryLaterBlock({
    required this.selected,
    required this.slots,
    required this.selectedSlot,
    required this.onPick,
  });
  final bool selected;
  final List<String> slots;
  final String? selectedSlot;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.reasonRowBg,
        borderRadius: BorderRadius.circular(AppCircular.r14),
        border: Border.all(color: AppColors.borderHeader, width: 1.5),
      ),
      padding: EdgeInsets.all(AppPadding.pH12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _RadioDot(selected: selected, color: AppColors.textPrimary),
              12.szW,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(LocaleKeys.failurePostponeLaterToday.tr(),
                        style: selected
                            ? const TextStyle().setMainTextColor.s14.bold
                            : const TextStyle().setMainTextColor.s14.semiBold),
                    4.szH,
                    Text(
                      LocaleKeys.failurePostponeLaterCaption.tr(),
                      style: const TextStyle().setSecondaryColor.s12.regular,
                    ),
                  ],
                ),
              ),
            ],
          ),
          8.szH,
          Row(
            children: [
              for (final slot in slots) ...[
                Expanded(
                  child: _TimeChip(
                    time: slot,
                    selected: selected && slot == selectedSlot,
                    onTap: () => onPick(slot),
                  ),
                ),
                if (slot != slots.last) 8.szW,
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.time,
    required this.selected,
    required this.onTap,
  });
  final String time;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSize.sH40,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppCircular.r11),
        border: Border.all(
          color: selected ? AppColors.textPrimary : AppColors.borderDefault,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        time,
        textDirection: TextDirection.ltr,
        style: const TextStyle()
            .setColor(selected ? AppColors.textPrimary : AppColors.chipCountMuted)
            .s14
            .bold,
      ),
    ).onClick(onTap: onTap);
  }
}

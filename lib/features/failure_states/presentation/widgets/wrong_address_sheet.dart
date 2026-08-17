part of '../imports/failure_states_imports.dart';

/// Result of the wrong-address step (1c): the courier's corrected address and
/// the chosen outcome (try again now / return to branch).
class WrongAddressResult {
  const WrongAddressResult({required this.choice, this.correctedAddress});
  final WrongAddressChoice choice;
  final String? correctedAddress;
}

/// 1c · «عنوان خاطئ» — step 2 of 2 (retryable). The courier just types the
/// corrected address, then picks one of two outcomes: retry the delivery now,
/// or return the pieces to the branch.
class _WrongAddressSheet extends StatefulWidget {
  const _WrongAddressSheet({required this.ctx});
  final FailureContext ctx;

  @override
  State<_WrongAddressSheet> createState() => _WrongAddressSheetState();
}

class _WrongAddressSheetState extends State<_WrongAddressSheet> {
  late final WrongAddressController _c = WrongAddressController(
    correctedAddress: widget.ctx.correctedAddress,
  );

  @override
  void dispose() {
    _c.dispose();
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
          _correctedAddressField(),
          16.szH,
          _FieldLabel(LocaleKeys.failureAfterCorrection.tr(), strong: true),
          8.szH,
          ValueListenableBuilder<WrongAddressChoice>(
            valueListenable: _c.choice,
            builder: (context, choice, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ChoiceRow(
                    label: LocaleKeys.failureTryAgain.tr(),
                    selected: choice == WrongAddressChoice.tryAgain,
                    onTap: () => _c.choose(WrongAddressChoice.tryAgain),
                  ),
                  8.szH,
                  _ChoiceRow(
                    label: LocaleKeys.failureReturnToBranchTitle.tr(),
                    selected: choice == WrongAddressChoice.returnToBranch,
                    onTap: () => _c.choose(WrongAddressChoice.returnToBranch),
                  ),
                ],
              );
            },
          ),
          20.szH,
          ValueListenableBuilder<WrongAddressChoice>(
            valueListenable: _c.choice,
            builder: (context, choice, _) {
              final tryAgain = choice == WrongAddressChoice.tryAgain;
              return _PrimaryButton(
                label: tryAgain
                    ? LocaleKeys.failureUpdateAddressRetry.tr()
                    : LocaleKeys.failureReturnToBranchTitle.tr(),
                leadingIcon: tryAgain ? FailureIcons.nav : FailureIcons.box,
                onTap: () => Navigator.of(context).pop(
                  WrongAddressResult(
                    choice: choice,
                    correctedAddress: _c.address.text.trim(),
                  ),
                ),
              );
            },
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

  /// The editable corrected-address field — a real RTL [TextField] prefilled
  /// from the controller, with the pin glyph and the emphasised ink border.
  Widget _correctedAddressField() {
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
            child: TextField(
              controller: _c.address,
              maxLines: null,
              textDirection: TextDirection.rtl,
              textInputAction: TextInputAction.done,
              cursorColor: AppColors.brand,
              style: const TextStyle()
                  .setMainTextColor
                  .s14
                  .semiBold
                  .withHeight(1.5),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single-select outcome row for the wrong-address step — mirrors the reason
/// row style: brand border + red wash + brand radio dot when selected.
class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: selected ? AppColors.failedBg : AppColors.reasonRowBg,
        borderRadius: BorderRadius.circular(AppCircular.r14),
        border: Border.all(
          color: selected ? AppColors.brand : AppColors.borderHeader,
          width: 1.5,
        ),
      ),
      padding: EdgeInsets.all(AppPadding.pH16),
      child: Row(
        children: [
          _RadioDot(selected: selected),
          12.szW,
          Expanded(
            child: Text(
              label,
              style: selected
                  ? const TextStyle().setMainTextColor.s14.bold
                  : const TextStyle().setMainTextColor.s14.semiBold,
            ),
          ),
        ],
      ),
    ).onClick(onTap: onTap);
  }
}

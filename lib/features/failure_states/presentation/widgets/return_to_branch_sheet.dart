part of '../imports/failure_states_imports.dart';

/// 1e · «الإرجاع للفرع» — the single confirm screen shared by the three final
/// reasons (not present / refused / mismatch). Last step before logging; states
/// what stays in the courier's custody. Confirm records the failure (→ 1f);
/// "رجوع للسبب" / the back arrow return to the reason step.
class _ReturnToBranchSheet extends StatefulWidget {
  const _ReturnToBranchSheet({required this.ctx, required this.reason});
  final FailureContext ctx;
  final FailureReason reason;

  @override
  State<_ReturnToBranchSheet> createState() => _ReturnToBranchSheetState();
}

class _ReturnToBranchSheetState extends State<_ReturnToBranchSheet> {
  final _confirmed = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _confirmed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctx = widget.ctx;
    return _SheetScaffold(
      title: LocaleKeys.failureReturnToBranchTitle.tr(),
      onBack: () => Navigator.of(context).pop(SecondStepResult.back),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            LocaleKeys.failureReturnToBranchIntro.tr(),
            style: const TextStyle().setSecondaryColor.s14.regular.withHeight(
              1.5,
            ),
          ),
          16.szH,
          _summaryCard(ctx),
          16.szH,
          ValueListenableBuilder<bool>(
            valueListenable: _confirmed,
            builder: (context, checked, _) => _ConfirmCustodyRow(
              checked: checked,
              onTap: () => _confirmed.value = !checked,
            ),
          ),
          12.szH,
          _Callout(
            icon: FailureIcons.box,
            iconColor: AppColors.postponedText,
            text: LocaleKeys.failureReturnHeldHint.tr(),
            bg: AppColors.reasonRowBg,
            textColor: AppColors.textSecondary,
            borderColor: AppColors.borderHeader,
          ),
          20.szH,
          _PrimaryButton(
            label: LocaleKeys.failureLogNonDelivery.tr(),
            danger: true,
            onTap: () => Navigator.of(context).pop(true),
          ),
          8.szH,
          _OutlineButton(
            label: LocaleKeys.failureBackToReason.tr(),
            labelColor: AppColors.textTertiary,
            onTap: () => Navigator.of(context).pop(SecondStepResult.back),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(FailureContext ctx) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppCircular.r16),
        border: Border.all(color: AppColors.borderHeader),
      ),
      padding: EdgeInsets.all(AppPadding.pH16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SummaryRow(
            label: LocaleKeys.failureSummaryReason.tr(),
            value: widget.reason.label,
            valueColor: AppColors.dangerAccent,
          ),
          12.szH,
          _SummaryRow(
            label: LocaleKeys.failureSummaryOrder.tr(),
            value: ctx.orderNum,
            ltrValue: true,
            emphasize: true,
          ),
          12.szH,
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.summaryDivider)),
            ),
            padding: EdgeInsets.only(top: AppPadding.pH12),
            child: _SummaryRow(
              label: LocaleKeys.failureSummaryReturnedPieces.tr(),
              value: ctx.piecesLabel,
            ),
          ),
          12.szH,
          _SummaryRow(
            label: LocaleKeys.failureSummaryReturnedTo.tr(),
            value: ctx.branch,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.ltrValue = false,
    this.emphasize = false,
  });
  final String label;
  final String value;
  final Color? valueColor;
  final bool ltrValue;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    var style = const TextStyle()
        .setColor(valueColor ?? AppColors.textPrimary)
        .s14;
    style = emphasize ? style.bold : style.semiBold;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle().setSecondaryColor.s14.regular),
        8.szW,
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            textDirection: ltrValue ? TextDirection.ltr : null,
            style: style,
          ),
        ),
      ],
    );
  }
}

class _ConfirmCustodyRow extends StatelessWidget {
  const _ConfirmCustodyRow({required this.checked, required this.onTap});
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      checked: checked,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppCircular.r14),
          border: Border.all(color: AppColors.textPrimary, width: 1.5),
        ),
        padding: EdgeInsets.all(AppPadding.pH16),
        child: Row(
          children: [
            Container(
              width: AppSize.sW24,
              height: AppSize.sH24,
              decoration: BoxDecoration(
                color: checked ? AppColors.inkFill : AppColors.surface,
                borderRadius: BorderRadius.circular(AppCircular.r8),
                border: checked
                    ? null
                    : Border.all(color: AppColors.reasonDotBorder, width: 2),
              ),
              child: checked
                  ? Center(
                      child: IconWidget(
                        icon: FailureIcons.tick,
                        color: AppColors.surface,
                        height: AppSize.sH14,
                        width: AppSize.sW14,
                      ),
                    )
                  : null,
            ),
            12.szW,
            Expanded(
              child: Text(
                LocaleKeys.failureCustodyConfirm.tr(),
                style: const TextStyle().setMainTextColor.s14.semiBold
                    .withHeight(1.5),
              ),
            ),
          ],
        ),
      ).onClick(onTap: onTap),
    );
  }
}

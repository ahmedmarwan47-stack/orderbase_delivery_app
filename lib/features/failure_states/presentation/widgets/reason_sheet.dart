part of '../imports/failure_states_imports.dart';

/// What the reason step (1a) resolves to.
class ReasonStepResult {
  const ReasonStepResult.next(this.reason) : postpone = false;
  const ReasonStepResult.postpone()
      : reason = null,
        postpone = true;

  final FailureReason? reason;
  final bool postpone;
}

/// 1a · «سبب عدم التسليم» — step 1 of 2. Pick the not-delivered reason. Each row
/// carries its outcome tag («يرجع للفرع» / «قابل للإعادة»). "التالي" advances to
/// the reason's second step; the postpone button hands off to the postpone flow.
class _ReasonSheet extends StatefulWidget {
  const _ReasonSheet({required this.ctx, this.initial = FailureReason.notPresent});
  final FailureContext ctx;
  final FailureReason initial;

  @override
  State<_ReasonSheet> createState() => _ReasonSheetState();
}

class _ReasonSheetState extends State<_ReasonSheet> {
  late final ReasonStepController _c =
      ReasonStepController(initial: widget.initial);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetScaffold(
      title: LocaleKeys.failureReasonTitle.tr(),
      stepCaption: LocaleKeys.failureStep1Of2.tr(),
      body: ValueListenableBuilder<FailureReason>(
        valueListenable: _c.selected,
        builder: (context, selected, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final reason in FailureReason.values) ...[
                _ReasonRow(
                  reason: reason,
                  selected: reason == selected,
                  onTap: () => _c.select(reason),
                ),
                if (reason != FailureReason.values.last) 8.szH,
              ],
              20.szH,
              _PrimaryButton(
                label: LocaleKeys.failureNext.tr(),
                trailingIcon: FailureIcons.chevronLeft,
                onTap: () => Navigator.of(context)
                    .pop(ReasonStepResult.next(selected)),
              ),
              8.szH,
              _OutlineButton(
                label: LocaleKeys.failureCustomerAskedPostpone.tr(),
                leadingIcon: FailureIcons.clock,
                leadingIconColor: AppColors.postponedText,
                borderColor: AppColors.borderDefault,
                borderWidth: 1.5,
                onTap: () => Navigator.of(context)
                    .pop(const ReasonStepResult.postpone()),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReasonRow extends StatelessWidget {
  const _ReasonRow({
    required this.reason,
    required this.selected,
    required this.onTap,
  });
  final FailureReason reason;
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
              reason.label,
              style: selected
                  ? const TextStyle().setMainTextColor.s14.bold
                  : const TextStyle().setMainTextColor.s14.semiBold,
            ),
          ),
          if (reason.outcome != ReasonOutcome.none) ...[
            8.szW,
            _ReasonTag(outcome: reason.outcome, onLightRow: selected),
          ],
        ],
      ),
    ).onClick(onTap: onTap);
  }
}

part of '../imports/settlement_imports.dart';

/// The returns handover — the parcels are listed inside their batches above;
/// this is the courier's one act about them: confirming they were physically
/// handed to the branch. Physically handing parcels back is the courier's act
/// even though settling the money is the branch's, so the button stays in the
/// app. Once handed over, a note says so; otherwise the section is silent.
class _ReturnsSection extends StatelessWidget {
  const _ReturnsSection();

  @override
  Widget build(BuildContext context) {
    final shift = ShiftController.instance;
    final returns = shift.pendingReturns;
    if (returns.isEmpty && !shift.returnsHandedOver) {
      return const SizedBox.shrink();
    }
    if (returns.isEmpty) {
      return const _ReturnsHandedNote().paddingOnly(top: AppPadding.pH12);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        12.szH,
        _HandReturnsButton(
          count: returns.length,
          pieces: shift.returnPieces,
          branch: shift.returnsBranch,
        ),
      ],
    );
  }
}

/// The action that hands the whole batch back — same confirmation sheet the
/// standalone returns page raises, so the two entry points cannot drift.
class _HandReturnsButton extends StatelessWidget {
  const _HandReturnsButton({
    required this.count,
    required this.pieces,
    required this.branch,
  });

  final int count;
  final int pieces;
  final String branch;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSize.sH52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppCircular.r15),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconWidget(
            icon: AppAssets.svg.box,
            color: AppColors.textPrimary,
            height: AppSize.sH18,
            width: AppSize.sW18,
          ),
          8.szW,
          Text(
            LocaleKeys.settlementHandReturns.tr(
              namedArgs: {
                'count': arabicDigits(count),
                'pieces': _piecesLabel(pieces),
              },
            ),
            style: const TextStyle().setMainTextColor.s14.semiBold,
          ),
        ],
      ),
    ).onClick(
      onTap: () => showReturnsHandoverSheet(
        context,
        count: count,
        pieces: pieces,
        branch: branch,
      ),
    );
  }
}

/// Shown once the returns are back at the branch — the settlement page should
/// still say so, otherwise the button simply disappears and the courier is
/// left wondering whether it was ever there.
class _ReturnsHandedNote extends StatelessWidget {
  const _ReturnsHandedNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.deliveredBg,
        borderRadius: BorderRadius.circular(AppCircular.r16),
      ),
      child: Row(
        children: [
          IconWidget(
            icon: AppAssets.svg.check,
            color: AppColors.greenAccent,
            height: AppSize.sH18,
            width: AppSize.sW18,
          ),
          12.szW,
          Expanded(
            child: Text(
              LocaleKeys.failureReturnsDoneTitle.tr(),
              style: const TextStyle()
                  .setColor(AppColors.deliveredText)
                  .s12
                  .semiBold
                  .withHeight(1.5),
            ),
          ),
        ],
      ).paddingAll(AppPadding.pH16),
    );
  }
}

/// «N قطعة» / «N قطع» with Eastern-Arabic digits.
String _piecesLabel(int pieces) {
  final unit = pieces == 1
      ? LocaleKeys.failurePiecesUnitSingular.tr()
      : LocaleKeys.failurePiecesUnitPlural.tr();
  return '${arabicDigits(pieces)} $unit';
}

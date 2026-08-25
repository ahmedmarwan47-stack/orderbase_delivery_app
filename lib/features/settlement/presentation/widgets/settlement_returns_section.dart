part of '../imports/settlement_imports.dart';

/// "مرتجعات للفرع" — the parcels the courier is still carrying, listed on the
/// settlement page beside the cash.
///
/// Settling is one act, not two: at the end of a shift the courier hands the
/// branch back everything they are holding — the cash they collected *and* the
/// orders they could not deliver. Splitting those across two screens meant a
/// courier could settle the money and walk out with a bag of returns, so the
/// returns moved here. The dedicated returns page still exists (route
/// `/returns`) for anyone who wants only that half.
class _ReturnsSection extends StatelessWidget {
  const _ReturnsSection();

  @override
  Widget build(BuildContext context) {
    final shift = ShiftController.instance;
    final returns = shift.pendingReturns;
    // Nothing failed today, or the batch is already back at the branch — a
    // section with nothing in it would just be a row of noise on the page.
    if (returns.isEmpty && !shift.returnsHandedOver) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              LocaleKeys.failureReturnsToBranch.tr(),
              style: const TextStyle().setMainTextColor.s16.semiBold,
            ),
            if (returns.isNotEmpty)
              Text(
                _piecesLabel(shift.returnPieces),
                style: const TextStyle().setHintColor.s12.regular,
              ),
          ],
        ),
        12.szH,
        if (returns.isEmpty)
          const _ReturnsHandedNote()
        else
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppCircular.r16),
              border: Border.all(color: AppColors.borderCard),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < returns.length; i++) ...[
                  if (i > 0)
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.surfaceSubtle,
                    ),
                  _ReturnLine(order: returns[i]),
                ],
              ],
            ),
          ),
        if (returns.isNotEmpty) ...[
          12.szH,
          _HandReturnsButton(
            count: returns.length,
            pieces: shift.returnPieces,
            branch: shift.returnsBranch,
          ),
        ],
      ],
    );
  }
}

/// One returned order: number + reason on one side, its piece count on the
/// other — the two things the branch checks when taking the parcel back.
class _ReturnLine extends StatelessWidget {
  const _ReturnLine({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    order.num,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle().setMainTextColor.s14.semiBold,
                  ),
                  8.szW,
                  Flexible(
                    child: Text(
                      order.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle().setSecondaryColor.s12.regular,
                    ),
                  ),
                ],
              ),
              4.szH,
              Text(
                order.reason ?? LocaleKeys.failureReasonOther.tr(),
                style: const TextStyle().setHintColor.s12.regular,
              ),
            ],
          ),
        ),
        8.szW,
        Text(
          _piecesLabel(order.pieces),
          style: const TextStyle().setSecondaryColor.s12.semiBold,
        ),
      ],
    ).paddingSymmetric(horizontal: AppPadding.pW16, vertical: AppPadding.pH12);
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
            LocaleKeys.failureHandReturns.tr(),
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
/// still say so, otherwise the section simply disappears and the courier is
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

part of '../imports/failure_states_imports.dart';

/// Body of the dedicated «مرتجعات للفرع» (returns to branch) page. A returns-
/// focused screen — not the active queue: a prominent count of what's in the
/// courier's custody, the list of returned orders, and the handover button.
/// Confirming the handover (via a confirmation sheet) empties the custody and
/// flips the whole page to its empty state. All driven by [ShiftController].
class _ReturnsListBody extends StatelessWidget {
  const _ReturnsListBody();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ShiftController.instance,
      builder: (_, _) {
        final shift = ShiftController.instance;
        final returns = shift.pendingReturns;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _ReturnsPageHeader(),
            Expanded(
              child: returns.isEmpty
                  ? const _ReturnsEmptyState()
                  : _ReturnsContent(
                      returns: returns,
                      pieces: shift.returnPieces,
                      branch: shift.returnsBranch,
                    ),
            ),
          ],
        );
      },
    );
  }
}

/// White page header — back tile + title.
class _ReturnsPageHeader extends StatelessWidget {
  const _ReturnsPageHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.borderHeader)),
      ),
      padding: EdgeInsets.only(
        left: AppPadding.pW20,
        right: AppPadding.pW20,
        top: AppPadding.pH12,
        bottom: AppPadding.pH16,
      ),
      child: Row(
        children: [
          const HeaderBackButton(),
          12.szW,
          Text(
            LocaleKeys.failureReturnsPageTitle.tr(),
            style: const TextStyle().setMainTextColor.s14.semiBold,
          ),
        ],
      ),
    );
  }
}

/// Populated state: hero count → returned-order list → pinned handover button.
class _ReturnsContent extends StatelessWidget {
  const _ReturnsContent({
    required this.returns,
    required this.pieces,
    required this.branch,
  });

  final List<Order> returns;
  final int pieces;
  final String branch;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: AppPadding.pW20,
              vertical: AppPadding.pH16,
            ),
            children: [
              _ReturnsHero(
                count: returns.length,
                pieces: pieces,
                branch: branch,
              ),
              20.szH,
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  LocaleKeys.failureReturnsListLabel.tr(),
                  style: const TextStyle().setSecondaryColor.s12.semiBold,
                ),
              ),
              12.szH,
              for (var i = 0; i < returns.length; i++) ...[
                if (i != 0) 12.szH,
                _ReturnOrderCard(order: returns[i]),
              ],
            ],
          ),
        ),
        _HandoverBar(count: returns.length, pieces: pieces, branch: branch),
      ],
    );
  }
}

/// The prominent custody count — the "orders returned" number, front and centre.
class _ReturnsHero extends StatelessWidget {
  const _ReturnsHero({
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
      decoration: BoxDecoration(
        color: AppColors.paymentCardBg,
        borderRadius: BorderRadius.circular(AppCircular.r20),
      ),
      padding: EdgeInsets.all(AppPadding.pH20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.failureReturnsInCustody.tr(),
                  style: const TextStyle().setWhite.s14.semiBold,
                ),
                12.szH,
                Row(
                  textBaseline: TextBaseline.alphabetic,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  children: [
                    Text(
                      arabicDigits(count),
                      style: const TextStyle().setWhite.s36.bold.tabular,
                    ),
                    8.szW,
                    Text(
                      _ordersUnit(count),
                      style: const TextStyle()
                          .setColor(AppColors.paymentLabel)
                          .s16
                          .semiBold,
                    ),
                  ],
                ),
                6.szH,
                Text(
                  '${_piecesLabel(pieces)} · '
                  '${LocaleKeys.failureReturnsHandedTo.tr(namedArgs: {'branch': branch})}',
                  style: const TextStyle()
                      .setColor(AppColors.paymentLabel)
                      .s12
                      .regular
                      .withHeight(1.5),
                ),
              ],
            ),
          ),
          12.szW,
          Container(
            width: AppSize.sW44,
            height: AppSize.sH44,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppCircular.r12),
            ),
            child: Center(
              child: IconWidget(
                icon: FailureIcons.box,
                color: AppColors.textPrimary,
                height: AppSize.sH20,
                width: AppSize.sW20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One returned order — status tile · number + «تعذّر التسليم» pill · reason ·
/// pieces.
class _ReturnOrderCard extends StatelessWidget {
  const _ReturnOrderCard({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppCircular.r16),
        border: Border.all(color: AppColors.borderCardFaint),
      ),
      padding: EdgeInsets.all(AppPadding.pH16),
      child: Row(
        children: [
          Container(
            width: AppSize.sW40,
            height: AppSize.sH40,
            decoration: BoxDecoration(
              color: AppColors.failedBg,
              borderRadius: BorderRadius.circular(AppCircular.r12),
            ),
            child: Center(
              child: IconWidget(
                icon: FailureIcons.box,
                color: AppColors.failedText,
                height: AppSize.sH20,
                width: AppSize.sW20,
              ),
            ),
          ),
          12.szW,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      order.num,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle().setMainTextColor.s16.bold,
                    ),
                    8.szW,
                    _StatusPill(
                      label: LocaleKeys.failureStatusCouldNotDeliver.tr(),
                      bg: AppColors.failedBg,
                      fg: AppColors.failedText,
                    ),
                  ],
                ),
                4.szH,
                Text(
                  order.reason ?? LocaleKeys.failureReasonOther.tr(),
                  style: const TextStyle().setSecondaryColor.s12.regular,
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
      ),
    );
  }
}

/// The pinned bottom bar carrying the primary handover action.
class _HandoverBar extends StatelessWidget {
  const _HandoverBar({
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
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderHeader)),
      ),
      padding: EdgeInsets.only(
        left: AppPadding.pW20,
        right: AppPadding.pW20,
        top: AppPadding.pH12,
        bottom: AppPadding.pH12 + MediaQuery.of(context).viewPadding.bottom,
      ),
      child: _PrimaryButton(
        label: LocaleKeys.failureHandReturns.tr(),
        leadingIcon: FailureIcons.box,
        onTap: () => _showReturnsHandoverSheet(
          context,
          count: count,
          pieces: pieces,
          branch: branch,
        ),
      ),
    );
  }
}

/// The empty state shown once the returns are handed to the branch — the
/// isolated Higgsfield handover illustration + a reassuring done message.
class _ReturnsEmptyState extends StatelessWidget {
  const _ReturnsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: AppPadding.pW32,
          vertical: AppPadding.pH24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AppAssets.img.returnsHandover,
              width: 240.w,
              height: 240.h,
              fit: BoxFit.contain,
            ),
            24.szH,
            Text(
              LocaleKeys.failureReturnsDoneTitle.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle().setMainTextColor.s20.bold,
            ),
            8.szH,
            Text(
              LocaleKeys.failureReturnsDoneBody.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle().setSecondaryColor.s14.regular.withHeight(
                1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── helpers ──────────────────────────────────────────────────────────────────

/// «طلب» / «طلبات» — singular for one order, plural otherwise.
String _ordersUnit(int count) => count == 1
    ? LocaleKeys.failureOrdersUnitSingular.tr()
    : LocaleKeys.failureOrdersUnitPlural.tr();

/// «N قطعة» / «N قطع» with Eastern-Arabic digits.
String _piecesLabel(int pieces) {
  final unit = pieces == 1
      ? LocaleKeys.failurePiecesUnitSingular.tr()
      : LocaleKeys.failurePiecesUnitPlural.tr();
  return '${arabicDigits(pieces)} $unit';
}

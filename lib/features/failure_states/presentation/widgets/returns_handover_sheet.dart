part of '../imports/failure_states_imports.dart';

/// Opens the returns-handover confirmation sheet. On confirm, the whole returns
/// batch leaves the courier's custody ([ShiftController.handOverReturns]) and
/// the returns page flips to its empty state.
/// Public entry point for the returns hand-over confirmation.
///
/// The returns live on the **settlement** page now — end of day is when the
/// courier squares up both the cash and the parcels they are still carrying —
/// so that feature needs to be able to raise this sheet too. The standalone
/// returns page still calls the private form below.
Future<void> showReturnsHandoverSheet(
  BuildContext context, {
  required int count,
  required int pieces,
  required String branch,
}) => _showReturnsHandoverSheet(
  context,
  count: count,
  pieces: pieces,
  branch: branch,
);

Future<void> _showReturnsHandoverSheet(
  BuildContext context, {
  required int count,
  required int pieces,
  required String branch,
}) async {
  final confirmed = await showAppSheet<bool>(
    context,
    child: _ReturnsHandoverSheet(count: count, pieces: pieces, branch: branch),
  );
  if (confirmed == true) ShiftController.instance.handOverReturns();
}

/// «تأكيد تسليم المرتجعات» — the last check before the returns leave the
/// courier's hands: a plain-language intro + a batch summary (orders · pieces ·
/// branch), then confirm / cancel.
class _ReturnsHandoverSheet extends StatelessWidget {
  const _ReturnsHandoverSheet({
    required this.count,
    required this.pieces,
    required this.branch,
  });

  final int count;
  final int pieces;
  final String branch;

  @override
  Widget build(BuildContext context) {
    return _SheetScaffold(
      title: LocaleKeys.failureReturnsConfirmTitle.tr(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            LocaleKeys.failureReturnsConfirmIntro.tr(
              namedArgs: {'branch': branch},
            ),
            style: const TextStyle().setSecondaryColor.s14.regular.withHeight(
              1.5,
            ),
          ),
          16.szH,
          Container(
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
                  label: LocaleKeys.failureReturnsConfirmOrders.tr(),
                  value: '${arabicDigits(count)} ${_ordersUnit(count)}',
                  emphasize: true,
                ),
                12.szH,
                _SummaryRow(
                  label: LocaleKeys.failureReturnsConfirmPieces.tr(),
                  value: _piecesLabel(pieces),
                  emphasize: true,
                ),
                12.szH,
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.summaryDivider),
                    ),
                  ),
                  padding: EdgeInsets.only(top: AppPadding.pH12),
                  child: _SummaryRow(
                    label: LocaleKeys.failureReturnsConfirmBranch.tr(),
                    value: branch,
                  ),
                ),
              ],
            ),
          ),
          20.szH,
          _PrimaryButton(
            label: LocaleKeys.failureReturnsConfirmCta.tr(),
            leadingIcon: FailureIcons.box,
            onTap: () => Navigator.of(context).pop(true),
          ),
          8.szH,
          _OutlineButton(
            label: LocaleKeys.failureReturnsConfirmCancel.tr(),
            labelColor: AppColors.textTertiary,
            onTap: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }
}

part of '../imports/failure_states_imports.dart';

/// What the "logged" sheet (1f) resolves to.
enum LoggedResult { undo, continueRoute, backToList }

/// 1f · «تم تسجيل عدم التسليم» — a confirmation sheet (not a full screen), so the
/// courier stays in the route context. Undo is available only during the
/// countdown window; after it the reason is locked.
class _LoggedSheet extends StatefulWidget {
  const _LoggedSheet({required this.ctx, required this.reason, this.undoSeconds = 10});
  final FailureContext ctx;
  final FailureReason reason;
  final int undoSeconds;

  @override
  State<_LoggedSheet> createState() => _LoggedSheetState();
}

class _LoggedSheetState extends State<_LoggedSheet> {
  late final UndoController _undo = UndoController(total: widget.undoSeconds);

  @override
  void dispose() {
    _undo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: AppSize.sW64,
              height: AppSize.sH64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.failedBg,
              ),
              child: Center(
                child: IconWidget(
                  icon: FailureIcons.alert,
                  color: AppColors.brand,
                  height: AppSize.sH32,
                  width: AppSize.sH32,
                ),
              ),
            ),
          ),
          12.szH,
          Text(
            LocaleKeys.failureLoggedTitle.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle().setMainTextColor.s20.extraBold,
          ),
          12.szH,
          _summaryLine(),
          16.szH,
          _undoCard(),
          16.szH,
          _PrimaryButton(
            label: LocaleKeys.failureContinueRoute.tr(),
            leadingIcon: FailureIcons.nav,
            onTap: () => Navigator.of(context).pop(LoggedResult.continueRoute),
          ),
          8.szH,
          _OutlineButton(
            label: LocaleKeys.failureBackToOrdersList.tr(),
            labelColor: AppColors.textTertiary,
            onTap: () => Navigator.of(context).pop(LoggedResult.backToList),
          ),
          8.szH,
          Text(
            LocaleKeys.failureReasonLocksHint.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle().setColor(AppColors.chipCountMuted).s12.regular.withHeight(1.7),
          ),
        ],
      ),
    );
  }

  Widget _summaryLine() {
    final base = const TextStyle().setSecondaryColor.s14.regular.withHeight(1.7);
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          // Composed summary: "الطلب <#> — <reason>. <pieces> مسجّلة للإرجاع للفرع."
          TextSpan(text: LocaleKeys.failureLoggedSummaryPrefix.tr()),
          TextSpan(
            text: widget.ctx.orderNum,
            style: const TextStyle().setTertiaryColor.s14.bold,
          ),
          TextSpan(text: ' — ${widget.reason.label}. '),
          TextSpan(
            text: LocaleKeys.failureLoggedSummaryPieces.tr(
              namedArgs: {'pieces': widget.ctx.piecesLabel},
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _undoCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.paymentCardBg,
        borderRadius: BorderRadius.circular(AppCircular.r16),
      ),
      padding: EdgeInsets.all(AppPadding.pH16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ValueListenableBuilder<int>(
            valueListenable: _undo.secondsLeft,
            builder: (context, left, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconWidget(
                        icon: FailureIcons.undo,
                        color: AppColors.surface,
                        height: AppSize.sH20,
                        width: AppSize.sW20,
                      ),
                      12.szW,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(LocaleKeys.failureCanUndoNow.tr(),
                                style: const TextStyle().setWhite.s14.bold),
                            4.szH,
                            Text(
                              LocaleKeys.failureUndoWindowEnds.tr(
                                namedArgs: {'n': '$left'},
                              ),
                              style: const TextStyle()
                                  .setColor(AppColors.mutedOnDark)
                                  .s12
                                  .regular,
                            ),
                          ],
                        ),
                      ),
                      12.szW,
                      _UndoButton(
                        onTap: () =>
                            Navigator.of(context).pop(LoggedResult.undo),
                      ),
                    ],
                  ),
                  12.szH,
                  _UndoProgress(fraction: _undo.fraction(left)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _UndoButton extends StatelessWidget {
  const _UndoButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: Container(
        height: AppSize.sH40,
        padding: EdgeInsets.symmetric(horizontal: AppPadding.pW16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppCircular.r11),
        ),
        alignment: Alignment.center,
        child: Text(LocaleKeys.failureUndo.tr(),
            style: const TextStyle().setMainTextColor.s14.bold),
      ).onClick(onTap: onTap),
    );
  }
}

class _UndoProgress extends StatelessWidget {
  const _UndoProgress({required this.fraction});
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppCircular.r3),
      child: Container(
        height: AppSize.sH4,
        color: AppColors.undoTrack,
        alignment: AlignmentDirectional.centerStart,
        child: FractionallySizedBox(
          widthFactor: fraction,
          child: Container(color: AppColors.surface),
        ),
      ),
    );
  }
}

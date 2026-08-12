part of '../../imports/order_flow_imports.dart';

/// Which branch the fail sheet chose.
enum FailResult { failed, postpone }

/// Outcome of the fail sheet: the branch taken plus, for a recorded failure,
/// the chosen reason (already translated) and the mandatory note.
class FailOutcome {
  const FailOutcome({required this.action, this.reasonLabel, this.note});

  final FailResult action;
  final String? reasonLabel;
  final String? note;
}

/// Fail sheet (Order Flow.dc.html, `showFail`): pick a non-delivery reason,
/// add a mandatory note, then either record the failure or hand off to the
/// postpone sheet. Returns the chosen [FailOutcome].
Future<FailOutcome?> showFailSheet(BuildContext context) {
  return showAppSheet<FailOutcome>(context, child: const _FailSheet());
}

/// StatefulWidget only to own the [FailSheetController] lifecycle — no
/// `setState`; the reason list rebuilds via [ValueListenableBuilder].
class _FailSheet extends StatefulWidget {
  const _FailSheet();

  @override
  State<_FailSheet> createState() => _FailSheetState();
}

class _FailSheetState extends State<_FailSheet> {
  final FailSheetController _controller = FailSheetController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SheetShell(
      title: LocaleKeys.failTitle.tr(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ValueListenableBuilder<int>(
            valueListenable: _controller.selected,
            builder: (_, selected, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < FailSheetController.reasonKeys.length; i++) ...[
                  _reasonRow(i, selected == i),
                  if (i != FailSheetController.reasonKeys.length - 1) 8.szH,
                ],
              ],
            ),
          ),
          16.szH,
          Text(
            LocaleKeys.failNoteLabel.tr(),
            style: const TextStyle().setSecondaryColor.s12.semiBold,
          ),
          8.szH,
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppCircular.r13),
              border: Border.all(color: AppColors.borderHeader),
            ),
            child: TextField(
              controller: _controller.note,
              textDirection: TextDirection.rtl,
              minLines: 2,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
              style: const TextStyle().setMainTextColor.s14.regular,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: LocaleKeys.failNoteHint.tr(),
                hintStyle: const TextStyle().setSecondaryColor.s14.regular,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppPadding.pW16,
                  vertical: AppPadding.pH12,
                ),
              ),
            ),
          ),
          20.szH,
          // The failure record needs a reason and a note: keep the button muted
          // and untappable until both are provided.
          ValueListenableBuilder<bool>(
            valueListenable: _controller.canSubmit,
            builder: (_, canSubmit, _) {
              return Container(
                height: 54.h, // primary action height
                decoration: BoxDecoration(
                  color:
                      canSubmit ? AppColors.dangerAccent : AppColors.borderDefault,
                  borderRadius:
                      BorderRadius.circular(AppCircular.r15), // mockup radius
                ),
                alignment: Alignment.center,
                child: Text(
                  LocaleKeys.failSubmit.tr(),
                  style: const TextStyle()
                      .setColor(
                          canSubmit ? AppColors.surface : AppColors.chipCountMuted)
                      .s16
                      .bold,
                ),
              ).onClick(
                onTap: canSubmit
                    ? () => Navigator.of(context).pop(
                          FailOutcome(
                            action: FailResult.failed,
                            reasonLabel: _controller.selectedReasonKey?.tr(),
                            note: _controller.note.text.trim(),
                          ),
                        )
                    : null,
              );
            },
          ),
          8.szH,
          Container(
            height: 50.h, // secondary action height
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppCircular.r15), // mockup radius
              border: Border.all(color: AppColors.borderDefault, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconWidget(
                  icon: AppAssets.svg.clock,
                  color: AppColors.postponedText,
                  height: AppSize.sH18,
                  width: AppSize.sW18,
                ),
                8.szW,
                Text(
                  LocaleKeys.failPostpone.tr(),
                  style: const TextStyle().setMainTextColor.s14.bold,
                ),
              ],
            ),
          ).onClick(
            onTap: () => Navigator.of(context)
                .pop(const FailOutcome(action: FailResult.postpone)),
          ),
        ],
      ),
    );
  }

  Widget _reasonRow(int i, bool selected) {
    return Container(
      decoration: BoxDecoration(
        color: selected ? AppColors.failedBg : AppColors.reasonRowBg,
        borderRadius: BorderRadius.circular(AppCircular.r14),
        border: Border.all(
          color: selected ? AppColors.brand : AppColors.borderHeader,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 22.w,
            height: 22.h,
            decoration: BoxDecoration(
              color: selected ? AppColors.brand : const Color(0x00000000),
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppColors.brand : AppColors.reasonDotBorder,
                width: 2,
              ),
            ),
            child: selected
                ? Center(
                    child: IconWidget(
                      icon: AppAssets.svg.check,
                      color: AppColors.surface,
                      height: 13.h,
                      width: 13.w,
                    ),
                  )
                : null,
          ),
          12.szW,
          Expanded(
            child: Text(
              FailSheetController.reasonKeys[i].tr(),
              style: const TextStyle().setMainTextColor.s14.semiBold,
            ),
          ),
        ],
      ).paddingAll(AppPadding.pH16),
    ).onClick(onTap: () => _controller.select(i));
  }
}

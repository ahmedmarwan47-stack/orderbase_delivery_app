part of '../../imports/order_flow_imports.dart';

/// Which branch the postpone sheet chose.
enum PostponeResult { confirm, back }

/// Outcome of the postpone sheet: the branch taken plus, on confirm, the chosen
/// re-attempt slot as a display string (e.g. "13 سبتمبر · 4:00 م").
class PostponeOutcome {
  const PostponeOutcome({required this.action, this.display});

  final PostponeResult action;
  final String? display;
}

/// Postpone sheet (Order Flow.dc.html, `showPostpone`): pick a new date/time
/// (with quick-slot shortcuts) for a later re-attempt. The back arrow returns
/// to the fail sheet. Returns [PostponeOutcome].
Future<PostponeOutcome?> showPostponeSheet(BuildContext context) {
  return showAppSheet<PostponeOutcome>(context, child: const _PostponeSheet());
}

/// StatefulWidget only to own the [PostponeSheetController] lifecycle — no
/// `setState`; the date/time fields rebuild via [ValueListenableBuilder].
class _PostponeSheet extends StatefulWidget {
  const _PostponeSheet();

  @override
  State<_PostponeSheet> createState() => _PostponeSheetState();
}

class _PostponeSheetState extends State<_PostponeSheet> {
  final PostponeSheetController _controller = PostponeSheetController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SheetShell(
      title: LocaleKeys.postponeTitle.tr(),
      onBack: () => Navigator.of(context)
          .pop(const PostponeOutcome(action: PostponeResult.back)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            LocaleKeys.postponeDesc.tr(),
            style: const TextStyle().setSecondaryColor.s14.regular,
          ),
          16.szH,
          Row(
            children: [
              _quickSlot(
                LocaleKeys.postponeSlot1.tr(),
                const TimeOfDay(hour: 13, minute: 30),
              ),
              8.szW,
              _quickSlot(
                LocaleKeys.postponeSlot2.tr(),
                const TimeOfDay(hour: 14, minute: 30),
              ),
              8.szW,
              _quickSlot(
                LocaleKeys.postponeSlot3.tr(),
                const TimeOfDay(hour: 18, minute: 0),
              ),
            ],
          ),
          16.szH,
          Text(
            LocaleKeys.postponeDateLabel.tr(),
            style: const TextStyle().setMainTextColor.s14.bold,
          ),
          8.szH,
          ValueListenableBuilder<DateTime>(
            valueListenable: _controller.date,
            builder: (_, _, _) => _field(
              icon: AppAssets.svg.note,
              value: _controller.dateLabel,
              onTap: () => _controller.pickDate(context),
            ),
          ),
          16.szH,
          Text(
            LocaleKeys.postponeTimeLabel.tr(),
            style: const TextStyle().setMainTextColor.s14.bold,
          ),
          8.szH,
          ValueListenableBuilder<TimeOfDay>(
            valueListenable: _controller.time,
            builder: (_, _, _) => _field(
              icon: AppAssets.svg.clock,
              value: _controller.timeLabel,
              onTap: () => _controller.pickTime(context),
            ),
          ),
          24.szH,
          Container(
            height: AppSize.sH56,
            decoration: BoxDecoration(
              color: AppColors.inkFill,
              borderRadius: BorderRadius.circular(AppCircular.r15), // mockup radius
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconWidget(
                  icon: AppAssets.svg.clock,
                  color: AppColors.surface,
                  height: AppSize.sH20,
                  width: AppSize.sW20,
                ),
                8.szW,
                Text(
                  LocaleKeys.postponeConfirm.tr(),
                  style: const TextStyle().setWhite.s16.bold,
                ),
              ],
            ),
          ).onClick(
            onTap: () => Navigator.of(context).pop(
              PostponeOutcome(
                action: PostponeResult.confirm,
                display: _controller.display,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickSlot(String label, TimeOfDay time) {
    return Expanded(
      child: Container(
        height: AppSize.sH44,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppCircular.r12),
          border: Border.all(color: AppColors.borderHeader),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle().setMainTextColor.s14.bold,
        ),
      ).onClick(onTap: () => _controller.setTime(time)),
    );
  }

  Widget _field({
    required String icon,
    required String value,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppCircular.r13),
        border: Border.all(color: AppColors.borderHeader),
      ),
      child: Row(
        children: [
          IconWidget(
            icon: icon,
            color: AppColors.postponedText,
            height: AppSize.sH18,
            width: AppSize.sW18,
          ),
          8.szW,
          Text(
            value,
            style: const TextStyle().setMainTextColor.s16.bold,
          ),
        ],
      ).paddingSymmetric(
        horizontal: AppPadding.pW16,
        vertical: AppPadding.pH12,
      ),
    ).onClick(onTap: onTap);
  }
}

part of '../imports/queue_imports.dart';

/// Horizontally-scrolling filter chips. The amber "مؤجلة" chip navigates to the
/// postponed list instead of filtering inline (postponed sits outside the queue).
class _QueueFilterChips extends StatelessWidget {
  const _QueueFilterChips({required this.vc});
  final QueueViewController vc;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<QueueFilter>(
      valueListenable: vc.filter,
      builder: (_, selected, _) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsetsDirectional.only(
          start: AppPadding.pW20,
          end: AppPadding.pW20,
        ),
        child: Row(
          spacing: AppSize.sW8,
          children: [
            _FilterChip(
              labelKey: LocaleKeys.filterAll,
              count: vc.countFor(QueueFilter.all),
              selected: selected == QueueFilter.all,
              onTap: () => vc.selectFilter(QueueFilter.all),
            ),
            _FilterChip(
              labelKey: LocaleKeys.filterTransit,
              count: vc.countFor(QueueFilter.transit),
              selected: selected == QueueFilter.transit,
              onTap: () => vc.selectFilter(QueueFilter.transit),
            ),
            _FilterChip.postponed(
              count: vc.postponed.length,
              selected: selected == QueueFilter.postponed,
              onTap: () => vc.selectFilter(QueueFilter.postponed),
            ),
            _FilterChip(
              labelKey: LocaleKeys.filterDelivered,
              count: vc.countFor(QueueFilter.delivered),
              selected: selected == QueueFilter.delivered,
              onTap: () => vc.selectFilter(QueueFilter.delivered),
            ),
            _FilterChip(
              labelKey: LocaleKeys.filterFailed,
              count: vc.countFor(QueueFilter.failed),
              selected: selected == QueueFilter.failed,
              onTap: () => vc.selectFilter(QueueFilter.failed),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.labelKey,
    required this.count,
    required this.selected,
    required this.onTap,
  }) : postponedStyle = false;

  const _FilterChip.postponed({
    required this.count,
    required this.onTap,
    this.selected = false,
  }) : labelKey = LocaleKeys.filterPostponed,
       postponedStyle = true;

  final String labelKey;
  final int count;
  final bool selected;
  final bool postponedStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    Border? border;
    if (postponedStyle) {
      if (selected) {
        bg = AppColors.postponedText;
        fg = AppColors.surface;
      } else {
        bg = AppColors.postponedBg;
        fg = AppColors.postponedText;
        border = Border.all(color: AppColors.postponedBorder);
      }
    } else if (selected) {
      bg = AppColors.inkFill;
      fg = AppColors.surface;
    } else {
      // White tile + hairline so the unselected chip stays visible now that the
      // filters sit on the paper page (surfaceMuted was invisible against it).
      bg = AppColors.surface;
      fg = AppColors.textTertiary;
      border = Border.all(color: AppColors.borderDefault);
    }
    return Container(
      height: AppSize.sH28,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppCircular.r12),
        border: border,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(labelKey.tr(), style: const TextStyle().setColor(fg).s12.bold),
          8.szW,
          _CountBadge(
            count: count,
            selected: selected,
            postponedStyle: postponedStyle,
          ),
        ],
      ).paddingSymmetric(horizontal: AppPadding.pW12),
    ).onClick(
      onTap: () {
        AppHaptics.tick();
        onTap();
      },
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({
    required this.count,
    required this.selected,
    required this.postponedStyle,
  });
  final int count;
  final bool selected;
  final bool postponedStyle;

  @override
  Widget build(BuildContext context) {
    final text = arabicDigits(count);
    if (selected) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(AppCircular.r8),
        ),
        child: Text(
          text,
          style: const TextStyle().setWhite.s12.bold,
        ).paddingSymmetric(horizontal: AppPadding.pW8),
      );
    }
    return Text(
      text,
      style: const TextStyle()
          .setColor(
            postponedStyle ? AppColors.postponedText : AppColors.textSecondary,
          )
          .s12
          .bold,
    );
  }
}

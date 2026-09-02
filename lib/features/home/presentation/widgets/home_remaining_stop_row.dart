part of '../imports/home_imports.dart';

/// One "remaining stop" list row — a numbered badge, name + area, an ETA time,
/// and a trailing chevron. Shared by the Compact (1c) and Flat (2a) route lists,
/// which differ only in badge size/shape, name weight and time color.
class _HomeRemainingStopRow extends StatelessWidget {
  const _HomeRemainingStopRow({
    required this.index,
    required this.name,
    required this.area,
    required this.time,
    required this.badgeSize,
    required this.badgeBg,
    required this.badgeColor,
    required this.badgeCircle,
    required this.nameSize,
    required this.nameWeight,
    required this.timeColor,
    required this.showDivider,
    required this.verticalPadding,
  });

  final String index;
  final String name;
  final String area;
  final String time;
  final double badgeSize;
  final Color badgeBg;
  final Color badgeColor;
  final bool badgeCircle;
  final double nameSize;
  final FontWeight nameWeight;
  final Color timeColor;
  final bool showDivider;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: showDivider
          ? const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.itemDivider)),
            )
          : null,
      child: Row(
        spacing: AppSize.sW12,
        children: [
          Container(
            width: badgeSize,
            height: badgeSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: badgeCircle
                  ? null
                  : BorderRadius.circular(AppCircular.r8),
              shape: badgeCircle ? BoxShape.circle : BoxShape.rectangle,
            ),
            child: Text(
              index,
              style: const TextStyle()
                  .setColor(badgeColor)
                  .s14
                  .semiBold
                  .tabular,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle().setMainTextColor
                      .copyWith(fontSize: nameSize, fontWeight: nameWeight)
                      .withHeight(1.33),
                ),
                Text(
                  area,
                  style: const TextStyle().setSecondaryColor.s12.regular
                      .withHeight(1.33),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle().setColor(timeColor).s14.semiBold.tabular,
          ),
          IconWidget(
            icon: AppAssets.svg.chevronLeft,
            color: AppColors.timelineDotMuted,
            height: AppSize.sH16,
            width: AppSize.sW16,
          ),
        ],
      ).paddingSymmetric(vertical: verticalPadding),
    );
  }
}

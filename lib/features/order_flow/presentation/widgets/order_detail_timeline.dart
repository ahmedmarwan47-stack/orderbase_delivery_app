part of '../imports/order_flow_imports.dart';

/// Order route timeline — an active (red) node connected by a rail to a muted
/// upcoming/past node.
class _Timeline extends StatelessWidget {
  const _Timeline();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.orderDetailTimelineTitle.tr(),
          style: const TextStyle().setTertiaryColor.s14.bold,
        ).paddingOnly(bottom: AppPadding.pH12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                children: [
                  Container(
                    width: 12.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: AppColors.brand,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.timelineRing, width: 3),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      width: 2.w,
                      child: const ColoredBox(color: AppColors.borderDefault),
                    ).paddingSymmetric(vertical: AppPadding.pH2),
                  ),
                ],
              ),
              12.szW,
              Expanded(
                child: const _TimelineText(
                  titleKey: LocaleKeys.orderDetailTimelinePicked,
                  timeKey: LocaleKeys.orderDetailTimelinePickedTime,
                  titleColor: AppColors.textPrimary,
                ).paddingOnly(bottom: AppPadding.pH12),
              ),
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 12.w,
              child: const _Dot(color: AppColors.timelineDotMuted, size: 12),
            ),
            12.szW,
            const Expanded(
              child: _TimelineText(
                titleKey: LocaleKeys.orderDetailTimelineAssigned,
                timeKey: LocaleKeys.orderDetailTimelineAssignedTime,
                titleColor: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ],
    ).paddingOnly(
      left: AppPadding.pW4,
      right: AppPadding.pW4,
      top: AppPadding.pH8,
      bottom: AppPadding.pH4,
    );
  }
}

/// A timeline node's title + timestamp.
class _TimelineText extends StatelessWidget {
  const _TimelineText({
    required this.titleKey,
    required this.timeKey,
    required this.titleColor,
  });
  final String titleKey;
  final String timeKey;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titleKey.tr(),
          style: const TextStyle().setColor(titleColor).s14.bold.withHeight(20 / 14),
        ),
        Text(
          timeKey.tr(),
          textDirection: TextDirection.ltr,
          style: const TextStyle().setSecondaryColor.s12.regular.withHeight(16 / 12),
        ),
      ],
    );
  }
}

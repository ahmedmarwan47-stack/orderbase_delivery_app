part of '../imports/order_flow_imports.dart';

/// Order route timeline — an active (red) node connected by a rail to a muted
/// upcoming/past node.
class _Timeline extends StatelessWidget {
  const _Timeline({required this.pickedTime, required this.assignedTime});

  final String pickedTime;
  final String assignedTime;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.orderDetailTimelineTitle.tr(),
          style: const TextStyle().setTertiaryColor.s14.semiBold,
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
                      width: 2.w, // 2px connector rule — off the 4px grid
                      child: const _TimelineRail(),
                    ).paddingSymmetric(vertical: AppPadding.pH2),
                  ),
                ],
              ),
              12.szW,
              Expanded(
                child: _TimelineText(
                  titleKey: LocaleKeys.orderDetailTimelinePicked,
                  time: pickedTime,
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
            Expanded(
              child: _TimelineText(
                titleKey: LocaleKeys.orderDetailTimelineAssigned,
                time: assignedTime,
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

/// The connector rail between the previous node and the current (red) one. A
/// brand fill "charges" up the grey track toward the current node — the same
/// zero-to-full progress fill the home hero uses — so the log reads as
/// animating up to the current state. Static grey under Reduce Motion.
class _TimelineRail extends StatefulWidget {
  const _TimelineRail();

  @override
  State<_TimelineRail> createState() => _TimelineRailState();
}

class _TimelineRailState extends State<_TimelineRail>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _ctrl.stop();
    } else if (!_ctrl.isAnimating) {
      _ctrl.repeat();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reduced(context)) {
      return const ColoredBox(color: AppColors.borderDefault);
    }
    // A DecoratedBox gradient (not a Stack/FractionallySizedBox) so the rail
    // stays a leaf box with trivial intrinsics — safe inside the enclosing
    // IntrinsicHeight, which a Stack here would break (zero-height collapse).
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        // Ease the fill in over the first 80% of the loop, hold full briefly,
        // then restart — identical timing to the home progress segment.
        final fill = Curves.easeInOut.transform(
          (_ctrl.value / 0.8).clamp(0.0, 1.0),
        );
        // Keep the two stops strictly inside (0,1) so adjacent stops never
        // coincide at the ends. Brand fills from the bottom (past node) up.
        final f = fill.clamp(0.001, 0.999);
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: const [
                AppColors.brand,
                AppColors.brand,
                AppColors.borderDefault,
                AppColors.borderDefault,
              ],
              stops: [0.0, f, f, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// A timeline node's title + timestamp.
class _TimelineText extends StatelessWidget {
  const _TimelineText({
    required this.titleKey,
    required this.time,
    required this.titleColor,
  });
  final String titleKey;
  final String time;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titleKey.tr(),
          style: const TextStyle().setColor(titleColor).s14.semiBold.withHeight(20 / 14),
        ),
        Text(
          time,
          textDirection: TextDirection.ltr,
          style: const TextStyle().setSecondaryColor.s12.regular.withHeight(16 / 12),
        ),
      ],
    );
  }
}

part of '../imports/notifications_imports.dart';

/// Calm, centered empty state for the notifications feed — shown when there are
/// no notifications at all. A muted circular tile with a bell glyph, then a bold
/// "all caught up" title and a secondary reassurance line. Matches the feed's
/// paper/ink tokens (see [_NotificationTile]). Defensive: the sample feed is
/// never empty today, but the screen stays correct when it is.
class _NotificationsEmpty extends StatelessWidget {
  const _NotificationsEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppSize.sW64,
            height: AppSize.sH64,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: IconWidget(
                icon: AppAssets.svg.bell,
                color: AppColors.textTertiary,
                height: AppSize.sH28,
                width: AppSize.sW28,
              ),
            ),
          ),
          20.szH,
          Text(
            LocaleKeys.notifEmptyTitle.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle().setMainTextColor.s18.bold,
          ),
          8.szH,
          Text(
            LocaleKeys.notifEmptySub.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle().setSecondaryColor.s14.regular,
          ),
        ],
      ).paddingSymmetric(horizontal: AppPadding.pW20),
    );
  }
}

part of '../imports/notifications_imports.dart';

/// White page title row for the Notifications tab — matches the More/Queue
/// header treatment (bold title on the right; an unread pill on the left).
class _NotificationsHeader extends StatelessWidget {
  const _NotificationsHeader({required this.unread, this.scrolled = false});
  final int unread;

  /// True once the feed has scrolled under the header — the header then fades
  /// in its surface background + hairline (transparent while at the top).
  final bool scrolled;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        // Fade the SAME white in/out (transparent-white, never transparent-
        // black) so the transition never flashes a dark tint.
        color: AppColors.surface.withValues(alpha: scrolled ? 1 : 0),
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderHeader.withValues(alpha: scrolled ? 1 : 0),
          ),
        ),
      ),
      child:
          Row(
            children: [
              const HeaderBackButton(),
              12.szW,
              Text(
                LocaleKeys.navNotifications.tr(),
                style: const TextStyle().setMainTextColor.s14.semiBold,
              ),
              const Spacer(),
              if (unread > 0)
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.failedBg,
                    borderRadius: BorderRadius.circular(AppCircular.r20),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppPadding.pW12,
                    vertical: AppPadding.pH4,
                  ),
                  child: Text(
                    LocaleKeys.notifNewCount.tr(namedArgs: {'n': '$unread'}),
                    style: const TextStyle()
                        .setColor(AppColors.failedText)
                        .s12
                        .semiBold,
                  ),
                ),
            ],
          ).paddingOnly(
            left: AppPadding.pW20,
            top: AppPadding.pH12,
            right: AppPadding.pW20,
            bottom: AppPadding.pH16,
          ),
    );
  }
}

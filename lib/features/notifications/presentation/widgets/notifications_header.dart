part of '../imports/notifications_imports.dart';

/// White page title row for the Notifications tab — matches the More/Queue
/// header treatment (bold title on the right; an unread pill on the left).
class _NotificationsHeader extends StatelessWidget {
  const _NotificationsHeader({required this.unread});
  final int unread;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppPadding.pW20,
        right: AppPadding.pW20,
        top: AppPadding.pH8,
        bottom: AppPadding.pH16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconWidget(
                icon: AppAssets.svg.chevronRight,
                color: AppColors.textTertiary,
                height: AppSize.sH18,
                width: AppSize.sW18,
              ),
              8.szW,
              Text(LocaleKeys.orderDetailBack.tr(),
                  style: const TextStyle().setTertiaryColor.s14.semiBold),
            ],
          )
              .paddingSymmetric(vertical: AppPadding.pH8)
              .onClick(onTap: () => Navigator.of(context).maybePop()),
          SizedBox(
            height: 56.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LocaleKeys.navNotifications.tr(),
                  style: const TextStyle().setMainTextColor.s16.extraBold,
                ),
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
                      style:
                          const TextStyle().setColor(AppColors.failedText).s12.bold,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

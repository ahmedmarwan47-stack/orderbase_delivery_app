part of '../imports/notifications_imports.dart';

/// A single notification card — a kind-tinted icon tile (leading, RTL right),
/// the title + body stacked, and the relative time on the far side. Unread
/// items stand out on a plain white card with a brand dot; already-read items
/// recede onto a muted background. Tapping opens the referenced order.
class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, this.onTap});
  final AppNotification notification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final n = notification;
    return Container(
      decoration: BoxDecoration(
        color: n.unread ? AppColors.surface : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppCircular.r16),
        border: Border.all(color: AppColors.borderCardFaint),
      ),
      padding: EdgeInsets.all(AppPadding.pH16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppSize.sW40,
            height: AppSize.sH40,
            decoration: BoxDecoration(
              color: n.kind.tileBg,
              borderRadius: BorderRadius.circular(AppCircular.r12),
            ),
            child: Center(
              child: IconWidget(
                icon: n.kind.icon,
                color: n.kind.iconColor,
                height: AppSize.sH20,
                width: AppSize.sW20,
              ),
            ),
          ),
          12.szW,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        n.title,
                        style: const TextStyle().setMainTextColor.s14.semiBold,
                      ),
                    ),
                    8.szW,
                    Text(
                      n.time,
                      style: const TextStyle().setHintColor.s12.regular,
                    ),
                    if (n.unread) ...[
                      8.szW,
                      Container(
                        width: AppSize.sW8,
                        height: AppSize.sH8,
                        margin: EdgeInsets.only(top: AppMargin.mH4),
                        decoration: const BoxDecoration(
                          color: AppColors.brand,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                6.szH,
                Text(
                  n.body,
                  style: const TextStyle()
                      .setSecondaryColor
                      .s12
                      .regular
                      .withHeight(1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    ).onClick(onTap: onTap);
  }
}

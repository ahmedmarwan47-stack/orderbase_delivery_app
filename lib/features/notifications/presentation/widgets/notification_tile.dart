part of '../imports/notifications_imports.dart';

/// A single notification card — a kind-tinted icon tile (leading, RTL right),
/// the title + body stacked, and the relative time on the far side. Unread
/// items stand out on a plain white card with a brand dot; already-read items
/// recede onto a muted background. Tapping opens the referenced order.
class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    this.onTap,
    this.last = false,
  });
  final AppNotification notification;
  final VoidCallback? onTap;

  /// Last row of the feed — drops the trailing hairline.
  final bool last;

  @override
  Widget build(BuildContext context) {
    final n = notification;
    return Container(
      decoration: last
          ? null
          : const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.borderDefault),
              ),
            ),
      padding: EdgeInsets.symmetric(vertical: AppPadding.pH12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Kind-tinted circle at the reading-start (right in RTL).
          Container(
            width: AppSize.sW44,
            height: AppSize.sH44,
            decoration: BoxDecoration(
              color: n.kind.tileBg,
              shape: BoxShape.circle,
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
          // The message, with the relative time directly beneath it.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  n.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle().setMainTextColor.s14.semiBold
                      .withHeight(1.35),
                ),
                4.szH,
                Text(
                  n.time,
                  style: const TextStyle().setHintColor.s12.regular,
                ),
              ],
            ),
          ),
          // Unread marker at the far reading-end, vertically centered.
          if (n.unread) ...[
            12.szW,
            Container(
              width: AppSize.sW8,
              height: AppSize.sH8,
              decoration: const BoxDecoration(
                color: AppColors.brand,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    ).onClick(onTap: onTap);
  }
}

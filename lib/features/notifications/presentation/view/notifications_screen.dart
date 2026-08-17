part of '../imports/notifications_imports.dart';

/// Notifications / الاشعارات — the courier's activity feed (order assigned /
/// cancelled / notes added / wallet credit). Hosted as the Notifications tab of
/// the app shell, so it carries the shared bottom nav. Static feed for now.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key, this.onSelectTab, this.onOpenOrder});

  /// Forwarded to the bottom nav so the app shell can switch tabs.
  final ValueChanged<NavTab>? onSelectTab;

  /// Opens the order a notification refers to (by number, without '#'). The
  /// app shell resolves it against the shift and pushes the order flow.
  final ValueChanged<String>? onOpenOrder;

  @override
  Widget build(BuildContext context) {
    final items = sampleNotifications();
    final unread = items.where((n) => n.unread).length;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _NotificationsHeader(unread: unread),
              Expanded(
                child: items.isEmpty
                    ? const _NotificationsEmpty()
                    : ListView.separated(
                        padding: EdgeInsetsDirectional.only(
                          start: AppPadding.pW20,
                          end: AppPadding.pW20,
                          top: AppPadding.pH4,
                          bottom: AppPadding.pH20,
                        ),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => 12.szH,
                        itemBuilder: (_, i) => _NotificationTile(
                          notification: items[i],
                          onTap: onOpenOrder == null
                              ? null
                              : () => onOpenOrder!(items[i].orderNum),
                        ),
                      ),
              ),
              const HomeIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

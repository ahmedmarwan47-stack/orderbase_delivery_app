part of '../imports/notifications_imports.dart';

/// Notifications / الاشعارات — the courier's activity feed (order assigned /
/// cancelled / notes added / wallet credit). Hosted as the Notifications tab of
/// the app shell, so it carries the shared bottom nav. Static feed for now.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, this.onSelectTab, this.onOpenOrder});

  /// Forwarded to the bottom nav so the app shell can switch tabs.
  final ValueChanged<NavTab>? onSelectTab;

  /// Opens the order a notification refers to (by number, without '#'). The
  /// app shell resolves it against the shift and pushes the order flow.
  final ValueChanged<String>? onOpenOrder;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ScrollController _scroll = ScrollController();

  // The header is transparent at the top and gains its surface background once
  // the feed scrolls beneath it (iOS large-title behaviour).
  final ValueNotifier<bool> _scrolled = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    final v = _scroll.offset > 2;
    if (v != _scrolled.value) _scrolled.value = v;
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    _scrolled.dispose();
    super.dispose();
  }

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
              ValueListenableBuilder<bool>(
                valueListenable: _scrolled,
                builder: (_, scrolled, _) =>
                    _NotificationsHeader(unread: unread, scrolled: scrolled),
              ),
              Expanded(
                child: items.isEmpty
                    ? const _NotificationsEmpty()
                    : ListView.separated(
                        controller: _scroll,
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
                          onTap: widget.onOpenOrder == null
                              ? null
                              : () => widget.onOpenOrder!(items[i].orderNum),
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

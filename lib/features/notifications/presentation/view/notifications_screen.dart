part of '../imports/notifications_imports.dart';

/// Notifications / الاشعارات — the courier's activity feed (batch dispatched /
/// order assigned / cancelled / notes / wallet credit / cash limit / settled).
///
/// Two lifecycles:
///  * **In the shell** ([embedded] = true) — the app shell hosts it as a page
///    inside the tab frame: the unified header and the tab bar stay put and
///    this widget renders only the title row and the feed.
///  * **Standalone** (DevGallery) — it draws its own back header + indicator.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
    this.onSelectTab,
    this.onOpenOrder,
    this.embedded = false,
  });

  /// Forwarded to the bottom nav so the app shell can switch tabs.
  final ValueChanged<NavTab>? onSelectTab;

  /// Opens the order a notification refers to (by number, without '#'). The
  /// app shell resolves it against the shift and pushes the order flow.
  final ValueChanged<String>? onOpenOrder;

  /// Hosted inside the shell's frame — no header of its own, no indicator.
  final bool embedded;

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
    // Rebuild as the feed grows — the simulator files batch / cash / settled
    // events while this page may be on screen.
    return AnimatedBuilder(
      animation: NotificationsStore.instance,
      builder: (context, _) {
        final items = NotificationsStore.instance.items;
        final unread = items.where((n) => n.unread).length;
        final feed = items.isEmpty
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
                  onTap: widget.onOpenOrder == null || items[i].orderNum.isEmpty
                      ? null
                      : () => widget.onOpenOrder!(items[i].orderNum),
                ),
              );

        if (widget.embedded) {
          return Column(
            children: [
              _NotificationsTitleRow(unread: unread),
              Expanded(child: feed),
            ],
          );
        }

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
                    builder: (_, scrolled, _) => _NotificationsHeader(
                      unread: unread,
                      scrolled: scrolled,
                    ),
                  ),
                  Expanded(child: feed),
                  const HomeIndicator(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The in-shell title row: page name on the right, unread pill on the left.
/// No back button — the header's bell is the way out.
class _NotificationsTitleRow extends StatelessWidget {
  const _NotificationsTitleRow({required this.unread});
  final int unread;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          LocaleKeys.navNotifications.tr(),
          style: const TextStyle().setMainTextColor.s14.bold,
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
              LocaleKeys.notifNewCount.tr(
                namedArgs: {'n': arabicDigits(unread)},
              ),
              style: const TextStyle()
                  .setColor(AppColors.failedText)
                  .s12
                  .semiBold,
            ),
          ),
      ],
    ).paddingOnly(
      left: AppPadding.pW20,
      top: AppPadding.pH8,
      right: AppPadding.pW20,
      bottom: AppPadding.pH12,
    );
  }
}

part of '../imports/notifications_imports.dart';

/// The kind of a courier notification — drives the tinted icon tile, matching
/// the status palette used across the app (transit blue / failed red /
/// postponed amber / delivered green).
enum NotifKind { assigned, cancelled, note, wallet }

extension NotifKindX on NotifKind {
  String get icon => switch (this) {
        NotifKind.assigned => AppAssets.svg.box,
        NotifKind.cancelled => AppAssets.svg.x,
        NotifKind.note => AppAssets.svg.note,
        NotifKind.wallet => AppAssets.svg.wallet,
      };

  Color get tileBg => switch (this) {
        NotifKind.assigned => AppColors.transitPillBg,
        NotifKind.cancelled => AppColors.failedBg,
        NotifKind.note => AppColors.heroCodPillBg,
        NotifKind.wallet => AppColors.deliveredBg,
      };

  Color get iconColor => switch (this) {
        NotifKind.assigned => AppColors.transitBg,
        NotifKind.cancelled => AppColors.failedText,
        NotifKind.note => AppColors.postponedText,
        NotifKind.wallet => AppColors.deliveredText,
      };
}

/// A single courier notification row.
class AppNotification {
  const AppNotification({
    required this.kind,
    required this.orderNum,
    required this.title,
    required this.body,
    required this.time,
    this.unread = false,
  });

  final NotifKind kind;

  /// The order this notification is about (without '#'); tapping the card opens
  /// that order's detail.
  final String orderNum;
  final String title;
  final String body;
  final String time; // relative label, e.g. "١٠ دقائق"
  final bool unread;
}

/// Sample feed mirroring the reference (order assigned / cancelled / notes /
/// wallet credit). Uses this shift's own order numbers + branch so the feed
/// reads as part of the same app. Resolved through [LocaleKeys] so the copy is
/// localized like the rest of the app.
List<AppNotification> sampleNotifications() {
  const branch = 'مدينة نصر';
  return [
    AppNotification(
      kind: NotifKind.assigned,
      orderNum: '89340',
      title: LocaleKeys.notifTitleAssigned.tr(namedArgs: {'num': '89340'}),
      body: LocaleKeys.notifBodyAssigned
          .tr(namedArgs: {'ready': '526689', 'branch': branch}),
      time: LocaleKeys.notifMinutesAgo.tr(namedArgs: {'n': '١٠'}),
      unread: true,
    ),
    AppNotification(
      kind: NotifKind.cancelled,
      orderNum: '89355',
      title: LocaleKeys.notifTitleCancelled.tr(namedArgs: {'num': '89355'}),
      body: LocaleKeys.notifBodyCancelled
          .tr(namedArgs: {'num': '89355', 'branch': branch}),
      time: LocaleKeys.notifMinutesAgo.tr(namedArgs: {'n': '١٢'}),
      unread: true,
    ),
    AppNotification(
      kind: NotifKind.note,
      orderNum: '89289',
      title: LocaleKeys.notifTitleNote.tr(namedArgs: {'num': '89289'}),
      body: LocaleKeys.notifBodyNote.tr(),
      time: LocaleKeys.notifMinutesAgo.tr(namedArgs: {'n': '٢٥'}),
      unread: true,
    ),
    AppNotification(
      kind: NotifKind.wallet,
      orderNum: '89298',
      title: LocaleKeys.notifTitleWallet
          .tr(namedArgs: {'amt': '٢٠', 'num': '89298'}),
      body: LocaleKeys.notifBodyWallet
          .tr(namedArgs: {'amt': '٢٠', 'num': '89298'}),
      time: LocaleKeys.notifHourAgo.tr(),
    ),
    AppNotification(
      kind: NotifKind.assigned,
      orderNum: '89293',
      title: LocaleKeys.notifTitleAssigned.tr(namedArgs: {'num': '89293'}),
      body: LocaleKeys.notifBodyAssigned
          .tr(namedArgs: {'ready': '526701', 'branch': branch}),
      time: LocaleKeys.notifHoursAgo.tr(namedArgs: {'n': '٢'}),
    ),
    AppNotification(
      kind: NotifKind.note,
      orderNum: '89322',
      title: LocaleKeys.notifTitleNote.tr(namedArgs: {'num': '89322'}),
      body: LocaleKeys.notifBodyNote.tr(),
      time: LocaleKeys.notifHoursAgo.tr(namedArgs: {'n': '٣'}),
    ),
    AppNotification(
      kind: NotifKind.wallet,
      orderNum: '89304',
      title: LocaleKeys.notifTitleWallet
          .tr(namedArgs: {'amt': '١٥', 'num': '89304'}),
      body: LocaleKeys.notifBodyWallet
          .tr(namedArgs: {'amt': '١٥', 'num': '89304'}),
      time: LocaleKeys.notifHoursAgo.tr(namedArgs: {'n': '٤'}),
    ),
  ];
}

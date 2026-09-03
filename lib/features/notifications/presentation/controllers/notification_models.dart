part of '../imports/notifications_imports.dart';

/// The kind of a courier notification — drives the tinted icon tile, matching
/// the status palette used across the app (transit blue / failed red /
/// postponed amber / delivered green).
enum NotifKind { assigned, batch, cancelled, note, wallet, cash, settled }

extension NotifKindX on NotifKind {
  String get icon => switch (this) {
    NotifKind.assigned => AppAssets.svg.box,
    NotifKind.batch => AppAssets.svg.box,
    NotifKind.cancelled => AppAssets.svg.x,
    NotifKind.note => AppAssets.svg.note,
    NotifKind.wallet => AppAssets.svg.wallet,
    NotifKind.cash => AppAssets.svg.alert,
    NotifKind.settled => AppAssets.svg.cash,
  };

  Color get tileBg => switch (this) {
    NotifKind.assigned => AppColors.transitPillBg,
    NotifKind.batch => AppColors.transitPillBg,
    NotifKind.cancelled => AppColors.failedBg,
    NotifKind.note => AppColors.heroCodPillBg,
    NotifKind.wallet => AppColors.deliveredBg,
    // Over the cash limit is the one non-failure red in the app.
    NotifKind.cash => AppColors.failedBg,
    // Settlement is slate, like its card — never the delivered green.
    NotifKind.settled => AppColors.paymentCardBg,
  };

  Color get iconColor => switch (this) {
    NotifKind.assigned => AppColors.transitBg,
    NotifKind.batch => AppColors.transitBg,
    NotifKind.cancelled => AppColors.failedText,
    NotifKind.note => AppColors.postponedText,
    NotifKind.wallet => AppColors.deliveredText,
    NotifKind.cash => AppColors.failedText,
    NotifKind.settled => AppColors.cashBright,
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
    // Newest first: the batch that started this shift.
    AppNotification(
      kind: NotifKind.batch,
      orderNum: '89289',
      title: LocaleKeys.notifTitleBatch.tr(
        namedArgs: {'id': sampleBatchOneId, 'count': '٨'},
      ),
      body: LocaleKeys.notifBodyBatch.tr(
        namedArgs: {'branch': branch, 'cash': '2,290'},
      ),
      time: LocaleKeys.notifMinutesAgo.tr(namedArgs: {'n': '٥'}),
      unread: true,
    ),
    AppNotification(
      kind: NotifKind.assigned,
      orderNum: '89340',
      title: LocaleKeys.notifTitleAssigned.tr(namedArgs: {'num': '89340'}),
      body: LocaleKeys.notifBodyAssigned.tr(
        namedArgs: {'ready': '526689', 'branch': branch},
      ),
      time: LocaleKeys.notifMinutesAgo.tr(namedArgs: {'n': '١٠'}),
      unread: true,
    ),
    AppNotification(
      kind: NotifKind.cancelled,
      orderNum: '89355',
      title: LocaleKeys.notifTitleCancelled.tr(namedArgs: {'num': '89355'}),
      body: LocaleKeys.notifBodyCancelled.tr(
        namedArgs: {'num': '89355', 'branch': branch},
      ),
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
      title: LocaleKeys.notifTitleWallet.tr(
        namedArgs: {'amt': '٢٠', 'num': '89298'},
      ),
      body: LocaleKeys.notifBodyWallet.tr(
        namedArgs: {'amt': '٢٠', 'num': '89298'},
      ),
      time: LocaleKeys.notifHourAgo.tr(),
    ),
    AppNotification(
      kind: NotifKind.assigned,
      orderNum: '89293',
      title: LocaleKeys.notifTitleAssigned.tr(namedArgs: {'num': '89293'}),
      body: LocaleKeys.notifBodyAssigned.tr(
        namedArgs: {'ready': '526701', 'branch': branch},
      ),
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
      title: LocaleKeys.notifTitleWallet.tr(
        namedArgs: {'amt': '١٥', 'num': '89304'},
      ),
      body: LocaleKeys.notifBodyWallet.tr(
        namedArgs: {'amt': '١٥', 'num': '89304'},
      ),
      time: LocaleKeys.notifHoursAgo.tr(namedArgs: {'n': '٤'}),
    ),
  ];
}

/// The live notification feed.
///
/// Seeded from [sampleNotifications] and appended to as the shift runs, so an
/// event the courier was told about in a sheet — a batch landing, say — is
/// still there in the list afterwards instead of vanishing with the sheet.
class NotificationsStore extends ChangeNotifier {
  NotificationsStore._();
  static final NotificationsStore instance = NotificationsStore._();

  List<AppNotification>? _items;

  /// Seeded lazily: the sample feed resolves [LocaleKeys], which needs
  /// easy_localization to be initialised first.
  List<AppNotification> get items => _items ??= sampleNotifications();

  /// File a notification at the top of the feed, newest first.
  void add(AppNotification n) {
    _items = [n, ...items];
    notifyListeners();
  }

  /// Announce a freshly dispatched batch.
  void addBatchAssigned(OrderBatch batch, {required String branch}) {
    add(
      AppNotification(
        kind: NotifKind.batch,
        orderNum: batch.orders.first.num.replaceAll('#', '').trim(),
        title: LocaleKeys.notifTitleBatch.tr(
          namedArgs: {'id': batch.id, 'count': arabicDigits(batch.count)},
        ),
        body: LocaleKeys.notifBodyBatch.tr(
          namedArgs: {
            'branch': branch,
            'cash': formatThousands(batch.codTotal),
          },
        ),
        time: LocaleKeys.notifMinutesAgo.tr(namedArgs: {'n': '١'}),
        unread: true,
      ),
    );
  }

  /// The courier crossed the cash limit — once per crossing.
  void addCashOverLimit({required int cash, required int limit}) {
    add(
      AppNotification(
        kind: NotifKind.cash,
        orderNum: '',
        title: LocaleKeys.notifTitleCash.tr(
          namedArgs: {'cash': formatThousands(cash)},
        ),
        body: LocaleKeys.notifBodyCash.tr(
          namedArgs: {'limit': formatThousands(limit)},
        ),
        time: LocaleKeys.notifJustNow.tr(),
        unread: true,
      ),
    );
  }
}

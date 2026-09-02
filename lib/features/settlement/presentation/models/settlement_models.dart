part of '../imports/settlement_imports.dart';

/// One cash order in a settlement. `paid` is what the courier actually
/// collected; `order` is the order's value. Any excess (`wallet`) was change
/// the courier kept for the customer's wallet. Pure value type.
class SettlementLine {
  const SettlementLine({
    required this.num,
    required this.name,
    required this.order,
    required this.paid,
  });

  /// Order number, e.g. `#89289` — always rendered LTR inside the RTL flow.
  final String num;
  final String name;

  /// The order's value in EGP.
  final int order;

  /// Cash actually collected in EGP (>= [order]).
  final int paid;

  /// Change owed to the customer's wallet — the amount collected above value.
  int get wallet => paid > order ? paid - order : 0;

  bool get hasWallet => wallet > 0;
}

/// One parcel going back to the branch with the cash.
class SettlementReturn {
  const SettlementReturn({
    required this.num,
    required this.name,
    required this.reason,
    required this.pieces,
  });

  final String num;
  final String name;
  final String reason;
  final int pieces;
}

/// One batch inside a day's settlement — the cash it produced and the parcels
/// it sends back. A batch still at the branch has neither yet, and is listed
/// so the day still accounts for it.
class SettlementBatch {
  const SettlementBatch({
    required this.id,
    required this.orderCount,
    this.lines = const [],
    this.returns = const [],
    this.pending = false,
  });

  final String id;
  final int orderCount;
  final List<SettlementLine> lines;
  final List<SettlementReturn> returns;

  /// Dispatched but not carried yet.
  final bool pending;

  int get cashTotal => lines.fold(0, (sum, l) => sum + l.paid);
  int get walletTotal => lines.fold(0, (sum, l) => sum + l.wallet);
  int get returnPieces => returns.fold(0, (sum, r) => sum + r.pieces);
}

/// Where a day's settlement stands.
enum SettlementStatus {
  /// Still delivering — cash is accruing.
  open,

  /// The courier is done and expected at the branch; the cashier has not
  /// settled yet.
  awaiting,

  /// The branch settled the day from its dashboard.
  settled,
}

/// A whole day's settlement — its batches plus every derived total the views
/// render. Today's is built live from the shift; past days come from history.
class SettlementData {
  const SettlementData({
    required this.date,
    required this.branch,
    required this.batches,
    required this.status,
    required this.cashierName,
    this.settledAt,
  });

  final DateTime date;
  final String branch;
  final List<SettlementBatch> batches;
  final SettlementStatus status;

  /// The cashier who receives the cash (shown on the settled summary).
  final String cashierName;

  /// When the branch settled — null until it does.
  final DateTime? settledAt;

  bool get isSettled => status == SettlementStatus.settled;

  /// Every cash line across the day's batches.
  List<SettlementLine> get lines => [for (final b in batches) ...b.lines];

  List<SettlementReturn> get returns => [
    for (final b in batches) ...b.returns,
  ];

  /// Total cash in hand = Σ paid (what the cashier receives).
  int get cashTotal => lines.fold(0, (sum, l) => sum + l.paid);

  /// Σ order value (the "قيمة الطلبات" breakdown figure).
  int get ordersTotal => lines.fold(0, (sum, l) => sum + l.order);

  /// Σ wallet change (the "فكة للمحفظة" breakdown figure).
  int get walletTotal => lines.fold(0, (sum, l) => sum + l.wallet);

  /// Number of cash orders in the settlement.
  int get rowCount => lines.length;

  /// Batches that actually reached the courier's hands.
  int get carriedBatchCount => batches.where((b) => !b.pending).length;

  int get orderCount => batches.fold(0, (sum, b) => sum + b.orderCount);

  String get dateLabel => formatDateArabic(date);

  SettlementData copyWith({SettlementStatus? status, DateTime? settledAt}) {
    return SettlementData(
      date: date,
      branch: branch,
      batches: batches,
      status: status ?? this.status,
      cashierName: cashierName,
      settledAt: settledAt ?? this.settledAt,
    );
  }
}

/// Sample data mirroring the mockup's own DCLogic `state` — kept so the ported
/// screen stays visually comparable to Settlement.dc.html.
/// Totals: cashTotal 3170, ordersTotal 3070, walletTotal 100, rowCount 4.
SettlementData get sampleSettlement => SettlementData(
  date: DateTime.now(),
  branch: ShiftController.instance.branchName,
  cashierName: LocaleKeys.settlementCashierDefault.tr(),
  status: SettlementStatus.open,
  batches: const [
    SettlementBatch(
      id: sampleBatchOneId,
      orderCount: 6,
      lines: [
        SettlementLine(num: '#89289', name: 'محمد حمدي', order: 1200, paid: 1250),
        SettlementLine(num: '#89285', name: 'منى خالد', order: 800, paid: 800),
      ],
    ),
    SettlementBatch(
      id: sampleBatchTwoId,
      orderCount: 4,
      lines: [
        SettlementLine(num: '#89291', name: 'أحمد فؤاد', order: 450, paid: 500),
        SettlementLine(num: '#89272', name: 'ياسمين عادل', order: 620, paid: 620),
      ],
    ),
  ],
);

/// Live settlement snapshot built from today's shift, batch by batch: each
/// carried batch's delivered cash orders (order value vs cash collected) and
/// the parcels it sends back; a batch still at the branch is listed as pending.
/// Status follows the courier: open while delivering, awaiting once they are
/// expected at the branch, settled when the cashier has taken the cash.
SettlementData get shiftSettlement {
  final shift = ShiftController.instance;
  final batches = <SettlementBatch>[
    for (final b in shift.carriedBatches.reversed)
      SettlementBatch(
        id: b.id,
        orderCount: b.count,
        lines: [
          for (final o in shift.ordersOfBatch(b.id))
            if (o.status == OrderStatus.delivered &&
                !o.prepaid &&
                (o.collected ?? o.cod ?? 0) > 0)
              SettlementLine(
                num: o.num,
                name: o.name,
                order: o.cod ?? 0,
                paid: o.collected ?? o.cod ?? 0,
              ),
        ],
        returns: [
          for (final o in shift.ordersOfBatch(b.id))
            if (o.status == OrderStatus.failed)
              SettlementReturn(
                num: o.num,
                name: o.name,
                reason: o.reason ?? LocaleKeys.failureReasonOther.tr(),
                pieces: o.pieces,
              ),
        ],
      ),
    for (final b in shift.pendingBatches)
      SettlementBatch(id: b.id, orderCount: b.count, pending: true),
  ];
  final receipt = shift.settlement;
  return SettlementData(
    date: DateTime.now(),
    branch: shift.branchName,
    batches: batches,
    status: shift.settled
        ? SettlementStatus.settled
        : shift.status == CourierStatus.returning
        ? SettlementStatus.awaiting
        : SettlementStatus.open,
    cashierName: receipt?.cashier ?? LocaleKeys.settlementCashierDefault.tr(),
    settledAt: receipt?.at,
  );
}

/// The last seven days, newest first — sample history until there is a
/// backend to read it from. Every day is settled; that is what makes it
/// history.
List<SettlementData> get sampleSettlementHistory {
  final today = DateTime.now();
  final cashier = LocaleKeys.settlementCashierDefault.tr();
  final branch = ShiftController.instance.branchName;
  SettlementData day(
    int daysAgo,
    List<SettlementBatch> batches, {
    int hour = 21,
    int minute = 10,
  }) {
    final d = today.subtract(Duration(days: daysAgo));
    return SettlementData(
      date: d,
      branch: branch,
      batches: batches,
      status: SettlementStatus.settled,
      cashierName: cashier,
      settledAt: DateTime(d.year, d.month, d.day, hour, minute),
    );
  }

  return [
    day(1, const [
      SettlementBatch(
        id: 'B #7871',
        orderCount: 6,
        lines: [
          SettlementLine(num: '#89201', name: 'منى خالد', order: 800, paid: 800),
          SettlementLine(num: '#89207', name: 'كريم سعيد', order: 1150, paid: 1200),
          SettlementLine(num: '#89214', name: 'هدى مراد', order: 420, paid: 420),
        ],
        returns: [
          SettlementReturn(num: '#89209', name: 'سامي رشاد', reason: 'العميل رفض الاستلام', pieces: 1),
        ],
      ),
      SettlementBatch(
        id: 'B #7873',
        orderCount: 3,
        lines: [
          SettlementLine(num: '#89228', name: 'أحمد فؤاد', order: 750, paid: 750),
        ],
      ),
    ], hour: 20, minute: 45),
    day(2, const [
      SettlementBatch(
        id: 'B #7864',
        orderCount: 7,
        lines: [
          SettlementLine(num: '#89150', name: 'ياسمين عادل', order: 620, paid: 620),
          SettlementLine(num: '#89154', name: 'عمر الشناوي', order: 980, paid: 1000),
          SettlementLine(num: '#89161', name: 'رنا صبري', order: 1040, paid: 1040),
        ],
      ),
    ]),
    day(3, const [
      SettlementBatch(
        id: 'B #7852',
        orderCount: 5,
        lines: [
          SettlementLine(num: '#89088', name: 'محمود عزت', order: 1300, paid: 1300),
          SettlementLine(num: '#89092', name: 'نهى فتحي', order: 560, paid: 600),
        ],
      ),
      SettlementBatch(
        id: 'B #7855',
        orderCount: 4,
        lines: [
          SettlementLine(num: '#89104', name: 'شريف عادل', order: 890, paid: 890),
          SettlementLine(num: '#89110', name: 'دينا سمير', order: 1270, paid: 1270),
        ],
        returns: [
          SettlementReturn(num: '#89107', name: 'ليلى فتحي', reason: 'العميل غير متواجد', pieces: 2),
        ],
      ),
      SettlementBatch(
        id: 'B #7858',
        orderCount: 2,
        lines: [],
      ),
    ], hour: 21, minute: 30),
    day(4, const [
      SettlementBatch(
        id: 'B #7840',
        orderCount: 6,
        lines: [
          SettlementLine(num: '#89012', name: 'طارق الشناوي', order: 640, paid: 640),
          SettlementLine(num: '#89019', name: 'سلمى فؤاد', order: 1120, paid: 1150),
          SettlementLine(num: '#89023', name: 'خالد سمير', order: 480, paid: 480),
        ],
      ),
    ]),
    day(5, const [
      SettlementBatch(
        id: 'B #7831',
        orderCount: 8,
        lines: [
          SettlementLine(num: '#88940', name: 'نور عادل', order: 700, paid: 700),
          SettlementLine(num: '#88946', name: 'هناء مصطفى', order: 1500, paid: 1500),
          SettlementLine(num: '#88951', name: 'يوسف كمال', order: 920, paid: 950),
          SettlementLine(num: '#88957', name: 'مي حسن', order: 380, paid: 380),
        ],
      ),
    ], hour: 22),
    day(6, const [
      SettlementBatch(
        id: 'B #7822',
        orderCount: 4,
        lines: [
          SettlementLine(num: '#88870', name: 'عمر شريف', order: 1050, paid: 1050),
          SettlementLine(num: '#88874', name: 'سارة علي', order: 640, paid: 700),
        ],
      ),
    ]),
    day(7, const [
      SettlementBatch(
        id: 'B #7810',
        orderCount: 5,
        lines: [
          SettlementLine(num: '#88801', name: 'كريم عادل', order: 450, paid: 450),
          SettlementLine(num: '#88805', name: 'منى سعيد', order: 1330, paid: 1350),
          SettlementLine(num: '#88811', name: 'أحمد فؤاد', order: 860, paid: 860),
        ],
      ),
    ]),
  ];
}

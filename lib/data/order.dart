import 'flow_order.dart';

enum OrderStatus { transit, delivered, postponed, failed }

class Order {
  const Order({
    required this.num,
    required this.name,
    required this.addr,
    required this.area,
    required this.status,
    this.due,
    this.cod,
    this.prepaid = false,
    this.dist,
    this.returns,
    this.reason,
    this.postponedAt,
    this.items = const [],
    this.note,
    this.collected,
    this.phone,
  });

  final String num;
  final String name;
  final String addr;
  final String area;
  final OrderStatus status;
  final String? due; // promised delivery time label, e.g. "٢:٤٥ م"
  final int? cod; // cash-on-delivery amount in EGP
  final bool prepaid;
  final String? dist; // distance label shown on the queue card, e.g. "4.2 كم"
  final String? returns; // postponed: when it returns to the active queue
  final String? reason; // postponed reason, or failure reason once returned
  final String? postponedAt; // postponed: when it was postponed

  /// The order's line items — shown on the detail screen and the source of the
  /// [pieces] count carried on the card. Kept on [Order] so a tapped card and
  /// its detail agree (number of items, COD vs prepaid, note).
  final List<FlowOrderItem> items;

  /// Customer note for the courier; `null` hides the notes card.
  final String? note;

  /// Cash actually collected on delivery (COD). Set when the order is marked
  /// delivered so the shift's "collected today" total is real.
  final int? collected;

  /// The customer's phone, in dialable form. Powers the Order Detail call
  /// button and the Live Activity's "اتصال بالعميل" — null simply hides both.
  final String? phone;

  /// Number of pieces = the sum of item quantities. Reflected on the card meta
  /// ("<area> · N قطعة") and on the detail.
  int get pieces => items.fold(0, (sum, it) => sum + it.qty);

  /// Full delivery address ("street - area") for the hero + detail.
  String get fullAddress => '$addr - $area';

  Order copyWith({
    OrderStatus? status,
    String? reason,
    int? collected,
  }) {
    return Order(
      num: num,
      name: name,
      addr: addr,
      area: area,
      status: status ?? this.status,
      due: due,
      cod: cod,
      prepaid: prepaid,
      dist: dist,
      returns: returns,
      reason: reason ?? this.reason,
      postponedAt: postponedAt,
      items: items,
      note: note,
      collected: collected ?? this.collected,
      phone: phone,
    );
  }
}

/// Sample data mirroring the mockup's own `state.orders`. Names are Arabic (the
/// app is Arabic-first) and every order carries its items + note so a tapped
/// card and its detail agree.
final List<Order> sampleOrders = [
  const Order(
    num: '#89289',
    phone: '+201092890',
    name: 'محمد حمدي',
    addr: 'شارع بن عبدالعزيز',
    area: 'زهراء مدينة نصر',
    status: OrderStatus.transit,
    due: '٢:٤٥ م',
    cod: 1200,
    dist: '4.2 كم',
    items: [
      FlowOrderItem(
        name: 'فادج شوكولاتة بالبندق',
        variant: 'متوسطة – 20 سم',
        weight: '600 جم',
        qty: 2,
      ),
      FlowOrderItem(
        name: 'كوكيز الشوفان بالعسل',
        variant: 'علبة – 12 قطعة',
        weight: '350 جم',
        qty: 2,
      ),
    ],
    note:
        'برجاء الاتصال قبل التوصيل بساعة على الأقل. العميل في الدور الخامس والمصعد معطّل، فيُرجى الصعود على السلّم.',
  ),
  const Order(
    num: '#89304',
    phone: '+201093040',
    name: 'سارة علي',
    addr: 'شارع ١٠',
    area: 'زهراء مدينة نصر',
    status: OrderStatus.postponed,
    returns: '٤:٣٠ م',
    reason: 'العميل طلب التوصيل بعد ساعتين',
    postponedAt: '٢:٣٠ م',
    cod: 640,
    items: [
      FlowOrderItem(
        name: 'تشيز كيك بالفراولة',
        variant: 'صغيرة – 14 سم',
        weight: '450 جم',
      ),
    ],
  ),
  const Order(
    num: '#89322',
    phone: '+201093220',
    name: 'نور عادل',
    addr: 'شارع ٢٦',
    area: 'زهراء مدينة نصر',
    status: OrderStatus.delivered,
    collected: 0,
    items: [
      FlowOrderItem(
        name: 'مافن فانيليا',
        variant: 'علبة – 6 قطع',
        weight: '300 جم',
      ),
    ],
  ),
  const Order(
    num: '#89293',
    phone: '+201092930',
    name: 'يوسف كمال',
    addr: 'شارع النصر',
    area: 'مصر الجديدة',
    status: OrderStatus.transit,
    due: '٣:١٥ م',
    prepaid: true,
    dist: '6.8 كم',
    items: [
      FlowOrderItem(
        name: 'كيك ريد فيلفيت',
        variant: 'كبيرة – 24 سم',
        weight: '900 جم',
      ),
    ],
    note: 'الرجاء الاتصال قبل الوصول بـ 10 دقائق. البواب يستلم الطلب لو العميل غير موجود.',
  ),
  const Order(
    num: '#89298',
    phone: '+201092980',
    name: 'هناء مصطفى',
    addr: 'شارع التسعين',
    area: 'المعادي',
    status: OrderStatus.transit,
    due: '٣:٤٠ م',
    cod: 640,
    dist: '11.5 كم',
    items: [
      FlowOrderItem(
        name: 'تورتة شوكولاتة',
        variant: 'وسط – 18 سم',
        weight: '700 جم',
      ),
      FlowOrderItem(
        name: 'بسكويت زبدة',
        variant: 'علبة – 20 قطعة',
        weight: '400 جم',
      ),
    ],
  ),
  const Order(
    num: '#89311',
    phone: '+201093110',
    name: 'عمر شريف',
    addr: 'شارع ٩',
    area: 'المقطم',
    status: OrderStatus.postponed,
    returns: '٦:٠٠ م',
    reason: 'العميل مش في البيت قبل ٦ م',
    postponedAt: '١:٠٥ م',
    prepaid: true,
    items: [
      FlowOrderItem(
        name: 'كب كيك متنوع',
        variant: 'علبة – 6 قطع',
        weight: '450 جم',
        qty: 3,
      ),
    ],
  ),
  const Order(
    num: '#89340',
    phone: '+201093400',
    name: 'كريم عادل',
    addr: 'شارع الثورة',
    area: 'مدينة نصر',
    status: OrderStatus.transit,
    due: '٤:٠٠ م',
    cod: 450,
    dist: '7.3 كم',
    items: [
      FlowOrderItem(
        name: 'تشيز كيك أوريو',
        variant: 'كبيرة – 22 سم',
        weight: '850 جم',
      ),
    ],
  ),
  const Order(
    num: '#89355',
    phone: '+201093550',
    name: 'ليلى فتحي',
    addr: 'شارع الحرية',
    area: 'مدينة نصر',
    status: OrderStatus.failed,
    reason: 'تعذّر التواصل مع العميل',
    items: [
      FlowOrderItem(
        name: 'تورتة عيد ميلاد',
        variant: 'كبيرة – 26 سم',
        weight: '1200 جم',
      ),
    ],
  ),
  const Order(
    num: '#89361',
    phone: '+201093610',
    name: 'خالد سمير',
    addr: 'شارع ٩',
    area: 'المعادي',
    status: OrderStatus.failed,
    reason: 'العميل رفض استلام الطلب',
    items: [
      FlowOrderItem(
        name: 'دونات متنوع',
        variant: 'علبة – 12 قطعة',
        weight: '600 جم',
        qty: 2,
      ),
    ],
  ),
  const Order(
    num: '#89372',
    phone: '+201093720',
    name: 'منى سعيد',
    addr: 'شارع الميرغني',
    area: 'مصر الجديدة',
    status: OrderStatus.failed,
    reason: 'عدم تطابق المنتج',
    items: [
      FlowOrderItem(
        name: 'تشيز كيك مانجو',
        variant: 'وسط – 18 سم',
        weight: '650 جم',
        qty: 2,
      ),
    ],
  ),
];

/// Builds the rich per-order [FlowOrder] the order-flow screens expect straight
/// from a queue [Order]. Items, note, COD/prepaid and piece count all carry
/// across, so a tapped card and its detail always agree. Shared by the queue
/// (card taps) and the app shell (Home's next-stop hero).
FlowOrder orderToFlow(Order o) {
  return FlowOrder(
    num: o.num,
    name: o.name,
    meta: o.pieces > 0 ? '${o.area} · ${o.pieces} قطعة' : o.area,
    state: switch (o.status) {
      OrderStatus.transit || OrderStatus.postponed => FlowOrderState.active,
      OrderStatus.delivered => FlowOrderState.done,
      OrderStatus.failed => FlowOrderState.failed,
    },
    cod: o.cod != null && !o.prepaid,
    amount: o.cod != null ? formatThousands(o.cod!) : null,
    address: o.fullAddress,
    items: o.items,
    note: o.note,
    assignedTime: o.due ?? '',
    pickedTime: '',
    dateLabel: '',
  );
}

String formatThousands(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i != 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}

/// Western → Eastern-Arabic digits for counts shown in Arabic copy.
String arabicDigits(Object value) {
  const eastern = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  var s = value.toString();
  for (var i = 0; i < 10; i++) {
    s = s.replaceAll('$i', eastern[i]);
  }
  return s;
}

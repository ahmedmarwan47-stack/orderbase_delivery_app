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
  final String? reason; // postponed: reason given
  final String? postponedAt; // postponed: when it was postponed

  Order copyWith({OrderStatus? status}) {
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
      reason: reason,
      postponedAt: postponedAt,
    );
  }
}

/// Sample data mirroring the mockup's own `state.orders`, kept identical so
/// the ported screen is visually comparable to the mockup.
final List<Order> sampleOrders = [
  const Order(
    num: '#89289',
    name: 'Mohamed Hamdy',
    addr: 'شارع بن عبدالعزيز',
    area: 'زهراء مدينة نصر',
    status: OrderStatus.transit,
    due: '٢:٤٥ م',
    cod: 1200,
    dist: '4.2 كم',
  ),
  const Order(
    num: '#89304',
    name: 'Sara Ali',
    addr: 'شارع ١٠',
    area: 'زهراء مدينة نصر',
    status: OrderStatus.postponed,
    returns: '٤:٣٠ م',
    reason: 'العميل طلب التوصيل بعد ساعتين',
    postponedAt: '٢:٣٠ م',
    cod: 640,
  ),
  const Order(
    num: '#89322',
    name: 'Nour Adel',
    addr: 'شارع ٢٦',
    area: 'زهراء مدينة نصر',
    status: OrderStatus.delivered,
  ),
  const Order(
    num: '#89293',
    name: 'Youssef Kamal',
    addr: 'شارع النصر',
    area: 'مصر الجديدة',
    status: OrderStatus.transit,
    due: '٣:١٥ م',
    prepaid: true,
    dist: '6.8 كم',
  ),
  const Order(
    num: '#89298',
    name: 'Hana Mostafa',
    addr: 'شارع التسعين',
    area: 'المعادي',
    status: OrderStatus.transit,
    due: '٣:٤٠ م',
    cod: 640,
    dist: '11.5 كم',
  ),
  const Order(
    num: '#89311',
    name: 'Omar Sherif',
    addr: 'شارع ٩',
    area: 'المقطم',
    status: OrderStatus.postponed,
    returns: '٦:٠٠ م',
    reason: 'العميل مش في البيت قبل ٦ م',
    postponedAt: '١:٠٥ م',
    prepaid: true,
  ),
  const Order(
    num: '#89340',
    name: 'Karim Adel',
    addr: 'شارع الثورة',
    area: 'مدينة نصر',
    status: OrderStatus.transit,
    due: '٤:٠٠ م',
    cod: 450,
    dist: '7.3 كم',
  ),
  const Order(
    num: '#89355',
    name: 'Laila Fathy',
    addr: 'شارع الحرية',
    area: 'مدينة نصر',
    status: OrderStatus.failed,
  ),
];

String formatThousands(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i != 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}

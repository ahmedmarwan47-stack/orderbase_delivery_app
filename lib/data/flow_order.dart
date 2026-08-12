/// Order shape used by the Order Flow screens (orders list → detail → pickup →
/// result). Mirrors the mockup's own `orderList` in Order Flow.dc.html — kept
/// separate from the Queue States [Order] model, which has a different shape.
enum FlowOrderState { active, done, failed }

class FlowOrder {
  const FlowOrder({
    required this.num,
    required this.name,
    required this.meta,
    required this.state,
    required this.cod,
    this.pay,
    this.amount,
  });

  final String num;
  final String name;
  final String meta; // "زهراء مدينة نصر · 4 قطع"
  final FlowOrderState state;
  final bool cod; // cash-on-delivery
  final String? pay; // status label for non-active/paid rows ("مدفوع", ...)
  final String? amount; // COD amount label, e.g. "1,200"
}

/// Sample data identical to the mockup's `orderList`, so the ported screen is
/// visually comparable side-by-side.
const List<FlowOrder> sampleFlowOrders = [
  FlowOrder(
    num: '#89289',
    name: 'محمد حمدي',
    meta: 'زهراء مدينة نصر · 4 قطع',
    state: FlowOrderState.active,
    cod: true,
    amount: '1,200',
  ),
  FlowOrder(
    num: '#89291',
    name: 'أحمد فؤاد',
    meta: 'مصر الجديدة · 1 قطعة',
    state: FlowOrderState.active,
    cod: true,
    amount: '450',
  ),
  FlowOrder(
    num: '#89290',
    name: 'سارة إبراهيم',
    meta: 'مدينة نصر · 2 قطعة',
    state: FlowOrderState.active,
    cod: false,
    pay: 'مدفوع',
  ),
  FlowOrder(
    num: '#89285',
    name: 'منى خالد',
    meta: 'المعادي · 2 قطعة',
    state: FlowOrderState.done,
    cod: false,
    pay: 'تم التحصيل · 800 جم',
  ),
  FlowOrder(
    num: '#89282',
    name: 'كريم سمير',
    meta: 'الرحاب · 3 قطع',
    state: FlowOrderState.done,
    cod: false,
    pay: 'مدفوع',
  ),
  FlowOrder(
    num: '#89279',
    name: 'هالة نبيل',
    meta: 'التجمع الخامس · 1 قطعة',
    state: FlowOrderState.failed,
    cod: false,
    pay: 'تعذّر التسليم',
  ),
];

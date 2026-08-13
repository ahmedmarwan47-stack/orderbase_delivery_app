/// A single line item on an order's detail screen (merchant thumb, name,
/// variant, weight and quantity).
class FlowOrderItem {
  const FlowOrderItem({
    required this.name,
    required this.variant,
    required this.weight,
    this.qty = 1,
  });

  final String name;
  final String variant;
  final String weight;
  final int qty;
}

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
    required this.address,
    required this.items,
    this.note,
    required this.dateLabel,
    required this.assignedTime,
    required this.pickedTime,
  });

  final String num;
  final String name;
  final String meta; // "زهراء مدينة نصر · 4 قطع"
  final FlowOrderState state;
  final bool cod; // cash-on-delivery
  final String? pay; // status label for non-active/paid rows ("مدفوع", ...)
  final String? amount; // COD amount label, e.g. "1,200"

  /// Full delivery address, shown under the map preview on Order Detail.
  final String address;

  /// The order's line items, shown on Order Detail.
  final List<FlowOrderItem> items;

  /// Customer note for the courier; `null` hides the notes card entirely.
  final String? note;

  /// Human-readable order date shown in the detail header, e.g.
  /// "13 سبتمبر 2024". A real per-order field, not a hardcoded UI string.
  final String dateLabel;

  /// Timeline timestamps (LTR), oldest first: assigned to the courier, then
  /// picked up from the branch.
  final String assignedTime;
  final String pickedTime;

  /// The COD amount as an int (e.g. "1,200" → 1200) for the collection flow.
  /// Falls back to 0 when there is no amount (prepaid rows).
  int get codDue => int.tryParse((amount ?? '').replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
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
    address:
        '4290 عمارات الضباط - شارع بن عبدالعزيز، الدور الـ5 شقة رقم 52 - زهراء مدينة نصر، القاهرة',
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
        'برجاء الاتصال قبل التوصيل بساعة على الأقل. العميل في الدور الخامس والمصعد معطّل، فيُرجى الصعود على السلّم. لو لم يردّ على الهاتف، جرّب الرقم البديل 0100 123 4567 أو اترك الطلب مع الأمن في البوابة الرئيسية وأبلغني برسالة.',
    dateLabel: '13 سبتمبر 2024',
    assignedTime: '13 سبتمبر 2024 · 12:30pm',
    pickedTime: '13 سبتمبر 2024 · 01:30pm',
  ),
  FlowOrder(
    num: '#89291',
    name: 'أحمد فؤاد',
    meta: 'مصر الجديدة · 1 قطعة',
    state: FlowOrderState.active,
    cod: true,
    amount: '450',
    address: 'برج النيل - شارع الميرغني، الدور الـ3 شقة رقم 14 - مصر الجديدة، القاهرة',
    items: [
      FlowOrderItem(
        name: 'تشيز كيك بالفراولة',
        variant: 'صغيرة – 14 سم',
        weight: '450 جم',
      ),
    ],
    note: 'الرجاء الاتصال قبل الوصول بـ 10 دقائق. البواب يستلم الطلب لو العميل غير موجود.',
    dateLabel: '13 سبتمبر 2024',
    assignedTime: '13 سبتمبر 2024 · 12:45pm',
    pickedTime: '13 سبتمبر 2024 · 01:40pm',
  ),
  FlowOrder(
    num: '#89290',
    name: 'سارة إبراهيم',
    meta: 'مدينة نصر · 2 قطعة',
    state: FlowOrderState.active,
    cod: false,
    pay: 'مدفوع',
    address: 'عمارات النصر - شارع مصطفى النحاس، الدور الـ2 شقة رقم 7 - مدينة نصر، القاهرة',
    items: [
      FlowOrderItem(
        name: 'كيك ريد فيلفيت',
        variant: 'كبيرة – 24 سم',
        weight: '900 جم',
      ),
      FlowOrderItem(
        name: 'مافن فانيليا',
        variant: 'علبة – 6 قطع',
        weight: '300 جم',
      ),
    ],
    dateLabel: '13 سبتمبر 2024',
    assignedTime: '13 سبتمبر 2024 · 01:00pm',
    pickedTime: '13 سبتمبر 2024 · 01:55pm',
  ),
  FlowOrder(
    num: '#89285',
    name: 'منى خالد',
    meta: 'المعادي · 2 قطعة',
    state: FlowOrderState.done,
    cod: false,
    pay: 'تم التحصيل · 800 جم',
    address: 'كورنيش النيل - شارع 9، الدور الأرضي شقة رقم 3 - المعادي، القاهرة',
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
    dateLabel: '13 سبتمبر 2024',
    assignedTime: '13 سبتمبر 2024 · 09:15am',
    pickedTime: '13 سبتمبر 2024 · 10:05am',
  ),
  FlowOrder(
    num: '#89282',
    name: 'كريم سمير',
    meta: 'الرحاب · 3 قطع',
    state: FlowOrderState.done,
    cod: false,
    pay: 'مدفوع',
    address: 'مجاورة 3، فيلا 21 - الرحاب، مدينة الرحاب، القاهرة الجديدة',
    items: [
      FlowOrderItem(
        name: 'تشيز كيك أوريو',
        variant: 'كبيرة – 22 سم',
        weight: '850 جم',
      ),
      FlowOrderItem(
        name: 'كب كيك متنوع',
        variant: 'علبة – 6 قطع',
        weight: '450 جم',
        qty: 3,
      ),
    ],
    dateLabel: '13 سبتمبر 2024',
    assignedTime: '13 سبتمبر 2024 · 08:20am',
    pickedTime: '13 سبتمبر 2024 · 09:10am',
  ),
  FlowOrder(
    num: '#89279',
    name: 'هالة نبيل',
    meta: 'التجمع الخامس · 1 قطعة',
    state: FlowOrderState.failed,
    cod: false,
    pay: 'تعذّر التسليم',
    address: 'شارع التسعين الشمالي، بجوار كارفور - التجمع الخامس، القاهرة الجديدة',
    items: [
      FlowOrderItem(
        name: 'تورتة عيد ميلاد',
        variant: 'كبيرة – 26 سم',
        weight: '1200 جم',
      ),
    ],
    note: 'العميل طلب التأجيل ليوم آخر — لن يكون متواجدًا اليوم.',
    dateLabel: '13 سبتمبر 2024',
    assignedTime: '13 سبتمبر 2024 · 07:40am',
    pickedTime: '13 سبتمبر 2024 · 08:30am',
  ),
];

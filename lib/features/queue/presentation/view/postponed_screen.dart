part of '../imports/queue_imports.dart';

/// Postponed list — Queue States 1e. The separate home for orders taken out of
/// the active queue, each with its return time, reason, and a manual return
/// action. Local list state lives in this Screen (small, self-contained).
class PostponedScreen extends StatefulWidget {
  const PostponedScreen({super.key, this.orders});

  final List<Order>? orders;

  @override
  State<PostponedScreen> createState() => _PostponedScreenState();
}

class _PostponedScreenState extends State<PostponedScreen> {
  late final ValueNotifier<List<Order>> _orders = ValueNotifier(
    List<Order>.from(
      widget.orders ??
          sampleOrders.where((o) => o.status == OrderStatus.postponed),
    ),
  );

  void _returnToQueue(Order o) {
    _orders.value = List.of(_orders.value)..remove(o);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(LocaleKeys.returnedToQueue.tr(namedArgs: {'num': o.num})),
        ),
      );
  }

  @override
  void dispose() {
    _orders.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: _PostponedBody(orders: _orders, onReturn: _returnToQueue),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../data/order.dart';
import '../features/home/presentation/imports/home_imports.dart';
import '../features/order_flow/presentation/imports/order_flow_imports.dart';
import '../features/orders/presentation/imports/orders_imports.dart';
import '../features/pickup/presentation/imports/pickup_imports.dart';
import '../features/queue/presentation/imports/queue_imports.dart';
import '../theme/colors.dart';
import 'sheet_preview_host.dart';

/// Temporary launcher listing the screens built so far, so each can be opened
/// while there's no real navigation yet. Replaced by the app's actual entry
/// flow once enough screens are wired together.
class DevGallery extends StatelessWidget {
  const DevGallery({super.key});

  static final _screens = <String, WidgetBuilder>{
    'الرئيسية · Home (1a)': (_) => const HomeScreen(),
    'طلبات اليوم · Orders list': (context) => OrdersListScreen(
          onOpenOrder: (_) => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const OrderDetailScreen())),
        ),
    'قائمة الطلبات · Queue (1b)': (_) => const QueueScreen(),
    'بحث · Queue search (1a)': (_) =>
        const QueueScreen(startSearching: true, initialQuery: 'زهراء'),
    'لا نتائج · Queue no-results (1c)': (_) =>
        const QueueScreen(startSearching: true, initialQuery: '89345'),
    'فاضية · Queue cleared (1d)': (_) => QueueScreen(
          orders: sampleOrders
              .where((o) => o.status == OrderStatus.postponed)
              .toList(),
        ),
    'المؤجلة · Postponed (1e)': (_) => const PostponedScreen(),
    'تفاصيل الطلب · Order detail': (_) => const OrderDetailScreen(),
    'استلام من الفرع · Pickup': (_) => const PickupScreen(),
    'نتيجة · Result — تم التسليم': (_) => const ResultScreen(kind: ResultKind.delivered),
    'نتيجة · Result — لم يتم التسليم': (_) => const ResultScreen(kind: ResultKind.failed),
    'نتيجة · Result — تأجيل': (_) => const ResultScreen(kind: ResultKind.postponed),
    'ورقة · Handoff sheet': (_) =>
        SheetPreviewHost(label: 'تأكيد التسليم', open: showHandoffSheet),
    'ورقة · Fail sheet': (_) => SheetPreviewHost(label: 'سبب عدم التسليم', open: showFailSheet),
    'ورقة · Postpone sheet': (_) =>
        SheetPreviewHost(label: 'تأجيل التسليم', open: showPostponeSheet),
  };

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          title: const Text('Orderbase — الشاشات',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 18)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final entry in _screens.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.inkFill,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: entry.value)),
                  child: Text(entry.key, style: const TextStyle(fontSize: 16)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

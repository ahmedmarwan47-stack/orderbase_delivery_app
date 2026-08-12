import 'package:flutter/material.dart';

import '../screens/home/home_screen.dart';
import '../screens/order_detail/order_detail_screen.dart';
import '../screens/orders_list/orders_list_screen.dart';
import '../screens/pickup/pickup_screen.dart';
import '../theme/colors.dart';

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
    'تفاصيل الطلب · Order detail': (_) => const OrderDetailScreen(),
    'استلام من الفرع · Pickup': (_) => const PickupScreen(),
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

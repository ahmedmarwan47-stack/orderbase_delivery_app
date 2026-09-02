import 'package:flutter/material.dart';

import '../data/order.dart';
import '../features/auth/presentation/imports/auth_imports.dart';
import '../features/cod/presentation/imports/cod_imports.dart';
import '../features/failure_states/presentation/imports/failure_states_imports.dart';
import '../features/home/presentation/imports/home_imports.dart';
import '../features/notifications/presentation/imports/notifications_imports.dart';
import '../features/order_flow/presentation/imports/order_flow_imports.dart';
import '../features/orders/presentation/imports/orders_imports.dart';
import '../features/pickup/presentation/imports/pickup_imports.dart';
import '../features/queue/presentation/imports/queue_imports.dart';
import '../features/settlement/presentation/imports/settlement_imports.dart';
import '../theme/colors.dart';
import 'sheet_preview_host.dart';

/// Temporary launcher listing the screens built so far, so each can be opened
/// while there's no real navigation yet. Replaced by the app's actual entry
/// flow once enough screens are wired together.
class DevGallery extends StatelessWidget {
  const DevGallery({super.key});

  static final _screens = <String, WidgetBuilder>{
    'الرئيسية · Home (1a)': (_) => const HomeScreen(),
    'الرئيسية · Home — لا دفعة بعد': (_) =>
        const HomeScreen(preview: HomePreview.idle),
    'الرئيسية · Home — متوقَّع في الفرع': (_) =>
        const HomeScreen(preview: HomePreview.returning),
    'الرئيسية · Home — تمت التسوية': (_) =>
        const HomeScreen(preview: HomePreview.settled),
    'الاشعارات · Notifications': (_) => const NotificationsScreen(),
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
    'تفاصيل الطلب · Order detail (COD)': (_) => const OrderDetailScreen(),
    'تفاصيل الطلب · Order detail (مدفوع/prepaid)': (_) =>
        const OrderDetailScreen(cod: false),
    'استلام من الفرع · Pickup': (_) => const PickupScreen(),
    'نتيجة · Result — تم التسليم': (_) => const ResultScreen(kind: ResultKind.delivered),
    'نتيجة · Result — لم يتم التسليم': (_) => const ResultScreen(kind: ResultKind.failed),
    'نتيجة · Result — تأجيل': (_) => const ResultScreen(kind: ResultKind.postponed),
    'ورقة · COD 2a — تحصيل النقدية': (_) => SheetPreviewHost(
          label: 'تحصيل النقدية',
          open: (ctx) async => showCodCollectionSheet(
            ctx,
            due: 1200,
            orderNum: '89289',
            customerName: 'محمد حمدي',
          ),
        ),
    'ورقة · Handoff sheet': (_) =>
        SheetPreviewHost(label: 'تأكيد التسليم', open: showHandoffSheet),
    'ورقة · Postpone sheet': (_) =>
        SheetPreviewHost(label: 'تأجيل التسليم', open: showPostponeSheet),
    // Auth flow (Auth.dc.html 1a–1f). Login walks the whole reset flow
    // (login → forgot → code → new password → success) via internal pushes.
    // Failure States (Failure States.dc.html 1a–1g)
    'تعذّر · Failure flow (كامل)': (_) =>
        const FailureStatesHost(runFlow: true),
    'تعذّر · 1a — سبب عدم التسليم': (_) =>
        const FailureStatesHost(preview: FailureStatePreview.reason),
    'تعذّر · 1b — العميل غير متواجد': (_) =>
        const FailureStatesHost(preview: FailureStatePreview.notPresent),
    'تعذّر · 1c — عنوان خاطئ': (_) =>
        const FailureStatesHost(preview: FailureStatePreview.wrongAddress),
    'تعذّر · 1d — عدم تطابق المنتج': (_) =>
        const FailureStatesHost(preview: FailureStatePreview.productMismatch),
    'تعذّر · 1e — الإرجاع للفرع': (_) =>
        const FailureStatesHost(preview: FailureStatePreview.returnToBranch),
    'تعذّر · 1g — مرتجعات للفرع': (_) => const ReturnsListScreen(),
    'التسوية · Settlement (اليوم، حيّة)': (_) => const SettlementScreen(),
    'التسوية · Settlement (open)': (_) =>
        SettlementScreen(data: sampleSettlement),
    'التسوية · Settlement (settled)': (_) => SettlementScreen(
          data: sampleSettlement,
          startStage: SettlementStage.settled,
        ),
    'التسوية · يوم سابق (read-only)': (_) =>
        SettlementDayScreen(day: sampleSettlementHistory.first),
    'الرئيسية · Home 1b (Glance)': (_) => const HomeGlanceScreen(),
    'الرئيسية · Home 1c (Compact)': (_) => const HomeCompactScreen(),
    'الرئيسية · Home 2a (Flat)': (_) => const HomeFlatScreen(),
    'دخول · Auth 1a — تسجيل الدخول': (_) => const LoginScreen(),
    'نسيت · Auth 1b — نسيت كلمة المرور': (_) => const ForgotPasswordScreen(),
    'كود · Auth 1c — ادخل الكود': (_) => const CodeEntryScreen(),
    'جديدة · Auth 1d — كلمة مرور جديدة': (_) => const NewPasswordScreen(),
    'تغيير · Auth 1e — تغيير كلمة المرور': (_) => const ChangePasswordScreen(),
    'تم · Auth 1f — تم التغيير': (_) => const AuthSuccessScreen(),
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

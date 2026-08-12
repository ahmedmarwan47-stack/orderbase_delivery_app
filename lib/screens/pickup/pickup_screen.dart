import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/flow_order.dart';
import '../../icons/app_icon.dart';
import '../../theme/colors.dart';
import '../../theme/radius.dart';
import '../../theme/shadows.dart';
import '../../theme/spacing.dart';
import '../../widgets/home_indicator.dart';

/// Pickup — Order Flow step 0 (Order Flow.dc.html, `isPickup`): collecting a
/// batch of ready orders from the branch, confirmed in one action. No tab bar;
/// it's a focused task screen with a sticky confirm bar.
class PickupScreen extends StatelessWidget {
  const PickupScreen({super.key, this.onConfirm});

  /// Confirms pickup (all orders → "in transit"). Wired to the flow later.
  final VoidCallback? onConfirm;

  /// The active orders waiting at the branch, ordered by number to match the
  /// mockup (#89289, #89290, #89291).
  static final List<FlowOrder> _orders = sampleFlowOrders
      .where((o) => o.state == FlowOrderState.active)
      .toList()
    ..sort((a, b) => a.num.compareTo(b.num));

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _header(context),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s20, AppSpacing.s16, AppSpacing.s20, AppSpacing.s20),
                  itemCount: _orders.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s12),
                  itemBuilder: (_, i) => _PickupCard(order: _orders[i]),
                ),
              ),
              _confirmBar(),
              const HomeIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.s20, AppSpacing.s8, AppSpacing.s20, AppSpacing.s16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.borderHeader)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.s8),
              child: Row(
                children: [
                  AppIcon(AppIconName.chevronRight, color: AppColors.textTertiary, size: 18),
                  SizedBox(width: AppSpacing.s8),
                  Text('الرجوع',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textTertiary)),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.r13),
                child: SvgPicture.asset('assets/images/sale_sucre.svg', width: 48, height: 48),
              ),
              const SizedBox(width: AppSpacing.s12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('استلام من الفرع',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  SizedBox(height: AppSpacing.s4),
                  Text('Sale Sucre · فرع مدينة نصر',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          Container(
            padding: const EdgeInsets.all(AppSpacing.s12),
            decoration: BoxDecoration(
              color: AppColors.heroCodPillBg,
              borderRadius: BorderRadius.circular(AppRadius.r12),
              border: Border.all(color: AppColors.pickupBannerBorder),
            ),
            child: Row(
              children: const [
                AppIcon(AppIconName.bag, color: AppColors.postponedText, size: 18),
                SizedBox(width: AppSpacing.s8),
                Expanded(
                  child: Text(
                    '3 طلبات جاهزة للاستلام — أكّد الاستلام مرة واحدة لكل الطلبات',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.pickupBannerText,
                        height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _confirmBar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderHeader)),
      ),
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.s20, AppSpacing.s16, AppSpacing.s20, AppSpacing.s12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: onConfirm,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.inkFill,
                borderRadius: BorderRadius.circular(15),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  AppIcon(AppIconName.check, color: Colors.white, size: 20),
                  SizedBox(width: AppSpacing.s8),
                  Text('تأكيد استلام الطلبات (3)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          const Text('بتأكيد الاستلام تتحول كل الطلبات إلى «في الطريق»',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _PickupCard extends StatelessWidget {
  const _PickupCard({required this.order});
  final FlowOrder order;

  @override
  Widget build(BuildContext context) {
    final payLabel = order.cod ? 'عند الاستلام' : 'مدفوع';
    final payFg = order.cod ? AppColors.postponedText : AppColors.deliveredText;
    final payBg = order.cod ? AppColors.heroCodPillBg : AppColors.deliveredBg;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r16),
        border: Border.all(color: AppColors.borderCardFaint),
        boxShadow: AppShadows.card,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 84,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.r12),
                child: Image.asset('assets/merchant/fudge-cake.jpg', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(order.num,
                          textDirection: TextDirection.ltr,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary)),
                      const SizedBox(width: AppSpacing.s8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s8, vertical: AppSpacing.s4),
                        decoration: BoxDecoration(
                            color: payBg, borderRadius: BorderRadius.circular(7)),
                        child: Text(payLabel,
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700, color: payFg)),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(order.name,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textBody)),
                  const SizedBox(height: AppSpacing.s4),
                  Text(order.meta,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

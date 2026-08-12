import 'package:flutter/material.dart';

import '../../data/flow_order.dart';
import '../../icons/app_icon.dart';
import '../../theme/colors.dart';
import '../../theme/radius.dart';
import '../../theme/shadows.dart';
import '../../theme/spacing.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/status_bar.dart';

/// Orders list — first step of the Order Flow (Order Flow.dc.html, `isOrders`).
/// Header + filter chips + order cards. The filter is local state.
class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key, this.onOpenOrder, this.onSelectTab});

  /// Called when an order card is tapped (opens the detail step).
  final ValueChanged<FlowOrder>? onOpenOrder;

  /// Forwarded to the bottom nav so the app shell can switch tabs.
  final ValueChanged<NavTab>? onSelectTab;

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

enum _Filter { all, active, done }

class _OrdersListScreenState extends State<OrdersListScreen> {
  _Filter _filter = _Filter.all;

  List<FlowOrder> get _visible {
    switch (_filter) {
      case _Filter.all:
        return sampleFlowOrders;
      case _Filter.active:
        return sampleFlowOrders
            .where((o) => o.state == FlowOrderState.active)
            .toList();
      case _Filter.done:
        return sampleFlowOrders
            .where((o) =>
                o.state == FlowOrderState.done || o.state == FlowOrderState.failed)
            .toList();
    }
  }

  int _count(_Filter f) {
    switch (f) {
      case _Filter.all:
        return sampleFlowOrders.length;
      case _Filter.active:
        return sampleFlowOrders.where((o) => o.state == FlowOrderState.active).length;
      case _Filter.done:
        return sampleFlowOrders
            .where((o) =>
                o.state == FlowOrderState.done || o.state == FlowOrderState.failed)
            .length;
    }
  }

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
              const StatusBar(),
              _header(),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s20, AppSpacing.s16, AppSpacing.s20, AppSpacing.s20),
                  itemCount: _visible.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s12),
                  itemBuilder: (_, i) => _OrderCard(
                    order: _visible[i],
                    onTap: () => widget.onOpenOrder?.call(_visible[i]),
                  ),
                ),
              ),
              BottomNav(
                  active: NavTab.orders,
                  notificationsBadge: true,
                  onTap: widget.onSelectTab),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('طلبات اليوم',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary)),
                  SizedBox(height: AppSpacing.s4),
                  Text('١٣ سبتمبر · 17 طلبًا',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                ],
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(AppRadius.r12),
                ),
                child: const Center(
                  child: AppIcon(AppIconName.search, color: AppColors.textPrimary, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          Row(
            children: [
              _FilterChip(
                label: 'الكل',
                count: _count(_Filter.all),
                selected: _filter == _Filter.all,
                onTap: () => setState(() => _filter = _Filter.all),
              ),
              const SizedBox(width: AppSpacing.s8),
              _FilterChip(
                label: 'قيد التنفيذ',
                count: _count(_Filter.active),
                selected: _filter == _Filter.active,
                onTap: () => setState(() => _filter = _Filter.active),
              ),
              const SizedBox(width: AppSpacing.s8),
              _FilterChip(
                label: 'منجزة',
                count: _count(_Filter.done),
                selected: _filter == _Filter.done,
                onTap: () => setState(() => _filter = _Filter.done),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
        decoration: BoxDecoration(
          color: selected ? AppColors.inkFill : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? AppColors.inkFill : AppColors.borderDefault),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.textTertiary,
              ),
            ),
            const SizedBox(width: AppSpacing.s8),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.chipCountMuted,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onTap});

  final FlowOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Pay pill is derived purely from the COD flag, matching the mockup.
    final payLabel = order.cod ? 'عند الاستلام' : 'مدفوع';
    final payFg = order.cod ? AppColors.postponedText : AppColors.deliveredText;
    final payBg = order.cod ? AppColors.heroCodPillBg : AppColors.deliveredBg;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r16),
        border: Border.all(color: AppColors.borderCard),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.r12),
                  child: Image.asset('assets/merchant/fudge-cake.jpg',
                      width: 88, height: 88, fit: BoxFit.cover),
                ),
                const SizedBox(width: AppSpacing.s16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: AppSpacing.s8,
                        runSpacing: AppSpacing.s4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(order.num,
                              textDirection: TextDirection.ltr,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary)),
                          _PayPill(label: payLabel, fg: payFg, bg: payBg),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      Text(order.name,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: AppSpacing.s4),
                      Text(order.meta,
                          style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (order.cod) ...[
            const SizedBox(height: AppSpacing.s12),
            Container(
              padding: const EdgeInsets.only(top: AppSpacing.s12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.surfaceSubtle)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('المطلوب تحصيله نقدًا',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  Text('${order.amount} جم',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          fontFeatures: [FontFeature.tabularFigures()])),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PayPill extends StatelessWidget {
  const _PayPill({required this.label, required this.fg, required this.bg});

  final String label;
  final Color fg;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: AppSpacing.s4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(7)),
      child: Text(label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

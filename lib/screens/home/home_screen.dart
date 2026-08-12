import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../icons/app_icon.dart';
import '../../theme/colors.dart';
import '../../theme/radius.dart';
import '../../theme/shadows.dart';
import '../../theme/spacing.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/map_view.dart';
import '../../widgets/status_bar.dart';

/// Home / الرئيسية — design option 1a ("Airy": next-stop hero + 2×2 stats).
/// Ported from Home Directions.dc.html (#1a).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
              const StatusBar(background: AppColors.background),
              const _MerchantHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s20, AppSpacing.s4, AppSpacing.s20, AppSpacing.s20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: const [
                      _NextStopCard(),
                      SizedBox(height: AppSpacing.s20),
                      _TodayStats(),
                    ],
                  ),
                ),
              ),
              const BottomNav(active: NavTab.home, notificationsBadge: true),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────── Header ────────────────────────────────

class _MerchantHeader extends StatelessWidget {
  const _MerchantHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.s20, AppSpacing.s12, AppSpacing.s20, AppSpacing.s16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.r13),
                child: SvgPicture.asset('assets/images/sale_sucre.svg',
                    width: 46, height: 46),
              ),
              const SizedBox(width: AppSpacing.s12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('محمد عبدالرحمن',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  SizedBox(height: AppSpacing.s4),
                  Text('Sale Sucre',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
          _SquareIconButton(
            icon: AppIconName.search,
            iconColor: AppColors.textPrimary,
            size: 40,
            iconSize: 20,
            background: AppColors.surface,
            border: const Color(0x12000000), // rgba(0,0,0,.07)
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────── Next-stop card ──────────────────────────

class _NextStopCard extends StatelessWidget {
  const _NextStopCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderCardFaint),
        boxShadow: AppShadows.heroCard,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // header
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20, AppSpacing.s16, AppSpacing.s20, AppSpacing.s12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    AppIcon(AppIconName.nav, color: AppColors.brand, size: 18),
                    SizedBox(width: AppSpacing.s8),
                    Text('الوجهة التالية',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s4),
                  decoration: BoxDecoration(
                    color: AppColors.failedBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('المحطة 2 من 5',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.stopCountText)),
                ),
              ],
            ),
          ),
          // progress
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20, 0, AppSpacing.s20, AppSpacing.s16),
            child: Row(
              children: const [
                _ProgressSeg(AppColors.greenAccent),
                SizedBox(width: AppSpacing.s8),
                _ProgressSeg(AppColors.brand),
                SizedBox(width: AppSpacing.s8),
                _ProgressSeg(AppColors.borderDefault),
                SizedBox(width: AppSpacing.s8),
                _ProgressSeg(AppColors.borderDefault),
                SizedBox(width: AppSpacing.s8),
                _ProgressSeg(AppColors.borderDefault),
              ],
            ),
          ),
          // map strip
          const MapView(height: 96, showHairlines: true),
          // order info
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20, AppSpacing.s16, AppSpacing.s20, AppSpacing.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('طلب ‏#89289',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            fontFeatures: [FontFeature.tabularFigures()])),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s12, vertical: AppSpacing.s4),
                      decoration: BoxDecoration(
                        color: AppColors.heroCodPillBg,
                        borderRadius: BorderRadius.circular(AppRadius.r8),
                      ),
                      child: const Text('الدفع عند الاستلام',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.postponedText)),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s8),
                const Text('محمد حمدي',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: AppSpacing.s8),
                Row(
                  children: const [
                    AppIcon(AppIconName.pin, color: AppColors.brand, size: 16),
                    SizedBox(width: AppSpacing.s8),
                    Text('زهراء مدينة نصر — القاهرة',
                        style: TextStyle(fontSize: 14, color: AppColors.textTertiary, height: 1.5)),
                  ],
                ),
                const SizedBox(height: AppSpacing.s8),
                Row(
                  children: [
                    Row(
                      children: const [
                        AppIcon(AppIconName.clock, color: AppColors.textTertiary, size: 15),
                        SizedBox(width: AppSpacing.s4),
                        Text('خلال 15 دقيقة',
                            style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                      ],
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                          color: AppColors.textSecondary, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    const Text('1.2 كم',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                            fontFeatures: [FontFeature.tabularFigures()])),
                  ],
                ),
              ],
            ),
          ),
          // actions
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20, AppSpacing.s16, AppSpacing.s20, AppSpacing.s16),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.inkFill,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('عرض الطلب',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                          SizedBox(width: AppSpacing.s8),
                          AppIcon(AppIconName.chevronLeft, color: Colors.white, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                _SquareIconButton(
                  icon: AppIconName.phone,
                  iconColor: AppColors.brand,
                  size: 52,
                  iconSize: 21,
                  radius: 15,
                  background: AppColors.surface,
                  border: AppColors.brand,
                  borderWidth: 1.5,
                ),
                const SizedBox(width: AppSpacing.s12),
                _SquareIconButton(
                  icon: AppIconName.chat,
                  iconColor: AppColors.greenAccent,
                  size: 52,
                  iconSize: 21,
                  radius: 15,
                  background: AppColors.deliveredBg,
                  border: AppColors.deliveredBorder,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressSeg extends StatelessWidget {
  const _ProgressSeg(this.color);
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 6,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
      ),
    );
  }
}

// ─────────────────────────────── Stats ─────────────────────────────────

class _TodayStats extends StatelessWidget {
  const _TodayStats();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('نظرة عامة اليوم',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textTertiary)),
        const SizedBox(height: AppSpacing.s12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              Expanded(
                child: _StatCard(
                  icon: AppIconName.bike,
                  iconColor: AppColors.textPrimary,
                  tile: AppColors.iconTileNeutral,
                  value: '10',
                  label: 'قيد التنفيذ',
                ),
              ),
              SizedBox(width: AppSpacing.s12),
              Expanded(
                child: _StatCard(
                  icon: AppIconName.check,
                  iconColor: AppColors.greenAccent,
                  tile: AppColors.deliveredBg,
                  value: '05',
                  label: 'تم التوصيل',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              Expanded(
                child: _StatCard(
                  icon: AppIconName.fail,
                  iconColor: AppColors.brand,
                  tile: AppColors.failedBg,
                  value: '02',
                  label: 'تعذر التسليم',
                ),
              ),
              SizedBox(width: AppSpacing.s12),
              Expanded(
                child: _StatCard(
                  icon: AppIconName.cash,
                  iconColor: AppColors.greenAccent,
                  tile: AppColors.deliveredBg,
                  value: '22,500',
                  valueSuffix: ' جم',
                  valueColor: AppColors.greenAccent,
                  valueSize: 24,
                  label: 'إجمالي التحصيل',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.tile,
    required this.value,
    required this.label,
    this.valueSuffix,
    this.valueColor = AppColors.textPrimary,
    this.valueSize = 28,
  });

  final AppIconName icon;
  final Color iconColor;
  final Color tile;
  final String value;
  final String? valueSuffix;
  final Color valueColor;
  final double valueSize;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderCardFaint),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: tile, borderRadius: BorderRadius.circular(AppRadius.r12)),
            child: Center(child: AppIcon(icon, color: iconColor, size: 22)),
          ),
          const SizedBox(height: AppSpacing.s12),
          Text.rich(
            TextSpan(
              text: value,
              style: TextStyle(
                fontSize: valueSize,
                fontWeight: FontWeight.w800,
                color: valueColor,
                height: 1,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              children: valueSuffix == null
                  ? null
                  : [
                      TextSpan(
                        text: valueSuffix,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ],
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ─────────────────────────── shared bits ───────────────────────────────

class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({
    required this.icon,
    required this.iconColor,
    required this.size,
    required this.iconSize,
    required this.background,
    this.border,
    this.borderWidth = 1,
    this.radius = AppRadius.r12,
  });

  final AppIconName icon;
  final Color iconColor;
  final double size;
  final double iconSize;
  final Color background;
  final Color? border;
  final double borderWidth;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
        border: border != null ? Border.all(color: border!, width: borderWidth) : null,
      ),
      child: Center(child: AppIcon(icon, color: iconColor, size: iconSize)),
    );
  }
}

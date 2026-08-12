import 'package:flutter/material.dart';

import '../../icons/app_icon.dart';
import '../../theme/colors.dart';
import '../../theme/radius.dart';
import '../../theme/spacing.dart';
import '../../widgets/home_indicator.dart';
import '../../widgets/status_bar.dart';

/// The three outcomes of a delivery attempt, shown on the result screen.
enum ResultKind { delivered, failed, postponed }

/// Result — Order Flow terminal step (Order Flow.dc.html, `isResult`).
/// A centered outcome screen with a tinted badge, a summary card whose last
/// row is variant-specific, and two follow-up actions. Defaults match the
/// mockup's sample data for order #89289.
class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    this.kind = ResultKind.delivered,
    this.orderNum = '#89289',
    this.customer = 'Mohmaed Hamdy',
    this.codAmount = '1,200 جم',
    this.showWalletChange = true,
    this.walletChange = '+50 جم',
    this.reasonLabel = 'العميل غير متواجد',
    this.postponeDisplay = '13 سبتمبر · 4:00 م',
    this.onContinue,
    this.onHome,
  });

  final ResultKind kind;
  final String orderNum;
  final String customer;
  final String codAmount;
  final bool showWalletChange;
  final String walletChange;
  final String reasonLabel;
  final String postponeDisplay;
  final VoidCallback? onContinue;
  final VoidCallback? onHome;

  Color get _tint => switch (kind) {
        ResultKind.delivered => AppColors.greenAccent,
        ResultKind.postponed => AppColors.postponedText,
        ResultKind.failed => AppColors.brand,
      };

  Color get _tintBg => switch (kind) {
        ResultKind.delivered => AppColors.deliveredBg,
        ResultKind.postponed => AppColors.heroCodPillBg,
        ResultKind.failed => AppColors.failedBg,
      };

  AppIconName get _icon => switch (kind) {
        ResultKind.delivered => AppIconName.check,
        ResultKind.postponed => AppIconName.clock,
        ResultKind.failed => AppIconName.fail,
      };

  String get _title => switch (kind) {
        ResultKind.delivered => 'تم التسليم بنجاح',
        ResultKind.postponed => 'تم تأجيل الطلب',
        ResultKind.failed => 'تم تسجيل عدم التسليم',
      };

  String get _sub => switch (kind) {
        ResultKind.delivered => 'تم إغلاق الطلب وإضافته إلى تحصيلات اليوم.',
        ResultKind.postponed => 'يبقى الطلب معك وتُعيد المحاولة في وقت لاحق اليوم.',
        ResultKind.failed => 'يعود المنتج إلى الفرع — نتيجة نهائية.',
      };

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const StatusBar(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(color: _tintBg, shape: BoxShape.circle),
                          child: Center(child: AppIcon(_icon, color: _tint, size: 52)),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s20),
                      Text(_title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      const SizedBox(height: AppSpacing.s8),
                      Text(_sub,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 14, color: AppColors.textSecondary, height: 1.6)),
                      const SizedBox(height: AppSpacing.s20),
                      _summaryCard(),
                    ],
                  ),
                ),
              ),
              _actions(context),
              const HomeIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.r16),
        border: Border.all(color: AppColors.borderHeader),
      ),
      child: Column(
        children: [
          _row('رقم الطلب', orderNum,
              valueLtr: true, valueWeight: FontWeight.w800),
          const SizedBox(height: AppSpacing.s12),
          _row('العميل', customer, valueLtr: true, valueWeight: FontWeight.w700),
          ..._variantRows(),
        ],
      ),
    );
  }

  List<Widget> _variantRows() {
    switch (kind) {
      case ResultKind.delivered:
        return [
          _dividerRow('تم تحصيله نقدًا', codAmount,
              valueColor: AppColors.deliveredText,
              valueSize: 16,
              valueWeight: FontWeight.w800,
              tabular: true),
          if (showWalletChange) ...[
            const SizedBox(height: AppSpacing.s12),
            _row('فكة للمحفظة', walletChange,
                valueColor: AppColors.postponedText, valueWeight: FontWeight.w700, tabular: true),
          ],
        ];
      case ResultKind.failed:
        return [
          _dividerRow('السبب', reasonLabel,
              valueColor: AppColors.dangerAccent, valueWeight: FontWeight.w700),
        ];
      case ResultKind.postponed:
        return [
          _dividerRow('الموعد الجديد', postponeDisplay,
              valueColor: AppColors.postponedText, valueWeight: FontWeight.w700),
        ];
    }
  }

  Widget _dividerRow(String label, String value,
      {required Color valueColor,
      double valueSize = 14,
      FontWeight valueWeight = FontWeight.w700,
      bool tabular = false}) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.s12),
      padding: const EdgeInsets.only(top: AppSpacing.s12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.summaryDivider)),
      ),
      child: _row(label, value,
          valueColor: valueColor, valueSize: valueSize, valueWeight: valueWeight, tabular: tabular),
    );
  }

  Widget _row(String label, String value,
      {Color valueColor = AppColors.textPrimary,
      double valueSize = 14,
      FontWeight valueWeight = FontWeight.w700,
      bool valueLtr = false,
      bool tabular = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        Text(value,
            textDirection: valueLtr ? TextDirection.ltr : null,
            style: TextStyle(
              fontSize: valueSize,
              fontWeight: valueWeight,
              color: valueColor,
              fontFeatures: tabular ? const [FontFeature.tabularFigures()] : null,
            )),
      ],
    );
  }

  Widget _actions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: onContinue,
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.inkFill,
                borderRadius: BorderRadius.circular(15),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  AppIcon(AppIconName.nav, color: Colors.white, size: 19),
                  SizedBox(width: AppSpacing.s8),
                  Text('متابعة المسار — المحطة التالية',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          GestureDetector(
            onTap: onHome ?? () => Navigator.of(context).maybePop(),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.borderDefault),
              ),
              alignment: Alignment.center,
              child: const Text('العودة للرئيسية',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textTertiary)),
            ),
          ),
        ],
      ),
    );
  }
}

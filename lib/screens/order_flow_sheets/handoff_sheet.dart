import 'package:flutter/material.dart';

import '../../icons/app_icon.dart';
import '../../theme/colors.dart';
import '../../theme/radius.dart';
import '../../theme/spacing.dart';
import '../../widgets/app_sheet.dart';

/// Handoff sheet (Order Flow.dc.html, `showHandoff`): capture a delivery photo,
/// confirm the collected cash, optionally move the change to the wallet, then
/// confirm. Returns `true` when delivery is confirmed.
Future<bool?> showHandoffSheet(BuildContext context) {
  return showAppSheet<bool>(context, child: const _HandoffSheet());
}

class _HandoffSheet extends StatefulWidget {
  const _HandoffSheet();

  @override
  State<_HandoffSheet> createState() => _HandoffSheetState();
}

class _HandoffSheetState extends State<_HandoffSheet> {
  bool _photo = false;
  bool _wallet = true;

  @override
  Widget build(BuildContext context) {
    return SheetShell(
      title: 'تأكيد التسليم',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text.rich(
            const TextSpan(
              text: 'الطلب ',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              children: [
                TextSpan(
                    text: '#89289',
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textTertiary)),
                TextSpan(text: ' — محمد حمدي'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          Text.rich(
            const TextSpan(
              text: 'صورة التسليم ',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              children: [
                TextSpan(text: '*', style: TextStyle(color: AppColors.dangerAccent)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          _photo ? _capturedPhoto() : _capturePrompt(),
          const SizedBox(height: AppSpacing.s16),
          _codCard(),
          const SizedBox(height: AppSpacing.s16),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(true),
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
                  Text('تأكيد التسليم',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _capturePrompt() {
    return GestureDetector(
      onTap: () => setState(() => _photo = true),
      child: Container(
        height: 141,
        decoration: BoxDecoration(
          color: AppColors.photoDashBg,
          borderRadius: BorderRadius.circular(AppRadius.r16),
          border: Border.all(color: AppColors.dashedBorder, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.photoTile,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(child: AppIcon(AppIconName.cam, color: AppColors.textTertiary, size: 26)),
            ),
            const SizedBox(height: AppSpacing.s4),
            const Text('التقاط صورة التسليم',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const Text('مطلوبة لإتمام التسليم',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _capturedPhoto() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.r16),
      child: SizedBox(
        height: 130,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/merchant/fudge-cake.jpg', fit: BoxFit.cover),
            const ColoredBox(color: AppColors.photoGreenWash),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(color: AppColors.greenAccent, shape: BoxShape.circle),
                child: const Center(child: AppIcon(AppIconName.check, color: Colors.white, size: 17)),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              child: GestureDetector(
                onTap: () => setState(() => _photo = true),
                child: Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
                  decoration: BoxDecoration(
                    color: AppColors.scrim,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      AppIcon(AppIconName.cam, color: Colors.white, size: 14),
                      SizedBox(width: AppSpacing.s8),
                      Text('إعادة الالتقاط',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _codCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.r16),
        border: Border.all(color: AppColors.borderHeader),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('المطلوب تحصيله', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              Text('1,200 جم',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      fontFeatures: [FontFeature.tabularFigures()])),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('المبلغ المُحصّل',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: AppColors.inkFill, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('1,250',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            fontFeatures: [FontFeature.tabularFigures()])),
                    SizedBox(width: AppSpacing.s8),
                    Text('جم', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.s16),
            padding: const EdgeInsets.only(top: AppSpacing.s12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.summaryDivider)),
            ),
            child: GestureDetector(
              onTap: () => setState(() => _wallet = !_wallet),
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Row(
                      children: [
                        AppIcon(AppIconName.wallet, color: AppColors.postponedText, size: 18),
                        SizedBox(width: AppSpacing.s8),
                        Flexible(
                          child: Text('إضافة الفكة (50 جم) للمحفظة',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textBody)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  _WalletToggle(on: _wallet),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletToggle extends StatelessWidget {
  const _WalletToggle({required this.on});
  final bool on;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: on ? AppColors.greenAccent : AppColors.dashedBorder,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        // flex-end (mockup "on") maps to the end of the RTL row.
        mainAxisAlignment: on ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            width: 21,
            height: 21,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Color(0x33000000), offset: Offset(0, 1), blurRadius: 2)],
            ),
          ),
        ],
      ),
    );
  }
}

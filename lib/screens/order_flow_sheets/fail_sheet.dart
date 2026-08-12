import 'package:flutter/material.dart';

import '../../icons/app_icon.dart';
import '../../theme/colors.dart';
import '../../theme/radius.dart';
import '../../theme/spacing.dart';
import '../../widgets/app_sheet.dart';

/// Outcome of the fail sheet.
enum FailResult { failed, postpone }

/// Fail sheet (Order Flow.dc.html, `showFail`): pick a non-delivery reason,
/// add a note, then either record the failure or hand off to the postpone
/// sheet. Returns the chosen [FailResult].
Future<FailResult?> showFailSheet(BuildContext context) {
  return showAppSheet<FailResult>(context, child: const _FailSheet());
}

const _reasons = <String>[
  'العميل غير متواجد',
  'العميل رفض الاستلام',
  'عدم تطابق المنتج',
  'عنوان خاطئ',
  'زحام مروري أو تأخير',
  'سبب آخر',
];

class _FailSheet extends StatefulWidget {
  const _FailSheet();

  @override
  State<_FailSheet> createState() => _FailSheetState();
}

class _FailSheetState extends State<_FailSheet> {
  int _selected = 0; // defaults to "العميل غير متواجد"

  @override
  Widget build(BuildContext context) {
    return SheetShell(
      title: 'سبب عدم التسليم',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < _reasons.length; i++) ...[
            _reasonRow(i),
            if (i != _reasons.length - 1) const SizedBox(height: AppSpacing.s8),
          ],
          const SizedBox(height: AppSpacing.s16),
          const Text('ملاحظة (إلزامية)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.s8),
          Container(
            constraints: const BoxConstraints(minHeight: 58),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.r13),
              border: Border.all(color: AppColors.borderHeader),
            ),
            child: const Text('اكتب تفاصيل ما حدث…',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          ),
          const SizedBox(height: AppSpacing.s16 + AppSpacing.s4),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(FailResult.failed),
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.dangerAccent,
                borderRadius: BorderRadius.circular(15),
              ),
              alignment: Alignment.center,
              child: const Text('تسجيل عدم التسليم',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(FailResult.postpone),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.borderDefault, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  AppIcon(AppIconName.clock, color: AppColors.postponedText, size: 18),
                  SizedBox(width: AppSpacing.s8),
                  Text('تأجيل لوقت لاحق اليوم',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reasonRow(int i) {
    final selected = _selected == i;
    return GestureDetector(
      onTap: () => setState(() => _selected = i),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: selected ? AppColors.failedBg : AppColors.reasonRowBg,
          borderRadius: BorderRadius.circular(AppRadius.r14),
          border: Border.all(
              color: selected ? AppColors.brand : AppColors.borderHeader, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: selected ? AppColors.brand : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                    color: selected ? AppColors.brand : AppColors.reasonDotBorder, width: 2),
              ),
              child: selected
                  ? const Center(child: AppIcon(AppIconName.check, color: Colors.white, size: 13))
                  : null,
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Text(_reasons[i],
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            ),
          ],
        ),
      ),
    );
  }
}

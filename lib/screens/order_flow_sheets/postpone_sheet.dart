import 'package:flutter/material.dart';

import '../../icons/app_icon.dart';
import '../../theme/colors.dart';
import '../../theme/radius.dart';
import '../../theme/spacing.dart';
import '../../widgets/app_sheet.dart';

/// Outcome of the postpone sheet.
enum PostponeResult { confirm, back }

/// Postpone sheet (Order Flow.dc.html, `showPostpone`): pick a new date/time
/// (with quick-slot shortcuts) for a later re-attempt. The back arrow returns
/// to the fail sheet. Returns [PostponeResult].
Future<PostponeResult?> showPostponeSheet(BuildContext context) {
  return showAppSheet<PostponeResult>(context, child: const _PostponeSheet());
}

const _months = [
  'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
  'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
];

class _PostponeSheet extends StatefulWidget {
  const _PostponeSheet();

  @override
  State<_PostponeSheet> createState() => _PostponeSheetState();
}

class _PostponeSheetState extends State<_PostponeSheet> {
  DateTime _date = DateTime(2024, 9, 13);
  TimeOfDay _time = const TimeOfDay(hour: 16, minute: 0);

  String get _dateLabel => '${_date.day} ${_months[_date.month - 1]} ${_date.year}';

  String get _timeLabel {
    final h = _time.hourOfPeriod == 0 ? 12 : _time.hourOfPeriod;
    final m = _time.minute.toString().padLeft(2, '0');
    final ap = _time.period == DayPeriod.am ? 'ص' : 'م';
    return '$h:$m $ap';
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2024),
      lastDate: DateTime(2026),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _time);
    if (t != null) setState(() => _time = t);
  }

  @override
  Widget build(BuildContext context) {
    return SheetShell(
      title: 'تأجيل التسليم',
      onBack: () => Navigator.of(context).pop(PostponeResult.back),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('حدّد الموعد الجديد الذي طلبه العميل لإعادة التوصيل',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.s16),
          Row(
            children: [
              _quickSlot('بعد ساعة', const TimeOfDay(hour: 13, minute: 30)),
              const SizedBox(width: AppSpacing.s8),
              _quickSlot('بعد ساعتين', const TimeOfDay(hour: 14, minute: 30)),
              const SizedBox(width: AppSpacing.s8),
              _quickSlot('٦:٠٠ م', const TimeOfDay(hour: 18, minute: 0)),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          const Text('التاريخ',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: AppSpacing.s8),
          _field(icon: AppIconName.note, value: _dateLabel, onTap: _pickDate),
          const SizedBox(height: AppSpacing.s16),
          const Text('الوقت',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: AppSpacing.s8),
          _field(icon: AppIconName.clock, value: _timeLabel, onTap: _pickTime),
          const SizedBox(height: AppSpacing.s24),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(PostponeResult.confirm),
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
                  AppIcon(AppIconName.clock, color: Colors.white, size: 20),
                  SizedBox(width: AppSpacing.s8),
                  Text('تأكيد التأجيل',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickSlot(String label, TimeOfDay time) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _time = time),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.r12),
            border: Border.all(color: AppColors.borderHeader),
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ),
      ),
    );
  }

  Widget _field({required AppIconName icon, required String value, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.r13),
          border: Border.all(color: AppColors.borderHeader),
        ),
        child: Row(
          children: [
            AppIcon(icon, color: AppColors.postponedText, size: 18),
            const SizedBox(width: AppSpacing.s8),
            Text(value,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

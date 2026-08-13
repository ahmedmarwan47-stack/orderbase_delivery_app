part of '../imports/order_flow_imports.dart';

/// Ephemeral state for the postpone sheet: the chosen re-attempt date and time,
/// plus the labels derived from them. No `setState`.
class PostponeSheetController {
  PostponeSheetController()
      : date = ValueNotifier(DateTime(2024, 9, 13)),
        time = ValueNotifier(const TimeOfDay(hour: 16, minute: 0)),
        selectedSlot = ValueNotifier<int?>(null);

  final ValueNotifier<DateTime> date;
  final ValueNotifier<TimeOfDay> time;

  /// Which quick-slot chip is active (0/1/2), or `null` when the date/time was
  /// picked manually. The chips and a manual pick are mutually exclusive.
  final ValueNotifier<int?> selectedSlot;

  // Arabic month names used only to format the date label (locale formatting
  // data, not UI copy).
  static const List<String> _months = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  String get dateLabel {
    final d = date.value;
    return '${d.day} ${_months[d.month - 1]} ${d.year}';
  }

  /// Compact date (no year) used for the result summary, e.g. "13 سبتمبر".
  String get shortDateLabel {
    final d = date.value;
    return '${d.day} ${_months[d.month - 1]}';
  }

  /// The re-attempt slot as shown on the result screen, e.g. "13 سبتمبر · 4:00 م".
  String get display => '$shortDateLabel · $timeLabel';

  String get timeLabel {
    final t = time.value;
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final ap = t.period == DayPeriod.am
        ? LocaleKeys.postponeAm.tr()
        : LocaleKeys.postponePm.tr();
    return '$h:$m $ap';
  }

  /// Selects a quick-slot chip and syncs [date]/[time] to it, computed live off
  /// `DateTime.now()`: 0 → in an hour, 1 → in two hours, 2 → today at 6:00 م.
  void selectSlot(int index) {
    final now = DateTime.now();
    final DateTime target;
    switch (index) {
      case 0:
        target = now.add(const Duration(hours: 1));
      case 1:
        target = now.add(const Duration(hours: 2));
      default:
        target = DateTime(now.year, now.month, now.day, 18, 0);
    }
    date.value = DateTime(target.year, target.month, target.day);
    time.value = TimeOfDay(hour: target.hour, minute: target.minute);
    selectedSlot.value = index;
  }

  Future<void> pickDate(BuildContext context) async {
    final d = await showDatePicker(
      context: context,
      initialDate: date.value,
      firstDate: DateTime(2024),
      lastDate: DateTime(2026),
    );
    if (d != null) {
      date.value = d;
      selectedSlot.value = null; // a manual pick clears the quick-slot chips
    }
  }

  Future<void> pickTime(BuildContext context) async {
    final t = await showTimePicker(context: context, initialTime: time.value);
    if (t != null) {
      time.value = t;
      selectedSlot.value = null; // a manual pick clears the quick-slot chips
    }
  }

  void dispose() {
    date.dispose();
    time.dispose();
    selectedSlot.dispose();
  }
}

import 'package:tallyvel/core/time/calendar_date.dart';

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Writes [date] for a person: `30 Nov 2026`.
String formatDate(CalendarDate date) =>
    '${date.day} ${_months[date.month - 1]} ${date.year}';

import 'package:flutter_test/flutter_test.dart';
import 'package:tallyvel/core/time/calendar_date.dart';
import 'package:tallyvel/core/time/format_date.dart';

void main() {
  test('writes day, month name and year', () {
    expect(formatDate(CalendarDate(2026, 11, 30)), '30 Nov 2026');
    expect(formatDate(CalendarDate(2027, 1, 5)), '5 Jan 2027');
  });
}

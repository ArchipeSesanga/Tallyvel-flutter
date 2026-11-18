import 'package:flutter_test/flutter_test.dart';
import 'package:tallyvel/core/time/calendar_date.dart';

void main() {
  group('parse', () {
    test('reads the API format and writes it back unchanged', () {
      final date = CalendarDate.parse('2026-11-30');
      expect((date.year, date.month, date.day), (2026, 11, 30));
      expect(date.toString(), '2026-11-30');
    });

    test('rejects a day that does not exist', () {
      expect(CalendarDate.tryParse('2026-11-31'), isNull);
      expect(CalendarDate.tryParse('2026-02-29'), isNull); // not a leap year
      expect(CalendarDate.tryParse('2028-02-29'), isNotNull); // a leap year
      expect(() => CalendarDate(2026, 13, 1), throwsArgumentError);
    });

    test('rejects anything that is not YYYY-MM-DD', () {
      for (final bad in [
        '',
        '2026-1-5',
        '2026-11-30T00:00:00Z',
        '30/11/2026',
        ' 2026-11-30',
      ]) {
        expect(CalendarDate.tryParse(bad), isNull, reason: '"$bad"');
      }
      expect(() => CalendarDate.parse('nope'), throwsFormatException);
    });
  });

  group('inSouthAfrica', () {
    test('22:30 UTC on 31 October is already 1 November in Johannesburg', () {
      final instant = DateTime.utc(2026, 10, 31, 22, 30);
      expect(CalendarDate.inSouthAfrica(instant), CalendarDate(2026, 11, 1));
    });

    test('21:59 UTC is still the same day; 22:00 UTC is the next', () {
      expect(
        CalendarDate.inSouthAfrica(DateTime.utc(2026, 10, 31, 21, 59)),
        CalendarDate(2026, 10, 31),
      );
      expect(
        CalendarDate.inSouthAfrica(DateTime.utc(2026, 10, 31, 22)),
        CalendarDate(2026, 11, 1),
      );
    });

    test('the device time zone makes no difference', () {
      // A local DateTime for the same instant gives the same South African day.
      final utc = DateTime.utc(2026, 10, 31, 22, 30);
      expect(
        CalendarDate.inSouthAfrica(utc.toLocal()),
        CalendarDate.inSouthAfrica(utc),
      );
    });
  });

  group('comparing', () {
    test('equal dates are equal and hash alike', () {
      expect(CalendarDate(2026, 11, 30), CalendarDate.parse('2026-11-30'));
      expect(
        CalendarDate(2026, 11, 30).hashCode,
        CalendarDate.parse('2026-11-30').hashCode,
      );
    });

    test('counts days across month and year ends', () {
      expect(
        CalendarDate(2026, 11, 17).daysUntil(CalendarDate(2026, 11, 30)),
        13,
      );
      expect(CalendarDate(2026, 12, 31).daysUntil(CalendarDate(2027, 1, 1)), 1);
      expect(
        CalendarDate(2026, 11, 30).daysUntil(CalendarDate(2026, 11, 17)),
        -13,
      );
    });

    test('orders by day', () {
      final dates = [
        CalendarDate(2026, 12, 1),
        CalendarDate(2026, 11, 30),
        CalendarDate(2026, 11, 1),
      ]..sort();
      expect(dates.map((d) => d.toString()), [
        '2026-11-01',
        '2026-11-30',
        '2026-12-01',
      ]);
      expect(
        CalendarDate(2026, 11, 1).isBefore(CalendarDate(2026, 11, 2)),
        isTrue,
      );
    });
  });
}

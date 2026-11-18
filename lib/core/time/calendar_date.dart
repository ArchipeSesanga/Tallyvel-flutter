import 'package:flutter/foundation.dart';

/// A day on the calendar, with no time of day and no time zone.
///
/// The API sends due dates as plain `"2026-11-30"` strings that mean *South
/// African* days. Parsing one into a `DateTime` would invent a midnight and a
/// zone, and in another zone that midnight is a different day. A
/// [CalendarDate] keeps only the year, month and day.
///
/// Instants (when something was recorded) stay `DateTime` values in UTC; use
/// [CalendarDate.inSouthAfrica] to ask which South African day one falls on.
@immutable
final class CalendarDate implements Comparable<CalendarDate> {
  /// Creates the date [year]-[month]-[day]. Throws [ArgumentError] if there is
  /// no such day (for example 31 November).
  CalendarDate(this.year, this.month, this.day) {
    if (!_exists(year, month, day)) {
      throw ArgumentError('No such date: $year-$month-$day');
    }
  }

  /// Reads `YYYY-MM-DD`. Throws [FormatException] for anything else.
  factory CalendarDate.parse(String iso) =>
      tryParse(iso) ?? (throw FormatException('Not a YYYY-MM-DD date', iso));

  /// The South African calendar day that contains [instant].
  ///
  /// South Africa is UTC+2 all year (no daylight saving), so a fixed two-hour
  /// shift is exact. `2026-10-31T22:30:00Z` is 1 November there.
  factory CalendarDate.inSouthAfrica(DateTime instant) {
    final local = instant.toUtc().add(const Duration(hours: 2));
    return CalendarDate(local.year, local.month, local.day);
  }

  /// Reads `YYYY-MM-DD`, or returns `null`.
  static CalendarDate? tryParse(String iso) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(iso);
    if (match == null) return null;
    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    return _exists(year, month, day) ? CalendarDate(year, month, day) : null;
  }

  static bool _exists(int year, int month, int day) {
    final check = DateTime.utc(year, month, day);
    return check.year == year && check.month == month && check.day == day;
  }

  /// The year.
  final int year;

  /// The month, 1 to 12.
  final int month;

  /// The day of the month, 1 to 31.
  final int day;

  /// How many whole days from this date to [other] (negative if [other] is
  /// earlier).
  int daysUntil(CalendarDate other) => DateTime.utc(
    other.year,
    other.month,
    other.day,
  ).difference(DateTime.utc(year, month, day)).inDays;

  @override
  int compareTo(CalendarDate other) => daysUntil(other) * -1;

  /// Whether this day is before [other].
  bool isBefore(CalendarDate other) => compareTo(other) < 0;

  @override
  bool operator ==(Object other) =>
      other is CalendarDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  /// `YYYY-MM-DD`, exactly as the API writes it.
  @override
  String toString() =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';
}

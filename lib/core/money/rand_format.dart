import 'package:tallyvel/core/money/cents.dart';

/// The grouping separator in South African rand amounts: a non-breaking space,
/// so "R1 234,50" never wraps in the middle of a number.
const _group = '\u00A0';

/// Formats [amount] the way `en-ZA` writes rand: `R1 234,50`.
///
/// - the group separator is U+00A0, so a number never wraps in the middle;
/// - the decimal separator is a comma, and there are always two decimals;
/// - a negative amount reads `-R10,00`, with the minus before the R.
String formatRand(Cents amount) {
  final cents = amount.value.abs();
  final rand = (cents ~/ 100).toString();
  final fraction = (cents % 100).toString().padLeft(2, '0');

  final grouped = StringBuffer();
  for (var i = 0; i < rand.length; i++) {
    if (i > 0 && (rand.length - i) % 3 == 0) grouped.write(_group);
    grouped.write(rand[i]);
  }
  final sign = amount.isNegative ? '-' : '';
  return '${sign}R$grouped,$fraction';
}

final _amountPattern = RegExp(r'^(\d+)(?:[.,](\d{1,2}))?$');

/// Reads what a person types into an amount field and returns it as [Cents],
/// or `null` if it is not a valid, non-negative rand amount.
///
/// **The full-stop decision.** `en-ZA` writes the decimal separator as a comma,
/// but a phone's number keypad types a full stop, and a person who types
/// `500.50` means R500,50. So BOTH `,` and `.` are accepted, as the decimal
/// separator and only as that: neither is ever a thousands separator (that is
/// a space or U+00A0). The price of this is that `1.234` and `1,234` are
/// refused, because with one or two digits after the separator it is cents and
/// with three it is ambiguous, and guessing wrong moves a decimal point.
///
/// Accepts `500`, `500.5`, `500,50`, `0,10`, `R 1 234,50`, `1234.50` and a
/// non-breaking space as a group separator. Spaces and a leading `R` are
/// ignored. Rejects the empty string, a minus sign, more than two decimals,
/// two separators (`1,234.50`), a bare separator (`.5`, `12.`), anything that
/// is not digits, and anything above [Cents.max]. It never goes through a
/// `double`, so `0,10` is exactly 10 cents.
Cents? parseRand(String input) {
  final cleaned = input
      .trim()
      .replaceFirst(RegExp('^[Rr]'), '')
      .replaceAll(RegExp(r'[\s\u00A0]'), '');
  final match = _amountPattern.firstMatch(cleaned);
  if (match == null) return null;

  final rand = BigInt.parse(match.group(1)!);
  final fraction = (match.group(2) ?? '').padRight(2, '0');
  final total = rand * BigInt.from(100) + BigInt.parse(fraction);
  if (total > BigInt.from(Cents.max.value)) return null;
  return Cents(total.toInt());
}

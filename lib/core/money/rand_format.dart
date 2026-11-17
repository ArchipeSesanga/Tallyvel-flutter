import 'package:tallyvel/core/money/cents.dart';

/// The grouping separator in South African rand amounts: a non-breaking space,
/// so "R1 234,50" never wraps in the middle of a number.
const _group = ' ';

/// Formats [amount] the South African way: `R1 234,50` (space between
/// thousands, comma before the cents, always two decimals). A negative amount
/// reads `-R10,00`.
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
/// Accepts `500`, `500.5`, `500,50`, `R 1 234,50` and `1234.50`. Spaces and a
/// leading `R` are ignored. Rejects more than two decimals (`1.234` is not
/// "one thousand two hundred and thirty-four"), a minus sign, anything that is
/// not digits, and anything above [Cents.max]. It never goes through a
/// `double`, so `0,10` is exactly 10 cents.
Cents? parseRand(String input) {
  final cleaned = input
      .trim()
      .replaceFirst(RegExp('^[Rr]'), '')
      .replaceAll(RegExp(r'[\s ]'), '');
  final match = _amountPattern.firstMatch(cleaned);
  if (match == null) return null;

  final rand = BigInt.parse(match.group(1)!);
  final fraction = (match.group(2) ?? '').padRight(2, '0');
  final total = rand * BigInt.from(100) + BigInt.parse(fraction);
  if (total > BigInt.from(Cents.max.value)) return null;
  return Cents(total.toInt());
}

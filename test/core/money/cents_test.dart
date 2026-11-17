import 'package:flutter_test/flutter_test.dart';
import 'package:tallyvel/core/money/cents.dart';
import 'package:tallyvel/core/money/rand_format.dart';

void main() {
  group('Cents arithmetic', () {
    test('adds, subtracts and multiplies exactly', () {
      expect(const Cents(10) + const Cents(20), const Cents(30));
      expect(const Cents(50000) - const Cents(10), const Cents(49990));
      expect(const Cents(30000) * 4, const Cents(120000));
      expect(-const Cents(5), const Cents(-5));
    });

    test('ten cents added ten times is exactly one rand', () {
      // 0.1 + 0.1 + ... as doubles is 0.9999999999999999. Cents is exact.
      var total = Cents.zero;
      for (var i = 0; i < 10; i++) {
        total += const Cents(10);
      }
      expect(total, const Cents(100));
    });

    test('compares', () {
      expect(const Cents(1) < const Cents(2), isTrue);
      expect(const Cents(2) <= const Cents(2), isTrue);
      expect(const Cents(3) > const Cents(2), isTrue);
      expect(const Cents(2) >= const Cents(3), isFalse);
      expect(const Cents(-1).isNegative, isTrue);
      expect(Cents.zero.isZero, isTrue);
    });
  });

  group('formatRand', () {
    test('uses a comma for cents and always shows two decimals', () {
      expect(formatRand(const Cents(50000)), 'R500,00');
      expect(formatRand(const Cents(10)), 'R0,10');
      expect(formatRand(const Cents(1)), 'R0,01');
      expect(formatRand(Cents.zero), 'R0,00');
      expect(formatRand(const Cents(10050)), 'R100,50');
    });

    test('groups thousands with a non-breaking space', () {
      expect(formatRand(const Cents(123450)), 'R1 234,50');
      expect(formatRand(const Cents(100000000)), 'R1 000 000,00');
    });

    test('puts the minus before the R', () {
      expect(formatRand(const Cents(-1000)), '-R10,00');
    });

    test('holds the largest amount the API accepts', () {
      expect(formatRand(Cents.max), 'R90 071 992 547 409,91');
    });
  });

  group('parseRand', () {
    test('reads whole rand and one or two decimals', () {
      expect(parseRand('500'), const Cents(50000));
      expect(parseRand('500.5'), const Cents(50050));
      expect(parseRand('500,50'), const Cents(50050));
      expect(parseRand('0,10'), const Cents(10));
      expect(parseRand('0.01'), const Cents(1));
    });

    test('ignores a leading R, spaces and non-breaking spaces', () {
      expect(parseRand('R 1 234,50'), const Cents(123450));
      expect(parseRand(' r1234.50 '), const Cents(123450));
      expect(parseRand('R1 234,50'), const Cents(123450));
    });

    test('round-trips what formatRand writes', () {
      for (final cents in [0, 1, 10, 99, 100, 10050, 123450, 99999999]) {
        expect(parseRand(formatRand(Cents(cents))), Cents(cents));
      }
    });

    test('rejects what is not a rand amount', () {
      for (final bad in [
        '',
        ' ',
        'R',
        'abc',
        '-5',
        '1.234', // three decimals: not one thousand two hundred thirty-four
        '1,234,5',
        '12.',
        '.5',
        '1e3',
      ]) {
        expect(parseRand(bad), isNull, reason: '"$bad"');
      }
    });

    test('rejects more than the API accepts, without overflowing', () {
      expect(parseRand('90071992547409,91'), Cents.max);
      expect(parseRand('90071992547409,92'), isNull);
      expect(parseRand('99999999999999999999999'), isNull);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:tallyvel/core/failures/failure.dart';
import 'package:tallyvel/core/observability/is_worth_reporting.dart';

void main() {
  group('a bug is reported', () {
    test('a StateError', () => expect(isWorthReporting(StateError('x')), true));
    test('a FormatException', () {
      expect(isWorthReporting(const FormatException('x')), isTrue);
    });
  });

  group('a failure that is a bug on one side is reported', () {
    test('the API answered 5xx', () {
      expect(
        isWorthReporting(const ServerFailure(correlationId: 'abc123')),
        isTrue,
      );
    });
    test('the API answered something unreadable', () {
      expect(isWorthReporting(const UnexpectedFailure()), isTrue);
    });
  });

  group('a failure that is the app working as designed is not', () {
    const quiet = <String, Failure>{
      'not found': NotFoundFailure(),
      'forbidden': ForbiddenFailure(),
      'validation': ValidationFailure(),
      'conflict': ConflictFailure(),
      'rule': RuleFailure(),
      'rate limited': RateLimitedFailure(),
      'unauthorised': UnauthorisedFailure(),
      'no answer': NoAnswerFailure(),
    };
    for (final entry in quiet.entries) {
      test(entry.key, () => expect(isWorthReporting(entry.value), isFalse));
    }
  });
}

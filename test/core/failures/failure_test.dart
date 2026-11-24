import 'package:flutter_test/flutter_test.dart';
import 'package:tallyvel/core/failures/failure.dart';

void main() {
  test(
    'a failure prints only its type, and the correlation id if it has one',
    () {
      const all = <Failure>[
        ServerFailure(correlationId: 'abc123'),
        NotFoundFailure(),
        ForbiddenFailure(),
        ValidationFailure(),
        ConflictFailure(),
        RuleFailure(),
        RateLimitedFailure(),
        UnauthorisedFailure(),
        NoAnswerFailure(),
        UnexpectedFailure(),
      ];

      expect(all.map((f) => f.toString()), [
        'ServerFailure(correlationId: abc123)',
        'NotFoundFailure',
        'ForbiddenFailure',
        'ValidationFailure',
        'ConflictFailure',
        'RuleFailure',
        'RateLimitedFailure',
        'UnauthorisedFailure',
        'NoAnswerFailure',
        'UnexpectedFailure',
      ]);
    },
  );
}

import 'package:tallyvel/core/failures/failure.dart';

/// Whether [error] should reach a developer.
///
/// Not a [Failure] means a bug in the app (a `StateError`, a cast, a bad
/// index): reported. A [Failure] is the app working as designed, because it
/// is the API saying no or the phone being offline, with two exceptions: the
/// API's own 5xx, and an answer the app cannot read. Those are a bug on one
/// side or the other.
///
/// The `switch` has no wildcard, so a new [Failure] case does not compile
/// until someone decides which side it is on.
bool isWorthReporting(Object error) {
  if (error is! Failure) return true;
  return switch (error) {
    ServerFailure() => true,
    UnexpectedFailure() => true,
    NotFoundFailure() => false,
    ForbiddenFailure() => false,
    ValidationFailure() => false,
    ConflictFailure() => false,
    RuleFailure() => false,
    RateLimitedFailure() => false,
    UnauthorisedFailure() => false,
    NoAnswerFailure() => false,
  };
}

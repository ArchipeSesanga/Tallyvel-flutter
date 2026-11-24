/// Why a call to the API did not give the app what it asked for.
///
/// One sealed type, so a `switch` over it needs no wildcard and a new case
/// cannot be forgotten. A failure never carries what the API said in its
/// `detail`, a field value, a name or an amount: those can hold a person's
/// data, and a failure ends up in logs and error reports. What it may carry is
/// the correlation id, which is how a report is matched to the API's logs.
sealed class Failure implements Exception {
  const Failure();
}

/// The API answered 5xx: its fault, not the person's. [correlationId] is the
/// id the API sent back for this request, to find it in the API's logs.
final class ServerFailure extends Failure {
  /// Creates a server failure for the request with [correlationId].
  const ServerFailure({required this.correlationId});

  /// The id of the failed request, as the API sent it.
  final String correlationId;

  @override
  String toString() => 'ServerFailure(correlationId: $correlationId)';
}

/// 404: there is no such thing, or it is not the person's to see.
final class NotFoundFailure extends Failure {
  /// Creates a not-found failure.
  const NotFoundFailure();

  @override
  String toString() => 'NotFoundFailure';
}

/// 403: the person may not do this.
final class ForbiddenFailure extends Failure {
  /// Creates a forbidden failure.
  const ForbiddenFailure();

  @override
  String toString() => 'ForbiddenFailure';
}

/// 400/422: something the person typed or chose is not acceptable.
final class ValidationFailure extends Failure {
  /// Creates a validation failure.
  const ValidationFailure();

  @override
  String toString() => 'ValidationFailure';
}

/// 409: the thing changed since the person last saw it.
final class ConflictFailure extends Failure {
  /// Creates a conflict failure.
  const ConflictFailure();

  @override
  String toString() => 'ConflictFailure';
}

/// A business rule said no (for example "that cycle is closed").
final class RuleFailure extends Failure {
  /// Creates a rule failure.
  const RuleFailure();

  @override
  String toString() => 'RuleFailure';
}

/// 429: too many requests; try again later.
final class RateLimitedFailure extends Failure {
  /// Creates a rate-limited failure.
  const RateLimitedFailure({this.retryAfterSeconds});

  /// The API's `Retry-After`, in whole seconds, if it sent one. It is the
  /// length of the rate-limit window, so an upper bound on the wait.
  final int? retryAfterSeconds;

  @override
  String toString() => 'RateLimitedFailure';
}

/// 401: the person is not signed in, or their session ended.
final class UnauthorisedFailure extends Failure {
  /// Creates an unauthorised failure.
  const UnauthorisedFailure();

  @override
  String toString() => 'UnauthorisedFailure';
}

/// The phone could not reach the API (no signal, timeout).
final class NoAnswerFailure extends Failure {
  /// Creates a no-answer failure.
  const NoAnswerFailure();

  @override
  String toString() => 'NoAnswerFailure';
}

/// The API answered, but not with anything the app can read. That means the
/// app and the API disagree about the contract: a bug on one side.
final class UnexpectedFailure extends Failure {
  /// Creates an unexpected failure.
  const UnexpectedFailure();

  @override
  String toString() => 'UnexpectedFailure';
}

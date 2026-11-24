import 'dart:io';

import 'package:dio/dio.dart';
import 'package:tallyvel/core/failures/failure.dart';

/// What is shown in a report when a 5xx carries no correlation id.
const noCorrelationId = 'none';

/// Turns what went wrong with a request into a [Failure].
///
/// Reads the status, the `correlationId` of the API's problem body and the
/// `Retry-After` header. It never keeps the body's `detail`, `title` or any
/// field: they can hold a person's data.
Failure failureFromDio(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return const NoAnswerFailure();
    case DioExceptionType.badResponse:
      return _failureFromResponse(e.response);
    case DioExceptionType.transformTimeout:
    case DioExceptionType.badCertificate:
    case DioExceptionType.cancel:
      return const UnexpectedFailure();
    case DioExceptionType.unknown:
      return e.error is SocketException || e.error is HandshakeException
          ? const NoAnswerFailure()
          : const UnexpectedFailure();
  }
}

Failure _failureFromResponse(Response<dynamic>? response) {
  final status = response?.statusCode;
  if (response == null || status == null) return const UnexpectedFailure();
  return switch (status) {
    400 => const ValidationFailure(),
    401 => const UnauthorisedFailure(),
    403 => const ForbiddenFailure(),
    // 410 is an invite that no longer exists: the same to the person.
    404 || 410 => const NotFoundFailure(),
    409 => const ConflictFailure(),
    422 => const RuleFailure(),
    429 => RateLimitedFailure(
      retryAfterSeconds: int.tryParse(
        response.headers.value('retry-after') ?? '',
      ),
    ),
    >= 500 && < 600 => ServerFailure(
      correlationId: _correlationIdOf(response.data) ?? noCorrelationId,
    ),
    _ => const UnexpectedFailure(),
  };
}

String? _correlationIdOf(Object? body) {
  if (body is! Map) return null;
  final id = body['correlationId'];
  return id is String && id.isNotEmpty ? id : null;
}

/// Runs [call], turning a failed request into a [Failure] and a body that is
/// not valid JSON into an [UnexpectedFailure]. A repository checks the shape
/// of what it reads and throws [UnexpectedFailure] itself; anything else is a
/// bug and is let through as it is.
Future<T> guardApi<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on DioException catch (e) {
    throw failureFromDio(e);
  } on FormatException {
    throw const UnexpectedFailure();
  }
}

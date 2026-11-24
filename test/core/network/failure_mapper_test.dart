import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tallyvel/core/failures/failure.dart';
import 'package:tallyvel/core/network/api_client.dart';
import 'package:tallyvel/core/network/failure_mapper.dart';

import '../../support/fake_http_adapter.dart';

Future<Failure> _failureFor(FakeReply reply) async {
  final dio = createApiDio(
    baseUrl: 'http://api.test',
    tokens: TokenStore(),
    adapter: FakeHttpAdapter((_) => reply),
  );
  try {
    await dio.get<Object?>('/x');
  } on DioException catch (e) {
    return failureFromDio(e);
  }
  fail('the request should have failed');
}

void main() {
  group('a status becomes a Failure', () {
    final table = <int, Matcher>{
      400: isA<ValidationFailure>(),
      401: isA<UnauthorisedFailure>(),
      403: isA<ForbiddenFailure>(),
      404: isA<NotFoundFailure>(),
      409: isA<ConflictFailure>(),
      410: isA<NotFoundFailure>(),
      422: isA<RuleFailure>(),
      418: isA<UnexpectedFailure>(),
    };
    for (final entry in table.entries) {
      test('${entry.key}', () async {
        expect(await _failureFor(FakeReply(entry.key)), entry.value);
      });
    }
  });

  test('a 5xx keeps only the correlation id', () async {
    final failure = await _failureFor(
      const FakeReply(
        500,
        body: {
          'correlationId': 'abc123',
          'detail': 'secret detail',
          'title': 'x',
        },
      ),
    );

    expect(failure, isA<ServerFailure>());
    expect((failure as ServerFailure).correlationId, 'abc123');
    expect(failure.toString(), isNot(contains('secret')));
  });

  test('a 5xx with no readable body still is a server failure', () async {
    final failure = await _failureFor(const FakeReply(503));

    expect(failure, isA<ServerFailure>());
    expect((failure as ServerFailure).correlationId, noCorrelationId);
  });

  test('a 429 keeps Retry-After in whole seconds', () async {
    final failure = await _failureFor(
      const FakeReply(429, headers: {'retry-after': '60'}),
    );

    expect(failure, isA<RateLimitedFailure>());
    expect((failure as RateLimitedFailure).retryAfterSeconds, 60);
  });

  test('a 429 with no Retry-After has none', () async {
    final failure = await _failureFor(const FakeReply(429));

    expect((failure as RateLimitedFailure).retryAfterSeconds, isNull);
  });

  group('no answer', () {
    DioException of(DioExceptionType type, [Object? error]) => DioException(
      requestOptions: RequestOptions(),
      type: type,
      error: error,
    );

    test('timeouts and connection errors', () {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.connectionError,
      ]) {
        expect(failureFromDio(of(type)), isA<NoAnswerFailure>());
      }
    });

    test('a socket error', () {
      expect(
        failureFromDio(
          of(DioExceptionType.unknown, const SocketException('no route')),
        ),
        isA<NoAnswerFailure>(),
      );
    });

    test('anything else unknown is unexpected, a bug', () {
      expect(
        failureFromDio(of(DioExceptionType.unknown, StateError('x'))),
        isA<UnexpectedFailure>(),
      );
    });
  });

  test('the bearer token is sent once there is one', () async {
    final tokens = TokenStore();
    final adapter = FakeHttpAdapter((_) => const FakeReply(200, body: {}));
    final dio = createApiDio(
      baseUrl: 'http://api.test',
      tokens: tokens,
      adapter: adapter,
    );

    await dio.get<Object?>('/a');
    tokens.accessToken = 't0ken';
    await dio.get<Object?>('/b');

    expect(adapter.requests[0].headers['Authorization'], isNull);
    expect(adapter.requests[1].headers['Authorization'], 'Bearer t0ken');
  });
}

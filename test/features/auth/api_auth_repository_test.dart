import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tallyvel/app/composition_root.dart';
import 'package:tallyvel/core/failures/failure.dart';
import 'package:tallyvel/core/network/api_client.dart';
import 'package:tallyvel/features/auth/data/api_auth_repository.dart';
import 'package:tallyvel/features/auth/data/auth_provider.dart';
import 'package:tallyvel/features/auth/domain/auth_state.dart';

import '../../support/fake_http_adapter.dart';
import '../../support/recording_reporter.dart';
import '../../support/stubs.dart';

const _token = 'access-token-123';

FakeReply _api(RequestOptions o) => switch ((o.method, o.path)) {
  ('POST', '/api/v1/auth/login') => const FakeReply(
    200,
    body: {'accessToken': _token, 'expiresAt': '2026-11-24T12:15:00Z'},
  ),
  ('GET', '/api/v1/me') => const FakeReply(
    200,
    body: {
      'id': '1',
      'email': 'lerato@tallyvel.test',
      'fullName': 'Lerato M.',
      'createdAt': '2026-01-01T00:00:00Z',
    },
  ),
  ('POST', '/api/v1/auth/logout') => const FakeReply(204),
  _ => const FakeReply(404),
};

({ApiAuthRepository repo, TokenStore tokens, FakeHttpAdapter adapter}) _make(
  FutureOr<FakeReply> Function(RequestOptions) onRequest,
) {
  final tokens = TokenStore();
  final adapter = FakeHttpAdapter(onRequest);
  final dio = createApiDio(
    baseUrl: 'http://api.test',
    tokens: tokens,
    adapter: adapter,
  );
  return (
    repo: ApiAuthRepository(dio, tokens),
    tokens: tokens,
    adapter: adapter,
  );
}

void main() {
  group('signIn', () {
    test('logs in, then asks who it is with the token', () async {
      final t = _make(_api);

      final session = await t.repo.signIn(
        email: 'lerato@tallyvel.test',
        password: 'pw',
      );

      expect(session.email, 'lerato@tallyvel.test');
      expect(session.fullName, 'Lerato M.');
      expect(t.tokens.accessToken, _token);
      expect(t.adapter.requests[0].data, {
        'email': 'lerato@tallyvel.test',
        'password': 'pw',
      });
      expect(t.adapter.requests[1].headers['Authorization'], 'Bearer $_token');
    });

    test('a wrong password is Unauthorised and keeps no token', () async {
      final t = _make((_) => const FakeReply(401, body: {'title': 'x'}));

      await expectLater(
        t.repo.signIn(email: 'a@b.c', password: 'bad'),
        throwsA(isA<UnauthorisedFailure>()),
      );
      expect(t.tokens.accessToken, isNull);
    });

    test('if /me fails, the token is dropped again', () async {
      final t = _make(
        (o) => o.path.endsWith('/me') ? const FakeReply(500) : _api(o),
      );

      await expectLater(
        t.repo.signIn(email: 'a@b.c', password: 'pw'),
        throwsA(isA<ServerFailure>()),
      );
      expect(t.tokens.accessToken, isNull);
    });

    test('a login answer with no token is Unexpected', () async {
      final t = _make((_) => const FakeReply(200, body: {'nope': 1}));

      await expectLater(
        t.repo.signIn(email: 'a@b.c', password: 'pw'),
        throwsA(isA<UnexpectedFailure>()),
      );
      expect(t.tokens.accessToken, isNull);
    });
  });

  group('signOut', () {
    test('forgets the token even when the API cannot be reached', () async {
      final t = _make(_api);
      await t.repo.signIn(email: 'a@b.c', password: 'pw');
      final offline = _make(
        (o) => throw DioException.connectionError(
          requestOptions: o,
          reason: 'offline',
        ),
      )..tokens.accessToken = _token;

      await offline.repo.signOut();

      expect(offline.tokens.accessToken, isNull);
    });
  });

  group('the Auth notifier', () {
    ProviderContainer containerWith(
      StubAuthRepository repo,
      RecordingReporter reporter,
    ) {
      final c = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(repo),
          errorReporterProvider.overrideWithValue(reporter),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    test('signing in as a seeded account keeps the persona and name', () async {
      final c = containerWith(StubAuthRepository(), RecordingReporter());

      await c
          .read(authProvider.notifier)
          .signIn(
            email: ' Lerato@tallyvel.test ',
            password: StubAuthRepository.password,
          );

      expect(
        c.read(authProvider),
        isA<SignedIn>()
            .having((s) => s.persona, 'persona', Persona.lerato)
            .having((s) => s.displayName, 'displayName', 'Lerato M.'),
      );
    });

    test(
      'a server failure is reported and rethrown; still signed out',
      () async {
        final reporter = RecordingReporter();
        final c = containerWith(
          StubAuthRepository(
            failure: const ServerFailure(correlationId: 'abc123'),
          ),
          reporter,
        );

        await expectLater(
          c.read(authProvider.notifier).signIn(email: 'a@b.c', password: 'x'),
          throwsA(isA<ServerFailure>()),
        );

        expect(reporter.errors, hasLength(1));
        expect(c.read(authProvider), isA<SignedOut>());
      },
    );

    test('a wrong password is not reported', () async {
      final reporter = RecordingReporter();
      final c = containerWith(StubAuthRepository(), reporter);

      await expectLater(
        c.read(authProvider.notifier).signIn(email: 'a@b.c', password: 'x'),
        throwsA(isA<UnauthorisedFailure>()),
      );

      expect(reporter.errors, isEmpty);
    });

    test('signing out tells the repository and signs out', () async {
      final repo = StubAuthRepository();
      final c = containerWith(repo, RecordingReporter());
      await c
          .read(authProvider.notifier)
          .signIn(
            email: 'lerato@tallyvel.test',
            password: StubAuthRepository.password,
          );

      c.read(authProvider.notifier).signOut();

      expect(c.read(authProvider), isA<SignedOut>());
      expect(repo.signOuts, 1);
    });
  });
}

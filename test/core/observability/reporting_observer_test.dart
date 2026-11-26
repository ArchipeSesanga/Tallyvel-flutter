import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:tallyvel/core/failures/failure.dart';
import 'package:tallyvel/core/observability/reporting_observer.dart';
import 'package:tallyvel/features/auth/domain/auth_state.dart';
import 'package:tallyvel/features/home/presentation/home_providers.dart';

import '../../support/provider_harness.dart';
import '../../support/recording_reporter.dart';
import '../../support/stubs.dart';

/// A container whose Home repository fails with [error], reporting through
/// [reporter]. Home is listened to, not just read: it auto-disposes.
ProviderContainer _homeFailingWith(
  Object error,
  RecordingReporter reporter, {
  Duration? Function(int, Object)? retry,
}) {
  final container = ProviderContainer(
    retry: retry ?? (_, _) => null,
    observers: [ReportingObserver(reporter)],
    overrides: <Override>[
      ...fakeWorldAs(
        Persona.lerato,
        home: StubHomeRepository((_) => Future.error(error)),
      ),
    ],
  );
  addTearDown(container.dispose);
  container.listen(homeProvider, (_, _) {}, onError: (_, _) {});
  return container;
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  group('ReportingObserver, with no retry', () {
    test(
      'a server failure is reported once, with its correlation id',
      () async {
        final reporter = RecordingReporter();
        _homeFailingWith(
          const ServerFailure(correlationId: 'abc123'),
          reporter,
        );
        await _settle();

        expect(reporter.errors, hasLength(1));
        expect(
          reporter.errors.single,
          isA<ServerFailure>().having(
            (f) => f.correlationId,
            'correlationId',
            'abc123',
          ),
        );
      },
    );

    test('not found is not reported', () async {
      final reporter = RecordingReporter();
      _homeFailingWith(const NotFoundFailure(), reporter);
      await _settle();

      expect(reporter.errors, isEmpty);
    });

    test('forbidden is not reported', () async {
      final reporter = RecordingReporter();
      _homeFailingWith(const ForbiddenFailure(), reporter);
      await _settle();

      expect(reporter.errors, isEmpty);
    });

    test('a plain StateError (a bug) is reported', () async {
      final reporter = RecordingReporter();
      final bug = StateError('boom');
      _homeFailingWith(bug, reporter);
      await _settle();

      expect(reporter.errors, [bug]);
    });
  });

  group("Riverpod's default retry", () {
    testWidgets('reports a server failure once, when the retries run out', (
      tester,
    ) async {
      final reporter = RecordingReporter();
      _homeFailingWith(
        const ServerFailure(correlationId: 'abc123'),
        reporter,
        retry: ProviderContainer.defaultRetry,
      );

      // While it retries, Riverpod does not tell observers about the
      // failure: a retry is "loading", not "failed".
      await tester.pump(const Duration(seconds: 5));
      expect(reporter.errors, isEmpty);

      // The last attempt is about 38 s in; after it the failure is final.
      await tester.pump(const Duration(seconds: 60));
      expect(reporter.errors, hasLength(1));
    });

    testWidgets('does not retry a bug, so it is reported at once, once', (
      tester,
    ) async {
      final reporter = RecordingReporter();
      _homeFailingWith(
        StateError('boom'),
        reporter,
        retry: ProviderContainer.defaultRetry,
      );
      await tester.pump(const Duration(seconds: 60));

      expect(reporter.errors, hasLength(1));
    });
  });
}

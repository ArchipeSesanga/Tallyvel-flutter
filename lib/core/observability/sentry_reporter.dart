import 'dart:async';

import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:tallyvel/core/failures/failure.dart';
import 'package:tallyvel/core/observability/error_reporter.dart';

/// Sends errors to Sentry.
///
/// The only file under `lib/` besides `main.dart` that imports
/// `package:sentry_flutter` (`test/architecture` checks this). It is built only
/// when there is a DSN, and Sentry is started in `main.dart`.
class SentryReporter implements ErrorReporter {
  /// Creates a reporter that sends to the already-initialised Sentry.
  const SentryReporter();

  @override
  void report(Object error, StackTrace stackTrace) {
    unawaited(
      Sentry.captureException(
        error,
        stackTrace: stackTrace,
        withScope: (scope) async {
          // The type only, for a failure. Never `toString()` of anything
          // that could hold a person's data.
          await scope.setTag('failure', error.runtimeType.toString());
          if (error case ServerFailure(:final correlationId)) {
            await scope.setTag('correlation_id', correlationId);
          }
        },
      ),
    );
  }
}

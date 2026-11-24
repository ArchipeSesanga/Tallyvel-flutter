import 'package:tallyvel/core/config/app_config.dart';
import 'package:tallyvel/core/observability/error_reporter.dart';
import 'package:tallyvel/core/observability/sentry_reporter.dart';

/// The reporter for [config]: Sentry when there is a DSN, otherwise one that
/// does nothing. Without a DSN no `SentryReporter` is ever built.
ErrorReporter reporterFor(AppConfig config) =>
    config.sentryEnabled ? const SentryReporter() : const NoopReporter();

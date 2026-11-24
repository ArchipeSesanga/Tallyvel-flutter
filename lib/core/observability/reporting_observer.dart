import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tallyvel/core/observability/error_reporter.dart';
import 'package:tallyvel/core/observability/is_worth_reporting.dart';

/// Reports a provider's failure, if it is worth reporting.
///
/// The one place in the app that reports errors from providers: screens and
/// repositories never call a reporter themselves.
base class ReportingObserver extends ProviderObserver {
  /// Creates an observer that sends to [reporter].
  const ReportingObserver(this.reporter);

  /// Where reportable failures go.
  final ErrorReporter reporter;

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    if (isWorthReporting(error)) reporter.report(error, stackTrace);
  }
}

import 'package:tallyvel/core/observability/error_reporter.dart';

/// An [ErrorReporter] that keeps what it was given, for tests.
class RecordingReporter implements ErrorReporter {
  /// The errors reported, in order.
  final List<Object> errors = [];

  @override
  void report(Object error, StackTrace stackTrace) => errors.add(error);
}

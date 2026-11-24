/// Where an error that is worth a developer's attention is sent.
///
/// An interface, so the app never knows whether Sentry is behind it, and a
/// test can swap in something that only remembers what it was given.
abstract interface class ErrorReporter {
  /// Sends [error] and where it happened. Never throws and never waits: the
  /// caller is in the middle of handling the error already.
  void report(Object error, StackTrace stackTrace);
}

/// Reports nothing. Used when there is no Sentry DSN.
class NoopReporter implements ErrorReporter {
  /// Creates a reporter that does nothing.
  const NoopReporter();

  @override
  void report(Object error, StackTrace stackTrace) {}
}

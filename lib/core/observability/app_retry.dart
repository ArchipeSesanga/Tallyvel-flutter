import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tallyvel/core/failures/failure.dart';
import 'package:tallyvel/core/observability/is_worth_reporting.dart';

/// Which failed providers Riverpod tries again by itself.
///
/// Only a failure that is likely to pass on its own: no signal, or "slow
/// down". Anything worth reporting is never retried here. Riverpod calls
/// `providerDidFail` once per attempt, so a retried server failure would
/// reach Sentry up to eleven times for one problem. The person's own
/// pull-to-refresh is the retry for those.
Duration? appRetry(int retryCount, Object error) {
  if (isWorthReporting(error)) return null;
  return switch (error) {
    NoAnswerFailure() || RateLimitedFailure() => ProviderContainer.defaultRetry(
      retryCount,
      error,
      maxRetries: 3,
    ),
    _ => null,
  };
}

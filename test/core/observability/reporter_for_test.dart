import 'package:flutter_test/flutter_test.dart';
import 'package:tallyvel/core/config/app_config.dart';
import 'package:tallyvel/core/observability/error_reporter.dart';
import 'package:tallyvel/core/observability/reporter_for.dart';
import 'package:tallyvel/core/observability/sentry_reporter.dart';

AppConfig _config({String dsn = ''}) => AppConfig.validate(
  env: 'dev',
  apiBaseUrl: 'https://api.tallyvel.example',
  flavor: 'dev',
  sentryDsn: dsn,
);

void main() {
  test('with an empty DSN the reporter does nothing, never Sentry', () {
    final reporter = reporterFor(_config());

    expect(reporter, isA<NoopReporter>());
    expect(reporter, isNot(isA<SentryReporter>()));
  });

  test('with a DSN the reporter is the Sentry one', () {
    final reporter = reporterFor(_config(dsn: 'https://key@o0.ingest.x/1'));

    expect(reporter, isA<SentryReporter>());
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:tallyvel/core/config/app_config.dart';

void main() {
  const url = 'https://api.tallyvel.example';

  test('accepts a config that matches the flavour', () {
    final config = AppConfig.validate(
      env: 'dev',
      apiBaseUrl: url,
      flavor: 'dev',
    );

    expect(config.env, 'dev');
    expect(config.apiBaseUrl, url);
  });

  group('Sentry DSN', () {
    test('no DSN: Sentry is off, and that is not an error', () {
      final config = AppConfig.validate(
        env: 'dev',
        apiBaseUrl: url,
        flavor: 'dev',
      );

      expect(config.sentryEnabled, isFalse);
    });

    test('a blank DSN counts as no DSN', () {
      final config = AppConfig.validate(
        env: 'dev',
        apiBaseUrl: url,
        flavor: 'dev',
        sentryDsn: '   ',
      );

      expect(config.sentryEnabled, isFalse);
    });

    test('a DSN turns Sentry on', () {
      final config = AppConfig.validate(
        env: 'dev',
        apiBaseUrl: url,
        flavor: 'dev',
        sentryDsn: 'https://key@o0.ingest.example/1',
      );

      expect(config.sentryEnabled, isTrue);
      expect(config.sentryDsn, 'https://key@o0.ingest.example/1');
    });
  });

  group('refuses to start without a config', () {
    test('when ENV is missing', () {
      expect(
        () => AppConfig.validate(env: '', apiBaseUrl: url, flavor: 'dev'),
        throwsA(isA<ConfigError>()),
      );
    });

    test('when API_BASE_URL is missing', () {
      expect(
        () => AppConfig.validate(env: 'dev', apiBaseUrl: '', flavor: 'dev'),
        throwsA(isA<ConfigError>()),
      );
    });
  });

  group('refuses a mismatch', () {
    test('a prod build given the dev config', () {
      expect(
        () => AppConfig.validate(env: 'dev', apiBaseUrl: url, flavor: 'prod'),
        throwsA(isA<ConfigError>()),
      );
    });

    test('a build with no flavour', () {
      expect(
        () => AppConfig.validate(env: 'dev', apiBaseUrl: url, flavor: null),
        throwsA(isA<ConfigError>()),
      );
    });
  });
}

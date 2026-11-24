import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tallyvel/app/app.dart';
import 'package:tallyvel/app/composition_root.dart';
import 'package:tallyvel/app/config_error_app.dart';
import 'package:tallyvel/core/config/app_config.dart';
import 'package:tallyvel/core/observability/reporter_for.dart';
import 'package:tallyvel/core/observability/reporting_observer.dart';
import 'package:tallyvel/features/onboarding/data/onboarding_status.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final AppConfig config;
  try {
    config = AppConfig.fromEnvironment();
  } on ConfigError catch (e) {
    runApp(ProviderScope(child: ConfigErrorApp(message: e.message)));
    return;
  }
  final prefs = await SharedPreferences.getInstance();
  final reporter = reporterFor(config);
  void start() => runApp(
    ProviderScope(
      observers: [ReportingObserver(reporter)],
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appConfigProvider.overrideWithValue(config),
        errorReporterProvider.overrideWithValue(reporter),
      ],
      child: const TallyvelApp(),
    ),
  );

  // No DSN: Sentry is never started, and the app runs exactly as it did
  // before Sentry was added.
  if (!config.sentryEnabled) {
    start();
    return;
  }
  await SentryFlutter.init((options) {
    options
      ..dsn = config.sentryDsn
      // One Sentry environment per flavour: dev, staging or prod.
      ..environment = config.env
      ..sendDefaultPii = false;
    // options.release is NOT set: Sentry builds it from the app id, version
    // and build number.
    // TODO(part-9): options.beforeSend = the scrubber goes here.
  }, appRunner: start);
}

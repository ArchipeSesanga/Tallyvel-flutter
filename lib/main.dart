import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tallyvel/app/app.dart';
import 'package:tallyvel/app/config_error_app.dart';
import 'package:tallyvel/core/config/app_config.dart';
import 'package:tallyvel/features/onboarding/data/onboarding_status.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    AppConfig.fromEnvironment();
  } on ConfigError catch (e) {
    runApp(ProviderScope(child: ConfigErrorApp(message: e.message)));
    return;
  }
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const TallyvelApp(),
    ),
  );
}

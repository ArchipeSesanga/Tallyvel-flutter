import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tallyvel/app/app.dart';
import 'package:tallyvel/app/config_error_app.dart';
import 'package:tallyvel/core/config/app_config.dart';

void main() {
  try {
    AppConfig.fromEnvironment();
  } on ConfigError catch (e) {
    runApp(ProviderScope(child: ConfigErrorApp(message: e.message)));
    return;
  }
  runApp(const ProviderScope(child: TallyvelApp()));
}

import 'package:flutter/services.dart' show appFlavor;

/// Thrown when the app has no config, or a config for a different flavour.
class ConfigError implements Exception {
  const ConfigError(this.message);

  final String message;

  @override
  String toString() => 'ConfigError: $message';
}

/// Per-flavour, non-secret configuration, read from `config/<flavour>.json`
/// passed with `--dart-define-from-file`.
class AppConfig {
  const AppConfig._({required this.env, required this.apiBaseUrl});

  static const knownEnvs = {'dev', 'staging', 'prod'};

  final String env;
  final String apiBaseUrl;

  /// Reads the compile-time config and checks it against the build flavour.
  /// Throws [ConfigError] if the config is missing or belongs to another flavour.
  static AppConfig fromEnvironment() => AppConfig.validate(
    env: const String.fromEnvironment('ENV'),
    apiBaseUrl: const String.fromEnvironment('API_BASE_URL'),
    flavor: appFlavor,
  );

  /// [flavor] is the flavour the app was built with (`--flavor`).
  /// Throws [ConfigError] unless [env] and [apiBaseUrl] are present and [env]
  /// matches [flavor].
  factory AppConfig.validate({
    required String env,
    required String apiBaseUrl,
    required String? flavor,
  }) {
    if (env.isEmpty || apiBaseUrl.isEmpty) {
      throw const ConfigError(
        'No config found. Run with --dart-define-from-file=config/<flavour>.json',
      );
    }
    if (!knownEnvs.contains(env)) {
      throw ConfigError('Unknown ENV "$env" in the config.');
    }
    if (flavor != env) {
      throw ConfigError(
        'Config mismatch: built as flavour "$flavor" but the config is for "$env".',
      );
    }
    return AppConfig._(env: env, apiBaseUrl: apiBaseUrl);
  }
}

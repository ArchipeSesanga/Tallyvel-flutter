import 'package:flutter/material.dart';

/// Shown instead of the app when the config is missing or does not match the
/// flavour.
class ConfigErrorApp extends StatelessWidget {
  /// Creates the screen that shows [message].
  const ConfigErrorApp({required this.message, super.key});

  /// What is wrong with the config.
  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tallyvel',
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(message, textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}

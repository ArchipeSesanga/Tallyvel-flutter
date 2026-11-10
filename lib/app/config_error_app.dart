import 'package:flutter/material.dart';

/// Shown instead of the app when the config is missing or does not match the
/// flavour.
class ConfigErrorApp extends StatelessWidget {
  const ConfigErrorApp({required this.message, super.key});

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

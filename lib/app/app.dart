import 'package:flutter/material.dart';

/// The root widget of the Tallyvel app.
class TallyvelApp extends StatelessWidget {
  /// Creates the app.
  const TallyvelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Tallyvel',
      home: Scaffold(body: Center(child: Text('Tallyvel'))),
    );
  }
}

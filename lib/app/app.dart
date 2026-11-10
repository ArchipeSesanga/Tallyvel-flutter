import 'package:flutter/material.dart';

class TallyvelApp extends StatelessWidget {
  const TallyvelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Tallyvel',
      home: Scaffold(body: Center(child: Text('Tallyvel'))),
    );
  }
}

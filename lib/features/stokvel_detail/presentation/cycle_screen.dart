import 'package:flutter/material.dart';

/// A single payout cycle of a stokvel.
class CycleScreen extends StatelessWidget {
  /// Creates the screen for [cycleId] of [stokvelId].
  const CycleScreen({
    required this.stokvelId,
    required this.cycleId,
    super.key,
  });

  /// The owning stokvel.
  final String stokvelId;

  /// The cycle being shown.
  final String cycleId;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Cycle $cycleId')),
        body: Center(child: Text('Stokvel $stokvelId · cycle $cycleId')),
      );
}

import 'package:flutter/material.dart';
import 'package:tallyvel/core/router/app_router.dart';

/// Details of a single stokvel.
class StokvelDetailScreen extends StatelessWidget {
  /// Creates the detail screen for [stokvelId].
  const StokvelDetailScreen({required this.stokvelId, super.key});

  /// The stokvel being shown.
  final String stokvelId;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Stokvel $stokvelId')),
        body: Center(
          child: TextButton(
            onPressed: () =>
                CycleRoute(id: stokvelId, cycleId: '1').go(context),
            child: const Text('Open cycle 1'),
          ),
        ),
      );
}

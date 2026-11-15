import 'package:flutter/material.dart';
import 'package:tallyvel/core/router/app_router.dart';

/// The Stokvels tab: the list of the user's stokvels.
class StokvelsScreen extends StatelessWidget {
  /// Creates the stokvels screen.
  const StokvelsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: TextButton(
            // Placeholder so nested navigation can be tested.
            onPressed: () => const StokvelRoute(id: '1').go(context),
            child: const Text('Stokvels (tap to open stokvel 1)'),
          ),
        ),
      );
}

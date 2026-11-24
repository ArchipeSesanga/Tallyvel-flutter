import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tallyvel/core/router/app_router.dart';
import 'package:tallyvel/features/auth/data/auth_provider.dart';
import 'package:tallyvel/features/auth/domain/auth_state.dart';

/// The Profile tab.
class ProfileScreen extends ConsumerWidget {
  /// Creates the profile screen.
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final name = switch (auth) {
      SignedIn(:final displayName, :final persona) =>
        displayName ?? persona?.displayName ?? '',
      SignedOut() => '',
    };
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(name),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                ref.read(authProvider.notifier).signOut();
                // go, not push: the signed-in screens leave the stack.
                const SignInRoute().go(context);
              },
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}

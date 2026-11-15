import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tallyvel/features/auth/data/auth_provider.dart';
import 'package:tallyvel/features/auth/domain/auth_state.dart';

/// Fake sign-in: type the email of Lerato, Sipho or Thandi, or tap a chip.
///
/// On success the router's redirect moves the user on; this screen does not
/// navigate itself.
class SignInScreen extends ConsumerStatefulWidget {
  /// Creates the sign-in screen.
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    final ok = ref.read(authProvider.notifier).signInWithEmail(_email.text);
    if (!ok) setState(() => _error = 'No account with that email');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Sign in',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  onChanged: (_) => setState(() => _error = null),
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    errorText: _error,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final p in Persona.values)
                      ActionChip(
                        label: Text(p.displayName),
                        onPressed: () => setState(() {
                          _email.text = p.email;
                          _error = null;
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                FilledButton(onPressed: _submit, child: const Text('Continue')),
              ],
            ),
          ),
        ),
      );
}

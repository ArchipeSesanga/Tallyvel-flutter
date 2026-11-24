import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tallyvel/core/failures/failure.dart';
import 'package:tallyvel/features/auth/data/auth_provider.dart';
import 'package:tallyvel/features/auth/domain/auth_state.dart';

/// What the person is told when signing in fails. Shows only what helps them:
/// never the API's own wording.
String signInErrorText(Failure failure) => switch (failure) {
  UnauthorisedFailure() => 'Wrong email or password',
  ValidationFailure() => 'Check your email and password',
  RateLimitedFailure(:final retryAfterSeconds) =>
    retryAfterSeconds == null
        ? 'Too many tries. Wait a moment and try again'
        : 'Too many tries. Wait up to $retryAfterSeconds seconds',
  NoAnswerFailure() => "Can't reach TallyVel. Check your connection",
  ServerFailure(:final correlationId) =>
    'Something went wrong on our side. Quote this to support: $correlationId',
  NotFoundFailure() ||
  ForbiddenFailure() ||
  ConflictFailure() ||
  RuleFailure() ||
  UnexpectedFailure() => 'Something went wrong. Try again',
};

/// Sign in with an email and password, checked by the API.
///
/// On success the router's redirect moves the user on; this screen does not
/// navigate itself. The chips only fill in the email of a demo account.
class SignInScreen extends ConsumerStatefulWidget {
  /// Creates the sign-in screen.
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(authProvider.notifier)
          .signIn(email: _email.text, password: _password.text);
    } on Failure catch (failure) {
      if (mounted) setState(() => _error = signInErrorText(failure));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
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
            Text('Sign in', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                key: const Key('sign-in-error'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
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
            FilledButton(
              onPressed: _busy ? null : _submit,
              child: _busy
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Continue'),
            ),
          ],
        ),
      ),
    ),
  );
}

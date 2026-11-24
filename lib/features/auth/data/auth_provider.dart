import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tallyvel/app/composition_root.dart';
import 'package:tallyvel/core/failures/failure.dart';
import 'package:tallyvel/core/observability/is_worth_reporting.dart';
import 'package:tallyvel/features/auth/domain/auth_state.dart';

part 'auth_provider.g.dart';

/// The current sign-in state. Signing in goes to the real API; nothing is
/// persisted, so closing the app signs the person out.
@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  @override
  AuthState build() => const SignedOut();

  /// Signs in with [email] and [password] against the API.
  ///
  /// Throws a [Failure] when it does not work; the screen shows it. A failure
  /// worth a developer's attention is reported here too, because a method
  /// call never reaches the provider observer.
  Future<void> signIn({required String email, required String password}) async {
    try {
      final session = await ref
          .read(authRepositoryProvider)
          .signIn(email: email.trim(), password: password);
      state = SignedIn(
        Persona.fromEmail(session.email),
        displayName: session.fullName,
      );
    } on Failure catch (failure, stack) {
      if (isWorthReporting(failure)) {
        ref.read(errorReporterProvider).report(failure, stack);
      }
      rethrow;
    }
  }

  /// Signs out. The API is told in the background; offline still signs out.
  void signOut() {
    state = const SignedOut();
    unawaited(ref.read(authRepositoryProvider).signOut());
  }
}

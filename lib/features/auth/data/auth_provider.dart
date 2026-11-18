import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tallyvel/features/auth/domain/auth_state.dart';

part 'auth_provider.g.dart';

/// The current sign-in state. Fake for now: nothing is persisted.
@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  @override
  AuthState build() => const SignedOut();

  /// Signs in as the persona with [email]. Returns false if there is none.
  bool signInWithEmail(String email) {
    final persona = Persona.fromEmail(email);
    if (persona == null) return false;
    state = SignedIn(persona);
    return true;
  }

  /// Signs out.
  void signOut() => state = const SignedOut();
}

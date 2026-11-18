/// The people the fake sign-in can sign in as.
enum Persona {
  /// Lerato M.
  lerato('Lerato M.', 'lerato@tallyvel.test'),

  /// Sipho N.
  sipho('Sipho N.', 'sipho@tallyvel.test'),

  /// Thandi K.
  thandi('Thandi K.', 'thandi@tallyvel.test');

  Persona(this.displayName, this.email);

  /// Name shown in the UI.
  final String displayName;

  /// The email that signs in as this persona.
  final String email;

  /// The persona whose [email] matches [input], ignoring case and
  /// surrounding spaces, or null when there is none.
  static Persona? fromEmail(String input) {
    final wanted = input.trim().toLowerCase();
    for (final p in values) {
      if (p.email == wanted) return p;
    }
    return null;
  }
}

/// Whether someone is signed in.
sealed class AuthState {
  const AuthState();
}

/// Nobody is signed in.
class SignedOut extends AuthState {
  /// Creates the signed-out state.
  const SignedOut();
}

/// [persona] is signed in.
class SignedIn extends AuthState {
  /// Creates the signed-in state for [persona].
  const SignedIn(this.persona);

  /// Who is signed in.
  final Persona persona;
}

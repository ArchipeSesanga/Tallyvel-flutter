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

/// Someone is signed in.
class SignedIn extends AuthState {
  /// Creates the signed-in state.
  ///
  /// [persona] is the fake-world person this account is, if it is one of the
  /// three seeded accounts; the fake repositories answer from it until the
  /// real API replaces them. [displayName] is the name on the account.
  const SignedIn(this.persona, {this.displayName, this.userId});

  /// The fake-world person this account is, or null for any other account.
  final Persona? persona;

  /// The name on the account, as the API has it.
  final String? displayName;

  /// The account's id, as the API has it. `null` for a test or fake sign-in,
  /// where the fake world's id for [persona] is used instead.
  final String? userId;
}

/// Who the API says just signed in.
class AuthSession {
  /// Creates a session.
  const AuthSession({
    required this.userId,
    required this.email,
    required this.fullName,
  });

  /// The account's id, as the API has it.
  final String userId;

  /// The account's email, as the API has it.
  final String email;

  /// The name on the account.
  final String fullName;
}

/// Signs a person in and out.
abstract interface class AuthRepository {
  /// Signs in with [email] and [password].
  ///
  /// Throws a `Failure`: `UnauthorisedFailure` for a wrong email or password,
  /// `RateLimitedFailure` after too many tries, `NoAnswerFailure` when the
  /// phone cannot reach the API.
  Future<AuthSession> signIn({required String email, required String password});

  /// Forgets the session. Never throws: signing out must work offline.
  Future<void> signOut();
}

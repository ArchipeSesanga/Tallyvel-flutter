import 'package:dio/dio.dart';
import 'package:tallyvel/core/failures/failure.dart';
import 'package:tallyvel/core/network/api_client.dart';
import 'package:tallyvel/core/network/failure_mapper.dart';
import 'package:tallyvel/features/auth/domain/auth_repository.dart';

/// Signs in against the real API: `POST /auth/login`, then `GET /me` for the
/// name and email.
///
/// The access token is kept in memory only ([TokenStore]). The API's refresh
/// token is an HttpOnly `Secure` cookie, which a phone on plain http cannot
/// use, so a person signs in again when the access token ends (README).
class ApiAuthRepository implements AuthRepository {
  /// Creates a repository that talks through [_dio] and keeps the token in
  /// [_tokens].
  ApiAuthRepository(this._dio, this._tokens);

  final Dio _dio;
  final TokenStore _tokens;

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    final login = await guardApi(
      () => _dio.post<Object?>(
        '/api/v1/auth/login',
        data: {'email': email, 'password': password},
      ),
    );
    final token = switch (login.data) {
      {'accessToken': final String token} when token.isNotEmpty => token,
      _ => throw const UnexpectedFailure(),
    };

    _tokens.accessToken = token;
    try {
      final me = await guardApi(() => _dio.get<Object?>('/api/v1/me'));
      return switch (me.data) {
        {'email': final String email, 'fullName': final String fullName} =>
          AuthSession(email: email, fullName: fullName),
        _ => throw const UnexpectedFailure(),
      };
    } on Failure {
      _tokens.accessToken = null;
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _dio.post<Object?>('/api/v1/auth/logout');
    } on DioException {
      // Offline or the API is down: the person is signed out here anyway.
    } finally {
      _tokens.accessToken = null;
    }
  }
}

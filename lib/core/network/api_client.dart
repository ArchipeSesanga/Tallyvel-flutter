import 'package:dio/dio.dart';

/// The access token, in memory only. It is gone when the app closes, so a
/// person signs in again; see README → Decisions.
class TokenStore {
  /// The token to send as `Authorization: Bearer`, or null when signed out.
  String? accessToken;
}

/// The timeouts follow the measured API: it gives up on its own database
/// after 15 s, so the receive timeout is above that and the person still gets
/// the 500 with its correlation id.
const _connectTimeout = Duration(seconds: 10);
const _sendTimeout = Duration(seconds: 10);
const _receiveTimeout = Duration(seconds: 20);

/// Builds the one [Dio] the app uses: [baseUrl] from the config, JSON, the
/// timeouts above and the bearer token from [tokens]. [onUnauthorised] runs
/// when a request other than sign-in is answered 401, because the token
/// ended. [adapter] is for tests.
Dio createApiDio({
  required String baseUrl,
  required TokenStore tokens,
  void Function()? onUnauthorised,
  HttpClientAdapter? adapter,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: _connectTimeout,
      sendTimeout: _sendTimeout,
      receiveTimeout: _receiveTimeout,
      headers: {Headers.acceptHeader: Headers.jsonContentType},
    ),
  );
  if (adapter != null) dio.httpClientAdapter = adapter;
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = tokens.accessToken;
        if (token != null && !options.headers.containsKey('Authorization')) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        final path = error.requestOptions.path;
        if (error.response?.statusCode == 401 &&
            !path.startsWith('/api/v1/auth/')) {
          tokens.accessToken = null;
          onUnauthorised?.call();
        }
        handler.next(error);
      },
    ),
  );
  return dio;
}

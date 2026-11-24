import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// A canned answer for [FakeHttpAdapter].
class FakeReply {
  /// Creates an answer with [status], a JSON [body] and [headers].
  const FakeReply(this.status, {this.body, this.headers = const {}});

  /// The HTTP status.
  final int status;

  /// Encoded as JSON when not null.
  final Object? body;

  /// Response headers, lower-case names.
  final Map<String, String> headers;
}

/// Answers every request from [onRequest] and keeps what was asked, so no test
/// touches a network.
class FakeHttpAdapter implements HttpClientAdapter {
  /// Creates an adapter answering with [onRequest].
  FakeHttpAdapter(this.onRequest);

  /// Produces the answer for a request. May throw a [DioException].
  final FutureOr<FakeReply> Function(RequestOptions options) onRequest;

  /// Every request seen, in order.
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final reply = await onRequest(options);
    final bytes = reply.body == null
        ? Uint8List(0)
        : Uint8List.fromList(utf8.encode(jsonEncode(reply.body)));
    return ResponseBody.fromBytes(
      bytes,
      reply.status,
      headers: {
        if (reply.body != null)
          Headers.contentTypeHeader: ['application/problem+json'],
        for (final e in reply.headers.entries) e.key: [e.value],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

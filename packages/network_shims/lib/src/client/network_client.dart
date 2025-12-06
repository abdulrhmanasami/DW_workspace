/// Network client abstraction
abstract class NetworkClient {
  Future<NetworkResponse> get(final String url,
      {final Map<String, String>? headers});
  Future<NetworkResponse> post(final String url,
      {final Map<String, String>? headers, final Object? body});
  Future<NetworkResponse> put(final String url,
      {final Map<String, String>? headers, final Object? body});
  Future<NetworkResponse> delete(final String url,
      {final Map<String, String>? headers});
}

class NetworkResponse {
  const NetworkResponse({
    required this.statusCode,
    required this.body,
    this.headers = const <String, String>{},
  });

  final int statusCode;
  final String body;
  final Map<String, String> headers;
}

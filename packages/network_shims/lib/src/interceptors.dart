/// Request and Response Interceptors
/// Created by: Cursor (auto-generated)
/// Purpose: HTTP interceptors for request/response manipulation
/// Last updated: 2025-11-04

/// Base request interceptor
abstract class RequestInterceptor {
  /// Called before a request is sent
  Future<void> onRequest(
      String url, Map<String, dynamic>? headers, dynamic data);
}

/// Base response interceptor
abstract class ResponseInterceptor {
  /// Called after a response is received
  Future<void> onResponse(dynamic response);
}

/// Logging interceptor for debugging
class LoggingInterceptor implements RequestInterceptor, ResponseInterceptor {
  @override
  Future<void> onRequest(
      String url, Map<String, dynamic>? headers, dynamic data) async {
    print('HTTP Request: $url');
    if (headers != null) print('Headers: $headers');
    if (data != null) print('Data: $data');
  }

  @override
  Future<void> onResponse(dynamic response) async {
    print('HTTP Response: $response');
  }
}

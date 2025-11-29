// Network Models and Data Classes
// Created by: Cursor (auto-generated)
// Purpose: Data models for network operations
// Last updated: 2025-11-04

/// HTTP Response wrapper
class Response {
  final int statusCode;
  final dynamic data;
  final Map<String, dynamic>? headers;
  final String? error;

  Response({
    required this.statusCode,
    this.data,
    this.headers,
    this.error,
  });

  bool get isSuccessful => statusCode >= 200 && statusCode < 300;

  @override
  String toString() =>
      'Response(status: $statusCode, data: $data, error: $error)';
}

/// Request configuration
class RequestConfig {
  final String url;
  final String method;
  final Map<String, dynamic>? headers;
  final dynamic data;
  final Duration? timeout;

  RequestConfig({
    required this.url,
    required this.method,
    this.headers,
    this.data,
    this.timeout,
  });
}

class HttpHeaders {
  final Map<String, String> value;
  const HttpHeaders(this.value);
}

class HttpRequest {
  final String url;
  final String method;
  final dynamic body;
  final HttpHeaders headers;

  const HttpRequest({
    required this.url,
    required this.method,
    this.body,
    this.headers = const HttpHeaders({}),
  });
}

class HttpResponse<T> {
  final int status;
  final T? data;
  final HttpHeaders headers;

  const HttpResponse({
    required this.status,
    this.data,
    this.headers = const HttpHeaders({}),
  });
}

class CertificatePinningConfig {
  final List<String> allowedSpkiSha256;
  const CertificatePinningConfig(this.allowedSpkiSha256);
}

class CertificatePinningPolicy {
  final bool enabled;
  final CertificatePinningConfig? config;
  final List<String> hosts;
  final List<List<int>> certificateDerPins;
  final bool allowSelfSigned;

  const CertificatePinningPolicy({
    required this.enabled,
    this.config,
    this.hosts = const [],
    this.certificateDerPins = const [],
    this.allowSelfSigned = false,
  });

  bool appliesTo(String host) {
    if (!enabled) return false;
    if (hosts.isEmpty) return true;
    return hosts.contains(host);
  }
}

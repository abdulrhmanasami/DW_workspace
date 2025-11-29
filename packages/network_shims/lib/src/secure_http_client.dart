import 'dart:convert';
import 'dart:io';

import 'certificate_pinning.dart';
import 'models.dart';

/// Component: Secure HTTP Client
/// Created by: Cursor (auto-generated)
/// Purpose: Production-grade secure HTTP client interface
/// Last updated: 2025-11-02

/// HTTP request wrapper
class Request {
  final String method;
  final Uri url;
  final Map<String, String> headers;
  final dynamic body;

  const Request({
    required this.method,
    required this.url,
    this.headers = const {},
    this.body,
  });

  /// Creates a GET request
  factory Request.get(Uri url, {Map<String, String> headers = const {}}) {
    return Request(method: 'GET', url: url, headers: headers);
  }

  /// Creates a POST request
  factory Request.post(
    Uri url, {
    Map<String, String> headers = const {},
    dynamic body,
  }) {
    return Request(method: 'POST', url: url, headers: headers, body: body);
  }

  /// Creates a PUT request
  factory Request.put(
    Uri url, {
    Map<String, String> headers = const {},
    dynamic body,
  }) {
    return Request(method: 'PUT', url: url, headers: headers, body: body);
  }

  /// Creates a DELETE request
  factory Request.delete(Uri url, {Map<String, String> headers = const {}}) {
    return Request(method: 'DELETE', url: url, headers: headers);
  }

  /// Creates a PATCH request
  factory Request.patch(
    Uri url, {
    Map<String, String> headers = const {},
    dynamic body,
  }) {
    return Request(method: 'PATCH', url: url, headers: headers, body: body);
  }
}

/// Secure HTTP client interface that handles certificate pinning and secure communication
abstract class SecureHttpClient {
  /// Sends an HTTP request and returns the response
  Future<StreamedResponse> send(Request request);

  /// Closes the client and cleans up resources
  void close();
}

/// Alias retained for backwards compatibility with older shims that expect an
/// `HttpClient` type distinct from [SecureHttpClient].
typedef HttpClient = SecureHttpClient;

/// HTTP client factory interface
abstract class HttpClientFactory {
  /// Creates a secure HTTP client with optional certificate pinning
  SecureHttpClient create({CertificatePinningPolicy? pinning});

  /// Legacy method for backward compatibility - creates HttpClient
  HttpClient createClient({
    required List<CertificatePinningPolicy> pinningPolicies,
    SecurityContext? securityContext,
  }) {
    return create(
      pinning: pinningPolicies.isNotEmpty ? pinningPolicies.first : null,
    );
  }
}

/// Streamed response wrapper for HTTP responses
class StreamedResponse {
  final Stream<List<int>> stream;
  final int statusCode;
  final Map<String, String> headers;
  final String? reasonPhrase;

  const StreamedResponse({
    required this.stream,
    required this.statusCode,
    required this.headers,
    this.reasonPhrase,
  });

  /// Converts the streamed response to a string (for JSON/text responses)
  Future<String> text() async {
    final bytes = await stream.expand((chunk) => chunk).toList();
    return utf8.decode(bytes);
  }

  /// Converts the streamed response to bytes
  Future<List<int>> bytes() async {
    return stream.expand((chunk) => chunk).toList();
  }

  /// Decodes JSON response
  Future<dynamic> json() async {
    final text = await this.text();
    return jsonDecode(text);
  }
}

/// Certificate pinning policy that can be injected into the secure client
/// This allows runtime configuration of pinning behavior
class CertificatePinningInjector {
  final List<CertificatePinningPolicy> policies;

  const CertificatePinningInjector(this.policies);

  /// Applies the pinning policies to certificate validation
  /// Returns true if the certificate should be accepted
  bool validateCertificate(
    List<int> certificateBytes,
    String host,
  ) {
    final hostPolicies = policies.where((policy) => policy.appliesTo(host));

    if (hostPolicies.isEmpty) {
      // Fail-closed: No policies for this host means reject
      return false;
    }

    // Calculate fingerprint using the factory method
    // This will be implemented by concrete HttpClientFactory
    throw UnimplementedError(
      'Fingerprint calculation and validation must be implemented by concrete client',
    );
  }
}

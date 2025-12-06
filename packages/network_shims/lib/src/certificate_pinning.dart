// Certificate Pinning Configuration & Implementation
//
// Translates the abstract SecureHttpClient interface into a production-grade
// pinned HTTP client backed by dart:io.

import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:crypto/crypto.dart' as crypto;

import 'models.dart' as models;
import 'secure_http_client.dart';

/// Creates a secure HTTP client with TLS pinning.
///
/// When [pinningPolicies] is empty the method returns `null` unless
/// [allowUnpinnedClients] is true. This allows dev/test builds to degrade
/// gracefully while production builds fail fast if pins are missing.
SecureHttpClient? getSecureHttpClient({
  required List<models.CertificatePinningPolicy> pinningPolicies,
  io.SecurityContext? securityContext,
  Duration connectTimeout = const Duration(seconds: 10),
  Duration idleTimeout = const Duration(seconds: 30),
  bool allowUnpinnedClients = false,
}) {
  final activePolicies =
      pinningPolicies.where((policy) => policy.enabled).toList();

  if (activePolicies.isEmpty) {
    if (!allowUnpinnedClients) {
      return null;
    }
    return _InsecureSecureHttpClient(
      connectTimeout: connectTimeout,
      idleTimeout: idleTimeout,
    );
  }

  return _PinnedSecureHttpClient(
    policies: activePolicies,
    securityContext: securityContext,
    connectTimeout: connectTimeout,
    idleTimeout: idleTimeout,
  );
}

class _PinnedSecureHttpClient implements SecureHttpClient {
  _PinnedSecureHttpClient({
    required List<models.CertificatePinningPolicy> policies,
    io.SecurityContext? securityContext,
    required Duration connectTimeout,
    required Duration idleTimeout,
  })  : _validator = _PinningValidator(policies),
        _client = io.HttpClient(context: securityContext) {
    _client.connectionTimeout = connectTimeout;
    _client.idleTimeout = idleTimeout;
    _client.badCertificateCallback =
        (io.X509Certificate cert, String host, int port) {
      return _validator.allowBadCertificate(host, cert);
    };
  }

  final io.HttpClient _client;
  final _PinningValidator _validator;

  @override
  Future<StreamedResponse> send(Request request) async {
    final httpRequest = await _client.openUrl(request.method, request.url);
    request.headers.forEach((key, value) {
      if (value.isNotEmpty) {
        httpRequest.headers.set(key, value);
      }
    });

    final bodyBytes = _encodeBody(request);
    if (bodyBytes != null) {
      httpRequest.add(bodyBytes);
    }

    final response = await httpRequest.close();
    if (!_validator.validateResponse(request.url.host, response.certificate)) {
      await response.drain<void>();
      throw const TlsPinningException('TLS pinning validation failed');
    }

    return StreamedResponse(
      stream: response,
      statusCode: response.statusCode,
      headers: _copyHeaders(response.headers),
      reasonPhrase: response.reasonPhrase,
    );
  }

  @override
  void close() {
    _client.close(force: true);
  }
}

class _InsecureSecureHttpClient implements SecureHttpClient {
  _InsecureSecureHttpClient({
    required Duration connectTimeout,
    required Duration idleTimeout,
  }) {
    _client.connectionTimeout = connectTimeout;
    _client.idleTimeout = idleTimeout;
  }

  final io.HttpClient _client = io.HttpClient();

  @override
  Future<StreamedResponse> send(Request request) async {
    final httpRequest = await _client.openUrl(request.method, request.url);
    request.headers.forEach((key, value) {
      if (value.isNotEmpty) {
        httpRequest.headers.set(key, value);
      }
    });

    final bodyBytes = _encodeBody(request);
    if (bodyBytes != null) {
      httpRequest.add(bodyBytes);
    }

    final response = await httpRequest.close();
    return StreamedResponse(
      stream: response,
      statusCode: response.statusCode,
      headers: _copyHeaders(response.headers),
      reasonPhrase: response.reasonPhrase,
    );
  }

  @override
  void close() {
    _client.close(force: true);
  }
}

class _PinningValidator {
  _PinningValidator(this._policies);

  final List<models.CertificatePinningPolicy> _policies;

  bool allowBadCertificate(String host, io.X509Certificate certificate) {
    return _activePolicies(host)
        .any((policy) => policy.allowSelfSigned && policy.enabled);
  }

  bool validateResponse(String host, io.X509Certificate? certificate) {
    final policies = _activePolicies(host);
    if (policies.isEmpty) {
      return false;
    }

    if (certificate == null) {
      return policies.any((policy) => policy.allowSelfSigned);
    }

    final fingerprint = _fingerprint(certificate.der);

    for (final policy in policies) {
      final allowedHashes = policy.config?.allowedSpkiSha256 ?? const [];
      if (allowedHashes.contains(fingerprint)) {
        return true;
      }

      for (final derPin in policy.certificateDerPins) {
        if (_bytesEqual(derPin, certificate.der)) {
          return true;
        }
      }

      if (policy.allowSelfSigned) {
        return true;
      }
    }

    return false;
  }

  List<models.CertificatePinningPolicy> _activePolicies(String host) {
    return _policies.where((policy) => policy.appliesTo(host)).toList();
  }

  String _fingerprint(List<int> derBytes) {
    final digest = crypto.sha256.convert(derBytes);
    return base64Encode(digest.bytes);
  }
}

class TlsPinningException implements Exception {
  const TlsPinningException(this.message);
  final String message;

  @override
  String toString() => 'TlsPinningException($message)';
}

List<int>? _encodeBody(Request request) {
  final body = request.body;
  if (body == null) return null;

  if (body is List<int>) {
    return body;
  }

  if (body is String) {
    return utf8.encode(body);
  }

  if (body is Map<String, dynamic> || body is List<dynamic>) {
    if (!request.headers.containsKey('content-type')) {
      request.headers['content-type'] = 'application/json';
    }
    return utf8.encode(jsonEncode(body));
  }

  return utf8.encode(body.toString());
}

Map<String, String> _copyHeaders(io.HttpHeaders headers) {
  final map = <String, String>{};
  headers.forEach((name, values) {
    if (values.isNotEmpty) {
      map[name] = values.join(',');
    }
  });
  return map;
}

bool _bytesEqual(List<int> a, List<int> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}

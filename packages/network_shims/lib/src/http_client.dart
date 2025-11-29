/// Default HTTP client factory backed by the certificate pinning utilities.
///
/// This implementation exposes a tiny API surface that mirrors historic Clean-B
/// expectations (`create`, `createClient`, `createSecure`) while delegating the
/// heavy lifting to `getSecureHttpClient` in `certificate_pinning.dart`. The
/// factory enforces a single source of truth for timeouts, pinning policies, and
/// fallback behavior (whether unpinned clients are allowed).
import 'dart:io';

import 'certificate_pinning.dart';
import 'models.dart';
import 'secure_http_client.dart';

class DefaultHttpClientFactory implements HttpClientFactory {
  DefaultHttpClientFactory({
    List<CertificatePinningPolicy> pinningPolicies = const [],
    bool allowUnpinnedClients = false,
    SecurityContext? securityContext,
    Duration connectTimeout = const Duration(seconds: 10),
    Duration idleTimeout = const Duration(seconds: 30),
  })  : _pinningPolicies = List<CertificatePinningPolicy>.unmodifiable(
          pinningPolicies,
        ),
        _allowUnpinnedClients = allowUnpinnedClients,
        _securityContext = securityContext,
        _connectTimeout = connectTimeout,
        _idleTimeout = idleTimeout;

  final List<CertificatePinningPolicy> _pinningPolicies;
  final bool _allowUnpinnedClients;
  final SecurityContext? _securityContext;
  final Duration _connectTimeout;
  final Duration _idleTimeout;

  /// Returns the policies baked into this factory.
  List<CertificatePinningPolicy> get policies => _pinningPolicies;

  /// True when the factory may fall back to an insecure client (debug/dev only).
  bool get allowsUnpinnedClients => _allowUnpinnedClients;

  @override
  SecureHttpClient create({CertificatePinningPolicy? pinning}) {
    final mergedPolicies = [
      if (pinning != null) pinning,
      ..._pinningPolicies,
    ];
    return _buildClient(mergedPolicies);
  }

  @override
  HttpClient createClient({
    required List<CertificatePinningPolicy> pinningPolicies,
    SecurityContext? securityContext,
  }) {
    final mergedPolicies =
        pinningPolicies.isEmpty ? _pinningPolicies : pinningPolicies;
    return _buildClient(
      mergedPolicies,
      securityContextOverride: securityContext,
    );
  }

  /// Creates a new pinned client using the provided (or default) policies.
  SecureHttpClient _buildClient(
    List<CertificatePinningPolicy> policies, {
    SecurityContext? securityContextOverride,
  }) {
    final effectivePolicies =
        policies.where((policy) => policy.enabled).toList(growable: false);

    final client = getSecureHttpClient(
      pinningPolicies:
          effectivePolicies.isEmpty ? _pinningPolicies : effectivePolicies,
      securityContext: securityContextOverride ?? _securityContext,
      connectTimeout: _connectTimeout,
      idleTimeout: _idleTimeout,
      allowUnpinnedClients: _allowUnpinnedClients,
    );

    if (client == null) {
      throw StateError(
        'SecureHttpClient unavailable: no pinning policies were provided and '
        'allowUnpinnedClients is $_allowUnpinnedClients.',
      );
    }

    return client;
  }

  /// Returns a copy with tweaked properties (useful for per-service overrides).
  DefaultHttpClientFactory copyWith({
    List<CertificatePinningPolicy>? pinningPolicies,
    bool? allowUnpinnedClients,
    SecurityContext? securityContext,
    Duration? connectTimeout,
    Duration? idleTimeout,
  }) {
    return DefaultHttpClientFactory(
      pinningPolicies: pinningPolicies ?? _pinningPolicies,
      allowUnpinnedClients: allowUnpinnedClients ?? _allowUnpinnedClients,
      securityContext: securityContext ?? _securityContext,
      connectTimeout: connectTimeout ?? _connectTimeout,
      idleTimeout: idleTimeout ?? _idleTimeout,
    );
  }
}

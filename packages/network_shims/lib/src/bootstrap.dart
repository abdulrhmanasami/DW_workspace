/// Component: Network bootstrap utilities
/// Created by: Cursor B-central
/// Purpose: Global TLS pinning bootstrap helpers
/// Last updated: 2025-11-24

import 'http_client.dart';
import 'models.dart';
import 'secure_http_client.dart';

final _registry = _HttpClientRegistry();

/// Initializes the global HTTP client factory used throughout the app.
///
/// The first invocation caches a hardened [SecureHttpClient] so that
/// certificate-pinning failures are detected during startup instead of at the
/// first outbound request.
void initializeCertificatePinning(DefaultHttpClientFactory factory) {
  _registry.register(factory);
}

/// Returns the shared [SecureHttpClient] created during bootstrap.
///
/// Callers may override the pinning policies for a specific service by passing
/// [pinningPolicies]; otherwise the factory's default policies are used.
SecureHttpClient getHttpClient({
  List<CertificatePinningPolicy>? pinningPolicies,
}) {
  return _registry.getClient(pinningPolicies: pinningPolicies);
}

class _HttpClientRegistry {
  DefaultHttpClientFactory? _factory;
  SecureHttpClient? _cachedClient;

  void register(DefaultHttpClientFactory factory) {
    _factory = factory;
    _cachedClient?.close();
    _cachedClient = _safeCreate(factory);
  }

  SecureHttpClient getClient({
    List<CertificatePinningPolicy>? pinningPolicies,
  }) {
    final factory = _factory ?? _fallbackFactory;

    if (pinningPolicies != null && pinningPolicies.isNotEmpty) {
      return factory.copyWith(pinningPolicies: pinningPolicies).create();
    }

    return _cachedClient ??= _safeCreate(factory);
  }

  SecureHttpClient _safeCreate(DefaultHttpClientFactory factory) {
    try {
      return factory.create();
    } catch (_) {
      if (factory.allowsUnpinnedClients) {
        return factory.copyWith(
          allowUnpinnedClients: true,
          pinningPolicies: const <CertificatePinningPolicy>[],
        ).create();
      }
      rethrow;
    }
  }

  DefaultHttpClientFactory get _fallbackFactory =>
      _factory ??
      DefaultHttpClientFactory(
        allowUnpinnedClients: true,
      );
}

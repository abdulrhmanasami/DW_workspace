import 'dart:core';

import 'package:network_shims/network_shims.dart'
    show CertificatePinningConfig, CertificatePinningPolicy;

/// Deployment presets for the privacy backend.
enum PrivacyBackendEnvironment {
  staging,
  production,
}

/// Configuration object that defines how the privacy services reach the backend.
class PrivacyBackendConfig {
  PrivacyBackendConfig({
    required this.baseUrl,
    this.dsarPath = '/v1/privacy/dsar',
    this.consentPath = '/v1/privacy/consent',
    this.deletionPath = '/v1/privacy/delete',
    this.defaultHeaders = const {},
  });

  /// Convenience constructor that resolves a preset environment.
  factory PrivacyBackendConfig.fromEnvironment(
    PrivacyBackendEnvironment environment,
  ) {
    switch (environment) {
      case PrivacyBackendEnvironment.production:
        return PrivacyBackendConfig(
          baseUrl: Uri.parse('https://privacy.delivery-ways.com'),
        );
      case PrivacyBackendEnvironment.staging:
        return PrivacyBackendConfig(
          baseUrl: Uri.parse('https://staging.privacy.delivery-ways.com'),
        );
    }
  }

  final Uri baseUrl;
  final String dsarPath;
  final String consentPath;
  final String deletionPath;
  final Map<String, String> defaultHeaders;

  /// Resolve a relative path against the configured [baseUrl].
  Uri resolve(String path) {
    final normalized = path.startsWith('/') ? path.substring(1) : path;
    return baseUrl.resolve(normalized);
  }

  /// Builds HTTP headers by merging defaults with optional overrides.
  Map<String, String> headers([Map<String, String>? overrides]) {
    if (defaultHeaders.isEmpty && (overrides == null || overrides.isEmpty)) {
      return const {};
    }
    return {
      ...defaultHeaders,
      if (overrides != null) ...overrides,
    };
  }
}

/// Base class for all privacy/DSAR related failures that originate from the backend.
class PrivacyBackendException implements Exception {
  PrivacyBackendException(this.message, [this.statusCode]);

  final String message;
  final int? statusCode;

  @override
  String toString() =>
      'PrivacyBackendException(statusCode: $statusCode, message: $message)';
}

extension PrivacyTlsPolicies on PrivacyBackendConfig {
  List<CertificatePinningPolicy> toPinningPolicies() {
    final host = baseUrl.host;
    if (host.isEmpty) {
      return const [];
    }

    final pinHeader = defaultHeaders['x-privacy-pin-sha256'];
    final pins = _parsePins(pinHeader);
    final hasPins = pins.isNotEmpty;

    final isStagingHost =
        host.contains('staging') || host.contains('localhost') || host == '127.0.0.1';

    if (!hasPins && !isStagingHost) {
      return const [];
    }

    return [
      CertificatePinningPolicy(
        enabled: true,
        hosts: [host],
        config: pins.isEmpty ? null : CertificatePinningConfig(pins),
        allowSelfSigned: isStagingHost && pins.isEmpty,
      ),
    ];
  }
}

List<String> _parsePins(String? header) {
  if (header == null || header.trim().isEmpty) {
    return const [];
  }
  return header
      .split(',')
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toList();
}


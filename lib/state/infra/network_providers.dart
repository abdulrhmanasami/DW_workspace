/// Component: Network providers
/// Created by: Cursor B-central
/// Purpose: Riverpod wiring for SecureHttpClient + TLS pinning
/// Last updated: 2025-11-24

import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network_shims/index.dart'
    show DefaultHttpClientFactory, CertificatePinningPolicy;
import 'package:network_shims/network_shims.dart' show SecureHttpClient;

import 'feature_flags.dart' show certPinningEnabledProvider;

/// Exposes the certificate pinning policies pulled from config/Remote Config.
///
/// TODO: Wire real policies once backend delivers definitive fingerprints.
final certificatePinningPoliciesProvider =
    Provider<List<CertificatePinningPolicy>>((ref) {
      return const <CertificatePinningPolicy>[];
    });

/// Allows controlled fallback to the insecure path in debug/dev environments.
final allowUnpinnedClientsProvider = Provider<bool>((ref) {
  final enablePinning = ref.watch(certPinningEnabledProvider);
  return !enablePinning;
});

/// Shared [SecureHttpClient] configured with the current pinning policies.
final secureHttpClientProvider = Provider<SecureHttpClient>((ref) {
  final policies = ref.watch(certificatePinningPoliciesProvider);
  final allowUnpinned = ref.watch(allowUnpinnedClientsProvider);

  final factory = DefaultHttpClientFactory(
    pinningPolicies: policies,
    allowUnpinnedClients: allowUnpinned,
  );

  final client = factory.create();

  if (allowUnpinned && policies.isEmpty) {
    log(
      'SecureHttpClient running without active pinning policies '
      '(allowUnpinnedClients=true).',
      name: 'network_providers',
    );
  }

  ref.onDispose(client.close);
  return client;
});

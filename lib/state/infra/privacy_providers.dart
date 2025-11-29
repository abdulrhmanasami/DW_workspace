import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network_shims/index.dart' show DefaultHttpClientFactory;
import 'package:network_shims/network_shims.dart' as nw;
import 'package:privacy/privacy.dart';

/// Privacy backend configuration provider.
final privacyBackendConfigProvider = Provider<PrivacyBackendConfig>((ref) {
  // TODO: replace hardcoded environment with RemoteConfig/Build flavor.
  const env = PrivacyBackendEnvironment.staging;
  return PrivacyBackendConfig.fromEnvironment(env);
});

/// Shared SecureHttpClient wired through network_shims with TLS pinning.
final privacySecureClientProvider = Provider<nw.SecureHttpClient>((ref) {
  final config = ref.watch(privacyBackendConfigProvider);
  final policies = config.toPinningPolicies();
  final factory = DefaultHttpClientFactory(
    pinningPolicies: policies,
    allowUnpinnedClients: !kReleaseMode,
  );
  final client = factory.create();
  ref.onDispose(client.close);
  return client;
});

/// Exposes the PrivacyCenter façade to the rest of the app.
final privacyCenterProvider = Provider<PrivacyCenter>((ref) {
  final config = ref.watch(privacyBackendConfigProvider);
  final client = ref.watch(privacySecureClientProvider);
  return createPrivacyCenter(client: client, config: config);
});

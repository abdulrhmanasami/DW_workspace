/// Remote Config Riverpod Providers

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network_shims/index.dart' show DefaultHttpClientFactory;
import 'package:network_shims/network_shims.dart' show SecureHttpClient;

import '../src/remote_config/remote_config_service.dart';
import '../src/remote_config/rc_service_impl.dart';
import '../src/remote_config/rc_client.dart';
import '../src/remote_config/rc_sources.dart';
import '../config_manager.dart';

/// Provides the SecureHttpClient used by Remote Config.
final remoteConfigHttpClientProvider = Provider<SecureHttpClient>((ref) {
  final factory = DefaultHttpClientFactory(
    allowUnpinnedClients: true,
  );
  final client = factory.create();
  ref.onDispose(client.close);
  return client;
});

/// Remote Config Service Provider
final remoteConfigProvider = Provider<RemoteConfigService>((ref) {
  final configManager = ConfigManager.instance;
  final httpClient = ref.watch(remoteConfigHttpClientProvider);

  // Create HTTP client
  final client = RemoteConfigClient(
    configManager: configManager,
    httpClient: httpClient,
  );

  // Create sources
  final backendSource = BackendRemoteConfigSource(client);
  final defaultSource = InMemoryDefaultsSource();
  final compositeSource = CompositeConfigSource(
    backend: backendSource,
    defaults: defaultSource,
  );

  // Create service
  final service = RemoteConfigServiceImpl(source: compositeSource);

  // Initialize with defaults
  service.ensureInitialized();

  return service;
});

/// Remote Config Helpers for easy access
bool rcBool(Ref ref, String key, {bool defaultValue = false}) =>
    ref.watch(remoteConfigProvider).getBool(key, defaultValue: defaultValue);

String rcString(Ref ref, String key, {String defaultValue = ''}) =>
    ref.watch(remoteConfigProvider).getString(key, defaultValue: defaultValue);

double rcDouble(Ref ref, String key, {double defaultValue = 0.0}) =>
    ref.watch(remoteConfigProvider).getDouble(key, defaultValue: defaultValue);

int rcInt(Ref ref, String key, {int defaultValue = 0}) =>
    ref.watch(remoteConfigProvider).getInt(key, defaultValue: defaultValue);

Map<String, dynamic> rcJson(
  Ref ref,
  String key, {
  Map<String, dynamic> defaultValue = const {},
}) =>
    ref.watch(remoteConfigProvider).getJson(key, defaultValue: defaultValue);

/// Convenience providers for specific feature flags
final stripeGpayEnabledProvider = Provider<bool>(
  (ref) => rcBool(ref, RemoteConfigKeys.stripeGpayEnabled, defaultValue: false),
);

final trackingEnabledProvider = Provider<bool>(
  (ref) => rcBool(ref, RemoteConfigKeys.trackingEnabled, defaultValue: false),
);

final mapsProviderKeyProvider = Provider<String>(
  (ref) => rcString(
    ref,
    RemoteConfigKeys.mapsProvider,
    defaultValue: MapsProviderValues.google,
  ),
);

final paymentsEnvProvider = Provider<String>(
  (ref) => rcString(
    ref,
    RemoteConfigKeys.paymentsEnv,
    defaultValue: PaymentsEnvValues.test,
  ),
);

final uiThemeProvider = Provider<String>(
  (ref) => rcString(ref, RemoteConfigKeys.uiTheme, defaultValue: 'default'),
);

/// Provider for fetching remote config (call this on app start)
final fetchRemoteConfigProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(remoteConfigProvider);
  await service.fetchAndActivate();
});

/// Provider for remote config status
final remoteConfigStatusProvider = Provider<RemoteConfigStatus>((ref) {
  final service = ref.watch(remoteConfigProvider);
  return RemoteConfigStatus(
    lastFetchTime: service.getLastFetchTime(),
    hasData: service.hasKey(RemoteConfigKeys.stripeGpayEnabled),
  );
});

/// Remote config status model
class RemoteConfigStatus {
  final DateTime? lastFetchTime;
  final bool hasData;

  const RemoteConfigStatus({this.lastFetchTime, required this.hasData});

  bool get isInitialized => lastFetchTime != null;
}

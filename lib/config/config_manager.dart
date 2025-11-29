/// Component: AppConfig
/// Created by: Cursor (auto-generated)
/// Purpose: Environment-based application configuration with fail-closed policies
/// Last updated: 2025-11-01

import 'local_config_service.dart';
import 'package:foundation_shims/foundation_shims.dart' as fnd;

/// AppConfig provides environment-based configuration for fail-closed feature behavior
class AppConfig {
  // Environment variables from --dart-define
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static const stripeKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: '',
  );
  static const telemetryDsn = String.fromEnvironment(
    'TELEMETRY_DSN',
    defaultValue: '',
  );

  // Feature availability flags
  static bool get hasPayments => stripeKey.isNotEmpty;
  static bool get hasTelemetry => telemetryDsn.isNotEmpty;
  static bool get hasBackend => apiBaseUrl.isNotEmpty;

  // Policy banners for missing features
  static const String backendPolicyMessage =
      'Backend services are currently unavailable. '
      'Please check your configuration or contact support.';
  static const String paymentsPolicyMessage =
      'Payment services are currently unavailable. '
      'Please check your configuration or contact support.';
  static const String telemetryPolicyMessage =
      'Analytics services are disabled for privacy.';

  /// Check if a feature requires backend and if backend is available
  static bool canUseBackendFeature() => hasBackend;

  /// Check if a feature requires payments and if payments are available
  static bool canUsePaymentFeature() => hasPayments;

  /// Check if a feature requires telemetry and if telemetry is available
  static bool canUseTelemetryFeature() => hasTelemetry;
}

/// Component: ConfigManager
/// Created by: Cursor (auto-generated)
/// Purpose: Configuration manager with local and remote config services
/// Last updated: 2025-11-01

class ConfigManager implements fnd.ConfigManager {
  ConfigManager({
    required LocalConfigService localService,
    fnd.RemoteConfigService? remoteService,
    String? fallbackBaseUrl,
  })  : _localService = localService,
        _remoteService = remoteService,
        _fallbackBaseUrl = fallbackBaseUrl ?? AppConfig.apiBaseUrl {
    _seedDefaults();
  }

  final LocalConfigService _localService;
  final fnd.RemoteConfigService? _remoteService;
  final String _fallbackBaseUrl;

  static ConfigManager? _instance;

  /// Returns the shared application config manager (lazily created).
  static ConfigManager get instance {
    return _instance ??= ConfigManager(
      localService: LocalConfigService(),
    );
  }

  /// Registers [manager] as both the app-level singleton and the shared shim.
  static void registerGlobal(ConfigManager manager) {
    _instance = manager;
    fnd.ConfigManager.register(manager);
  }

  void _seedDefaults() {
    if (AppConfig.apiBaseUrl.isNotEmpty) {
      _localService.set<String>('api.baseUrl', AppConfig.apiBaseUrl);
    }
  }

  /// Optional hook to warm remote config.
  Future<void> initialize() async {
    await _remoteService?.fetchAndActivate();
  }

  @override
  String get apiBaseUrl {
    return _lookupString('api.baseUrl') ??
        (_fallbackBaseUrl.isNotEmpty
            ? _fallbackBaseUrl
            : 'https://api.deliveryways.com');
  }

  @override
  String? getString(String key, {String? defaultValue}) {
    return _lookupString(key) ?? defaultValue;
  }

  @override
  int? getInt(String key, {int? defaultValue}) {
    return _lookupInt(key) ?? defaultValue;
  }

  @override
  bool? getBool(String key, {bool? defaultValue}) {
    return _lookupBool(key) ?? defaultValue;
  }

  @override
  double? getDouble(String key, {double? defaultValue}) {
    return _lookupDouble(key) ?? defaultValue;
  }

  String? _lookupString(String key) {
    final localValue = _localService.get<String>(key);
    if (localValue != null && localValue.isNotEmpty) {
      return localValue;
    }

    final remote = _remoteService;
    if (remote != null && remote.hasKey(key)) {
      final remoteValue = remote.getString(key);
      return remoteValue.isEmpty ? null : remoteValue;
    }

    return null;
  }

  int? _lookupInt(String key) {
    final localValue = _localService.get<int>(key);
    if (localValue != null) {
      return localValue;
    }

    final remote = _remoteService;
    if (remote != null && remote.hasKey(key)) {
      return remote.getInt(key);
    }

    return null;
  }

  bool? _lookupBool(String key) {
    final localValue = _localService.get<bool>(key);
    if (localValue != null) {
      return localValue;
    }

    final remote = _remoteService;
    if (remote != null && remote.hasKey(key)) {
      return remote.getBool(key);
    }

    return null;
  }

  double? _lookupDouble(String key) {
    final localValue = _localService.get<double>(key);
    if (localValue != null) {
      return localValue;
    }

    final remote = _remoteService;
    if (remote != null && remote.hasKey(key)) {
      return remote.getDouble(key);
    }

    return null;
  }

  /// Allows tests to override configuration at runtime.
  void overrideValue<T>(String key, T value) => _localService.set<T>(key, value);
}

/// Remote Config Service Interface
/// Provides unified access to feature flags and configuration values
/// with backend JSON source and local fallback

abstract class RemoteConfigService {
  /// Fetch latest configuration from backend and activate it
  Future<void> fetchAndActivate();

  /// Get boolean value for key
  bool getBool(String key, {bool defaultValue = false});

  /// Get string value for key
  String getString(String key, {String defaultValue = ''});

  /// Get double value for key
  double getDouble(String key, {double defaultValue = 0.0});

  /// Get JSON object value for key
  Map<String, dynamic> getJson(
    String key, {
    Map<String, dynamic> defaultValue = const {},
  });

  /// Get integer value for key
  int getInt(String key, {int defaultValue = 0});

  /// Get boolean map value for key
  Map<String, bool> getBoolMap(
    String key, {
    Map<String, bool> defaultValue = const {},
  });

  /// Check if a key exists in configuration
  bool hasKey(String key);

  /// Get last fetch timestamp
  DateTime? getLastFetchTime();

  /// Force refresh (bypass cache)
  Future<void> forceRefresh();
}

/// Feature flag keys (standardized)
class RemoteConfigKeys {
  static const String stripeGpayEnabled = 'stripe_gpay_enabled';
  static const String trackingEnabled = 'tracking_enabled';
  static const String mapsProvider = 'maps_provider';
  static const String paymentsEnv = 'payments_env';
  static const String uiTheme = 'ui_theme';
  static const String certPinningEnabled = 'security_cert_pinning_enabled';

  // Tracking configuration
  static const String trackingSampleIntervalMs = 'tracking_sample_interval_ms';
  static const String trackingAccuracy = 'tracking_accuracy';
  static const String trackingMode = 'tracking_mode';

  // Uplink configuration
  static const String trackingUplinkEnabled = 'tracking_uplink_enabled';
  static const String trackingUplinkFlushIntervalMs =
      'tracking_uplink_flush_interval_ms';
  static const String trackingUplinkBatchSize = 'tracking_uplink_batch_size';
  static const String trackingUplinkEndpointBase =
      'tracking_uplink_endpoint_base';

  // Prevent instantiation
  RemoteConfigKeys._();
}

/// Maps provider values
class MapsProviderValues {
  static const String google = 'google';
  static const String stub = 'stub';
}

/// Payments environment values
class PaymentsEnvValues {
  static const String test = 'test';
  static const String prod = 'prod';
}

/// Tracking accuracy values
class TrackingAccuracyValues {
  static const String low = 'low';
  static const String balanced = 'balanced';
  static const String high = 'high';
}

/// Tracking mode values
class TrackingModeValues {
  static const String foreground = 'foreground';
  static const String background = 'background';
  static const String auto = 'auto';
}

/// Configuration fetch result
class FetchResult {
  final bool success;
  final String? error;
  final Duration? fetchDuration;

  const FetchResult({required this.success, this.error, this.fetchDuration});

  factory FetchResult.success([Duration? duration]) =>
      FetchResult(success: true, fetchDuration: duration);

  factory FetchResult.failure(String error) =>
      FetchResult(success: false, error: error);
}

/// Notifications Feature Config - Feature flags and configuration
/// Created by: Cursor B-ux
/// Purpose: Feature flag and config for notifications
/// Last updated: 2025-11-25

/// Feature configuration for notifications.
/// Reads from environment and provides centralized config access.
class NotificationsFeatureConfig {
  const NotificationsFeatureConfig._();

  /// Whether notifications feature is enabled via environment/build config.
  /// Set via --dart-define=ENABLE_NOTIFICATIONS=true during build.
  static bool get isEnabled {
    const envValue = String.fromEnvironment(
      'ENABLE_NOTIFICATIONS',
      defaultValue: 'false',
    );
    return envValue.toLowerCase() == 'true';
  }

  /// Remote config key for notifications enabled status.
  /// Used when checking against Remote Config service.
  static const String remoteConfigKey = 'notifications.enabled';

  /// Default timeout for backend availability checks.
  static const Duration availabilityCheckTimeout = Duration(seconds: 5);

  /// Interval for periodic availability re-checks.
  static const Duration availabilityRecheckInterval = Duration(minutes: 5);
}


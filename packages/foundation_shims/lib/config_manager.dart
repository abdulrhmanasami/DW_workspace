/// Configuration Manager - Remote Config Service Interface
/// Created by: Cursor B-central
/// Purpose: Unified interface for remote configuration values
/// Last updated: 2025-11-17

abstract class ConfigManager {
  static ConfigManager get instance => _instance;
  static ConfigManager _instance = _StubConfigManager();

  /// Registers the shared instance that infra packages should consume.
  static void register(ConfigManager manager) {
    _instance = manager;
  }

  /// Resets the shared instance back to the stub (mainly for tests).
  static void reset() {
    _instance = _StubConfigManager();
  }

  /// Canonical API base URL used by HTTP implementations.
  String get apiBaseUrl;

  /// Get string value for key
  String? getString(String key, {String? defaultValue});

  /// Get integer value for key
  int? getInt(String key, {int? defaultValue});

  /// Get boolean value for key
  bool? getBool(String key, {bool? defaultValue});

  /// Get double value for key
  double? getDouble(String key, {double? defaultValue});
}

/// Stub implementation for development/testing
class _StubConfigManager implements ConfigManager {
  static const _defaultBaseUrl = 'https://api.deliveryways.com';

  @override
  String get apiBaseUrl => _defaultBaseUrl;

  @override
  String? getString(String key, {String? defaultValue}) => defaultValue;

  @override
  int? getInt(String key, {int? defaultValue}) => defaultValue;

  @override
  bool? getBool(String key, {bool? defaultValue}) => defaultValue;

  @override
  double? getDouble(String key, {double? defaultValue}) => defaultValue;
}

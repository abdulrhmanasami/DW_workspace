/// Remote Config Data Models

import 'remote_config_service.dart';

/// Remote config entry with metadata
class RemoteConfigEntry {
  final String key;
  final dynamic value;
  final DateTime? lastModified;
  final String? source; // 'backend' or 'default'

  const RemoteConfigEntry({
    required this.key,
    required this.value,
    this.lastModified,
    this.source,
  });

  factory RemoteConfigEntry.fromJson(Map<String, dynamic> json) {
    return RemoteConfigEntry(
      key: json['key'] as String,
      value: json['value'],
      lastModified: json['lastModified'] is String
          ? DateTime.parse(json['lastModified'] as String)
          : null,
      source: json['source'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
      'lastModified': lastModified?.toIso8601String(),
      'source': source,
    };
  }

  @override
  String toString() =>
      'RemoteConfigEntry(key: $key, value: $value, source: $source)';
}

/// Configuration snapshot
class ConfigSnapshot {
  final Map<String, RemoteConfigEntry> entries;
  final DateTime fetchTime;
  final String source;

  const ConfigSnapshot({
    required this.entries,
    required this.fetchTime,
    required this.source,
  });

  /// Get entry by key
  RemoteConfigEntry? getEntry(String key) => entries[key];

  /// Get all keys
  Iterable<String> get keys => entries.keys;

  /// Check if key exists
  bool hasKey(String key) => entries.containsKey(key);

  /// Get value with type safety
  T? getValue<T>(String key) {
    final entry = entries[key];
    if (entry?.value is T) {
      return entry!.value as T;
    }
    return null;
  }

  @override
  String toString() =>
      'ConfigSnapshot(entries: ${entries.length}, source: $source, time: $fetchTime)';
}

/// Default configuration values
class DefaultConfig {
  static final Map<String, dynamic> values = {
    RemoteConfigKeys.stripeGpayEnabled: false,
    RemoteConfigKeys.trackingEnabled: false,
    RemoteConfigKeys.mapsProvider: MapsProviderValues.google,
    RemoteConfigKeys.paymentsEnv: PaymentsEnvValues.test,
    RemoteConfigKeys.uiTheme: 'default',
    RemoteConfigKeys.certPinningEnabled: false,
  };

  static bool getBool(String key) => values[key] as bool? ?? false;
  static String getString(String key) => values[key] as String? ?? '';
  static double getDouble(String key) =>
      (values[key] as num?)?.toDouble() ?? 0.0;
  static int getInt(String key) => (values[key] as num?)?.toInt() ?? 0;
  static Map<String, dynamic> getJson(String key) =>
      values[key] as Map<String, dynamic>? ?? {};
}

/// Cache metadata
class CacheMetadata {
  final DateTime lastFetch;
  final Duration ttl;

  const CacheMetadata({required this.lastFetch, required this.ttl});

  bool get isExpired => DateTime.now().difference(lastFetch) > ttl;

  factory CacheMetadata.now(Duration ttl) =>
      CacheMetadata(lastFetch: DateTime.now(), ttl: ttl);
}

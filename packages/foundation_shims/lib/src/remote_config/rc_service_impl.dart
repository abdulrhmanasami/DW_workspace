/// Remote Config Service Implementation

import 'dart:async';
import 'package:flutter/foundation.dart';

import 'remote_config_service.dart';
import 'rc_client.dart';
import 'rc_models.dart';

class RemoteConfigServiceImpl implements RemoteConfigService {
  final CompositeConfigSource source;
  ConfigSnapshot? _currentSnapshot;
  CacheMetadata? _cacheMetadata;
  final Duration cacheTTL;

  RemoteConfigServiceImpl({
    required this.source,
    this.cacheTTL = const Duration(minutes: 5),
  });

  @override
  Future<void> fetchAndActivate() async {
    try {
      // Check cache first
      if (_cacheMetadata != null && !_cacheMetadata!.isExpired) {
        debugPrint(
          'RemoteConfig: Using cached config (TTL: ${cacheTTL.inMinutes}min)',
        );
        return;
      }

      debugPrint('RemoteConfig: Fetching fresh config...');
      final snapshot = await source.fetch();

      _currentSnapshot = snapshot;
      _cacheMetadata = CacheMetadata.now(cacheTTL);
      debugPrint(
        'RemoteConfig: Activated config with ${snapshot.entries.length} entries',
      );
    } catch (e) {
      debugPrint('RemoteConfig: Error fetching config: $e');
    }
  }

  @override
  Future<void> forceRefresh() async {
    _cacheMetadata = null; // Invalidate cache
    await fetchAndActivate();
  }

  @override
  bool getBool(String key, {bool defaultValue = false}) {
    final value = _getValue(key);
    if (value is bool) return value;
    return defaultValue;
  }

  @override
  String getString(String key, {String defaultValue = ''}) {
    final value = _getValue(key);
    if (value is String) return value;
    return defaultValue;
  }

  @override
  double getDouble(String key, {double defaultValue = 0.0}) {
    final value = _getValue(key);
    if (value is num) return value.toDouble();
    return defaultValue;
  }

  @override
  int getInt(String key, {int defaultValue = 0}) {
    final value = _getValue(key);
    if (value is num) return value.toInt();
    return defaultValue;
  }

  @override
  Map<String, dynamic> getJson(
    String key, {
    Map<String, dynamic> defaultValue = const {},
  }) {
    final value = _getValue(key);
    if (value is Map<String, dynamic>) return value;
    return defaultValue;
  }

  @override
  Map<String, bool> getBoolMap(
    String key, {
    Map<String, bool> defaultValue = const {},
  }) {
    final value = _getValue(key);
    if (value is Map<String, dynamic>) {
      return value.map((k, v) => MapEntry(k, v is bool ? v : false));
    }
    return defaultValue;
  }

  @override
  bool hasKey(String key) {
    return _currentSnapshot?.hasKey(key) ?? false;
  }

  @override
  DateTime? getLastFetchTime() {
    return _cacheMetadata?.lastFetch;
  }

  dynamic _getValue(String key) {
    return _currentSnapshot?.getEntry(key)?.value;
  }

  /// Initialize with defaults if no config loaded yet
  void ensureInitialized() {
    if (_currentSnapshot == null) {
      final defaultSource = InMemoryDefaultsSource();
      _currentSnapshot = defaultSource.fetch();
      debugPrint('RemoteConfig: Initialized with defaults');
    }
  }

  /// Get current snapshot (for debugging)
  ConfigSnapshot? get currentSnapshot => _currentSnapshot;

  /// Get cache status
  CacheMetadata? get cacheMetadata => _cacheMetadata;
}

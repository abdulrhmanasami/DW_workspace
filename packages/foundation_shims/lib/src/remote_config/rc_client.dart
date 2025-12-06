/// Remote Config HTTP Client
/// Handles network requests with retry logic and timeout

import 'dart:async';
import 'dart:convert';

import 'package:network_shims/network_shims.dart';

import 'package:foundation_shims/config_manager.dart';
import 'rc_models.dart';

class RemoteConfigClient {
  final ConfigManager configManager;
  final Duration timeout;
  final int maxRetries;
  final Duration retryDelay;
  final SecureHttpClient httpClient;

  RemoteConfigClient({
    required this.configManager,
    required this.httpClient,
    this.timeout = const Duration(seconds: 15),
    this.maxRetries = 2,
    this.retryDelay = const Duration(seconds: 1),
  });

  /// Fetch configuration from backend
  Future<Map<String, dynamic>?> fetchConfig() async {
    final url = configManager.getString('remote_config_url');
    if (url == null || url.isEmpty) {
      return null;
    }

    final authToken = configManager.getString('auth_token');

    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final response = await _makeRequest(url, authToken).timeout(timeout);
        final body = await response.text();

        if (response.statusCode == 200) {
          final data = jsonDecode(body) as Map<String, dynamic>;
          return data;
        } else if (response.statusCode >= 500 && attempt < maxRetries) {
          // Retry on server errors
          await Future<void>.delayed(retryDelay * (attempt + 1));
          continue;
        } else {
          // Don't retry on client errors
          break;
        }
      } on TimeoutException {
        if (attempt < maxRetries) {
          await Future<void>.delayed(retryDelay * (attempt + 1));
          continue;
        }
        rethrow;
      } catch (e) {
        if (attempt < maxRetries) {
          await Future<void>.delayed(retryDelay * (attempt + 1));
          continue;
        }
        rethrow;
      }
    }

    return null;
  }

  Future<StreamedResponse> _makeRequest(String url, String? authToken) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (authToken != null && authToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $authToken';
    }

    return httpClient.send(Request.get(Uri.parse(url), headers: headers));
  }
}

/// HTTP-based remote config source
class BackendRemoteConfigSource {
  final RemoteConfigClient client;

  const BackendRemoteConfigSource(this.client);

  Future<ConfigSnapshot?> fetch() async {
    try {
      final data = await client.fetchConfig();
      if (data == null) return null;

      final entries = <String, RemoteConfigEntry>{};
      final fetchTime = DateTime.now();

      data.forEach((key, value) {
        entries[key] = RemoteConfigEntry(
          key: key,
          value: value,
          lastModified: fetchTime,
          source: 'backend',
        );
      });

      return ConfigSnapshot(
        entries: entries,
        fetchTime: fetchTime,
        source: 'backend',
      );
    } catch (e) {
      return null;
    }
  }
}

/// In-memory default config source
class InMemoryDefaultsSource {
  const InMemoryDefaultsSource();

  ConfigSnapshot fetch() {
    final entries = <String, RemoteConfigEntry>{};
    final fetchTime = DateTime.now();

    DefaultConfig.values.forEach((key, value) {
      entries[key] = RemoteConfigEntry(
        key: key,
        value: value,
        lastModified: fetchTime,
        source: 'default',
      );
    });

    return ConfigSnapshot(
      entries: entries,
      fetchTime: fetchTime,
      source: 'default',
    );
  }
}

/// Composite config source (backend + defaults)
class CompositeConfigSource {
  final BackendRemoteConfigSource backend;
  final InMemoryDefaultsSource defaults;

  const CompositeConfigSource({required this.backend, required this.defaults});

  Future<ConfigSnapshot> fetch() async {
    // Try backend first
    final backendSnapshot = await backend.fetch();

    // Always get defaults
    final defaultSnapshot = defaults.fetch();

    if (backendSnapshot != null) {
      // Merge backend over defaults
      final mergedEntries = Map<String, RemoteConfigEntry>.from(
        defaultSnapshot.entries,
      );
      mergedEntries.addAll(backendSnapshot.entries);

      return ConfigSnapshot(
        entries: mergedEntries,
        fetchTime: backendSnapshot.fetchTime,
        source: 'composite',
      );
    } else {
      // Return defaults only
      return defaultSnapshot;
    }
  }
}

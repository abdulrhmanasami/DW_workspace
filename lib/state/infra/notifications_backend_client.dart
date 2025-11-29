import 'dart:convert';
import 'dart:developer';

import 'package:foundation_shims/config_manager.dart';
import 'package:network_shims/network_shims.dart';
import 'package:notifications_shims/notifications_shims.dart';

class NotificationsHttpBackendClient implements NotificationsBackendClient {
  NotificationsHttpBackendClient({
    required ConfigManager configManager,
    required Future<String?> Function() authTokenProvider,
    required SecureHttpClient httpClient,
  }) : _configManager = configManager,
       _authTokenProvider = authTokenProvider,
       _httpClient = httpClient;

  final ConfigManager _configManager;
  final Future<String?> Function() _authTokenProvider;
  final SecureHttpClient _httpClient;

  Uri _resolve(String path) {
    final baseUrl =
        _configManager.getString('api.baseUrl') ??
        'https://api.deliveryways.com';
    final normalized = path.startsWith('/') ? path.substring(1) : path;
    return Uri.parse(baseUrl).resolve(normalized);
  }

  Future<Map<String, String>> _headers() async {
    final token = await _authTokenProvider();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  bool _canSend(NotificationDeviceMetadata metadata) {
    if (metadata.userId == null || metadata.userId!.isEmpty) {
      log(
        'Notifications backend skipped: userId missing.',
        name: 'notifications_backend_client',
      );
      return false;
    }
    return true;
  }

  @override
  Future<void> registerDeviceToken({
    required String token,
    required NotificationDeviceMetadata metadata,
  }) async {
    if (!_canSend(metadata)) return;

    final uri = _resolve('/api/v1/push/devices');
    final payload = jsonEncode({'token': token, 'device': metadata.toJson()});

    await _send(() async {
      final headers = await _headers();
      return _httpClient.send(
        Request.post(uri, headers: headers, body: payload),
      );
    });
  }

  @override
  Future<void> unregisterDeviceToken({
    required String token,
    required NotificationDeviceMetadata metadata,
  }) async {
    if (!_canSend(metadata)) return;

    final uri = _resolve('/api/v1/push/devices/${metadata.deviceId}');
    final payload = jsonEncode({'token': token, 'device': metadata.toJson()});

    await _send(() async {
      final headers = await _headers();
      return _httpClient.send(
        Request(method: 'DELETE', url: uri, headers: headers, body: payload),
      );
    });
  }

  @override
  Future<void> updateUserNotificationPreferences(
    NotificationPreferences preferences,
  ) async {
    final uri = _resolve('/api/v1/notification-preferences');
    await _send(() async {
      final headers = await _headers();
      return _httpClient.send(
        Request.put(
          uri,
          headers: headers,
          body: jsonEncode(preferences.toJson()),
        ),
      );
    });
  }

  Future<void> _send(Future<StreamedResponse> Function() request) async {
    try {
      final response = await request();
      final body = await response.text();
      final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
      if (!isSuccess) {
        log(
          'Notifications backend responded with ${response.statusCode}: $body',
          name: 'notifications_backend_client',
        );
      }
    } catch (error, stackTrace) {
      log(
        'Notifications backend request failed: $error',
        stackTrace: stackTrace,
        name: 'notifications_backend_client',
      );
    }
  }
}

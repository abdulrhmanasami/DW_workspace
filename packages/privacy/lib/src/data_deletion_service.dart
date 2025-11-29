import 'dart:convert';

import 'package:network_shims/network_shims.dart';

import 'privacy_backend_config.dart';

/// Handles user data deletion / anonymization workflows.
class DataDeletionService {
  DataDeletionService({
    required SecureHttpClient client,
    required PrivacyBackendConfig config,
  })  : _client = client,
        _config = config;

  final SecureHttpClient _client;
  final PrivacyBackendConfig _config;

  Future<void> deleteUserData(
    String userId, {
    bool anonymize = false,
    Map<String, dynamic>? metadata,
  }) async {
    final uri = _config.resolve(_config.deletionPath);
    final response = await _client.send(
      Request.post(
        uri,
        headers: _config.headers({'content-type': 'application/json'}),
        body: jsonEncode({
          'userId': userId,
          'anonymize': anonymize,
          if (metadata != null) 'metadata': metadata,
        }),
      ),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final errorBody = await response.text();
      throw PrivacyBackendException(
        'Failed to delete user data: $errorBody',
        response.statusCode,
      );
    }
  }
}


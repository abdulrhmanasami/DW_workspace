import 'dart:convert';

import 'package:network_shims/network_shims.dart';

import '../privacy_backend_config.dart';
import 'dsar_types.dart';

/// Service responsible for making DSAR-related backend calls.
class DSARService {
  DSARService({
    required SecureHttpClient client,
    required PrivacyBackendConfig config,
  })  : _client = client,
        _config = config;

  final SecureHttpClient _client;
  final PrivacyBackendConfig _config;

  Future<DSARResponse> submitRequest(DSARRequest request) async {
    final uri = _config.resolve(_config.dsarPath);
    final response = await _sendJson(
      Request.post(
        uri,
        headers: _headers(jsonBody: true),
        body: jsonEncode(request.toJson()),
      ),
    );
    return DSARResponse.fromJson(response);
  }

  Future<bool> hasConsented(String userId) async {
    final uri = _config.resolve(
      '${_config.consentPath}?userId=$userId',
    );
    final response = await _sendJson(Request.get(uri, headers: _headers()));
    final value = response['hasConsented'];
    if (value is bool) {
      return value;
    }
    throw PrivacyBackendException(
      'Unexpected payload for hasConsented: $response',
    );
  }

  Future<List<DataCategory>> listDataCategories(String userId) async {
    final uri = _config.resolve(
      '${_config.dsarPath}/categories?userId=$userId',
    );
    final response = await _sendJson(Request.get(uri, headers: _headers()));
    final data = response['categories'];
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(DataCategory.fromJson)
          .toList(growable: false);
    }
    return const [];
  }

  Future<List<DataRetentionPeriod>> listRetentionPolicies(
    String userId,
  ) async {
    final uri = _config.resolve(
      '${_config.dsarPath}/retention?userId=$userId',
    );
    final response = await _sendJson(Request.get(uri, headers: _headers()));
    final data = response['retention'];
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(DataRetentionPeriod.fromJson)
          .toList(growable: false);
    }
    return const [];
  }

  Map<String, String> _headers({bool jsonBody = false}) {
    final headers = _config.headers();
    if (jsonBody) {
      return {
        'content-type': 'application/json',
        ...headers,
      };
    }
    return headers;
  }

  Future<Map<String, dynamic>> _sendJson(Request request) async {
    final response = await _client.send(request);
    final body = await response.text();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw PrivacyBackendException(
        'Request to ${request.url} failed: $body',
        response.statusCode,
      );
    }
    if (body.isEmpty) {
      return const {};
    }
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw PrivacyBackendException(
      'Expected JSON object, got: $decoded',
      response.statusCode,
    );
  }
}


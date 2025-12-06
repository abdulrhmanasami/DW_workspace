// Uplink HTTP Client - Network communication layer
// Created by: Cursor B-mobility
// Purpose: HTTP client with retry, timeout, and error handling for uplink
// Last updated: 2025-11-14

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobility_uplink_impl/uplink_config.dart';

/// HTTP client exceptions
class UplinkHttpException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;

  const UplinkHttpException(this.message, {this.statusCode, this.responseBody});

  @override
  String toString() => 'UplinkHttpException: $message (status: $statusCode)';
}

class UplinkTimeoutException implements Exception {
  final String message;
  const UplinkTimeoutException(this.message);

  @override
  String toString() => 'UplinkTimeoutException: $message';
}

class UplinkNetworkException implements Exception {
  final String message;
  const UplinkNetworkException(this.message);

  @override
  String toString() => 'UplinkNetworkException: $message';
}

/// HTTP client for uplink operations with retry logic
class UplinkClient {
  final UplinkConfig config;
  final http.Client _httpClient;

  UplinkClient(this.config, {http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  /// Send POST request with retry logic
  Future<http.Response> post(
    Uri uri,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    final jsonBody = jsonEncode(body);
    final defaultHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // Add auth header if available
      // 'Authorization': 'Bearer ${config.authToken}',
    };

    if (headers != null) {
      defaultHeaders.addAll(headers);
    }

    for (int attempt = 0; attempt <= config.maxRetries; attempt++) {
      try {
        final response = await _httpClient
            .post(uri, headers: defaultHeaders, body: jsonBody)
            .timeout(config.requestTimeout);

        // Success responses
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response;
        }

        // Server errors - retry
        if (response.statusCode >= 500 && attempt < config.maxRetries) {
          await _delayBeforeRetry(attempt);
          continue;
        }

        // Client errors - don't retry
        throw UplinkHttpException(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      } on TimeoutException catch (_) {
        if (attempt < config.maxRetries) {
          await _delayBeforeRetry(attempt);
          continue;
        }
        throw UplinkTimeoutException(
            'Request timeout after ${config.maxRetries} retries');
      } on http.ClientException catch (e) {
        if (attempt < config.maxRetries) {
          await _delayBeforeRetry(attempt);
          continue;
        }
        throw UplinkNetworkException('Network error: ${e.message}');
      }
    }

    throw const UplinkHttpException('Max retries exceeded');
  }

  /// Exponential backoff delay bounded by configuration.
  Future<void> _delayBeforeRetry(int attempt) async {
    final minMs = config.retryBackoffMin.inMilliseconds;
    final maxMs = config.retryBackoffMax.inMilliseconds;
    final delayMs = (minMs * (1 << attempt)).clamp(minMs, maxMs);
    await Future<void>.delayed(Duration(milliseconds: delayMs));
  }

  /// Close the HTTP client
  void dispose() {
    _httpClient.close();
  }
}

/// Component: Stripe Backend Client
/// Created by: Cursor (auto-generated)
/// Purpose: HTTP client for Stripe backend communication with retry/timeout
/// Last updated: 2025-11-11

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:foundation_shims/foundation_shims.dart';

import 'package:payments/payments.dart';

class StripeBackendClient {
  final http.Client _client;
  final Duration _timeout;
  final int _maxRetries;
  final ConfigManager _configManager;
  final Uri _baseUrl;

  StripeBackendClient({
    required Uri baseUrl,
    http.Client? client,
    Duration? timeout,
    int? maxRetries,
    ConfigManager? configManager,
  })  : _baseUrl = baseUrl,
        _client = client ?? http.Client(),
        _timeout = timeout ?? const Duration(seconds: 15),
        _maxRetries = maxRetries ?? 2,
        _configManager = configManager ?? ConfigManager.instance;

  /// Get authorization token from config (if available)
  String? get _authToken {
    try {
      return _configManager.getString('auth_token');
    } catch (e) {
      return null; // ConfigManager might not support getString
    }
  }

  /// Make POST request with JSON body and retry logic
  Future<Map<String, dynamic>> postJson(
    Uri url,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    return _withRetry(() => _postJson(url, body, headers));
  }

  /// Make GET request with retry logic
  Future<Map<String, dynamic>> getJson(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    return _withRetry(() => _getJson(url, headers));
  }

  Future<Map<String, dynamic>> _postJson(
    Uri url,
    Map<String, dynamic> body,
    Map<String, String>? headers,
  ) async {
    final requestHeaders = _buildHeaders(headers);
    final response = await _client
        .post(
          url,
          headers: requestHeaders,
          body: jsonEncode(body),
        )
        .timeout(_timeout);

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> _getJson(
    Uri url,
    Map<String, String>? headers,
  ) async {
    final requestHeaders = _buildHeaders(headers);
    final response = await _client
        .get(
          url,
          headers: requestHeaders,
        )
        .timeout(_timeout);

    return _handleResponse(response);
  }

  Map<String, String> _buildHeaders(Map<String, String>? additionalHeaders) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add auth token if available
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    // Add additional headers
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        throw PaymentFailure(
          code: 'JSON_PARSE_ERROR',
          message: 'Failed to parse response: ${e.toString()}',
        );
      }
    } else {
      throw PaymentFailure(
        code: 'HTTP_${response.statusCode}',
        message: 'Backend request failed: ${response.body}',
      );
    }
  }

  /// Make POST request
  Future<Map<String, dynamic>> post(String path,
      {Map<String, dynamic>? body}) async {
    final url = _baseUrl.resolve(path);
    return await postJson(url, body ?? {});
  }

  /// Make GET request
  Future<Map<String, dynamic>> get(String path,
      {Map<String, String>? queryParameters}) async {
    final url = _baseUrl.resolve(path);
    if (queryParameters != null && queryParameters.isNotEmpty) {
      final queryString =
          queryParameters.entries.map((e) => '${e.key}=${e.value}').join('&');
      final urlWithQuery = Uri.parse('$url?$queryString');
      return await getJson(urlWithQuery);
    }
    return await getJson(url);
  }

  Future<T> _withRetry<T>(Future<T> Function() operation) async {
    int attempts = 0;
    while (attempts <= _maxRetries) {
      try {
        return await operation();
      } on TimeoutException {
        attempts++;
        if (attempts > _maxRetries) {
          throw PaymentFailure(
            code: 'TIMEOUT',
            message: 'Request timed out after $_timeout',
          );
        }
        // Wait before retry
        await Future.delayed(Duration(seconds: attempts));
      } on PaymentFailure {
        // Don't retry payment failures, rethrow immediately
        rethrow;
      } catch (e) {
        attempts++;
        if (attempts > _maxRetries) {
          throw PaymentFailure(
            code: 'NETWORK_ERROR',
            message: 'Network error: ${e.toString()}',
          );
        }
        // Wait before retry
        await Future.delayed(Duration(seconds: attempts));
      }
    }
    throw PaymentFailure(
      code: 'MAX_RETRIES_EXCEEDED',
      message: 'Maximum retry attempts exceeded',
    );
  }

  void dispose() {
    _client.close();
  }
}

/// DSR (Data Subject Rights) HTTP client
/// Created by: Cursor B-central
/// Purpose: HTTP client for DSR operations with proper error handling and retry logic
/// Last updated: 2025-11-12

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:foundation_shims/foundation_shims.dart';

import 'package:accounts_shims/src/accounts_endpoints.dart';
import 'dsr_contracts.dart';

/// HTTP client specifically for DSR operations
class DsrClient {
  final AccountsEndpoints endpoints;
  final ConfigManager configManager;
  final Duration timeout;
  final int maxRetries;
  final Duration retryDelay;

  DsrClient({
    required this.endpoints,
    required this.configManager,
    this.timeout = const Duration(seconds: 15),
    this.maxRetries = 2,
    this.retryDelay = const Duration(seconds: 1),
  });

  /// Create a new DSR request
  Future<DsrRequestSummary> createRequest(DsrCreateRequest request) async {
    final authToken = configManager.getString('auth_token');

    final response = await _postJson(
      endpoints.dsrCreate,
      request.toJson(),
      authToken: authToken,
    );

    final responseData = _decodeResponse(response);
    return dsrRequestSummaryFromJson(responseData);
  }

  /// Get status of a DSR request
  Future<DsrRequestSummary> getRequestStatus(DsrRequestId requestId) async {
    final authToken = configManager.getString('auth_token');

    final response = await _getJson(
      endpoints.dsrStatus(requestId.value),
      authToken: authToken,
    );

    final responseData = _decodeResponse(response);
    return dsrRequestSummaryFromJson(responseData);
  }

  /// Cancel a DSR request
  Future<void> cancelRequest(DsrRequestId requestId) async {
    final authToken = configManager.getString('auth_token');

    final response = await _postJson(
      endpoints.dsrCancel(requestId.value),
      {}, // Empty body for cancel
      authToken: authToken,
    );

    _decodeResponse(response); // Ensure success
  }

  /// Confirm erasure request
  Future<void> confirmErasure(DsrRequestId requestId) async {
    final authToken = configManager.getString('auth_token');

    final response = await _postJson(
      endpoints.dsrConfirm(requestId.value),
      {}, // Empty body for confirm
      authToken: authToken,
    );

    _decodeResponse(response); // Ensure success
  }

  /// Make authenticated POST request with JSON body
  Future<http.Response> _postJson(
    Uri url,
    Map<String, dynamic> body, {
    String? authToken,
  }) async {
    return _executeWithRetry(() async {
      final headers = _buildHeaders(authToken);
      final jsonBody = jsonEncode(body);

      return await http
          .post(url, headers: headers, body: jsonBody)
          .timeout(timeout);
    });
  }

  /// Make authenticated GET request
  Future<http.Response> _getJson(Uri url, {String? authToken}) async {
    return _executeWithRetry(() async {
      final headers = _buildHeaders(authToken);

      return await http.get(url, headers: headers).timeout(timeout);
    });
  }

  /// Build HTTP headers with authorization
  Map<String, String> _buildHeaders(String? authToken) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (authToken != null && authToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $authToken';
    }

    return headers;
  }

  /// Execute HTTP request with retry logic
  Future<http.Response> _executeWithRetry(
    Future<http.Response> Function() request,
  ) async {
    int attempts = 0;

    while (attempts <= maxRetries) {
      try {
        final response = await request();
        _validateResponse(response);
        return response;
      } on TimeoutException {
        attempts++;
        if (attempts > maxRetries) rethrow;
        await Future<void>.delayed(retryDelay * attempts);
      } catch (e) {
        attempts++;
        if (attempts > maxRetries) rethrow;
        // Only retry on network errors, not on HTTP errors
        if (e is! DsrException) rethrow;
        await Future<void>.delayed(retryDelay * attempts);
      }
    }

    throw const DsrException('Max retries exceeded');
  }

  /// Validate HTTP response and throw appropriate exceptions
  void _validateResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return; // Success
    }

    final responseBody = response.body;
    Map<String, dynamic>? errorData;

    try {
      errorData = jsonDecode(responseBody) as Map<String, dynamic>;
    } catch (_) {
      // If we can't parse error response, create a generic one
    }

    switch (response.statusCode) {
      case 400:
        throw DsrValidationException(
          errorData?['message'] as String? ?? 'Invalid request data',
        );
      case 401:
        throw const DsrException('Authentication required');
      case 403:
        throw const DsrException('Access denied');
      case 404:
        throw const DsrException('DSR request not found');
      case 409:
        // Conflict - might be existing request
        final existingId = errorData?['existing_request_id'] as String?;
        throw DsrConflictException(
          errorData?['message'] as String? ?? 'Request conflict',
          existingId != null ? DsrRequestId(existingId) : null,
        );
      case 422:
        throw DsrValidationException(
          errorData?['message'] as String? ?? 'Request validation failed',
        );
      case 429:
        throw const DsrException('Too many requests - please try again later');
      default:
        if (response.statusCode >= 500) {
          throw const DsrException('Server error - please try again later');
        } else {
          throw DsrException(
            'Request failed with status ${response.statusCode}',
          );
        }
    }
  }

  /// Decode successful response
  Map<String, dynamic> _decodeResponse(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw DsrException('Invalid response format: $e');
    }
  }
}

/// Base exception for DSR operations
class DsrException implements Exception {
  final String message;

  const DsrException(this.message);

  @override
  String toString() => 'DsrException: $message';
}

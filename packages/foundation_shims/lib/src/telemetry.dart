/// Component: Telemetry Service
/// Created by: Cursor (auto-generated)
/// Purpose: Hardened telemetry with timeouts, retry, and safety guards
/// Last updated: 2025-11-04

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Telemetry consent manager for GDPR compliance
class TelemetryConsent {
  static TelemetryConsent? _instance;
  bool _isAllowed = false;

  TelemetryConsent._();

  static TelemetryConsent get instance {
    return _instance ??= TelemetryConsent._();
  }

  bool get isAllowed => _isAllowed;

  Future<void> grant() async {
    _isAllowed = true;
  }

  Future<void> deny() async {
    _isAllowed = false;
  }
}

/// Enhanced telemetry service with hardening features
/// BL-102-006: Telemetry client hardening
class Telemetry {
  static Telemetry? _instance;

  // Hardening configuration
  static const Duration _defaultTimeout = Duration(seconds: 5);
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(milliseconds: 500);
  static const int _maxPayloadSize = 10 * 1024; // 10KB limit
  static const int _maxEventNameLength = 100;
  static const int _maxAttributeCount = 50;
  static const int _maxAttributeValueLength = 500;

  Telemetry._();

  static Telemetry get instance {
    return _instance ??= Telemetry._();
  }

  static Future<void> init({
    required String sentryDsn,
    required String environment,
    required String release,
    bool enableFirebasePerformance = false,
  }) async {
    // Initialize telemetry services
    // In clean version, we just initialize the basic structure
  }

  /// Safely log event with validation and retry logic
  Future<void> logEvent(String event, [Map<String, dynamic>? data]) async {
    if (!TelemetryConsent.instance.isAllowed) return;

    await _executeWithRetry(() async {
      // Validate inputs
      final sanitizedEvent = _sanitizeEventName(event);
      final sanitizedData = _sanitizeData(data);

      // Check payload size
      final payloadSize = _calculatePayloadSize(sanitizedEvent, sanitizedData);
      if (payloadSize > _maxPayloadSize) {
        await error(
          'Telemetry payload too large',
          context: {
            'event': sanitizedEvent,
            'payload_size': payloadSize,
            'max_size': _maxPayloadSize,
          },
        );
        return;
      }

      // Log event with timeout
      await _logWithTimeout('Telemetry Event: $sanitizedEvent', sanitizedData);
    });
  }

  /// Enhanced error logging with context validation
  Future<void> error(String message, {Map<String, dynamic>? context}) async {
    if (!TelemetryConsent.instance.isAllowed) return;

    await _executeWithRetry(() async {
      final sanitizedMessage = _sanitizeString(message, 1000);
      final sanitizedContext = _sanitizeData(context);

      await _logWithTimeout(
        'Telemetry Error: $sanitizedMessage',
        sanitizedContext,
      );
    });
  }

  /// Set user ID with validation
  Future<void> setUserId(String? userId) async {
    if (!TelemetryConsent.instance.isAllowed) return;

    await _executeWithRetry(() async {
      final sanitizedUserId = userId != null
          ? _sanitizeString(userId, 100)
          : null;
      await _logWithTimeout('Telemetry User ID Set', {
        'user_id': sanitizedUserId,
      });
    });
  }

  /// Set user property with validation
  Future<void> setUserProperty(String name, dynamic value) async {
    if (!TelemetryConsent.instance.isAllowed) return;

    await _executeWithRetry(() async {
      final sanitizedName = _sanitizeString(name, 100);
      final sanitizedValue = _sanitizeValue(value);

      await _logWithTimeout('Telemetry User Property', {
        'property': sanitizedName,
        'value': sanitizedValue,
      });
    });
  }

  /// Create telemetry span with timeout protection
  Future<TelemetrySpan> startTrace(String name) async {
    final sanitizedName = _sanitizeString(name, 100);
    return TelemetrySpan._(sanitizedName);
  }

  /// Execute operation with retry logic
  Future<void> _executeWithRetry(Future<void> Function() operation) async {
    int attempts = 0;
    while (attempts < _maxRetries) {
      try {
        await operation();
        return;
      } catch (e) {
        attempts++;
        if (attempts >= _maxRetries) {
          // Log final failure but don't throw to avoid breaking app flow
          _logWithoutTimeout(
            'Telemetry operation failed after $attempts attempts: $e',
          );
          return;
        }
        await Future<void>.delayed(_retryDelay * attempts);
      }
    }
  }

  /// Log with timeout protection
  Future<void> _logWithTimeout(String message, [dynamic data]) async {
    try {
      await Future(
        () => _logWithoutTimeout(message, data),
      ).timeout(_defaultTimeout);
    } catch (e) {
      // Timeout occurred - log minimal info
      _logWithoutTimeout('Telemetry timeout: ${message.substring(0, 50)}...');
    }
  }

  /// Basic logging without timeout (for error recovery)
  void _logWithoutTimeout(String message, [dynamic data]) {
    debugPrint(message);
    if (data != null) {
      try {
        final jsonData = jsonEncode(data);
        if (jsonData.length > 2000) {
          debugPrint('Data: [TRUNCATED - ${jsonData.length} chars]');
        } else {
          debugPrint('Data: $jsonData');
        }
      } catch (e) {
        debugPrint('Data: [SERIALIZATION ERROR: $e]');
      }
    }
  }

  /// Sanitize event name
  String _sanitizeEventName(String event) {
    if (event.isEmpty) return 'unknown_event';
    return _sanitizeString(
      event,
      _maxEventNameLength,
    ).replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
  }

  /// Sanitize data map
  Map<String, dynamic>? _sanitizeData(Map<String, dynamic>? data) {
    if (data == null) return null;
    if (data.length > _maxAttributeCount) {
      return Map.fromEntries(data.entries.take(_maxAttributeCount));
    }

    return data.map(
      (key, value) =>
          MapEntry(_sanitizeString(key, 100), _sanitizeValue(value)),
    );
  }

  /// Sanitize string value
  String _sanitizeString(String value, int maxLength) {
    if (value.length > maxLength) {
      return value.substring(0, maxLength);
    }
    return value;
  }

  /// Sanitize dynamic value
  dynamic _sanitizeValue(dynamic value) {
    if (value == null) return null;

    if (value is String) {
      return _sanitizeString(value, _maxAttributeValueLength);
    }

    if (value is Map<String, dynamic>) {
      return _sanitizeData(value);
    }

    if (value is List) {
      return value.take(10).map(_sanitizeValue).toList(); // Limit list size
    }

    // For other types, convert to string and sanitize
    final stringValue = value.toString();
    return _sanitizeString(stringValue, _maxAttributeValueLength);
  }

  /// Calculate approximate payload size
  int _calculatePayloadSize(String event, Map<String, dynamic>? data) {
    int size = event.length;
    if (data != null) {
      try {
        size += jsonEncode(data).length;
      } catch (e) {
        size += 1000; // Estimate for serialization error case
      }
    }
    return size;
  }
}

/// Enhanced telemetry span with timeout protection
class TelemetrySpan {
  final String name;
  final DateTime startTime = DateTime.now();
  final Map<String, String> _attributes = {};
  bool _isStopped = false;

  TelemetrySpan._(this.name);

  /// Set attributes with validation
  Future<void> setAttributes(Map<String, String> attributes) async {
    if (_isStopped) return;

    try {
      await Future(() async {
        for (final entry in attributes.entries.take(20)) {
          // Limit attributes
          final key = entry.key.length > 50
              ? entry.key.substring(0, 50)
              : entry.key;
          final value = entry.value.length > 200
              ? entry.value.substring(0, 200)
              : entry.value;
          _attributes[key] = value;
        }
      }).timeout(const Duration(seconds: 2));
    } catch (e) {
      // Timeout or error - continue without attributes
      debugPrint('TelemetrySpan attribute setting failed: $e');
    }
  }

  /// Set status with validation
  Future<void> setStatus(String status, [String? description]) async {
    if (_isStopped) return;

    try {
      await setAttributes({
        'status': status,
        if (description != null) 'status_description': description,
      });
    } catch (e) {
      // Ignore errors in status setting
    }
  }

  /// Stop span with timeout protection
  Future<void> stop() async {
    if (_isStopped) return;
    _isStopped = true;

    try {
      await Future(() async {
        final duration = DateTime.now().difference(startTime);
        final attributes = Map<String, String>.from(_attributes)
          ..['duration_ms'] = duration.inMilliseconds.toString();

        debugPrint('Telemetry Span "$name" completed');
        debugPrint('Attributes: $attributes');
      }).timeout(const Duration(seconds: 2));
    } catch (e) {
      // Timeout occurred - log minimal completion
      debugPrint('Telemetry Span "$name" completed (timeout)');
    }
  }
}

/// DSR (Data Subject Rights) audit logging for privacy compliance
/// Created by: Cursor B-central
/// Purpose: Standardized audit logging for DSR operations with PII protection
/// Last updated: 2025-11-12

import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

import 'dsr_models.dart';

/// Actions that can be performed on DSR requests
enum DsrAuditAction {
  /// Request creation initiated
  create,

  /// Status polling/check performed
  statusPoll,

  /// Request cancellation
  cancel,

  /// Erasure confirmation (GDPR right to be forgotten)
  confirm,

  /// Request completed successfully
  complete,

  /// Request failed
  fail,
}

/// Audit event for DSR operations
class DsrAuditEvent {
  /// Timestamp of the event
  final DateTime ts;

  /// Hashed user identifier (SHA-256, never raw user ID)
  final String userIdHash;

  /// DSR request identifier
  final DsrRequestId reqId;

  /// Type of DSR request
  final DsrRequestType type;

  /// Current status of the request
  final DsrStatus status;

  /// Action being performed
  final DsrAuditAction action;

  /// Additional metadata (safe, no PII)
  final Map<String, String> meta;

  const DsrAuditEvent({
    required this.ts,
    required this.userIdHash,
    required this.reqId,
    required this.type,
    required this.status,
    required this.action,
    this.meta = const {},
  });

  /// Create sanitized JSON representation (no PII exposure)
  Map<String, dynamic> toJson() => {
    'ts': ts.toIso8601String(),
    'user_id_hash': userIdHash,
    'request_id': reqId.value,
    'request_type': type.name,
    'status': status.name,
    'action': action.name,
    'meta': meta,
  };

  /// Create from JSON (for testing/debugging)
  factory DsrAuditEvent.fromJson(Map<String, dynamic> json) => DsrAuditEvent(
    ts: DateTime.parse(json['ts'] as String),
    userIdHash: json['user_id_hash'] as String,
    reqId: DsrRequestId(json['request_id'] as String),
    type: DsrRequestType.values.firstWhere(
      (e) => e.name == json['request_type'],
      orElse: () => DsrRequestType.export,
    ),
    status: DsrStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => DsrStatus.pending,
    ),
    action: DsrAuditAction.values.firstWhere(
      (e) => e.name == json['action'],
      orElse: () => DsrAuditAction.create,
    ),
    meta: Map<String, String>.from(json['meta'] as Map),
  );

  @override
  String toString() =>
      'DsrAuditEvent(ts: $ts, userHash: ${userIdHash.substring(0, 8)}..., '
      'reqId: ${reqId.value}, type: $type, status: $status, action: $action, meta: $meta)';
}

/// Abstract interface for audit event sinks
abstract class DsrAuditSink {
  /// Write an audit event (async to allow I/O operations)
  Future<void> write(DsrAuditEvent event);
}

/// No-op sink that discards all events (for disabled auditing)
class NoOpDsrAuditSink implements DsrAuditSink {
  const NoOpDsrAuditSink();

  @override
  Future<void> write(DsrAuditEvent event) async {
    // Do nothing - events are discarded
  }
}

/// Console sink that writes events to stdout (for development/debugging)
class ConsoleDsrAuditSink implements DsrAuditSink {
  const ConsoleDsrAuditSink();

  @override
  Future<void> write(DsrAuditEvent event) async {
    // ignore: avoid_print
    print('[DSR-AUDIT] ${jsonEncode(event.toJson())}');
  }
}

/// File sink that appends events as JSON lines to a file
class FileDsrAuditSink implements DsrAuditSink {
  final String filePath;

  const FileDsrAuditSink(this.filePath);

  @override
  Future<void> write(DsrAuditEvent event) async {
    final file = File(filePath);
    final jsonLine = '${jsonEncode(event.toJson())}\n';

    await file.writeAsString(jsonLine, mode: FileMode.append);
  }
}

/// Helper to sanitize URIs by removing sensitive query parameters
extension UriSanitization on Uri {
  /// Return URI without sensitive query parameters (passwords, tokens, secrets)
  String uriSansSensitive() {
    final sensitiveKeys = {
      'password',
      'token',
      'secret',
      'key',
      'auth',
      'api_key',
    };

    if (queryParameters.isEmpty) return toString();

    final sanitizedParams = Map<String, String>.from(queryParameters)
      ..removeWhere(
        (key, _) => sensitiveKeys.any(
          (sensitive) => key.toLowerCase().contains(sensitive.toLowerCase()),
        ),
      );

    final sanitizedUri = replace(queryParameters: sanitizedParams);
    return sanitizedUri.toString();
  }
}

/// Utility functions for audit logging
class DsrAuditUtils {
  /// Generate SHA-256 hash of user identifier for audit logging
  /// Never logs raw user IDs to protect privacy
  static String userHash(String userId) {
    final bytes = utf8.encode(userId);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }
}

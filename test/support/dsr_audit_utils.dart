import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

final _uuid = Uuid();

String hashUserId(String rawId, {String salt = 'handover_salt_v1'}) {
  final bytes = utf8.encode('$salt::$rawId');
  return sha256.convert(bytes).toString();
}

String sanitize(String input) {
  if (input.isEmpty) {
    return input;
  }

  final patterns = <RegExp>[
    RegExp(r'[A-Za-z\u0600-\u06FF]{2,}\s+[A-Za-z\u0600-\u06FF]{2,}'),
    RegExp(r'\b(Name|FullName|اسم|الاسم)\b\s*[:=]\s*.+', caseSensitive: false),
    RegExp(r'@[A-Za-z0-9_]+'),
    RegExp(r'\b(\+?\d{6,})\b'),
  ];

  var out = input;
  for (final pattern in patterns) {
    out = out.replaceAll(pattern, '[REDACTED]');
  }
  return out;
}

String newRequestId() => _uuid.v4();

Map<String, dynamic> dsrEvent({
  required String userIdRaw,
  required String requestType,
  required String action,
  required String status,
  required int tsEpochMs,
  String? requestId,
  String? sessionId,
  String source = 'app',
  String version = '1.0.0',
  Map<String, dynamic>? meta,
}) {
  final event = <String, dynamic>{
    'request_id': requestId ?? newRequestId(),
    'user_id_hash': hashUserId(userIdRaw),
    'request_type': requestType,
    'action': action,
    'status': status,
    'ts': tsEpochMs,
    if (sessionId != null) 'session_id': sessionId,
    'source': source,
    'version': version,
    'meta': _sanitizeMeta(meta ?? <String, dynamic>{}),
  };

  return event;
}

Map<String, dynamic> _sanitizeMeta(Map<String, dynamic> meta) {
  final sanitized = <String, dynamic>{};
  meta.forEach((key, value) {
    sanitized[key] = _sanitizeValue(value);
  });
  return sanitized;
}

dynamic _sanitizeValue(dynamic value) {
  if (value is String) {
    return sanitize(value);
  }
  if (value is Map) {
    final nested = <String, dynamic>{};
    value.forEach((dynamic key, dynamic nestedValue) {
      nested[key.toString()] = _sanitizeValue(nestedValue);
    });
    return nested;
  }
  if (value is Iterable) {
    return value.map(_sanitizeValue).toList();
  }
  return value;
}

import '../observability/observability.dart';
import 'dart:convert';
import 'package:core/rbac/rbac_models.dart';
import 'package:flutter/foundation.dart';

/// Component: RBAC Logger
/// Created by: Cursor (auto-generated)
/// Purpose: نظام السجلات الخاص بنظام RBAC
/// Last updated: 2025-10-09

/// مستويات السجلات
enum RBACLogLevel {
  debug(0),
  info(1),
  warn(2),
  error(3);

  const RBACLogLevel(this.value);
  final int value;
}

/// سجل نظام RBAC
class RBACLogger {
  static const String _tag = 'RBAC';
  final ObservabilityService _obs = ObservabilityService();

  /// تسجيل رسالة تصحيح
  void debug(
    String message, {
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(RBACLogLevel.debug, message, context: context, error: error);
  }

  /// تسجيل رسالة معلومات
  void info(
    String message, {
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(RBACLogLevel.info, message, context: context, error: error);
  }

  /// تسجيل تحذير
  void warn(
    String message, {
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(RBACLogLevel.warn, message, context: context, error: error);
  }

  /// تسجيل خطأ
  void error(
    String message, {
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(RBACLogLevel.error, message, context: context, error: error);
  }

  /// تسجيل عام
  void _log(
    RBACLogLevel level,
    String message, {
    Map<String, dynamic>? context,
    Object? error,
  }) {
    // استخدام نظام المراقبة الموجود
    switch (level) {
      case RBACLogLevel.debug:
        _obs.debug(_tag, message, context: context);
        break;
      case RBACLogLevel.info:
        _obs.info(_tag, message, context: context);
        break;
      case RBACLogLevel.warn:
        _obs.warning(_tag, message, context: context);
        break;
      case RBACLogLevel.error:
        _obs.error(_tag, message, context: context, error: error);
        break;
    }

    // تسجيل في وحدة التحكم للتطوير
    if (level.value >= RBACLogLevel.info.value) {
      debugPrint('[$_tag:${level.name.toUpperCase()}] $message');
      if (context != null && context.isNotEmpty) {
        debugPrint('  Context: ${jsonEncode(context)}');
      }
      if (error != null) {
        debugPrint('  Error: $error');
      }
    }
  }

  /// تسجيل قرار RBAC
  // TODO: Implement when RBACDecision context is available in core
  void logDecision(String decisionId, RBACDecision decision) {
    // Simplified implementation until RBACDecision context is available
    final Map<String, Object> context = <String, Object>{
      'decision_id': decisionId,
      'allowed': decision.allowed,
      'reason': decision.reason ?? 'No reason provided',
    };

    if (decision.allowed) {
      info('RBAC decision: ALLOWED', context: context);
    } else {
      warn('RBAC decision: DENIED', context: context);
    }
  }

  /// تسجيل محاولة وصول غير مصرح بها
  void logUnauthorizedAccess(
    String userId,
    String resource,
    String action, {
    String? sessionId,
    String? ipAddress,
    String? userAgent,
  }) {
    final Map<String, String> context = <String, String>{
      'user_id': userId,
      'resource': resource,
      'action': action,
    };

    if (sessionId != null) context['session_id'] = sessionId;
    if (ipAddress != null) context['ip_address'] = ipAddress;
    if (userAgent != null) context['user_agent'] = userAgent;

    warn('Unauthorized access attempt', context: context);

    // إرسال تنبيه أمان
    _obs.recordSecurityEvent('unauthorized_access', context);
  }

  /// تسجيل محاولة تصعيد صلاحيات
  void logPrivilegeEscalation(
    String userId,
    String attemptedRole,
    String currentRole, {
    String? sessionId,
    String? ipAddress,
  }) {
    final Map<String, String> context = <String, String>{
      'user_id': userId,
      'attempted_role': attemptedRole,
      'current_role': currentRole,
    };

    if (sessionId != null) context['session_id'] = sessionId;
    if (ipAddress != null) context['ip_address'] = ipAddress;

    error('Privilege escalation attempt', context: context);

    // إرسال تنبيه أمان عالي الخطورة
    _obs.recordSecurityEvent('privilege_escalation', context);
  }

  /// تسجيل نشاط مشبوه
  void logSuspiciousActivity(
    String userId,
    String activity,
    Map<String, dynamic> details, {
    String? sessionId,
  }) {
    final Map<String, Object> context = <String, Object>{
      'user_id': userId,
      'activity': activity,
      'details': details,
    };

    if (sessionId != null) context['session_id'] = sessionId;

    warn('Suspicious activity detected', context: context);

    // إرسال تنبيه أمان
    _obs.recordSecurityEvent('suspicious_activity', context);
  }

  /// تسجيل إحصائيات الأداء
  void logPerformanceMetrics(
    String operation,
    Duration duration, {
    Map<String, dynamic>? context,
  }) {
    info(
      'Performance metric',
      context: <String, dynamic>{
        'operation': operation,
        'duration_ms': duration.inMilliseconds,
        ...?context,
      },
    );

    // تسجيل مقياس أداء
    _obs.recordMetric('rbac_$operation', duration.inMilliseconds.toDouble());
  }

  /// تسجيل تغييرات في التكوين
  void logConfigurationChange(String changeType, Map<String, dynamic> changes) {
    info(
      'RBAC configuration changed',
      context: <String, dynamic>{'change_type': changeType, 'changes': changes},
    );
  }
}

/// Component: Observability Gate Interface
/// Created by: Cursor B-central
/// Purpose: Consent-aware gate for telemetry and crash reporting services
/// Last updated: 2025-11-12

import 'package:flutter/foundation.dart';
import 'consent_guard.dart';

/// Abstract interface for observability services with consent enforcement
abstract class ObservabilityGate {
  /// Initialize the observability services with initial consent
  Future<void> init({required Consent initialConsent});

  /// Update consent settings at runtime
  Future<void> setConsent(Consent consent);

  /// Log an event (analytics)
  Future<void> logEvent(String event, [Map<String, dynamic>? data]);

  /// Log an error/crash
  Future<void> logError(String message, {Map<String, dynamic>? context});

  /// Start a trace/span
  Future<ObservabilitySpan> startTrace(String name);

  /// Set user identifier
  Future<void> setUserId(String? userId);

  /// Set user property
  Future<void> setUserProperty(String name, dynamic value);

  /// Enable/disable crash collection
  Future<void> enableCrashCollection(bool enabled);

  /// Enable/disable analytics collection
  Future<void> enableAnalytics(bool enabled);

  /// Get current consent status
  Consent get currentConsent;
}

/// Real implementation that connects to actual SDKs (Firebase, Sentry, etc.)
/// This should only be used when consent is granted
class RealObservabilityGate implements ObservabilityGate {
  Consent _currentConsent = Consent.none;

  @override
  Consent get currentConsent => _currentConsent;

  @override
  Future<void> init({required Consent initialConsent}) async {
    _currentConsent = initialConsent;

    // Initialize real SDKs only if consent allows
    if (ConsentGuard.isCrashReportingAllowed(initialConsent)) {
      await enableCrashCollection(true);
    }

    if (ConsentGuard.isAnalyticsAllowed(initialConsent)) {
      await enableAnalytics(true);
    }
  }

  @override
  Future<void> setConsent(Consent consent) async {
    final previousConsent = _currentConsent;
    _currentConsent = consent;

    // Enable/disable services based on consent changes
    if (consent.crashReportingAllowed !=
        previousConsent.crashReportingAllowed) {
      await enableCrashCollection(consent.crashReportingAllowed);
    }

    if (consent.analyticsAllowed != previousConsent.analyticsAllowed) {
      await enableAnalytics(consent.analyticsAllowed);
    }
  }

  @override
  Future<void> logEvent(String event, [Map<String, dynamic>? data]) async {
    if (!ConsentGuard.validateOperation(
      _currentConsent,
      TelemetryOperation.analytics,
    )) {
      // Kill the operation - do not log anything
      return;
    }

    // TODO: Connect to real analytics SDK (Firebase Analytics, etc.)
    // For now, just log to console with consent marker
    debugPrint('REAL_ANALYTICS: Event logged - $event with data: $data');
  }

  @override
  Future<void> logError(String message, {Map<String, dynamic>? context}) async {
    if (!ConsentGuard.validateOperation(
      _currentConsent,
      TelemetryOperation.crashReporting,
    )) {
      // Kill the operation - do not log anything
      return;
    }

    // TODO: Connect to real crash reporting SDK (Firebase Crashlytics, Sentry, etc.)
    // For now, just log to console with consent marker
    debugPrint('REAL_CRASH: Error logged - $message with context: $context');
  }

  @override
  Future<ObservabilitySpan> startTrace(String name) async {
    if (!ConsentGuard.validateOperation(
      _currentConsent,
      TelemetryOperation.analytics,
    )) {
      return NoOpObservabilitySpan(name);
    }

    // TODO: Connect to real tracing SDK
    // For now, return real span
    return RealObservabilitySpan(name);
  }

  @override
  Future<void> setUserId(String? userId) async {
    if (!ConsentGuard.validateOperation(
      _currentConsent,
      TelemetryOperation.any,
    )) {
      return;
    }

    // TODO: Connect to real SDK user identification
    debugPrint('REAL_OBSERVABILITY: User ID set to $userId');
  }

  @override
  Future<void> setUserProperty(String name, dynamic value) async {
    if (!ConsentGuard.validateOperation(
      _currentConsent,
      TelemetryOperation.analytics,
    )) {
      return;
    }

    // TODO: Connect to real SDK user properties
    debugPrint('REAL_OBSERVABILITY: User property set - $name: $value');
  }

  @override
  Future<void> enableCrashCollection(bool enabled) async {
    // TODO: Connect to real crash reporting SDK enable/disable
    debugPrint('REAL_CRASH_COLLECTION: ${enabled ? 'ENABLED' : 'DISABLED'}');
  }

  @override
  Future<void> enableAnalytics(bool enabled) async {
    // TODO: Connect to real analytics SDK enable/disable
    debugPrint('REAL_ANALYTICS: ${enabled ? 'ENABLED' : 'DISABLED'}');
  }
}

/// No-Operation implementation that safely does nothing
/// Used when consent is denied or not yet granted
class NoOpObservabilityGate implements ObservabilityGate {
  @override
  Consent get currentConsent => Consent.none;

  @override
  Future<void> init({required Consent initialConsent}) async {
    // No-op - do nothing
    debugPrint('NO_OP_OBSERVABILITY: Initialized with consent: $initialConsent');
  }

  @override
  Future<void> setConsent(Consent consent) async {
    // No-op - ignore consent changes
    debugPrint('NO_OP_OBSERVABILITY: Consent change ignored - $consent');
  }

  @override
  Future<void> logEvent(String event, [Map<String, dynamic>? data]) async {
    // Kill operation completely - no logging, no network calls
    debugPrint('KILLED_BY_CONSENT: Analytics event blocked - $event');
  }

  @override
  Future<void> logError(String message, {Map<String, dynamic>? context}) async {
    // Kill operation completely - no logging, no network calls
    debugPrint('KILLED_BY_CONSENT: Crash report blocked - $message');
  }

  @override
  Future<ObservabilitySpan> startTrace(String name) async {
    // Return no-op span
    return NoOpObservabilitySpan(name);
  }

  @override
  Future<void> setUserId(String? userId) async {
    // Kill operation
    debugPrint('KILLED_BY_CONSENT: User ID setting blocked');
  }

  @override
  Future<void> setUserProperty(String name, dynamic value) async {
    // Kill operation
    debugPrint('KILLED_BY_CONSENT: User property setting blocked');
  }

  @override
  Future<void> enableCrashCollection(bool enabled) async {
    // No-op - ignore
    debugPrint('KILLED_BY_CONSENT: Crash collection toggle ignored');
  }

  @override
  Future<void> enableAnalytics(bool enabled) async {
    // No-op - ignore
    debugPrint('KILLED_BY_CONSENT: Analytics toggle ignored');
  }
}

/// Abstract interface for observability spans
abstract class ObservabilitySpan {
  String get name;
  Future<void> setAttributes(Map<String, String> attributes);
  Future<void> setStatus(String status, [String? description]);
  Future<void> stop();
}

/// Real span implementation
class RealObservabilitySpan implements ObservabilitySpan {
  @override
  final String name;
  final DateTime startTime = DateTime.now();

  RealObservabilitySpan(this.name);

  @override
  Future<void> setAttributes(Map<String, String> attributes) async {
    // TODO: Connect to real tracing SDK
    debugPrint('REAL_SPAN: $name attributes set: $attributes');
  }

  @override
  Future<void> setStatus(String status, [String? description]) async {
    // TODO: Connect to real tracing SDK
    debugPrint(
      'REAL_SPAN: $name status set to $status${description != null ? ' ($description)' : ''}',
    );
  }

  @override
  Future<void> stop() async {
    final duration = DateTime.now().difference(startTime);
    // TODO: Connect to real tracing SDK
    debugPrint('REAL_SPAN: $name stopped after ${duration.inMilliseconds}ms');
  }
}

/// No-op span implementation
class NoOpObservabilitySpan implements ObservabilitySpan {
  @override
  final String name;

  NoOpObservabilitySpan(this.name);

  @override
  Future<void> setAttributes(Map<String, String> attributes) async {
    // Kill operation
    debugPrint('KILLED_BY_CONSENT: Span $name attributes blocked');
  }

  @override
  Future<void> setStatus(String status, [String? description]) async {
    // Kill operation
    debugPrint('KILLED_BY_CONSENT: Span $name status blocked');
  }

  @override
  Future<void> stop() async {
    // Kill operation
    debugPrint('KILLED_BY_CONSENT: Span $name stop blocked');
  }
}

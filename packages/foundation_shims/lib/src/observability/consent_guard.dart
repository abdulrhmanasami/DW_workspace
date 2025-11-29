/// Component: Consent Guard Functions
/// Created by: Cursor B-central
/// Purpose: GDPR consent validation functions for telemetry and crash reporting
/// Last updated: 2025-11-12

/// Consent model representing user privacy choices
class Consent {
  final bool analytics;
  final bool crashReports;

  const Consent({required this.analytics, required this.crashReports});

  /// Check if any telemetry is allowed (analytics or crash reports)
  bool get anyTelemetryAllowed => analytics || crashReports;

  /// Check if crash reporting is allowed
  bool get crashReportingAllowed => crashReports;

  /// Check if analytics is allowed
  bool get analyticsAllowed => analytics;

  /// No consent - all disabled
  static const Consent none = Consent(analytics: false, crashReports: false);

  /// Full consent - all enabled
  static const Consent full = Consent(analytics: true, crashReports: true);
}

/// Consent guard functions for telemetry enforcement
class ConsentGuard {
  /// Check if telemetry is allowed based on consent
  static bool isTelemetryAllowed(Consent consent) =>
      consent.anyTelemetryAllowed;

  /// Check if crash reporting is allowed based on consent
  static bool isCrashReportingAllowed(Consent consent) =>
      consent.crashReportingAllowed;

  /// Check if analytics is allowed based on consent
  static bool isAnalyticsAllowed(Consent consent) => consent.analyticsAllowed;

  /// Validate that consent allows the requested telemetry operation
  static bool validateOperation(Consent consent, TelemetryOperation operation) {
    switch (operation) {
      case TelemetryOperation.analytics:
        return consent.analyticsAllowed;
      case TelemetryOperation.crashReporting:
        return consent.crashReportingAllowed;
      case TelemetryOperation.any:
        return consent.anyTelemetryAllowed;
    }
  }
}

/// Types of telemetry operations that require consent validation
enum TelemetryOperation {
  /// Analytics events (user behavior tracking)
  analytics,

  /// Crash reporting and error logging
  crashReporting,

  /// Any telemetry operation
  any,
}

/// Component: Crash Reporter Contracts
/// Created by: Cursor (auto-generated)
/// Purpose: Crash reporting abstractions
/// Last updated: 2025-11-03

/// Abstract crash reporter contract
abstract class CrashReporter {
  /// Report a caught exception
  Future<void> reportException(
    dynamic exception,
    StackTrace? stackTrace, {
    Map<String, dynamic>? context,
  });

  /// Report a non-fatal error
  Future<void> reportError(
    String message, {
    Map<String, dynamic>? context,
  });

  /// Set user context for crash reports
  Future<void> setUserContext({
    String? userId,
    String? email,
    Map<String, String>? customData,
  });

  /// Clear user context
  Future<void> clearUserContext();
}

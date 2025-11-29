/// Component: Performance Monitor Contracts
/// Created by: Cursor (auto-generated)
/// Purpose: Performance monitoring abstractions
/// Last updated: 2025-11-03

/// Abstract performance monitor contract
abstract class PerformanceMonitor {
  /// Start tracing an operation
  PerformanceTrace startTrace(String name);

  /// Record a metric
  Future<void> recordMetric(
    String name,
    num value, {
    Map<String, String>? attributes,
  });

  /// Set global attributes for all metrics
  Future<void> setGlobalAttributes(Map<String, String> attributes);
}

/// Performance trace contract
abstract class PerformanceTrace {
  /// Add attribute to trace
  Future<void> setAttribute(String key, String value);

  /// Stop the trace
  Future<void> stop();
}

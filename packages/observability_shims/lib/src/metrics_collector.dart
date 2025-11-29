/// Component: Metrics Collector Contracts
/// Created by: Cursor (auto-generated)
/// Purpose: Metrics collection abstractions
/// Last updated: 2025-11-03

/// Abstract metrics collector contract
abstract class MetricsCollector {
  /// Increment a counter metric
  Future<void> incrementCounter(
    String name, {
    int amount = 1,
    Map<String, String>? tags,
  });

  /// Record a gauge value
  Future<void> recordGauge(
    String name,
    num value, {
    Map<String, String>? tags,
  });

  /// Record a histogram value
  Future<void> recordHistogram(
    String name,
    num value, {
    Map<String, String>? tags,
  });

  /// Start a timer
  MetricsTimer startTimer(String name, {Map<String, String>? tags});
}

/// Metrics timer contract
abstract class MetricsTimer {
  /// Stop the timer and record the duration
  Future<void> stop();
}

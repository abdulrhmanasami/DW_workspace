/// Component: Logging Framework
/// Created by: Cursor (auto-generated)
/// Purpose: Unified logging abstractions
/// Last updated: 2025-11-03

/// Log levels
enum LogLevel { debug, info, warning, error, critical }

/// Logger interface
abstract class Logger {
  /// Log a debug message
  void debug(String message, {Map<String, dynamic>? context});

  /// Log an info message
  void info(String message, {Map<String, dynamic>? context});

  /// Log a warning message
  void warning(String message, {Map<String, dynamic>? context});

  /// Log an error message
  void error(
    String message, {
    Map<String, dynamic>? context,
    dynamic error,
    StackTrace? stackTrace,
  });

  /// Log a critical message
  void critical(
    String message, {
    Map<String, dynamic>? context,
    dynamic error,
    StackTrace? stackTrace,
  });
}

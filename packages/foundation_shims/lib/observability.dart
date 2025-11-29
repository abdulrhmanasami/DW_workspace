class ObservabilityService {
  const ObservabilityService();

  static const ObservabilityService instance = ObservabilityService();

  void logDebug(String tag, String message, [Map<String, Object?>? context]) {}

  void logInfo(String tag, String message, [Map<String, Object?>? context]) {}

  void logWarn(String tag, String message, [Map<String, Object?>? context]) {}

  void logError(
    String tag,
    String message, {
    Object? error,
    Map<String, Object?>? context,
  }) {}
}

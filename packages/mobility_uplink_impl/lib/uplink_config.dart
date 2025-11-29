/// Minimal configuration object for mobility uplink flows.
class UplinkConfig {
  final bool uplinkEnabled;
  final Duration retryBackoffMin;
  final Duration retryBackoffMax;
  final Duration flushInterval;
  final int batchSize;
  final int maxQueue;
  final Uri? endpoint;
  final Duration requestTimeout;
  final int maxRetries;

  const UplinkConfig({
    this.uplinkEnabled = true,
    this.retryBackoffMin = const Duration(seconds: 2),
    this.retryBackoffMax = const Duration(minutes: 2),
    this.flushInterval = const Duration(seconds: 10),
    this.batchSize = 50,
    this.maxQueue = 500,
    this.endpoint,
    this.requestTimeout = const Duration(seconds: 15),
    this.maxRetries = 2,
  });

  /// Convenience factory that can be wired to env/remote config inputs.
  factory UplinkConfig.fromEnv({
    bool? uplinkEnabled,
    Duration? retryBackoffMin,
    Duration? retryBackoffMax,
    Duration? flushInterval,
    int? batchSize,
    int? maxQueue,
    String? endpointBase,
    Duration? requestTimeout,
    int? maxRetries,
  }) {
    return UplinkConfig(
      uplinkEnabled: uplinkEnabled ?? true,
      retryBackoffMin: retryBackoffMin ?? const Duration(seconds: 2),
      retryBackoffMax: retryBackoffMax ?? const Duration(minutes: 2),
      flushInterval: flushInterval ?? const Duration(seconds: 10),
      batchSize: batchSize ?? 50,
      maxQueue: maxQueue ?? 500,
      endpoint: endpointBase != null && endpointBase.isNotEmpty
          ? Uri.parse(endpointBase)
          : null,
      requestTimeout: requestTimeout ?? const Duration(seconds: 15),
      maxRetries: maxRetries ?? 2,
    );
  }
}

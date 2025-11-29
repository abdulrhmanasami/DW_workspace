/// Network configuration
class NetworkConfig {
  const NetworkConfig({
    this.baseUrl = '',
    this.timeout = const Duration(seconds: 30),
    this.retryCount = 3,
  });

  final String baseUrl;
  final Duration timeout;
  final int retryCount;
}

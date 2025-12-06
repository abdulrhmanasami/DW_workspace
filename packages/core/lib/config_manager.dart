/// Configuration manager interface
abstract class ConfigManager {
  T get<T>(final String key, final T defaultValue);
  Future<void> set<T>(final String key, final T value);
  bool has(final String key);
  Future<void> reload();
}

class ConfigManagerStub implements ConfigManager {
  final Map<String, dynamic> _config = <String, dynamic>{};

  @override
  T get<T>(final String key, final T defaultValue) {
    final value = _config[key];
    if (value is T) return value;
    return defaultValue;
  }

  @override
  Future<void> set<T>(final String key, final T value) async {
    _config[key] = value;
  }

  @override
  bool has(final String key) => _config.containsKey(key);

  @override
  Future<void> reload() async {
    // Stub implementation - no reload
  }
}

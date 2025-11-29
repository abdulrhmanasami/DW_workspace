/// Component: LocalConfigService
/// Created by: Cursor (auto-generated)
/// Purpose: Local configuration storage service
/// Last updated: 2025-11-01

class LocalConfigService {
  final Map<String, Object?> _store = {};

  T? get<T>(String key) => _store[key] as T?;

  void set<T>(String key, T value) => _store[key] = value;
}

/// Component: Environment Configuration
/// Created by: Cursor (auto-generated)
/// Purpose: Environment and flavor management
/// Last updated: 2025-11-03

/// Application flavors
enum Flavor { development, staging, production }

/// Environment configuration contract
abstract class EnvironmentConfig {
  Flavor get currentFlavor;
  String get apiBaseUrl;
  String get environmentName;
  bool get isDebug;
  bool get enableLogging;
  Map<String, dynamic> get config;
}

/// App Info - Application Information Service
/// Created by: Cursor B-ux
/// Purpose: Abstract interface for accessing application information
/// Last updated: 2025-11-13

/// Application information model
class AppInfo {
  final String version;
  final String buildNumber;
  final String packageName;

  const AppInfo({
    required this.version,
    required this.buildNumber,
    required this.packageName,
  });

  @override
  String toString() =>
      'AppInfo(version: $version, build: $buildNumber, package: $packageName)';
}

/// Service for retrieving application information
abstract class AppInfoService {
  Future<AppInfo> getInfo();
}

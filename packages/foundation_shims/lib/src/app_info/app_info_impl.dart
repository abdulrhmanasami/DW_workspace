/// App Info Implementation - Package Info Plus
/// Created by: Cursor B-ux
/// Purpose: Implementation of AppInfoService using package_info_plus
/// Last updated: 2025-11-13

import 'package:package_info_plus/package_info_plus.dart';

import 'app_info.dart';

/// Implementation of AppInfoService using package_info_plus
class AppInfoServiceImpl implements AppInfoService {
  @override
  Future<AppInfo> getInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();

    return AppInfo(
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      packageName: packageInfo.packageName,
    );
  }
}

/// Global instance for convenience
final appInfoServiceImpl = AppInfoServiceImpl();

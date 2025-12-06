/// App Info Providers - Riverpod providers for app information
/// Created by: Cursor B-ux
/// Purpose: Riverpod providers for AppInfo service
/// Last updated: 2025-11-13

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:foundation_shims/src/app_info/app_info.dart';
import 'package:foundation_shims/src/app_info/app_info_impl.dart';

/// AppInfo service provider
final appInfoServiceProvider = Provider<AppInfoService>((ref) {
  return appInfoServiceImpl;
});

/// Convenience provider returning AppInfo
final appInfoProvider = FutureProvider<AppInfo>((ref) async {
  final service = ref.watch(appInfoServiceProvider);
  return service.getInfo();
});

/// Component: Location Permission Service
/// Created by: Cursor B-mobility
/// Purpose: Interface for location permission management
/// Last updated: 2025-11-11

import 'background_contracts.dart';

abstract class LocationPermissionService {
  Future<PermissionStatus> check();
  Future<PermissionStatus> request();
  Future<bool> isServiceEnabled();
}

/// No-Op implementation for safe fallback when permission services are not available
class NoOpLocationPermissionService implements LocationPermissionService {
  const NoOpLocationPermissionService();

  @override
  Future<PermissionStatus> check() async {
    // Return not determined: Permission service not available
    return PermissionStatus.notDetermined;
  }

  @override
  Future<PermissionStatus> request() async {
    // Return denied: Permission service not available
    return PermissionStatus.denied;
  }

  @override
  Future<bool> isServiceEnabled() async {
    // Return false: Permission service not available
    return false;
  }
}

enum LocationPermissionStatus { granted, denied, restricted, permanentlyDenied }

abstract class LocationPermissionService {
  Future<LocationPermissionStatus> check();
  Future<LocationPermissionStatus> request();
  Future<bool> isServiceEnabled();
}

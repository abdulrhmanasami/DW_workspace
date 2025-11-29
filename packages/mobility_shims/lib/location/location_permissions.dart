import 'models.dart';

abstract class LocationPermissionService {
  Future<bool> isServiceEnabled();
  Future<LocationPermission> check();
  Future<LocationPermission> request();
}

abstract class LocationService {
  Future<PositionFix> getCurrent();
  Stream<PositionFix> watch();
}

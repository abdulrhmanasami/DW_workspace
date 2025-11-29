import '../location/models.dart';

abstract class LocationPermissionService {
  Future<bool> isServiceEnabled();
  Future<bool> check();
  Future<bool> request();
}

abstract class LocationService {
  Future<LocationPoint> getCurrent();
  Stream<LocationPoint> watch();
}

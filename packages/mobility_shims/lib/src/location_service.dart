
import 'package:mobility_shims/location/models.dart';

abstract class LocationService {
  Future<LocationPoint> getCurrent();
  Stream<LocationPoint> watch();
  Future<bool> isServiceEnabled();
}

/// No-Op implementation for safe fallback when location services are not available
class NoOpLocationService implements LocationService {
  const NoOpLocationService();

  @override
  Future<LocationPoint> getCurrent() async {
    // Return default location: Location services not available
    return LocationPoint(
      latitude: 0.0,
      longitude: 0.0,
      timestamp: DateTime.now(),
    );
  }

  @override
  Stream<LocationPoint> watch() {
    // No-op stream: Location services not available
    return const Stream<LocationPoint>.empty();
  }

  @override
  Future<bool> isServiceEnabled() async {
    // Return false: Location services not available
    return false;
  }
}

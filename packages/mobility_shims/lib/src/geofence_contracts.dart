import 'types.dart';

typedef GeofenceId = String;

class GeofenceRegion {
  final GeofenceId id;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  GeofenceRegion({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
  });
}

class GeofenceConfig {
  final String id;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final bool notifyOnEnter;
  final bool notifyOnExit;
  final bool notifyOnDwell;
  final Duration? dwellDuration;
  const GeofenceConfig({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    this.notifyOnEnter = true,
    this.notifyOnExit = true,
    this.notifyOnDwell = false,
    this.dwellDuration,
  });
}

abstract class GeofenceManager {
  Future<void> setGeofences(List<GeofenceRegion> regions);
  Stream<GeofenceEvent> get onEnter;
  Stream<GeofenceEvent> get onExit;
}

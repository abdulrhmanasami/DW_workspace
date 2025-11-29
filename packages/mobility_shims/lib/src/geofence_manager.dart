import 'geofence_contracts.dart';
import 'types.dart';

export 'geofence_contracts.dart';
export 'types.dart' show GeofenceEvent, GeofenceEventType;

/// Legacy alias maintained for older imports. Prefer [GeofenceRegion].
typedef Geofence = GeofenceRegion;

/// Legacy alias maintained for older imports. Prefer [GeofenceManager].
typedef LegacyGeofenceManager = GeofenceManager;

typedef LegacyGeofenceEvent = GeofenceEvent;

typedef LegacyGeofenceEventType = GeofenceEventType;

typedef LegacyGeofence = GeofenceRegion;

class NoOpGeofenceManager implements GeofenceManager {
  const NoOpGeofenceManager();

  @override
  Future<void> setGeofences(List<GeofenceRegion> regions) async {}

  @override
  Stream<GeofenceEvent> get onEnter => const Stream<GeofenceEvent>.empty();

  @override
  Stream<GeofenceEvent> get onExit => const Stream<GeofenceEvent>.empty();
}

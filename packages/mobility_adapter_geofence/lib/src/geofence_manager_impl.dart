import 'dart:async';

import 'package:mobility_shims/mobility.dart'
    show GeofenceRegion, GeofenceEvent, GeofenceEventType, GeofenceManager, LocationPoint;

/// Stubbed geofence manager that keeps track of configured regions and emits
/// synthetic events. Real platform bindings should replace this class.
class GeofenceManagerImpl implements GeofenceManager {
  GeofenceManagerImpl();

  final _eventStreamController = StreamController<GeofenceEvent>.broadcast();
  final _enterController = StreamController<GeofenceEvent>.broadcast();
  final _exitController = StreamController<GeofenceEvent>.broadcast();

    Stream<GeofenceEvent> get events => _eventStreamController.stream;

  Stream<GeofenceEvent> onEvents() => events;

  @override
  Stream<GeofenceEvent> get onEnter => _enterController.stream;

  @override
  Stream<GeofenceEvent> get onExit => _exitController.stream;

  @override
  Future<void> setGeofences(List<GeofenceRegion> geofences) async {
    // Stored for inspection if needed.
  }

  /// Clears all configured geofences.
  Future<void> clearGeofences() async {
  }

  /// Simulates an enter event for testing purposes.
  void emitEnter(String geofenceId, {LocationPoint? location}) {
    final event = GeofenceEvent(
      id: geofenceId,
      type: GeofenceEventType.enter,
      timestamp: DateTime.now(),
      location: location,
    );
    _enterController.add(event);
    _eventStreamController.add(event);
  }

  /// Simulates an exit event for testing purposes.
  void emitExit(String geofenceId, {LocationPoint? location}) {
    final event = GeofenceEvent(
      id: geofenceId,
      type: GeofenceEventType.exit,
      timestamp: DateTime.now(),
      location: location,
    );
    _exitController.add(event);
    _eventStreamController.add(event);
  }

  Future<void> dispose() async {
    await _eventStreamController.close();
    await _enterController.close();
    await _exitController.close();
  }
}

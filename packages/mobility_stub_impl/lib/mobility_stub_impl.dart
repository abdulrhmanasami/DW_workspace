library mobility_stub_impl;

import 'dart:async';

import 'package:mobility_shims/mobility.dart';

/// TripRecorder NoOp implementation aligned with the canonical contract.
class NoOpTripRecorder implements TripRecorder {
  NoOpTripRecorder();

  final Map<String, List<TripPoint>> _trips = <String, List<TripPoint>>{};
  final StreamController<TripPoint> _pointStream =
      StreamController<TripPoint>.broadcast();
  String? _activeTripId;

  @override
  String? get activeTripId => _activeTripId;

  @override
  Stream<TripPoint> get points => _pointStream.stream;

  @override
  Future<void> beginTripWithId(
    String id, {
    DateTime? startedAt,
  }) async {
    _activeTripId = id;
    _trips.putIfAbsent(id, () => <TripPoint>[]);
  }

  @override
  Future<void> beginTrip({
    String? id,
    DateTime? startedAt,
  }) =>
      beginTripWithId(
        id ?? TripRecorder.generateTripId(),
        startedAt: startedAt,
      );

  @override
  Future<void> addPoint(TripPoint point) async {
    final bucket = _trips.putIfAbsent(point.tripId, () => <TripPoint>[]);
    bucket.add(point);
    _pointStream.add(point);
  }

  @override
  Future<void> endTrip({bool flush = true}) async {
    if (flush) {
      await this.flush();
    }
    _activeTripId = null;
  }

  @override
  Future<void> flush() async {
    // No remote uplink in the noop implementation.
  }

  @override
  Future<List<TripPoint>> getPoints({String? tripId}) async {
    final id = tripId ?? _activeTripId;
    if (id == null) return const [];
    final data = _trips[id];
    if (data == null) return const [];
    return List<TripPoint>.unmodifiable(data);
  }

  @override
  Future<void> reset() async {
    _trips.clear();
    _activeTripId = null;
  }

  void dispose() {
    _pointStream.close();
  }
}

/// GeofenceManager NoOp implementation.
class NoOpGeofenceManager implements GeofenceManager {
  NoOpGeofenceManager();

  final StreamController<GeofenceEvent> _events =
      StreamController<GeofenceEvent>.broadcast();

  @override
  Stream<GeofenceEvent> get events => _events.stream;

  @override
  Future<void> setGeofences(List<GeofenceConfig> geofences) async {
    // Nothing to register in noop mode.
  }

  @override
  Future<void> clearGeofences() async {
    // Nothing to clear in noop mode.
  }

  void dispose() {
    _events.close();
  }
}

/// BackgroundTrackingController NoOp implementation.
class NoOpBackgroundTrackingController
    implements BackgroundTrackingController {
  NoOpBackgroundTrackingController();

  final StreamController<LocationPoint> _positions =
      StreamController<LocationPoint>.broadcast();
  bool _isTracking = false;

  @override
  Stream<LocationPoint> get positionStream => _positions.stream;

  @override
  bool get isTracking => _isTracking;

  @override
  Future<void> startForeground({
    required BackgroundTrackingNotification notification,
    LocationRequestOptions options = const LocationRequestOptions(),
  }) async {
    _isTracking = true;
  }

  @override
  Future<void> stop() async {
    _isTracking = false;
  }

  void dispose() {
    _positions.close();
  }
}

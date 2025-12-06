library mobility_stub_impl;

import 'dart:async';

import 'package:mobility_shims/mobility.dart';

/// TripRecorder NoOp implementation aligned with the canonical contract.
class NoOpTripRecorder implements TripRecorder {
  const NoOpTripRecorder();

  @override
  Future<void> beginTrip(String id) async {}

  @override
  Future<void> endTrip() async {}

  @override
  Stream<LocationPoint> get points => const Stream<LocationPoint>.empty();
}

/// GeofenceManager NoOp implementation.
class NoOpGeofenceManager implements GeofenceManager {
  NoOpGeofenceManager();

  final StreamController<GeofenceEvent> _enter =
      StreamController<GeofenceEvent>.broadcast();
  final StreamController<GeofenceEvent> _exit =
      StreamController<GeofenceEvent>.broadcast();

  @override
  Stream<GeofenceEvent> get onEnter => _enter.stream;

  @override
  Stream<GeofenceEvent> get onExit => _exit.stream;

  @override
  Future<void> setGeofences(List<GeofenceRegion> regions) async {
    // No-op: just keep API surface compatible.
  }

  void dispose() {
    _enter.close();
    _exit.close();
  }
}

/// BackgroundTrackingController NoOp implementation.
class NoOpBackgroundTrackingController
    implements BackgroundTrackingController {
  NoOpBackgroundTrackingController();

  final StreamController<TrackingSessionState> _state =
      StreamController<TrackingSessionState>.broadcast();

  @override
  Stream<TrackingSessionState> get state => _state.stream;

  @override
  Future<void> startForeground() async {}

  @override
  Future<void> stop() async {}

  void dispose() {
    _state.close();
  }
}

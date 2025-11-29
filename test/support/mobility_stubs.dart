// Mobility Stubs for Testing
// Created by: Cursor A
// Purpose: Test stubs for mobility testing with configurable behavior
// Last updated: 2025-11-26

import 'dart:async';

import 'package:mobility_shims/mobility.dart';
import 'package:mobility_shims/mobility_shims.dart' as shims;

// Re-export the official stub implementations from mobility_shims
export 'package:mobility_shims/mobility_shims.dart'
    show StubLocationProvider, StubBackgroundTracker;

/// Test-only location provider that allows service to be enabled
class TestLocationProvider implements LocationProvider {
  const TestLocationProvider({
    this.serviceIsEnabled = true,
    this.permission = PermissionStatus.granted,
  });

  final bool serviceIsEnabled;
  final PermissionStatus permission;

  @override
  Stream<LocationPoint> watch() => const Stream<LocationPoint>.empty();

  @override
  Future<LocationPoint> getCurrent() async {
    return LocationPoint(
      latitude: 51.5074,
      longitude: -0.1278,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<PermissionStatus> requestPermission() async => permission;

  @override
  Future<bool> serviceEnabled() async => serviceIsEnabled;
}

/// Test-only background tracker that does nothing
class TestBackgroundTracker implements BackgroundTracker {
  const TestBackgroundTracker();

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  Stream<TrackingStatus> status() => Stream.value(TrackingStatus.stopped);
}

/// In-memory TripRecorder for testing
/// Stores points in memory and emits them via a stream
class InMemoryTripRecorder implements shims.TripRecorder {
  InMemoryTripRecorder();

  bool _isRecording = false;
  String? _currentTripId;
  final StreamController<LocationPoint> _pointsController =
      StreamController<LocationPoint>.broadcast();

  @override
  Future<void> beginTrip(String id) async {
    _isRecording = true;
    _currentTripId = id;
  }

  @override
  Future<void> endTrip() async {
    _isRecording = false;
    _currentTripId = null;
  }

  @override
  Stream<LocationPoint> get points => _pointsController.stream;

  /// Helper method for tests to simulate location points
  void addPoint(LocationPoint point) {
    if (_isRecording) {
      _pointsController.add(point);
    }
  }

  /// Helper to check if recording
  bool get isRecording => _isRecording;

  /// Helper to get current trip ID
  String? get currentTripId => _currentTripId;

  /// Clean up resources
  void dispose() {
    _pointsController.close();
  }
}

// Stub Implementations - Safe Fallbacks
// Created by: Cursor B-mobility
// Purpose: No-Op implementations for safe fallback when mobility features are disabled
// Last updated: 2025-11-13

import '../contracts.dart';
import '../background_contracts.dart';
import '../../location/models.dart' show LocationPoint;

/// Stub location provider that returns empty streams and throws safe exceptions
class StubLocationProvider implements LocationProvider {
  const StubLocationProvider();

  @override
  Stream<LocationPoint> watch() {
    return const Stream<LocationPoint>.empty();
  }

  @override
  Future<LocationPoint> getCurrent() {
    throw ConsentDeniedException(
      'Location services are disabled or consent not granted',
    );
  }

  @override
  Future<PermissionStatus> requestPermission() async {
    return PermissionStatus.denied;
  }

  @override
  Future<bool> serviceEnabled() async {
    return false;
  }
}

/// Stub background tracker that does nothing safely
class StubBackgroundTracker implements BackgroundTracker {
  const StubBackgroundTracker();

  @override
  Future<void> start() async {
    // No-op: Background tracking disabled
  }

  @override
  Future<void> stop() async {
    // No-op: Background tracking disabled
  }

  @override
  Stream<TrackingStatus> status() {
    return Stream.value(TrackingStatus.stopped);
  }
}

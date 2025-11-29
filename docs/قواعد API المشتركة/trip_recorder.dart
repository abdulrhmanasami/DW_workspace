/// Component: Trip Recorder
/// Created by: Cursor B-mobility
/// Purpose: Interface for trip recording operations
/// Last updated: 2025-11-11

import '../location/models.dart' show LocationPoint;

/// Trip summary data
class TripSummary {
  final String id;
  final double distanceKm; // in kilometers
  final Duration duration;
  final int pointsCount;

  const TripSummary({
    required this.id,
    required this.distanceKm,
    required this.duration,
    required this.pointsCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'distance_km': distanceKm,
      'duration_seconds': duration.inSeconds,
      'points_count': pointsCount,
    };
  }
}

abstract class TripRecorder {
  Future<void> beginTrip(String id);
  Future<void> endTrip();
  Stream<LocationPoint> get points;
}

/// No-Op implementation for safe fallback when trip recording is not available
class NoOpTripRecorder implements TripRecorder {
  const NoOpTripRecorder();

  @override
  Future<void> beginTrip(String id) async {
    // No-op: Trip recording not available
  }

  @override
  Future<void> endTrip() async {
    // No-op: Trip recording not available
  }

  @override
  Stream<LocationPoint> get points async* {
    // No-op stream: Trip recording not available
  }
}

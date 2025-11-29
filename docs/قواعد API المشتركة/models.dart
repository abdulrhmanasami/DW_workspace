import 'package:meta/meta.dart';

/// Canonical representation for any captured geographic point.
@immutable
class LocationPoint {
  final double latitude;
  final double longitude;
  final double? accuracyMeters;
  final double? altitudeMeters;
  final double? bearingDegrees;
  final double? speedMetersPerSecond;
  final DateTime? timestamp;

  const LocationPoint({
    required this.latitude,
    required this.longitude,
    double? accuracyMeters,
    double? accuracy,
    double? altitudeMeters,
    double? altitude,
    double? bearingDegrees,
    double? bearing,
    double? speedMetersPerSecond,
    double? speed,
    this.timestamp,
  })  : accuracyMeters = accuracyMeters ?? accuracy,
        altitudeMeters = altitudeMeters ?? altitude,
        bearingDegrees = bearingDegrees ?? bearing,
        speedMetersPerSecond = speedMetersPerSecond ?? speed;

  /// Backwards-compatible getters for legacy call sites.
  double? get accuracy => accuracyMeters;
  double? get altitude => altitudeMeters;
  double? get bearing => bearingDegrees;
  double? get speed => speedMetersPerSecond;
}

@immutable
class PositionFix {
  final double lat;
  final double lng;
  final double accuracy;
  final DateTime timestamp;

  const PositionFix({
    required this.lat,
    required this.lng,
    required this.accuracy,
    required this.timestamp,
  });
}

class PositionSettings {
  final double distanceFilterMeters;
  final Duration interval;

  const PositionSettings({
    required this.distanceFilterMeters,
    required this.interval,
  });
}

enum LocationPermission { denied, deniedForever, whileInUse, always }

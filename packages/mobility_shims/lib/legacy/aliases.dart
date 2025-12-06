// Legacy Bridge for mobility_shims - Backward compatibility layer
// Allows existing code to work with minimal changes

import 'package:mobility_shims/location/models.dart';

extension PositionFixCompat on PositionFix {
  LocationPoint toLocationPoint() => LocationPoint(
        latitude: lat,
        longitude: lng,
        accuracyMeters: accuracy,
        timestamp: timestamp,
      );
}

typedef LocationPermissionStatus = LocationPermission;

extension LocationPointCompat on LocationPoint {
  double get lat => latitude;
  double get lng => longitude;
  double? get accuracy => accuracyMeters;
  DateTime? get time => timestamp;
}

extension LocationPermissionCompat on LocationPermission {
  bool get isGranted =>
      this == LocationPermission.always ||
      this == LocationPermission.whileInUse;

  bool get isDenied =>
      this == LocationPermission.denied ||
      this == LocationPermission.deniedForever;
}

/// Component: Geographic Adapters
/// Created by: Cursor B-mobility
/// Purpose: Adapters for converting between mobility and maps types
/// Last updated: 2025-11-17

import 'geo_types.dart';

/// Adapters for converting between LocationPoint and MapPoint
/// Uses dynamic typing to avoid circular dependencies with mobility_shims
class GeoAdapters {
  /// Converts LocationPoint from mobility_shims to MapPoint for maps
  /// Uses dynamic typing to avoid compile-time dependency on mobility_shims
  static MapPoint mapPointFromLocation(dynamic locationPoint) {
    return MapPoint(
      latitude: (locationPoint.latitude as num).toDouble(),
      longitude: (locationPoint.longitude as num).toDouble(),
      accuracy: (locationPoint.accuracy as num?)?.toDouble(),
      altitude: (locationPoint.altitude as num?)?.toDouble(),
      speed: (locationPoint.speed as num?)?.toDouble(),
      timestamp: locationPoint.timestamp as DateTime,
    );
  }

  /// Converts MapPoint to LocationPoint for mobility operations
  /// Uses dynamic typing to avoid compile-time dependency on mobility_shims
  static dynamic locationFromMapPoint(MapPoint mapPoint) {
    // Return a dynamic object with LocationPoint-compatible fields
    // This avoids importing LocationPoint directly
    return _LocationPointCompat(
      latitude: mapPoint.latitude,
      longitude: mapPoint.longitude,
      accuracy: mapPoint.accuracy,
      altitude: mapPoint.altitude,
      speed: mapPoint.speed,
      timestamp: mapPoint.timestamp,
    );
  }
}

/// Compatibility class for LocationPoint to avoid direct import
class _LocationPointCompat {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;
  final double? speed;
  final DateTime timestamp;

  const _LocationPointCompat({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    this.speed,
    required this.timestamp,
  });
}

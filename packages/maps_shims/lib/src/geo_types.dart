import 'dart:math';
import 'types.dart';

/// Component: Geographic Types for Maps
/// Created by: Cursor B-mobility
/// Purpose: Location types specifically for map operations
/// Last updated: 2025-11-11

/// Geographic location point for map operations
/// This is the canonical type for map coordinates in the maps domain
class MapPoint {
  /// Latitude in decimal degrees (-90.0 to 90.0)
  /// Must be valid geographic coordinate
  final double latitude;

  /// Longitude in decimal degrees (-180.0 to 180.0)
  /// Must be valid geographic coordinate
  final double longitude;

  /// Optional altitude in meters above sea level
  final double? altitude;

  /// Optional accuracy of the location in meters
  final double? accuracy;

  /// Optional speed in meters per second
  final double? speed;

  /// Optional bearing (direction of travel) in degrees (0-360)
  final double? bearing;

  /// Timestamp when this location was recorded
  final DateTime timestamp;

  /// Creates a map point with validation
  MapPoint({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.accuracy,
    this.speed,
    this.bearing,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now(),
       assert(
         latitude >= -90.0 && latitude <= 90.0,
         'Latitude must be between -90.0 and 90.0 degrees',
       ),
       assert(
         longitude >= -180.0 && longitude <= 180.0,
         'Longitude must be between -180.0 and 180.0 degrees',
       ),
       assert(
         altitude == null || altitude >= -1000.0,
         'Altitude must be reasonable (>= -1000m)',
       ),
       assert(
         accuracy == null || accuracy >= 0.0,
         'Accuracy must be non-negative',
       ),
       assert(speed == null || speed >= 0.0, 'Speed must be non-negative'),
       assert(
         bearing == null || (bearing >= 0.0 && bearing <= 360.0),
         'Bearing must be between 0.0 and 360.0 degrees',
       );

  /// Creates a map point from coordinates with 6 decimal precision
  factory MapPoint.fromCoordinates(
    double lat,
    double lng, {
    double? altitude,
    double? accuracy,
    double? speed,
    double? bearing,
    DateTime? timestamp,
  }) {
    // Ensure 6 decimal places precision
    final roundedLat = double.parse(lat.toStringAsFixed(6));
    final roundedLng = double.parse(lng.toStringAsFixed(6));

    return MapPoint(
      latitude: roundedLat,
      longitude: roundedLng,
      altitude: altitude,
      accuracy: accuracy,
      speed: speed,
      bearing: bearing,
      timestamp: timestamp,
    );
  }

  /// Creates a copy with updated fields
  MapPoint copyWith({
    double? latitude,
    double? longitude,
    double? altitude,
    double? accuracy,
    double? speed,
    double? bearing,
    DateTime? timestamp,
  }) {
    return MapPoint(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      accuracy: accuracy ?? this.accuracy,
      speed: speed ?? this.speed,
      bearing: bearing ?? this.bearing,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Calculates distance to another map point in meters
  /// Uses Haversine formula for great circle distance
  double distanceTo(MapPoint other) {
    const double earthRadius = 6371000; // meters

    final lat1Rad = latitude * (pi / 180.0);
    final lat2Rad = other.latitude * (pi / 180.0);
    final deltaLatRad = (other.latitude - latitude) * (pi / 180.0);
    final deltaLngRad = (other.longitude - longitude) * (pi / 180.0);

    final a =
        sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) *
            cos(lat2Rad) *
            sin(deltaLngRad / 2) *
            sin(deltaLngRad / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  /// Converts to a map for serialization
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      if (altitude != null) 'altitude': altitude,
      if (accuracy != null) 'accuracy': accuracy,
      if (speed != null) 'speed': speed,
      if (bearing != null) 'bearing': bearing,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Creates from a map (deserialization)
  factory MapPoint.fromJson(Map<String, dynamic> json) {
    return MapPoint(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      altitude: json['altitude'] as double?,
      accuracy: json['accuracy'] as double?,
      speed: json['speed'] as double?,
      bearing: json['bearing'] as double?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }

  @override
  String toString() {
    return 'MapPoint(lat: $latitude, lng: $longitude, accuracy: $accuracy, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MapPoint &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.altitude == altitude &&
        other.accuracy == accuracy &&
        other.speed == speed &&
        other.bearing == bearing &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(
      latitude,
      longitude,
      altitude,
      accuracy,
      speed,
      bearing,
      timestamp,
    );
  }
}

/// Conversion utilities between mobility and maps domains
/// These converters are placed in maps_shims to avoid circular dependencies
class MapMobilityConverters {
  /// Converts LocationPoint from mobility_shims to MapPoint
  static MapPoint locationPointToMapPoint(dynamic locationPoint) {
    // This will be called with LocationPoint from mobility_shims
    // We use dynamic to avoid compile-time dependency
    return MapPoint(
      latitude: locationPoint.latitude,
      longitude: locationPoint.longitude,
      accuracy: locationPoint.accuracy,
      altitude: locationPoint.altitude,
      speed: locationPoint.speed,
      timestamp: locationPoint.timestamp,
    );
  }

  /// Converts MapPoint to a simple LatLng (for maps API)
  static LatLng mapPointToLatLng(MapPoint point) {
    // Return LatLng from maps_shims
    return LatLng(point.latitude, point.longitude);
  }

  /// Converts LatLng to MapPoint
  static MapPoint latLngToMapPoint(dynamic latLng) {
    return MapPoint(latitude: latLng.lat, longitude: latLng.lng);
  }
}

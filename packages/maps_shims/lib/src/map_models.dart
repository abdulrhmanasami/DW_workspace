/// Map Shim Models - Pure Dart Value Objects
/// Track B - Ticket #198: MapInterface تفاعلي (Streams/Sinks) + Stub Implementation
/// Purpose: Define canonical map data models for the app (no Flutter dependencies)

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'geo_types.dart' show MapPoint;

/// A latitude/longitude point on the Earth's surface.
///
/// Pure Dart implementation - no Flutter dependencies.
/// Used as the canonical coordinate type throughout DW maps integration.
@immutable
class GeoPoint {
  /// Creates a coordinate with the given [latitude] and [longitude].
  const GeoPoint(this.latitude, this.longitude)
      : assert(latitude >= -90.0 && latitude <= 90.0, 'Latitude must be between -90 and 90'),
        assert(longitude >= -180.0 && longitude <= 180.0, 'Longitude must be between -180 and 180');

  /// The latitude in degrees (between -90.0 and 90.0).
  final double latitude;

  /// The longitude in degrees (between -180.0 and 180.0).
  final double longitude;

  @override
  String toString() => 'GeoPoint($latitude, $longitude)';

  @override
  bool operator ==(Object other) {
    return other is GeoPoint &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => Object.hash(latitude, longitude);
}

/// A bounding box defined by two coordinates (southwest and northeast).
///
/// Used for viewport calculations and camera bounds.
@immutable
class MapBounds {
  /// Creates bounds with the given corners.
  const MapBounds({
    required this.southWest,
    required this.northEast,
  });

  /// The southwest corner of the bounds.
  final GeoPoint southWest;

  /// The northeast corner of the bounds.
  final GeoPoint northEast;

  /// Returns true if [point] is within these bounds.
  bool contains(GeoPoint point) {
    return point.latitude >= southWest.latitude &&
        point.latitude <= northEast.latitude &&
        point.longitude >= southWest.longitude &&
        point.longitude <= northEast.longitude;
  }

  /// Returns the center point of these bounds.
  GeoPoint get center => GeoPoint(
        (southWest.latitude + northEast.latitude) / 2,
        (southWest.longitude + northEast.longitude) / 2,
      );

  @override
  String toString() => 'MapBounds($southWest => $northEast)';

  @override
  bool operator ==(Object other) {
    return other is MapBounds &&
        other.southWest == southWest &&
        other.northEast == northEast;
  }

  @override
  int get hashCode => Object.hash(southWest, northEast);
}

/// Zoom level for map display.
///
/// Wrapper around double to provide semantic meaning and potential validation.
@immutable
class MapZoom {
  /// Creates a zoom level with the given value.
  const MapZoom(this.value);

  /// The zoom value (typically 0-22, but no strict bounds enforced).
  final double value;

  @override
  String toString() => 'MapZoom($value)';

  @override
  bool operator ==(Object other) {
    return other is MapZoom && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

/// Camera target defining map viewport center and zoom.
@immutable
class MapCameraTarget {
  /// Creates a camera target with the given properties.
  const MapCameraTarget({
    required this.center,
    this.zoom,
  });

  /// The geographic center of the camera view.
  final GeoPoint center;

  /// Optional zoom level.
  final MapZoom? zoom;

  /// Creates a copy with optional overrides.
  MapCameraTarget copyWith({
    GeoPoint? center,
    MapZoom? zoom,
  }) {
    return MapCameraTarget(
      center: center ?? this.center,
      zoom: zoom ?? this.zoom,
    );
  }

  @override
  String toString() => 'MapCameraTarget(center: $center, zoom: $zoom)';

  @override
  bool operator ==(Object other) {
    return other is MapCameraTarget &&
        other.center == center &&
        other.zoom == zoom;
  }

  @override
  int get hashCode => Object.hash(center, zoom);
}

/// Unique identifier for a map marker.
@immutable
class MapMarkerId {
  /// Creates a marker ID with the given string value.
  const MapMarkerId(this.value);

  /// The string identifier.
  final String value;

  @override
  String toString() => 'MapMarkerId($value)';

  @override
  bool operator ==(Object other) {
    return other is MapMarkerId && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

/// A marker overlay on the map.
///
/// Pure Dart implementation - no Flutter dependencies.
@immutable
class MapMarker {
  /// Creates a marker with the given properties.
  const MapMarker({
    required this.id,
    required this.position,
    this.label,
  });

  /// Unique identifier for this marker.
  final MapMarkerId id;

  /// Geographic position of the marker.
  final GeoPoint position;

  /// Optional text label displayed near the marker.
  final String? label;

  // 🔁 Legacy compatibility for existing code:
  String? get title => label;      // map_view_widget يعتمد على هذا
  GeoPoint get point => position;  // و هذا

  @override
  String toString() => 'MapMarker(id: $id, position: $position)';

  @override
  bool operator ==(Object other) {
    return other is MapMarker &&
        other.id == id &&
        other.position == position &&
        other.label == label;
  }

  @override
  int get hashCode => Object.hash(id, position, label);
}

/// Unique identifier for a map polyline.
@immutable
class MapPolylineId {
  /// Creates a polyline ID with the given string value.
  const MapPolylineId(this.value);

  /// The string identifier.
  final String value;

  @override
  String toString() => 'MapPolylineId($value)';

  @override
  bool operator ==(Object other) {
    return other is MapPolylineId && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

/// A polyline (path) overlay on the map.
///
/// Pure Dart implementation - no Flutter dependencies.
@immutable
class MapPolyline {
  /// Creates a polyline with the given properties.
  const MapPolyline({
    required this.id,
    required this.points,
    this.isPrimaryRoute = false,
  });

  /// Unique identifier for this polyline.
  final MapPolylineId id;

  /// Ordered list of points forming the path.
  final List<GeoPoint> points;

  /// Whether this represents the primary route (affects styling).
  final bool isPrimaryRoute;

  @override
  String toString() =>
      'MapPolyline(id: $id, points: ${points.length} pts, isPrimaryRoute: $isPrimaryRoute)';

  @override
  bool operator ==(Object other) {
    if (other is! MapPolyline) return false;
    if (other.id != id || other.isPrimaryRoute != isPrimaryRoute) return false;
    if (other.points.length != points.length) return false;
    for (int i = 0; i < points.length; i++) {
      if (other.points[i] != points[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(id, isPrimaryRoute, Object.hashAll(points));
}

// =============================================================================
// LEGACY CLASSES - Kept for backward compatibility
// =============================================================================

/// Basic latitude/longitude point.
/// @deprecated Use GeoPoint instead (Ticket #198)
class LatLng {
  final double lat;
  final double lng;

  const LatLng(this.lat, this.lng);
}

/// Legacy map marker definition.
/// @deprecated Use MapMarker instead (Ticket #198)
class LegacyMapMarker {
  final String id;
  final MapPoint point;
  final String? title;
  final String? snippet;

  const LegacyMapMarker({
    required this.id,
    required this.point,
    this.title,
    this.snippet,
  });
}

/// Camera definition for map viewports.
/// @deprecated Use MapCameraTarget instead (Ticket #198)
class MapCamera {
  final MapPoint target;
  final double zoom;

  const MapCamera({required this.target, this.zoom = 14});
}

/// Rich camera position model.
/// @deprecated Use MapCameraTarget instead (Ticket #198)
class CameraPosition {
  final LatLng target;
  final double zoom;
  final double bearing;
  final double tilt;

  const CameraPosition({
    required this.target,
    this.zoom = 14,
    this.bearing = 0,
    this.tilt = 0,
  });
}

/// LatLng bounds for viewport queries.
/// @deprecated Use MapBounds instead (Ticket #198)
class LatLngBounds {
  final LatLng southwest;
  final LatLng northeast;

  const LatLngBounds({required this.southwest, required this.northeast});
}

/// Legacy polyline definition for path rendering.
/// @deprecated Use MapPolyline instead (Ticket #198)
class LegacyMapPolyline {
  final String id;
  final List<LatLng> points;
  final Color? color;
  final double? width;

  const LegacyMapPolyline({
    required this.id,
    required this.points,
    this.color,
    this.width,
  });
}

/// Map configuration metadata.
/// @deprecated Use appropriate config classes instead (Ticket #198)
class MapConfig {
  final String provider;

  const MapConfig({required this.provider});
}

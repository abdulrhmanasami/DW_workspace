/// DW Map Shims - LatLng and Bounds
/// Track B - Ticket #109: Pure Dart Map Shim v1
/// Purpose: Define LatLng and Bounds types for map operations (no Flutter dependency)

import 'package:meta/meta.dart';

/// A latitude/longitude point on the Earth's surface.
///
/// Pure Dart implementation - no Flutter dependencies.
/// Used as the canonical coordinate type throughout DW maps integration.
@immutable
class DWLatLng {
  /// Creates a coordinate with the given [latitude] and [longitude].
  const DWLatLng(this.latitude, this.longitude);

  /// The latitude in degrees (between -90.0 and 90.0).
  final double latitude;

  /// The longitude in degrees (between -180.0 and 180.0).
  final double longitude;

  @override
  String toString() => 'DWLatLng($latitude, $longitude)';

  @override
  bool operator ==(Object other) {
    return other is DWLatLng &&
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
class DWLatLngBounds {
  /// Creates bounds with the given corners.
  const DWLatLngBounds({
    required this.southWest,
    required this.northEast,
  });

  /// The southwest corner of the bounds.
  final DWLatLng southWest;

  /// The northeast corner of the bounds.
  final DWLatLng northEast;

  /// Returns true if [point] is within these bounds.
  bool contains(DWLatLng point) {
    return point.latitude >= southWest.latitude &&
        point.latitude <= northEast.latitude &&
        point.longitude >= southWest.longitude &&
        point.longitude <= northEast.longitude;
  }

  /// Returns the center point of these bounds.
  DWLatLng get center => DWLatLng(
        (southWest.latitude + northEast.latitude) / 2,
        (southWest.longitude + northEast.longitude) / 2,
      );

  @override
  String toString() => 'DWLatLngBounds($southWest => $northEast)';

  @override
  bool operator ==(Object other) {
    return other is DWLatLngBounds &&
        other.southWest == southWest &&
        other.northEast == northEast;
  }

  @override
  int get hashCode => Object.hash(southWest, northEast);
}


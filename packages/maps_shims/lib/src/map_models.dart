import 'package:flutter/material.dart';
import 'geo_types.dart' show MapPoint;

/// Basic latitude/longitude point.
class LatLng {
  final double lat;
  final double lng;

  const LatLng(this.lat, this.lng);
}

/// Map marker definition.
class MapMarker {
  final String id;
  final MapPoint point;
  final String? title;
  final String? snippet;

  const MapMarker({
    required this.id,
    required this.point,
    this.title,
    this.snippet,
  });
}

/// Camera definition for map viewports.
class MapCamera {
  final MapPoint target;
  final double zoom;

  const MapCamera({required this.target, this.zoom = 14});
}

/// Rich camera position model.
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
class LatLngBounds {
  final LatLng southwest;
  final LatLng northeast;

  const LatLngBounds({required this.southwest, required this.northeast});
}

/// Polyline definition for path rendering.
class MapPolyline {
  final String id;
  final List<LatLng> points;
  final Color? color;
  final double? width;

  const MapPolyline({
    required this.id,
    required this.points,
    this.color,
    this.width,
  });
}

/// Map configuration metadata.
class MapConfig {
  final String provider;

  const MapConfig({required this.provider});
}

/// DW Map Shims - Polyline Definition
/// Track B - Ticket #109: Pure Dart Map Shim v1
/// Purpose: Define polyline types for route rendering (no Flutter dependency)

import 'package:meta/meta.dart';

import 'dw_lat_lng.dart';

/// Visual style for polyline rendering.
///
/// Used by implementations to determine color/stroke.
enum DWMapPolylineStyle {
  /// Standard route (e.g., user's trip route).
  route,

  /// Driver's route to pickup.
  driverRoute,

  /// Dashed style (e.g., walking directions).
  dashed,
}

/// A polyline (path) overlay on the map.
///
/// Pure Dart implementation - no Flutter dependencies.
@immutable
class DWMapPolyline {
  /// Creates a polyline with the given properties.
  const DWMapPolyline({
    required this.id,
    required this.points,
    this.style = DWMapPolylineStyle.route,
  });

  /// Unique identifier for this polyline.
  final String id;

  /// Ordered list of points forming the path.
  final List<DWLatLng> points;

  /// Visual style (affects color, stroke, pattern).
  final DWMapPolylineStyle style;

  @override
  String toString() =>
      'DWMapPolyline(id: $id, points: ${points.length} pts, style: $style)';

  @override
  bool operator ==(Object other) {
    if (other is! DWMapPolyline) return false;
    if (other.id != id || other.style != style) return false;
    if (other.points.length != points.length) return false;
    for (int i = 0; i < points.length; i++) {
      if (other.points[i] != points[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(id, style, Object.hashAll(points));
}


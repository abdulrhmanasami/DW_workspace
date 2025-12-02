/// DW Map Shims - Camera Position
/// Track B - Ticket #109: Pure Dart Map Shim v1
/// Purpose: Define camera position for map viewport (no Flutter dependency)

import 'package:meta/meta.dart';

import 'dw_lat_lng.dart';

/// Camera position defining what the map displays.
///
/// Pure Dart implementation - no Flutter dependencies.
@immutable
class DWMapCameraPosition {
  /// Creates a camera position with the given properties.
  const DWMapCameraPosition({
    required this.target,
    this.zoom = 14.0,
    this.tilt = 0.0,
    this.bearing = 0.0,
  });

  /// The geographic center of the camera view.
  final DWLatLng target;

  /// Zoom level (typically 0-21).
  /// Higher values = closer view.
  final double zoom;

  /// Camera tilt angle in degrees (0 = straight down).
  final double tilt;

  /// Camera bearing/rotation in degrees from north.
  final double bearing;

  /// Creates a copy with optional overrides.
  DWMapCameraPosition copyWith({
    DWLatLng? target,
    double? zoom,
    double? tilt,
    double? bearing,
  }) {
    return DWMapCameraPosition(
      target: target ?? this.target,
      zoom: zoom ?? this.zoom,
      tilt: tilt ?? this.tilt,
      bearing: bearing ?? this.bearing,
    );
  }

  @override
  String toString() =>
      'DWMapCameraPosition(target: $target, zoom: $zoom, tilt: $tilt, bearing: $bearing)';

  @override
  bool operator ==(Object other) {
    return other is DWMapCameraPosition &&
        other.target == target &&
        other.zoom == zoom &&
        other.tilt == tilt &&
        other.bearing == bearing;
  }

  @override
  int get hashCode => Object.hash(target, zoom, tilt, bearing);
}


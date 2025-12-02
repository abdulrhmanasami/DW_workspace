/// DW Map Shims - Marker Definition
/// Track B - Ticket #109: Pure Dart Map Shim v1
/// Purpose: Define map marker types for overlays (no Flutter dependency)

import 'package:meta/meta.dart';

import 'dw_lat_lng.dart';

/// Type of marker displayed on the map.
///
/// Used by implementations to determine icon/style.
enum DWMapMarkerType {
  /// User's pickup location.
  userPickup,

  /// Trip destination.
  destination,

  /// Driver's current location.
  driver,

  /// Generic point of interest.
  poi,
}

/// A marker overlay on the map.
///
/// Pure Dart implementation - no Flutter dependencies.
@immutable
class DWMapMarker {
  /// Creates a marker with the given properties.
  const DWMapMarker({
    required this.id,
    required this.position,
    this.type = DWMapMarkerType.poi,
    this.label,
  });

  /// Unique identifier for this marker.
  final String id;

  /// Geographic position of the marker.
  final DWLatLng position;

  /// Semantic type of the marker (affects rendering).
  final DWMapMarkerType type;

  /// Optional text label displayed near the marker.
  final String? label;

  @override
  String toString() => 'DWMapMarker(id: $id, position: $position, type: $type)';

  @override
  bool operator ==(Object other) {
    return other is DWMapMarker &&
        other.id == id &&
        other.position == position &&
        other.type == type &&
        other.label == label;
  }

  @override
  int get hashCode => Object.hash(id, position, type, label);
}


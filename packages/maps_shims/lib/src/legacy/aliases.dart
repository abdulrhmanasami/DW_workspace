/// Component: Legacy Compatibility Aliases
/// Created by: Cursor B-ux
/// Purpose: Backward compatibility for common map type names
/// Last updated: 2025-11-11

import '../map_models.dart';
import '../maps_contracts.dart';

// Compatibility aliases for common map type names
typedef GoogleLatLng = LatLng;
typedef MapLatLng = LatLng;

/// Legacy marker type alias for backward compatibility
typedef MapMarker = LegacyMapMarker;

/// Legacy polyline type alias for backward compatibility
typedef MapPolyline = LegacyMapPolyline;

/// Backward compatibility alias - prefer MapViewController.
typedef MapController = MapViewController;

// Extension for LatLng compatibility with different naming conventions
extension LatLngCompat on LatLng {
  double get latitude => lat;
  double get longitude => lng;
}

import 'map_models.dart';

/// Canonical map view controller interface used by the app layer.
abstract class MapViewController {
  /// Move camera to a target position.
  Future<void> moveCamera(MapCamera camera);

  /// Replace displayed markers.
  Future<void> setMarkers(List<MapMarker> markers);

  /// Replace displayed polylines.
  Future<void> setPolylines(List<MapPolyline> polylines);

  /// Optional hook for cleanup.
  void dispose();
}

/// Component: Marker Manager
/// Created by: Cursor (auto-generated)
/// Purpose: Interface for map markers management
/// Last updated: 2025-10-24

abstract class MarkerManager {
  Future<String> addMarker({
    required String id,
    required double latitude,
    required double longitude,
    String? title,
    String? snippet,
    String? iconPath,
  });

  Future<void> removeMarker(String markerId);
  Future<void> updateMarker({
    required String markerId,
    double? latitude,
    double? longitude,
    String? title,
    String? snippet,
    String? iconPath,
  });

  Future<void> clearAllMarkers();
  Stream<String> get markerTappedStream;
}

/// Component: Map Style Manager
/// Created by: Cursor (auto-generated)
/// Purpose: Interface for map styling operations
/// Last updated: 2025-10-24

abstract class MapStyleManager {
  Future<void> setMapStyle(String styleJson);
  Future<String> getCurrentStyle();
  Future<void> resetToDefaultStyle();
  List<String> get availableStyles;
}

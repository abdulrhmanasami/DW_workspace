import 'legacy/aliases.dart' show MapController;
import 'map_models.dart';

/// No-op controller used when no concrete maps implementation is wired.
class NoOpMapController implements MapController {
  const NoOpMapController();

  @override
  Future<void> moveCamera(MapCamera camera) async {
    // No-op
  }

  @override
  Future<void> setMarkers(List<MapMarker> markers) async {
    // No-op
  }

  @override
  void dispose() {
    // No-op
  }
}

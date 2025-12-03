/// Map Commands - From App to Map Implementation
/// Track B - Ticket #198: MapInterface تفاعلي (Streams/Sinks) + Stub Implementation
/// Purpose: Define commands sent from app to map via MapPort.commands

import 'map_models.dart';

/// Commands sent from app → map implementation via [MapPort.commands].
///
/// Sealed class hierarchy ensures exhaustive handling.
/// Pure Dart - no Flutter dependencies.
sealed class MapCommand {
  const MapCommand();
}

/// Set the camera to a specific target.
final class SetCameraCommand extends MapCommand {
  const SetCameraCommand(this.target);

  /// Target camera position.
  final MapCameraTarget target;

  @override
  String toString() => 'SetCameraCommand($target)';
}

/// Animate camera to fit the given bounds.
final class FitBoundsCommand extends MapCommand {
  const FitBoundsCommand(this.bounds, {this.padding = 50.0});

  /// Bounds to fit in view.
  final MapBounds bounds;

  /// Padding around the bounds in logical pixels.
  final double padding;

  @override
  String toString() => 'FitBoundsCommand($bounds, padding: $padding)';
}

/// Set markers on the map.
final class SetMarkersCommand extends MapCommand {
  const SetMarkersCommand(this.markers);

  /// Markers to display on the map.
  final List<MapMarker> markers;

  @override
  String toString() => 'SetMarkersCommand(${markers.length} markers)';
}

/// Set polylines on the map.
final class SetPolylinesCommand extends MapCommand {
  const SetPolylinesCommand(this.polylines);

  /// Polylines to display on the map.
  final List<MapPolyline> polylines;

  @override
  String toString() => 'SetPolylinesCommand(${polylines.length} polylines)';
}

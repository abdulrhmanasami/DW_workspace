/// Map Events - From Map Implementation to App
/// Track B - Ticket #198: MapInterface تفاعلي (Streams/Sinks) + Stub Implementation
/// Purpose: Define events emitted from map to app via MapPort.events

import 'map_models.dart';

/// Events emitted from map implementation → app via [MapPort.events].
///
/// Sealed class hierarchy ensures exhaustive handling.
/// Pure Dart - no Flutter dependencies.
sealed class MapEvent {
  const MapEvent();
}

/// User tapped on a marker.
final class MarkerTappedEvent extends MapEvent {
  const MarkerTappedEvent(this.markerId);

  /// ID of the marker that was tapped.
  final MapMarkerId markerId;

  @override
  String toString() => 'MarkerTappedEvent($markerId)';
}

/// Camera finished moving (after animation or gesture).
final class CameraMovedEvent extends MapEvent {
  const CameraMovedEvent(this.target);

  /// The final camera target.
  final MapCameraTarget target;

  @override
  String toString() => 'CameraMovedEvent($target)';
}

/// User tapped on the map (not on a marker).
final class MapTappedEvent extends MapEvent {
  const MapTappedEvent(this.position);

  /// Geographic position of the tap.
  final GeoPoint position;

  @override
  String toString() => 'MapTappedEvent($position)';
}

/// Map is ready for interaction.
final class MapReadyEvent extends MapEvent {
  const MapReadyEvent();

  @override
  String toString() => 'MapReadyEvent()';
}

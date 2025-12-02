/// DW Map Shims - Events (Map → App)
/// Track B - Ticket #109: Pure Dart Map Shim v1
/// Purpose: Define events emitted from map implementation to app

import 'dw_lat_lng.dart';
import 'dw_map_camera.dart';

/// Events emitted from map implementation → app via [DWMapController.events].
///
/// Sealed class hierarchy ensures exhaustive handling.
/// Pure Dart - no Flutter dependencies.
sealed class DWMapEvent {
  const DWMapEvent();
}

/// User tapped on a marker.
final class DWMarkerTappedEvent extends DWMapEvent {
  const DWMarkerTappedEvent(this.markerId);

  /// ID of the marker that was tapped.
  final String markerId;

  @override
  String toString() => 'DWMarkerTappedEvent($markerId)';
}

/// Camera finished moving (after animation or gesture).
final class DWCameraMovedEvent extends DWMapEvent {
  const DWCameraMovedEvent(this.position);

  /// The final camera position.
  final DWMapCameraPosition position;

  @override
  String toString() => 'DWCameraMovedEvent($position)';
}

/// User tapped on the map (not on a marker).
final class DWMapTappedEvent extends DWMapEvent {
  const DWMapTappedEvent(this.position);

  /// Geographic position of the tap.
  final DWLatLng position;

  @override
  String toString() => 'DWMapTappedEvent($position)';
}

/// Map is ready for interaction.
final class DWMapReadyEvent extends DWMapEvent {
  const DWMapReadyEvent();

  @override
  String toString() => 'DWMapReadyEvent()';
}

/// User started dragging the camera.
final class DWCameraMoveStartedEvent extends DWMapEvent {
  const DWCameraMoveStartedEvent({this.isGesture = false});

  /// True if the move was initiated by a user gesture.
  final bool isGesture;

  @override
  String toString() => 'DWCameraMoveStartedEvent(isGesture: $isGesture)';
}


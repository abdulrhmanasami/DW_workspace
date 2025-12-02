/// DW Map Shims - Commands (App → Map)
/// Track B - Ticket #109: Pure Dart Map Shim v1
/// Purpose: Define commands sent from app to map implementation

import 'dw_lat_lng.dart';
import 'dw_map_camera.dart';
import 'dw_map_marker.dart';
import 'dw_map_polyline.dart';

/// Commands sent from app → map implementation via [DWMapController.commands].
///
/// Sealed class hierarchy ensures exhaustive handling.
/// Pure Dart - no Flutter dependencies.
sealed class DWMapCommand {
  const DWMapCommand();
}

/// Set the complete map content (markers, polylines, camera).
///
/// Replaces all existing overlays with the provided content.
final class DWSetContentCommand extends DWMapCommand {
  const DWSetContentCommand({
    required this.markers,
    required this.polylines,
    this.camera,
  });

  /// Markers to display on the map.
  final List<DWMapMarker> markers;

  /// Polylines to display on the map.
  final List<DWMapPolyline> polylines;

  /// Optional camera position to animate to.
  final DWMapCameraPosition? camera;

  @override
  String toString() =>
      'DWSetContentCommand(markers: ${markers.length}, polylines: ${polylines.length}, camera: $camera)';
}

/// Animate camera to fit the given bounds.
final class DWAnimateToBoundsCommand extends DWMapCommand {
  const DWAnimateToBoundsCommand(this.bounds, {this.padding = 50.0});

  /// Bounds to fit in view.
  final DWLatLngBounds bounds;

  /// Padding around the bounds in logical pixels.
  final double padding;

  @override
  String toString() =>
      'DWAnimateToBoundsCommand($bounds, padding: $padding)';
}

/// Animate camera to a specific position.
final class DWAnimateToPositionCommand extends DWMapCommand {
  const DWAnimateToPositionCommand(this.position, {this.durationMs = 300});

  /// Target camera position.
  final DWMapCameraPosition position;

  /// Animation duration in milliseconds.
  final int durationMs;

  @override
  String toString() =>
      'DWAnimateToPositionCommand($position, duration: ${durationMs}ms)';
}

/// Clear all overlays from the map.
final class DWClearCommand extends DWMapCommand {
  const DWClearCommand();

  @override
  String toString() => 'DWClearCommand()';
}


/// DW Map Shims - In-Memory Map Controller
/// Track B - Ticket #109: Pure Dart Map Shim v1
/// Purpose: Testing implementation that stores state in memory

import 'dart:async';

import 'package:maps_shims/src/core/dw_lat_lng.dart';
import 'package:maps_shims/src/core/dw_map_camera.dart';
import 'package:maps_shims/src/core/dw_map_commands.dart';
import 'package:maps_shims/src/core/dw_map_controller.dart';
import 'package:maps_shims/src/core/dw_map_events.dart';
import 'package:maps_shims/src/core/dw_map_marker.dart';
import 'package:maps_shims/src/core/dw_map_polyline.dart';

/// In-memory implementation of [DWMapController] for testing.
///
/// This controller:
/// - Stores all map state in memory (no UI).
/// - Processes commands synchronously.
/// - Allows simulating events for test scenarios.
///
/// ## Usage in Tests
///
/// ```dart
/// final controller = InMemoryMapController();
///
/// // Send command
/// controller.commands.add(DWSetContentCommand(
///   markers: [DWMapMarker(id: 'pickup', ...)],
///   polylines: [],
/// ));
///
/// // Verify state
/// expect(controller.markers.length, 1);
///
/// // Simulate event
/// controller.simulateMarkerTap('pickup');
/// ```
class InMemoryMapController implements DWMapController {
  /// Creates a new in-memory controller.
  InMemoryMapController() {
    _commandsController.stream.listen(_handleCommand);
  }

  // Use sync: true to ensure commands are processed immediately for testing
  final _commandsController = StreamController<DWMapCommand>.broadcast(sync: true);
  final _eventsController = StreamController<DWMapEvent>.broadcast(sync: true);

  /// Current markers on the map.
  List<DWMapMarker> markers = const [];

  /// Current polylines on the map.
  List<DWMapPolyline> polylines = const [];

  /// Current camera position.
  DWMapCameraPosition? camera;

  /// History of all commands received (useful for verification in tests).
  final List<DWMapCommand> commandHistory = [];

  @override
  Sink<DWMapCommand> get commands => _commandsController.sink;

  @override
  Stream<DWMapEvent> get events => _eventsController.stream;

  void _handleCommand(DWMapCommand command) {
    commandHistory.add(command);

    switch (command) {
      case DWSetContentCommand():
        markers = List.unmodifiable(command.markers);
        polylines = List.unmodifiable(command.polylines);
        if (command.camera != null) {
          camera = command.camera;
        }
      case DWAnimateToBoundsCommand():
        // Simple behavior: set camera to center of bounds
        camera = DWMapCameraPosition(target: command.bounds.center);
      case DWAnimateToPositionCommand():
        camera = command.position;
        // Emit camera moved event after animation
        _eventsController.add(DWCameraMovedEvent(command.position));
      case DWClearCommand():
        markers = const [];
        polylines = const [];
    }
  }

  // ===========================================================================
  // Test Helpers
  // ===========================================================================

  /// Simulate user tapping a marker.
  void simulateMarkerTap(String markerId) {
    _eventsController.add(DWMarkerTappedEvent(markerId));
  }

  /// Simulate user tapping the map.
  void simulateMapTap(DWLatLng position) {
    _eventsController.add(DWMapTappedEvent(position));
  }

  /// Simulate camera movement finished.
  void simulateCameraMoved(DWMapCameraPosition position) {
    _eventsController.add(DWCameraMovedEvent(position));
  }

  /// Simulate map ready event.
  void simulateMapReady() {
    _eventsController.add(const DWMapReadyEvent());
  }

  /// Simulate camera move started.
  void simulateCameraMoveStarted({bool isGesture = false}) {
    _eventsController.add(DWCameraMoveStartedEvent(isGesture: isGesture));
  }

  /// Get marker by ID, or null if not found.
  DWMapMarker? markerById(String id) {
    for (final marker in markers) {
      if (marker.id == id) return marker;
    }
    return null;
  }

  /// Get polyline by ID, or null if not found.
  DWMapPolyline? polylineById(String id) {
    for (final polyline in polylines) {
      if (polyline.id == id) return polyline;
    }
    return null;
  }

  @override
  void dispose() {
    _commandsController.close();
    _eventsController.close();
  }
}


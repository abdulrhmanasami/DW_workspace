/// In-Memory Map Port - Stub Implementation for Testing
/// Track B - Ticket #198: MapInterface تفاعلي (Streams/Sinks) + Stub Implementation
/// Purpose: Testing implementation that stores state in memory

import 'dart:async';

import 'core/dw_lat_lng.dart';
import 'core/dw_map_camera.dart';
import 'core/dw_map_commands.dart';
import 'core/dw_map_controller.dart';
import 'core/dw_map_events.dart';
import 'core/dw_map_marker.dart';
import 'core/dw_map_polyline.dart';
import 'testing/in_memory_map_controller.dart';
import 'map_port.dart';
import 'map_events.dart';
import 'map_commands.dart';
import 'map_models.dart';

/// In-memory implementation of [MapPort] for testing.
///
/// This port:
/// - Wraps the existing [InMemoryMapController] for state management
/// - Translates between new API ([MapCommand]/[MapEvent]) and legacy DW API
/// - Stores all map state in memory (no UI)
/// - Allows simulating events for test scenarios
///
/// ## Usage in Tests
///
/// ```dart
/// final port = InMemoryMapPort();
///
/// // Send command
/// port.commands.add(SetMarkersCommand([marker]));
///
/// // Verify state
/// expect(port.markers.length, 1);
///
/// // Simulate event
/// port.simulateMarkerTap(MapMarkerId('pickup'));
/// ```
class InMemoryMapPort implements MapPort {
  /// Creates a new in-memory port.
  InMemoryMapPort() {
    _controller = InMemoryMapController();
    _setupEventTranslation();
  }

  late final InMemoryMapController _controller;
  final _eventsController = StreamController<MapEvent>.broadcast(sync: true);

  /// Current markers on the map.
  List<MapMarker> get markers => _controller.markers.map(_convertDWMarkerToMapMarker).toList();

  /// Current polylines on the map.
  List<MapPolyline> get polylines => _controller.polylines.map(_convertDWPolylineToMapPolyline).toList();

  /// Current camera target.
  MapCameraTarget? get camera => _controller.camera != null ? _convertDWCameraToMapCamera(_controller.camera!) : null;

  /// History of all commands received (useful for verification in tests).
  List<MapCommand> get commandHistory => _controller.commandHistory.map(_convertDWCommandToMapCommand).toList();

  @override
  Sink<MapCommand> get commands => _MapCommandSink(_controller.commands);

  @override
  Stream<MapEvent> get events => _eventsController.stream;

  void _setupEventTranslation() {
    _controller.events.listen((dwEvent) {
      final mapEvent = _convertDWEventToMapEvent(dwEvent);
      if (mapEvent != null) {
        _eventsController.add(mapEvent);
      }
    });
  }

  // ===========================================================================
  // Conversion Helpers (DW API ↔ New API)
  // ===========================================================================

  GeoPoint _convertDWLatLngToGeoPoint(DWLatLng dwLatLng) {
    return GeoPoint(dwLatLng.latitude, dwLatLng.longitude);
  }

  DWLatLng _convertGeoPointToDWLatLng(GeoPoint geoPoint) {
    return DWLatLng(geoPoint.latitude, geoPoint.longitude);
  }

  MapCameraTarget _convertDWCameraToMapCamera(DWMapCameraPosition dwCamera) {
    return MapCameraTarget(
      center: _convertDWLatLngToGeoPoint(dwCamera.target),
      zoom: MapZoom(dwCamera.zoom),
    );
  }

  DWMapCameraPosition _convertMapCameraToDWCamera(MapCameraTarget camera) {
    return DWMapCameraPosition(
      target: _convertGeoPointToDWLatLng(camera.center),
      zoom: camera.zoom?.value ?? 14.0,
    );
  }

  MapBounds _convertDWBoundsToMapBounds(DWLatLngBounds dwBounds) {
    return MapBounds(
      southWest: _convertDWLatLngToGeoPoint(dwBounds.southWest),
      northEast: _convertDWLatLngToGeoPoint(dwBounds.northEast),
    );
  }

  DWLatLngBounds _convertMapBoundsToDWBounds(MapBounds bounds) {
    return DWLatLngBounds(
      southWest: _convertGeoPointToDWLatLng(bounds.southWest),
      northEast: _convertGeoPointToDWLatLng(bounds.northEast),
    );
  }

  MapMarker _convertDWMarkerToMapMarker(DWMapMarker dwMarker) {
    return MapMarker(
      id: MapMarkerId(dwMarker.id),
      position: _convertDWLatLngToGeoPoint(dwMarker.position),
      label: dwMarker.label,
    );
  }

  DWMapMarker _convertMapMarkerToDWMarker(MapMarker marker) {
    return DWMapMarker(
      id: marker.id.value,
      position: _convertGeoPointToDWLatLng(marker.position),
      type: DWMapMarkerType.poi, // Default type
      label: marker.label,
    );
  }

  MapPolyline _convertDWPolylineToMapPolyline(DWMapPolyline dwPolyline) {
    return MapPolyline(
      id: MapPolylineId(dwPolyline.id),
      points: dwPolyline.points.map(_convertDWLatLngToGeoPoint).toList(),
      isPrimaryRoute: dwPolyline.style == DWMapPolylineStyle.route,
    );
  }

  DWMapPolyline _convertMapPolylineToDWPolyline(MapPolyline polyline) {
    return DWMapPolyline(
      id: polyline.id.value,
      points: polyline.points.map(_convertGeoPointToDWLatLng).toList(),
      style: polyline.isPrimaryRoute ? DWMapPolylineStyle.route : DWMapPolylineStyle.dashed,
    );
  }

  MapEvent? _convertDWEventToMapEvent(DWMapEvent dwEvent) {
    return switch (dwEvent) {
      DWMarkerTappedEvent() => MarkerTappedEvent(MapMarkerId(dwEvent.markerId)),
      DWCameraMovedEvent() => CameraMovedEvent(_convertDWCameraToMapCamera(dwEvent.position)),
      DWMapTappedEvent() => MapTappedEvent(_convertDWLatLngToGeoPoint(dwEvent.position)),
      DWMapReadyEvent() => const MapReadyEvent(),
      DWCameraMoveStartedEvent() => null, // Not in new API
    };
  }

  MapCommand _convertDWCommandToMapCommand(DWMapCommand dwCommand) {
    return switch (dwCommand) {
      DWSetContentCommand() => throw UnsupportedError('DWSetContentCommand should be decomposed'),
      DWAnimateToBoundsCommand() => FitBoundsCommand(
          _convertDWBoundsToMapBounds(dwCommand.bounds),
          padding: dwCommand.padding,
        ),
      DWAnimateToPositionCommand() => SetCameraCommand(_convertDWCameraToMapCamera(dwCommand.position)),
      DWClearCommand() => const SetMarkersCommand([]), // Approximation
    };
  }

  // ===========================================================================
  // Test Helpers
  // ===========================================================================

  /// Simulate user tapping a marker.
  void simulateMarkerTap(MapMarkerId markerId) {
    _controller.simulateMarkerTap(markerId.value);
  }

  /// Simulate user tapping the map.
  void simulateMapTap(GeoPoint position) {
    _controller.simulateMapTap(_convertGeoPointToDWLatLng(position));
  }

  /// Simulate camera movement finished.
  void simulateCameraMoved(MapCameraTarget target) {
    _controller.simulateCameraMoved(_convertMapCameraToDWCamera(target));
  }

  /// Simulate map ready event.
  void simulateMapReady() {
    _controller.simulateMapReady();
  }

  /// Get marker by ID, or null if not found.
  MapMarker? markerById(MapMarkerId id) {
    final dwMarker = _controller.markerById(id.value);
    return dwMarker != null ? _convertDWMarkerToMapMarker(dwMarker) : null;
  }

  /// Get polyline by ID, or null if not found.
  MapPolyline? polylineById(MapPolylineId id) {
    final dwPolyline = _controller.polylineById(id.value);
    return dwPolyline != null ? _convertDWPolylineToMapPolyline(dwPolyline) : null;
  }

  @override
  void dispose() {
    _controller.dispose();
    _eventsController.close();
  }
}

/// Internal sink that translates new API commands to DW commands.
class _MapCommandSink implements Sink<MapCommand> {
  _MapCommandSink(this._dwSink);

  final Sink<DWMapCommand> _dwSink;

  @override
  void add(MapCommand command) {
    final dwCommands = _convertMapCommandToDWCommands(command);
    for (final dwCommand in dwCommands) {
      _dwSink.add(dwCommand);
    }
  }

  @override
  void close() {
    _dwSink.close();
  }

  List<DWMapCommand> _convertMapCommandToDWCommands(MapCommand command) {
    return switch (command) {
      SetCameraCommand() => [
          DWAnimateToPositionCommand(DWMapCameraPosition(
            target: DWLatLng(command.target.center.latitude, command.target.center.longitude),
            zoom: command.target.zoom?.value ?? 14.0,
          )),
        ],
      FitBoundsCommand() => [
          DWAnimateToBoundsCommand(
            DWLatLngBounds(
              southWest: DWLatLng(command.bounds.southWest.latitude, command.bounds.southWest.longitude),
              northEast: DWLatLng(command.bounds.northEast.latitude, command.bounds.northEast.longitude),
            ),
            padding: command.padding,
          ),
        ],
      SetMarkersCommand() => [
          DWSetContentCommand(
            markers: command.markers
                .map((m) => DWMapMarker(
                      id: m.id.value,
                      position: DWLatLng(m.position.latitude, m.position.longitude),
                      type: DWMapMarkerType.poi,
                      label: m.label,
                    ))
                .toList(),
            polylines: const [],
          ),
        ],
      SetPolylinesCommand() => [
          DWSetContentCommand(
            markers: const [],
            polylines: command.polylines
                .map((p) => DWMapPolyline(
                      id: p.id.value,
                      points: p.points
                          .map((point) => DWLatLng(point.latitude, point.longitude))
                          .toList(),
                      style: p.isPrimaryRoute ? DWMapPolylineStyle.route : DWMapPolylineStyle.dashed,
                    ))
                .toList(),
          ),
        ],
    };
  }
}

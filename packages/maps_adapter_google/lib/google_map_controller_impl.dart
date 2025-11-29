/// Component: Google Maps Controller Implementation
/// Created by: Cursor B-ux
/// Purpose: Concrete implementation of MapController for Google Maps
/// Last updated: 2025-11-12

import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart' as g;
import 'package:maps_shims/maps.dart';

// Convert from our MapCamera to Google's CameraPosition
g.CameraPosition _toGoogleCameraPosition(MapCamera camera) {
  return g.CameraPosition(
    target: g.LatLng(camera.target.latitude, camera.target.longitude),
    zoom: camera.zoom,
  );
}

// Convert from our MapMarker to Google's Marker
g.Marker _toGoogleMarker(MapMarker marker) {
  return g.Marker(
    markerId: g.MarkerId(marker.id),
    position: g.LatLng(marker.point.latitude, marker.point.longitude),
    infoWindow: marker.title != null || marker.snippet != null
        ? g.InfoWindow(
            title: marker.title,
            snippet: marker.snippet,
          )
        : g.InfoWindow.noText,
  );
}

/// Google Maps implementation of MapController interface
class GoogleMapControllerImpl implements MapController {
  final Completer<g.GoogleMapController> _controllerCompleter;
  final Set<g.Marker> _markers = {};

  GoogleMapControllerImpl(this._controllerCompleter);

  Future<g.GoogleMapController> get _controller async =>
      await _controllerCompleter.future;

  @override
  Future<void> moveCamera(MapCamera camera) async {
    final controller = await _controller;
    await controller.animateCamera(
        g.CameraUpdate.newCameraPosition(_toGoogleCameraPosition(camera)));
  }

  @override
  Future<void> setMarkers(List<MapMarker> markers) async {
    _markers.clear();
    _markers.addAll(markers.map(_toGoogleMarker));

    // Note: In a real implementation, you'd update the map widget's markers
    // This is a simplified version - the actual update would happen in the builder
  }

  @override
  void dispose() {
    // GoogleMapController doesn't need explicit disposal
    // The completer will be cleaned up by the widget
  }
}

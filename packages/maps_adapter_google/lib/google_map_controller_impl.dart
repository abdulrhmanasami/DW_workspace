/// Component: Google Maps Controller Implementation
/// Created by: Cursor B-ux
/// Purpose: Concrete implementation of MapController for Google Maps
/// Last updated: 2025-11-12

import 'dart:async';
import 'dart:ui';
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
    markerId: g.MarkerId(marker.id.toString()),
    position: g.LatLng(marker.position.latitude, marker.position.longitude),
    infoWindow: marker.label != null
        ? g.InfoWindow(title: marker.label)
        : g.InfoWindow.noText,
  );
}

// Convert from our MapPolyline to Google's Polyline
g.Polyline _toGooglePolyline(MapPolyline polyline) {
  return g.Polyline(
    polylineId: g.PolylineId(polyline.id.toString()),
    points: polyline.points.map((point) => g.LatLng(point.latitude, point.longitude)).toList(),
    color: const Color(0xFF4285F4),
    width: 5,
  );
}

/// Google Maps implementation of MapController interface
class GoogleMapControllerImpl implements MapController {
  final Completer<g.GoogleMapController> _controllerCompleter;
  final Set<g.Marker> _markers = {};
  final Set<g.Polyline> _polylines = {};

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
  Future<void> setPolylines(List<MapPolyline> polylines) async {
    _polylines.clear();
    _polylines.addAll(polylines.map(_toGooglePolyline));

    // Note: In a real implementation, you'd update the map widget's polylines
    // This is a simplified version - the actual update would happen in the builder
  }

  @override
  void dispose() {
    // GoogleMapController doesn't need explicit disposal
    // The completer will be cleaned up by the widget
  }
}

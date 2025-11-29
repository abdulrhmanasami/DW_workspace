/// Component: Google Maps View Builder
/// Created by: Cursor B-ux
/// Purpose: Google Maps implementation of MapViewBuilder
/// Last updated: 2025-11-12

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as g;
import 'package:maps_shims/maps.dart';
import 'google_map_controller_impl.dart';

/// Google Maps implementation of MapViewBuilder
final googleMapViewBuilderProvider = Provider<MapViewBuilder>((ref) {
  return (params) {
    final completer = Completer<g.GoogleMapController>();
    final controllerImpl = GoogleMapControllerImpl(completer);

    return g.GoogleMap(
      initialCameraPosition: g.CameraPosition(
        target: g.LatLng(
          params.initialCameraPosition.target.latitude,
          params.initialCameraPosition.target.longitude,
        ),
        zoom: params.initialCameraPosition.zoom,
      ),
      onMapCreated: (controller) {
        completer.complete(controller);
        params.onMapReady(controllerImpl);
      },
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      compassEnabled: true,
      zoomControlsEnabled: true,
      mapType: g.MapType.normal,
    );
  };
});

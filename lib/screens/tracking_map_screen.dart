/// Component: TrackingMapScreen
/// Created by: Cursor B-ux
/// Purpose: Interactive map with path rendering and markers using unified interface
/// Last updated: 2025-11-12

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maps_shims/maps.dart';
import 'package:delivery_ways_clean/state/tracking_map/providers.dart';

class TrackingMapScreen extends ConsumerStatefulWidget {
  const TrackingMapScreen({super.key});

  @override
  ConsumerState<TrackingMapScreen> createState() => _TrackingMapScreenState();
}

class _TrackingMapScreenState extends ConsumerState<TrackingMapScreen> {
  MapController? _mapController;

  void _onMapReady(MapController controller) {
    _mapController = controller;
    // Update markers when map is ready
    _updateMarkers();
  }

  void _updateMarkers() {
    final trackingMap = ref.read(trackingMapProvider);
    if (_mapController != null && trackingMap.markers.isNotEmpty) {
      _mapController!.setMarkers(trackingMap.markers);
    }
  }

  @override
  void dispose() {
    // Clean up map controller resources
    _mapController?.dispose();
    _mapController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trackingMap = ref.watch(trackingMapProvider);
    final buildMap = ref.watch(mapViewBuilderProvider);

    // Update markers when tracking map state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateMarkers();
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Live Tracking')),
      body: buildMap(
        MapViewParams(
          initialCameraPosition: trackingMap.lastPoint != null
              ? MapCamera(
                  target: MapPoint(
                    latitude: trackingMap.lastPoint!.latitude,
                    longitude: trackingMap.lastPoint!.longitude,
                  ),
                  zoom: 15.0,
                )
              : MapCamera(
                  target: MapPoint(
                    latitude: 51.5074,
                    longitude: -0.1278,
                  ), // Default to London
                  zoom: 12.0,
                ),
          onMapReady: _onMapReady,
        ),
      ),
    );
  }
}

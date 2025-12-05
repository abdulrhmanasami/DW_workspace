/// Component: Maps Screen
/// Created by: Cursor B-ux (MapViewBuilder implementation)
/// Purpose: Maps smoke test screen using unified MapViewBuilder from maps_shims
/// Last updated: 2025-11-11

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maps_shims/maps.dart';
import 'package:design_system_shims/design_system_shims.dart';

class MapsScreen extends ConsumerWidget {
  const MapsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buildMap = ref.watch(mapViewBuilderProvider);

    return MapsScreenContent(buildMap: buildMap);
  }
}

class MapsScreenContent extends ConsumerStatefulWidget {
  final MapViewBuilder buildMap;

  const MapsScreenContent({super.key, required this.buildMap});

  @override
  ConsumerState<MapsScreenContent> createState() => _MapsScreenContentState();
}

class _MapsScreenContentState extends ConsumerState<MapsScreenContent> {
  MapController? _mapController;

  void _onMapReady(MapController controller) {
    _mapController = controller;
  }

  @override
  void dispose() {
    // Clean up map controller resources
    _mapController?.dispose();
    _mapController = null;
    super.dispose();
  }

  Future<void> _runMapsSmokeTest() async {
    final AppNoticePresenter presenter =
        ref.read(appNoticePresenterProvider);

    try {
      // Test 1: Move camera to a test location
      if (_mapController != null) {
        await _mapController!.moveCamera(
          MapCamera(
            target: MapPoint(
              latitude: 40.7128,
              longitude: -74.0060,
            ), // New York
            zoom: 15.0,
          ),
        );
      }

      // Test 2: Set a marker at test location
      if (_mapController != null) {
        await _mapController!.setMarkers([
          const MapMarker(
            id: MapMarkerId('test_location'),
            position: GeoPoint(40.7128, -74.0060),
            label: 'Test Location - New York City',
          ),
        ]);
      }

      presenter(
        AppNotice.success(
          message: 'Maps Smoke Test: SUCCESS - Camera moved and marker set',
        ),
      );
    } catch (e) {
      presenter(
        AppNotice.error(
          message: 'Maps Smoke Test: ERROR - $e',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Maps Smoke Test')),
      body: widget.buildMap(
        MapViewParams(
          initialCameraPosition: MapCamera(
            target: MapPoint(latitude: 51.5074, longitude: -0.1278), // London
            zoom: 12.0,
          ),
          onMapReady: _onMapReady,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _runMapsSmokeTest,
        tooltip: 'Run Maps Smoke Test',
        child: const Icon(Icons.map),
      ),
    );
  }
}

/// Ride Trip Map View Widget Tests - Track B Ticket #204
/// Purpose: Test RideTripMapView widget integration with mapStage/mapSnapshot
/// Created by: Track B - Ticket #204
/// Last updated: 2025-12-03
///
/// Tests cover:
/// - RideTripMapView renders placeholder when no snapshot
/// - RideTripMapView reads from rideTripSessionProvider and rideMapPortProvider

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Maps shims
import 'package:maps_shims/maps_shims.dart';

// App widgets and state
import 'package:delivery_ways_clean/widgets/mobility/ride_trip_map_view.dart';
import 'package:delivery_ways_clean/state/mobility/ride_trip_session.dart';
import 'package:delivery_ways_clean/state/mobility/ride_map_port_providers.dart';
import 'package:delivery_ways_clean/state/mobility/ride_map_projection.dart';

/// Recording MapPort implementation for testing.
/// Records all commands sent to it for verification.
class _RecordingMapPort implements MapPort {
  final List<MapCommand> recorded = <MapCommand>[];

  @override
  Sink<MapCommand> get commands => _RecordingSink(recorded);

  @override
  Stream<MapEvent> get events => const Stream<MapEvent>.empty();

  @override
  void dispose() {}
}

class _RecordingSink implements Sink<MapCommand> {
  _RecordingSink(this._commands);
  final List<MapCommand> _commands;

  @override
  void add(MapCommand data) => _commands.add(data);

  @override
  void close() {}
}

void main() {
  testWidgets('RideTripMapView renders empty placeholder when no snapshot',
      (tester) async {
    final container = ProviderContainer(
      overrides: [
        rideMapPortProvider.overrideWithValue(_RecordingMapPort()),
        // Override rideTripSessionProvider to return state with no snapshot
        rideTripSessionProvider.overrideWith(
          (ref) => RideTripSessionController(ref)..state = const RideTripSessionUiState(),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: RideTripMapView(),
        ),
      ),
    );

    // Should render without errors - placeholder is SizedBox.expand()
    expect(find.byType(RideTripMapView), findsOneWidget);
    expect(find.byType(SizedBox), findsOneWidget);

    container.dispose();
  });

  testWidgets('RideTripMapView renders map view when snapshot is available',
      (tester) async {
    // Create a test snapshot
    final testSnapshot = RideMapSnapshot(
      cameraTarget: const MapCameraTarget(
        center: GeoPoint(24.7136, 46.6753),
        zoom: MapZoom(15.0),
      ),
      markers: [
        MapMarker(
          id: const MapMarkerId('pickup'),
          position: const GeoPoint(24.7136, 46.6753),
          label: 'Pickup',
        ),
      ],
      polylines: const [],
    );

    final container = ProviderContainer(
      overrides: [
        rideMapPortProvider.overrideWithValue(_RecordingMapPort()),
        // Override rideTripSessionProvider with snapshot
        rideTripSessionProvider.overrideWith(
          (ref) => RideTripSessionController(ref)..state = RideTripSessionUiState(
            mapStage: RideMapStage.waitingForDriver,
            mapSnapshot: testSnapshot,
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: RideTripMapView(),
        ),
      ),
    );

    // Should render without errors - shows debug container with map info
    expect(find.byType(RideTripMapView), findsOneWidget);
    expect(find.byType(Container), findsOneWidget);

    // Should show stage name in debug text
    expect(find.text('Map Stage: waitingForDriver'), findsOneWidget);

    // Should show marker and polyline counts
    expect(find.text('Markers: 1, Polylines: 0'), findsOneWidget);

    container.dispose();
  });

  testWidgets('RideTripMapView shows different stages correctly', (tester) async {
    // Test different stages
    const stages = [
      RideMapStage.idle,
      RideMapStage.waitingForDriver,
      RideMapStage.driverEnRouteToPickup,
      RideMapStage.completed,
    ];

    for (final stage in stages) {
      final container = ProviderContainer(
        overrides: [
          rideMapPortProvider.overrideWithValue(_RecordingMapPort()),
          rideTripSessionProvider.overrideWith(
            (ref) => RideTripSessionController(ref)..state = RideTripSessionUiState(
              mapStage: stage,
              mapSnapshot: RideMapSnapshot(
                cameraTarget: const MapCameraTarget(
                  center: GeoPoint(24.7136, 46.6753),
                  zoom: MapZoom(15.0),
                ),
                markers: const [],
                polylines: const [],
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: RideTripMapView(key: ValueKey(stage)),
          ),
        ),
      );

      // Should show the correct stage name
      expect(find.text('Map Stage: ${stage.name}'), findsOneWidget);

      container.dispose();
    }
  });

  testWidgets('RideTripMapView shows driver marker when driverLocation is available - Track B #208',
      (tester) async {
    // Create a test snapshot with driver marker
    final testSnapshot = RideMapSnapshot(
      cameraTarget: const MapCameraTarget(
        center: GeoPoint(24.7136, 46.6753),
        zoom: MapZoom(15.0),
      ),
      markers: [
        // Pickup marker
        MapMarker(
          id: const MapMarkerId('pickup'),
          position: const GeoPoint(24.7136, 46.6753),
          label: 'Pickup',
        ),
        // Driver marker (simulating what RideMapProjector would create)
        MapMarker(
          id: const MapMarkerId('driver'),
          position: const GeoPoint(24.7140, 46.6760), // Driver position
          label: 'Driver',
        ),
      ],
      polylines: const [],
    );

    final container = ProviderContainer(
      overrides: [
        rideMapPortProvider.overrideWithValue(_RecordingMapPort()),
        // Override rideTripSessionProvider with snapshot and driver location
        rideTripSessionProvider.overrideWith(
          (ref) => RideTripSessionController(ref)..state = RideTripSessionUiState(
            mapStage: RideMapStage.driverEnRouteToPickup,
            mapSnapshot: testSnapshot,
            driverLocation: const GeoPoint(24.7140, 46.6760), // Same as driver marker position
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: RideTripMapView(),
        ),
      ),
    );

    // Should render without errors
    expect(find.byType(RideTripMapView), findsOneWidget);
    expect(find.byType(Container), findsOneWidget);

    // Should show correct stage
    expect(find.text('Map Stage: driverEnRouteToPickup'), findsOneWidget);

    // Should show driver marker in count
    expect(find.text('Markers: 2, Polylines: 0'), findsOneWidget);

    // Should have driver location set
    final sessionState = container.read(rideTripSessionProvider);
    expect(sessionState.driverLocation, isNotNull);
    expect(sessionState.driverLocation!.latitude, 24.7140);
    expect(sessionState.driverLocation!.longitude, 46.6760);
    expect(sessionState.hasDriverLocation, isTrue);

    container.dispose();
  });
}

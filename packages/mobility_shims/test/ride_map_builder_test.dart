/// RideMapConfig Builder Unit Tests - Track B Ticket #28
/// Purpose: Test the ride map configuration builders
/// Created by: Track B - Ticket #28
/// Last updated: 2025-11-28

import 'package:flutter_test/flutter_test.dart';
import 'package:maps_shims/maps_shims.dart';
import 'package:mobility_shims/mobility_shims.dart';

void main() {
  // Helper to create MobilityPlace with coordinates
  MobilityPlace placeWithLocation({
    required String label,
    required double lat,
    required double lng,
  }) {
    return MobilityPlace(
      label: label,
      location: LocationPoint(
        latitude: lat,
        longitude: lng,
        accuracyMeters: 10,
        timestamp: DateTime.now(),
      ),
    );
  }

  // Helper to create MobilityPlace without coordinates
  MobilityPlace placeWithoutLocation({required String label}) {
    return MobilityPlace(label: label);
  }

  group('buildDestinationPreviewMap', () {
    test('returns config with 2 markers when pickup and destination have coordinates', () {
      final pickup = placeWithLocation(
        label: 'Home',
        lat: 24.7136,
        lng: 46.6753,
      );
      final destination = placeWithLocation(
        label: 'Office',
        lat: 24.7500,
        lng: 46.7000,
      );

      final config = buildDestinationPreviewMap(
        pickup: pickup,
        destination: destination,
      );

      expect(config.markers.length, equals(2));
      expect(config.markers.map((m) => m.id).toList(), containsAll(['pickup', 'destination']));
    });

    test('returns config with 1 polyline when both have coordinates', () {
      final pickup = placeWithLocation(
        label: 'Start',
        lat: 24.7136,
        lng: 46.6753,
      );
      final destination = placeWithLocation(
        label: 'End',
        lat: 24.7500,
        lng: 46.7000,
      );

      final config = buildDestinationPreviewMap(
        pickup: pickup,
        destination: destination,
      );

      expect(config.polylines.length, equals(1));
      expect(config.polylines.first.points.length, equals(2));
    });

    test('returns config with only pickup marker when destination has no coordinates', () {
      final pickup = placeWithLocation(
        label: 'Home',
        lat: 24.7136,
        lng: 46.6753,
      );
      final destination = placeWithoutLocation(label: 'Unknown');

      final config = buildDestinationPreviewMap(
        pickup: pickup,
        destination: destination,
      );

      expect(config.markers.length, equals(1));
      expect(config.markers.first.id, equals('pickup'));
      expect(config.polylines, isEmpty);
    });

    test('returns config with only destination marker when pickup has no coordinates', () {
      final pickup = placeWithoutLocation(label: 'Unknown');
      final destination = placeWithLocation(
        label: 'Office',
        lat: 24.7500,
        lng: 46.7000,
      );

      final config = buildDestinationPreviewMap(
        pickup: pickup,
        destination: destination,
      );

      expect(config.markers.length, equals(1));
      expect(config.markers.first.id, equals('destination'));
      expect(config.polylines, isEmpty);
    });

    test('returns config with empty markers and no polylines when both are null', () {
      final config = buildDestinationPreviewMap(
        pickup: null,
        destination: null,
      );

      expect(config.markers, isEmpty);
      expect(config.polylines, isEmpty);
    });

    test('camera target is destination when both have coordinates', () {
      final pickup = placeWithLocation(
        label: 'Home',
        lat: 24.7136,
        lng: 46.6753,
      );
      final destination = placeWithLocation(
        label: 'Office',
        lat: 24.7500,
        lng: 46.7000,
      );

      final config = buildDestinationPreviewMap(
        pickup: pickup,
        destination: destination,
      );

      expect(config.cameraTarget.lat, closeTo(24.7500, 0.001));
      expect(config.cameraTarget.lng, closeTo(46.7000, 0.001));
    });

    test('camera target is pickup when only pickup has coordinates', () {
      final pickup = placeWithLocation(
        label: 'Home',
        lat: 24.7136,
        lng: 46.6753,
      );

      final config = buildDestinationPreviewMap(
        pickup: pickup,
        destination: null,
      );

      expect(config.cameraTarget.lat, closeTo(24.7136, 0.001));
      expect(config.cameraTarget.lng, closeTo(46.6753, 0.001));
    });

    test('camera target is default when no coordinates', () {
      final config = buildDestinationPreviewMap(
        pickup: null,
        destination: null,
      );

      // Default is Riyadh: 24.7136, 46.6753
      expect(config.cameraTarget.lat, closeTo(24.7136, 0.001));
      expect(config.cameraTarget.lng, closeTo(46.6753, 0.001));
    });

    test('zoom is default value', () {
      final config = buildDestinationPreviewMap(
        pickup: null,
        destination: null,
      );

      expect(config.cameraZoom, equals(RideMapConfig.defaultZoom));
    });
  });

  group('buildActiveTripMap', () {
    test('includes driver marker when driverLocation is provided and phase is driverAccepted', () {
      final pickup = placeWithLocation(
        label: 'Home',
        lat: 24.7136,
        lng: 46.6753,
      );
      final destination = placeWithLocation(
        label: 'Office',
        lat: 24.7500,
        lng: 46.7000,
      );
      final driverLocation = LocationPoint(
        latitude: 24.7200,
        longitude: 46.6800,
        accuracyMeters: 10,
        timestamp: DateTime.now(),
      );
      final activeTrip = RideTripState(
        tripId: 'trip-1',
        phase: RideTripPhase.driverAccepted,
      );

      final config = buildActiveTripMap(
        activeTrip: activeTrip,
        pickup: pickup,
        destination: destination,
        driverLocation: driverLocation,
      );

      expect(config.markers.length, equals(3));
      expect(config.markers.map((m) => m.id).toList(), containsAll(['pickup', 'destination', 'driver']));
    });

    test('includes driver marker when phase is driverArrived', () {
      final pickup = placeWithLocation(
        label: 'Home',
        lat: 24.7136,
        lng: 46.6753,
      );
      final driverLocation = LocationPoint(
        latitude: 24.7200,
        longitude: 46.6800,
        accuracyMeters: 10,
        timestamp: DateTime.now(),
      );
      final activeTrip = RideTripState(
        tripId: 'trip-1',
        phase: RideTripPhase.driverArrived,
      );

      final config = buildActiveTripMap(
        activeTrip: activeTrip,
        pickup: pickup,
        destination: null,
        driverLocation: driverLocation,
      );

      expect(config.markers.any((m) => m.id == 'driver'), isTrue);
    });

    test('includes driver marker when phase is inProgress', () {
      final pickup = placeWithLocation(
        label: 'Home',
        lat: 24.7136,
        lng: 46.6753,
      );
      final driverLocation = LocationPoint(
        latitude: 24.7200,
        longitude: 46.6800,
        accuracyMeters: 10,
        timestamp: DateTime.now(),
      );
      final activeTrip = RideTripState(
        tripId: 'trip-1',
        phase: RideTripPhase.inProgress,
      );

      final config = buildActiveTripMap(
        activeTrip: activeTrip,
        pickup: pickup,
        destination: null,
        driverLocation: driverLocation,
      );

      expect(config.markers.any((m) => m.id == 'driver'), isTrue);
    });

    test('does not include driver marker when driverLocation is null', () {
      final pickup = placeWithLocation(
        label: 'Home',
        lat: 24.7136,
        lng: 46.6753,
      );
      final activeTrip = RideTripState(
        tripId: 'trip-1',
        phase: RideTripPhase.driverAccepted,
      );

      final config = buildActiveTripMap(
        activeTrip: activeTrip,
        pickup: pickup,
        destination: null,
        driverLocation: null,
      );

      expect(config.markers.any((m) => m.id == 'driver'), isFalse);
    });

    test('does not include driver marker when phase is findingDriver', () {
      final pickup = placeWithLocation(
        label: 'Home',
        lat: 24.7136,
        lng: 46.6753,
      );
      final driverLocation = LocationPoint(
        latitude: 24.7200,
        longitude: 46.6800,
        accuracyMeters: 10,
        timestamp: DateTime.now(),
      );
      final activeTrip = RideTripState(
        tripId: 'trip-1',
        phase: RideTripPhase.findingDriver,
      );

      final config = buildActiveTripMap(
        activeTrip: activeTrip,
        pickup: pickup,
        destination: null,
        driverLocation: driverLocation,
      );

      expect(config.markers.any((m) => m.id == 'driver'), isFalse);
    });

    test('camera target is driver when driver marker exists', () {
      final pickup = placeWithLocation(
        label: 'Home',
        lat: 24.7136,
        lng: 46.6753,
      );
      final destination = placeWithLocation(
        label: 'Office',
        lat: 24.7500,
        lng: 46.7000,
      );
      final driverLocation = LocationPoint(
        latitude: 24.7300,
        longitude: 46.6900,
        accuracyMeters: 10,
        timestamp: DateTime.now(),
      );
      final activeTrip = RideTripState(
        tripId: 'trip-1',
        phase: RideTripPhase.driverAccepted,
      );

      final config = buildActiveTripMap(
        activeTrip: activeTrip,
        pickup: pickup,
        destination: destination,
        driverLocation: driverLocation,
      );

      // Camera should be on driver location
      expect(config.cameraTarget.lat, closeTo(24.7300, 0.001));
      expect(config.cameraTarget.lng, closeTo(46.6900, 0.001));
    });

    test('camera target falls back to destination when no driver', () {
      final pickup = placeWithLocation(
        label: 'Home',
        lat: 24.7136,
        lng: 46.6753,
      );
      final destination = placeWithLocation(
        label: 'Office',
        lat: 24.7500,
        lng: 46.7000,
      );
      final activeTrip = RideTripState(
        tripId: 'trip-1',
        phase: RideTripPhase.findingDriver,
      );

      final config = buildActiveTripMap(
        activeTrip: activeTrip,
        pickup: pickup,
        destination: destination,
        driverLocation: null,
      );

      // Camera should be on destination (fallback from base config)
      expect(config.cameraTarget.lat, closeTo(24.7500, 0.001));
      expect(config.cameraTarget.lng, closeTo(46.7000, 0.001));
    });

    test('preserves polylines from base config', () {
      final pickup = placeWithLocation(
        label: 'Home',
        lat: 24.7136,
        lng: 46.6753,
      );
      final destination = placeWithLocation(
        label: 'Office',
        lat: 24.7500,
        lng: 46.7000,
      );
      final activeTrip = RideTripState(
        tripId: 'trip-1',
        phase: RideTripPhase.inProgress,
      );

      final config = buildActiveTripMap(
        activeTrip: activeTrip,
        pickup: pickup,
        destination: destination,
        driverLocation: null,
      );

      expect(config.polylines.length, equals(1));
      expect(config.polylines.first.id, equals('route-pickup-destination'));
    });
  });

  group('buildPickupOnlyMap', () {
    test('returns config with 1 marker when pickup has coordinates', () {
      final pickup = placeWithLocation(
        label: 'Home',
        lat: 24.7136,
        lng: 46.6753,
      );

      final config = buildPickupOnlyMap(pickup: pickup);

      expect(config.markers.length, equals(1));
      expect(config.markers.first.id, equals('pickup'));
    });

    test('returns config with empty markers when pickup is null', () {
      final config = buildPickupOnlyMap(pickup: null);

      expect(config.markers, isEmpty);
    });

    test('returns config with no polylines', () {
      final pickup = placeWithLocation(
        label: 'Home',
        lat: 24.7136,
        lng: 46.6753,
      );

      final config = buildPickupOnlyMap(pickup: pickup);

      expect(config.polylines, isEmpty);
    });

    test('camera target is pickup location', () {
      final pickup = placeWithLocation(
        label: 'Home',
        lat: 24.7136,
        lng: 46.6753,
      );

      final config = buildPickupOnlyMap(pickup: pickup);

      expect(config.cameraTarget.lat, closeTo(24.7136, 0.001));
      expect(config.cameraTarget.lng, closeTo(46.6753, 0.001));
    });

    test('camera target is default when pickup is null', () {
      final config = buildPickupOnlyMap(pickup: null);

      expect(config.cameraTarget.lat, closeTo(24.7136, 0.001));
      expect(config.cameraTarget.lng, closeTo(46.6753, 0.001));
    });
  });

  group('RideMapConfig', () {
    test('copyWith creates a copy with updated fields', () {
      final config = RideMapConfig(
        cameraTarget: const LatLng(24.7136, 46.6753),
        cameraZoom: 14.0,
        markers: const [],
        polylines: const [],
      );

      final updated = config.copyWith(
        cameraZoom: 16.0,
      );

      expect(updated.cameraZoom, equals(16.0));
      expect(updated.cameraTarget.lat, equals(config.cameraTarget.lat));
    });

    test('equality is based on camera and counts', () {
      final config1 = RideMapConfig(
        cameraTarget: const LatLng(24.7136, 46.6753),
        cameraZoom: 14.0,
        markers: const [],
        polylines: const [],
      );

      final config2 = RideMapConfig(
        cameraTarget: const LatLng(24.7136, 46.6753),
        cameraZoom: 14.0,
        markers: const [],
        polylines: const [],
      );

      expect(config1, equals(config2));
    });

    test('defaultZoom is 14.0', () {
      expect(RideMapConfig.defaultZoom, equals(14.0));
    });

    test('defaultLocation is Riyadh', () {
      expect(RideMapConfig.defaultLocation.lat, closeTo(24.7136, 0.001));
      expect(RideMapConfig.defaultLocation.lng, closeTo(46.6753, 0.001));
    });
  });
}


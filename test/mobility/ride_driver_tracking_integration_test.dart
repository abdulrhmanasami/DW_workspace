// Ride Driver Tracking Integration Tests
// Created by: Track B - Ticket #208
// Purpose: Test end-to-end integration between tracking uplink and ride session driver location
// Last updated: 2025-12-03

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maps_shims/maps_shims.dart';
import 'package:mobility_shims/mobility_shims.dart';

// App imports
import 'package:delivery_ways_clean/state/mobility/ride_trip_session.dart';
import 'package:delivery_ways_clean/state/mobility/tracking_controller.dart';
import 'package:delivery_ways_clean/state/mobility/ride_map_port_providers.dart';
import 'package:delivery_ways_clean/state/mobility/ride_map_projection.dart';
import 'package:delivery_ways_clean/state/mobility/ride_draft_state.dart';
import '../support/mobility_stubs.dart';
import '../support/path_provider_stub.dart';
import '../support/uplink_spy.dart';

// Recording MapPort for testing command recording
class RecordingMapPort implements MapPort {
  final List<MapCommand> recordedCommands = <MapCommand>[];

  @override
  Stream<MapEvent> get events => const Stream<MapEvent>.empty();

  @override
  Sink<MapCommand> get commands => _RecordingSink(recordedCommands);

  @override
  void dispose() {
    // Nothing to dispose
  }
}

class _RecordingSink implements Sink<MapCommand> {
  final List<MapCommand> _commands;

  _RecordingSink(this._commands);

  @override
  void add(MapCommand command) {
    _commands.add(command);
  }

  @override
  void close() {
    // Nothing to close
  }
}

void main() {
  // Required for path_provider used by UplinkService
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    ensurePathProviderStubForTests();
  });

  group('Ride Driver Tracking Integration Tests', () {
    late SpyUplinkService uplinkSpy;
    late ProviderContainer container;
    late RideTripSessionController sessionController;

    setUp(() {
      uplinkSpy = SpyUplinkService();

      container = ProviderContainer(
        overrides: [
          // Override mobility config to enable tracking
          mobilityConfigProvider.overrideWithValue(true),
          consentBackgroundLocationProvider.overrideWithValue(true),

          // Override location and background tracker with test implementations
          locationProvider.overrideWith(
            (ref) => const TestLocationProvider(),
          ),
          backgroundTrackerProvider.overrideWith(
            (ref) => const TestBackgroundTracker(),
          ),

          // Override uplink service with spy
          uplinkServiceProvider.overrideWithValue(uplinkSpy),

          // Override map port with recording port for testing
          rideMapPortProvider.overrideWith(
            (ref) => RecordingMapPort(),
          ),
        ],
      );

      sessionController = container.read(rideTripSessionProvider.notifier);
    });

    tearDown(() {
      uplinkSpy.reset();
      container.dispose();
    });

    test('no active trip ignores tracking updates', () async {
      // Arrange: Ensure no active trip (draft state)

      // Start tracking session
      final trackingController = container.read(trackingControllerProvider.notifier);
      await trackingController.start();

      // Act: Simulate tracking points by directly updating controller state
      final point1 = LocationPoint(
        latitude: 51.5074,
        longitude: -0.1278,
        timestamp: DateTime.now(),
      );
      final point2 = LocationPoint(
        latitude: 51.5075,
        longitude: -0.1279,
        timestamp: DateTime.now().add(const Duration(seconds: 5)),
      );

      // Update tracking controller state to simulate receiving points
      trackingController.state = trackingController.state.copyWith(lastPoint: point1);
      await Future.delayed(const Duration(milliseconds: 10));
      trackingController.state = trackingController.state.copyWith(lastPoint: point2);

      // Allow subscription to process
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert: No driver location set
      expect(sessionController.state.driverLocation, isNull);
      expect(sessionController.state.hasDriverLocation, isFalse);

      // Assert: No map commands for driver marker
      final recordingPort = container.read(rideMapPortProvider) as RecordingMapPort;
      final driverMarkers = recordingPort.recordedCommands
          .whereType<SetMarkersCommand>()
          .cast<SetMarkersCommand>()
          .expand((cmd) => cmd.markers)
          .where((marker) => marker.id.value.contains('driver') || marker.title == 'Driver')
          .toList();
      expect(driverMarkers, isEmpty);

      await trackingController.stop();
    });

    test('active trip shows driver marker from tracking updates', () async {
      // Arrange: Start active trip
      const draft = RideDraftUiState(
        pickupPlace: MobilityPlace(
          id: 'pickup1',
          label: 'Pickup Location',
          address: '123 Pickup St',
          location: LocationPoint(latitude: 51.5072, longitude: -0.1276),
          type: MobilityPlaceType.searchResult,
        ),
        destinationPlace: MobilityPlace(
          id: 'dest1',
          label: 'Destination Location',
          address: '456 Dest St',
          location: LocationPoint(latitude: 51.5078, longitude: -0.1282),
          type: MobilityPlaceType.searchResult,
        ),
        paymentMethodId: 'card1',
        selectedOptionId: 'economy',
      );

      sessionController.startFromDraft(draft);

      // Start tracking session
      final trackingController = container.read(trackingControllerProvider.notifier);
      await trackingController.start();

      // Act: Send tracking points by updating controller state
      final point1 = LocationPoint(
        latitude: 51.5074,
        longitude: -0.1278,
        timestamp: DateTime.now(),
      );
      final point2 = LocationPoint(
        latitude: 51.5075,
        longitude: -0.1279,
        timestamp: DateTime.now().add(const Duration(seconds: 5)),
      );

      // Update tracking controller state to simulate receiving points
      trackingController.state = trackingController.state.copyWith(lastPoint: point1);
      await Future.delayed(const Duration(milliseconds: 10));
      trackingController.state = trackingController.state.copyWith(lastPoint: point2);

      // Allow subscription to process
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert: Driver location is set to latest point
      expect(sessionController.state.driverLocation, isNotNull);
      expect(sessionController.state.driverLocation!.latitude, 51.5075);
      expect(sessionController.state.driverLocation!.longitude, -0.1279);
      expect(sessionController.state.hasDriverLocation, isTrue);

      // Assert: Map commands include driver marker
      final recordingPort = container.read(rideMapPortProvider) as RecordingMapPort;
      final driverMarkers = recordingPort.recordedCommands
          .whereType<SetMarkersCommand>()
          .cast<SetMarkersCommand>()
          .expand((cmd) => cmd.markers)
          .where((marker) => marker.id.value.contains('driver') || marker.title == 'Driver')
          .toList();
      expect(driverMarkers, isNotEmpty);
      expect(driverMarkers.any((marker) =>
        marker.position.latitude == 51.5075 && marker.position.longitude == -0.1279), isTrue);

      await trackingController.stop();
    });

    test('trip completion clears driver location and stops updates', () async {
      // Arrange: Start active trip and tracking
      const draft = RideDraftUiState(
        pickupPlace: MobilityPlace(
          id: 'pickup1',
          label: 'Pickup Location',
          address: '123 Pickup St',
          location: LocationPoint(latitude: 51.5072, longitude: -0.1276),
          type: MobilityPlaceType.searchResult,
        ),
        destinationPlace: MobilityPlace(
          id: 'dest1',
          label: 'Destination Location',
          address: '456 Dest St',
          location: LocationPoint(latitude: 51.5078, longitude: -0.1282),
          type: MobilityPlaceType.searchResult,
        ),
        paymentMethodId: 'card1',
        selectedOptionId: 'economy',
      );

      sessionController.startFromDraft(draft);

      final trackingController = container.read(trackingControllerProvider.notifier);
      await trackingController.start();

      // Set initial driver location
      final point1 = LocationPoint(
        latitude: 51.5074,
        longitude: -0.1278,
        timestamp: DateTime.now(),
      );
      // Update tracking controller state to simulate receiving points
      trackingController.state = trackingController.state.copyWith(lastPoint: point1);
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify driver location is set
      expect(sessionController.state.driverLocation, isNotNull);

      // Move trip to inProgress phase (required for completion)
      sessionController.applyEvent(RideTripEvent.driverAccepted);
      sessionController.applyEvent(RideTripEvent.driverArrived);
      sessionController.applyEvent(RideTripEvent.startTrip);

      // Act: Complete the trip
      final completed = sessionController.completeCurrentTrip(
        destinationLabel: 'Destination',
        amountFormatted: 'SAR 25.00',
        serviceName: 'Economy',
      );
      expect(completed, isTrue);

      // Wait for completion to take effect
      await Future.delayed(const Duration(milliseconds: 50));

      // Send additional tracking points after completion
      final point2 = LocationPoint(
        latitude: 51.5076,
        longitude: -0.1280,
        timestamp: DateTime.now().add(const Duration(seconds: 10)),
      );
      // Update tracking controller state to simulate receiving points
      trackingController.state = trackingController.state.copyWith(lastPoint: point2);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert: Driver location is cleared after completion
      expect(sessionController.state.driverLocation, isNull);
      expect(sessionController.state.hasDriverLocation, isFalse);

      // Assert: Driver location is cleared after completion
      expect(sessionController.state.driverLocation, isNull);
      expect(sessionController.state.hasDriverLocation, isFalse);

      await trackingController.stop();
    });

    test('trip cancellation clears driver location and stops updates', () async {
      // Arrange: Start active trip and tracking
      const draft = RideDraftUiState(
        pickupPlace: MobilityPlace(
          id: 'pickup1',
          label: 'Pickup Location',
          address: '123 Pickup St',
          location: LocationPoint(latitude: 51.5072, longitude: -0.1276),
          type: MobilityPlaceType.searchResult,
        ),
        destinationPlace: MobilityPlace(
          id: 'dest1',
          label: 'Destination Location',
          address: '456 Dest St',
          location: LocationPoint(latitude: 51.5078, longitude: -0.1282),
          type: MobilityPlaceType.searchResult,
        ),
        paymentMethodId: 'card1',
        selectedOptionId: 'economy',
      );

      sessionController.startFromDraft(draft);

      final trackingController = container.read(trackingControllerProvider.notifier);
      await trackingController.start();

      // Set initial driver location
      final point1 = LocationPoint(
        latitude: 51.5074,
        longitude: -0.1278,
        timestamp: DateTime.now(),
      );
      // Update tracking controller state to simulate receiving points
      trackingController.state = trackingController.state.copyWith(lastPoint: point1);
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify driver location is set
      expect(sessionController.state.driverLocation, isNotNull);

      // Act: Cancel the trip
      sessionController.cancelCurrentTrip(
        destinationLabel: 'Destination',
        serviceName: 'Economy',
      );

      // Send additional tracking points after cancellation
      final point2 = LocationPoint(
        latitude: 51.5076,
        longitude: -0.1280,
        timestamp: DateTime.now().add(const Duration(seconds: 10)),
      );
      // Update tracking controller state to simulate receiving points
      trackingController.state = trackingController.state.copyWith(lastPoint: point2);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert: Driver location is cleared after cancellation
      expect(sessionController.state.driverLocation, isNull);
      expect(sessionController.state.hasDriverLocation, isFalse);

      await trackingController.stop();
    });

    // ===========================================================================
    // Track B - Ticket #209: Chaos Tests for Driver Tracking Invariants
    // ===========================================================================

    test('chaos: tracking updates before activeTrip are ignored', () async {
      // Arrange: No active trip (controller starts in idle state)

      // Start tracking session
      final trackingController = container.read(trackingControllerProvider.notifier);
      await trackingController.start();

      // Act: Send multiple tracking points before any trip starts
      final point1 = LocationPoint(
        latitude: 51.5074,
        longitude: -0.1278,
        timestamp: DateTime.now(),
      );
      final point2 = LocationPoint(
        latitude: 51.5075,
        longitude: -0.1279,
        timestamp: DateTime.now().add(const Duration(seconds: 5)),
      );
      final point3 = LocationPoint(
        latitude: 51.5076,
        longitude: -0.1280,
        timestamp: DateTime.now().add(const Duration(seconds: 10)),
      );

      // Update tracking controller state to simulate receiving points
      trackingController.state = trackingController.state.copyWith(lastPoint: point1);
      await Future.delayed(const Duration(milliseconds: 10));
      trackingController.state = trackingController.state.copyWith(lastPoint: point2);
      await Future.delayed(const Duration(milliseconds: 10));
      trackingController.state = trackingController.state.copyWith(lastPoint: point3);

      // Allow subscription to process
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert: Driver location remains null
      expect(sessionController.state.driverLocation, isNull);
      expect(sessionController.state.hasDriverLocation, isFalse);

      // Assert: Map stage remains idle
      expect(sessionController.state.mapStage, RideMapStage.idle);

      // Assert: No driver marker commands sent to MapPort
      final recordingPort = container.read(rideMapPortProvider) as RecordingMapPort;
      final driverMarkers = recordingPort.recordedCommands
          .whereType<SetMarkersCommand>()
          .cast<SetMarkersCommand>()
          .expand((cmd) => cmd.markers)
          .where((marker) => marker.id.value.contains('driver') || marker.title == 'Driver')
          .toList();
      expect(driverMarkers, isEmpty);

      await trackingController.stop();
    });

    test('chaos: late tracking updates after trip completion are ignored', () async {
      // Arrange: Start active trip and get to completion
      const draft = RideDraftUiState(
        pickupPlace: MobilityPlace(
          id: 'pickup1',
          label: 'Pickup Location',
          address: '123 Pickup St',
          location: LocationPoint(latitude: 51.5072, longitude: -0.1276),
          type: MobilityPlaceType.searchResult,
        ),
        destinationPlace: MobilityPlace(
          id: 'dest1',
          label: 'Destination Location',
          address: '456 Dest St',
          location: LocationPoint(latitude: 51.5078, longitude: -0.1282),
          type: MobilityPlaceType.searchResult,
        ),
        paymentMethodId: 'card1',
        selectedOptionId: 'economy',
      );

      sessionController.startFromDraft(draft);

      final trackingController = container.read(trackingControllerProvider.notifier);
      await trackingController.start();

      // Set initial driver location during active trip
      final point1 = LocationPoint(
        latitude: 51.5074,
        longitude: -0.1278,
        timestamp: DateTime.now(),
      );
      trackingController.state = trackingController.state.copyWith(lastPoint: point1);
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify driver location is set
      expect(sessionController.state.driverLocation, isNotNull);
      expect(sessionController.state.hasDriverLocation, isTrue);

      // Progress trip to completion
      sessionController.applyEvent(RideTripEvent.driverAccepted);
      sessionController.applyEvent(RideTripEvent.driverArrived);
      sessionController.applyEvent(RideTripEvent.startTrip);

      // Complete the trip using completeCurrentTrip (clears session)
      final completed = sessionController.completeCurrentTrip(
        destinationLabel: 'Destination',
        amountFormatted: 'SAR 25.00',
        serviceName: 'Economy',
      );
      expect(completed, isTrue);

      // Verify trip is completed and driver location is cleared
      expect(sessionController.state.activeTrip, isNull);
      expect(sessionController.state.driverLocation, isNull);
      expect(sessionController.state.mapStage, RideMapStage.idle);

      // Act: Send late tracking updates after trip completion
      final latePoint1 = LocationPoint(
        latitude: 51.5076,
        longitude: -0.1280,
        timestamp: DateTime.now().add(const Duration(seconds: 30)),
      );
      final latePoint2 = LocationPoint(
        latitude: 51.5077,
        longitude: -0.1281,
        timestamp: DateTime.now().add(const Duration(seconds: 35)),
      );

      trackingController.state = trackingController.state.copyWith(lastPoint: latePoint1);
      await Future.delayed(const Duration(milliseconds: 100));
      trackingController.state = trackingController.state.copyWith(lastPoint: latePoint2);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert: Driver location remains null after completion
      expect(sessionController.state.driverLocation, isNull);
      expect(sessionController.state.hasDriverLocation, isFalse);

      // Assert: Map stage remains idle (session is cleared after completeCurrentTrip)
      expect(sessionController.state.mapStage, RideMapStage.idle);

      // Assert: The main invariant - no driver location leakage after completion
      // Late tracking updates should not revive driver location since there's no active trip
      expect(sessionController.state.driverLocation, isNull);
      expect(sessionController.state.hasDriverLocation, isFalse);

      // The session remains cleared
      expect(sessionController.state.activeTrip, isNull);

      await trackingController.stop();
    });

    test('chaos: late tracking updates after trip cancellation are ignored', () async {
      // Arrange: Start active trip and cancel it
      const draft = RideDraftUiState(
        pickupPlace: MobilityPlace(
          id: 'pickup1',
          label: 'Pickup Location',
          address: '123 Pickup St',
          location: LocationPoint(latitude: 51.5072, longitude: -0.1276),
          type: MobilityPlaceType.searchResult,
        ),
        destinationPlace: MobilityPlace(
          id: 'dest1',
          label: 'Destination Location',
          address: '456 Dest St',
          location: LocationPoint(latitude: 51.5078, longitude: -0.1282),
          type: MobilityPlaceType.searchResult,
        ),
        paymentMethodId: 'card1',
        selectedOptionId: 'economy',
      );

      sessionController.startFromDraft(draft);

      final trackingController = container.read(trackingControllerProvider.notifier);
      await trackingController.start();

      // Set initial driver location during active trip
      final point1 = LocationPoint(
        latitude: 51.5074,
        longitude: -0.1278,
        timestamp: DateTime.now(),
      );
      trackingController.state = trackingController.state.copyWith(lastPoint: point1);
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify driver location is set
      expect(sessionController.state.driverLocation, isNotNull);

      // Cancel the trip
      final cancelled = sessionController.cancelCurrentTrip(destinationLabel: 'Destination');
      expect(cancelled, isTrue);

      // Verify trip is cancelled and driver location is cleared
      expect(sessionController.state.activeTrip, isNull);
      expect(sessionController.state.driverLocation, isNull);
      expect(sessionController.state.mapStage, RideMapStage.idle);

      // Act: Send late tracking updates after trip cancellation
      final latePoint = LocationPoint(
        latitude: 51.5076,
        longitude: -0.1280,
        timestamp: DateTime.now().add(const Duration(seconds: 30)),
      );

      trackingController.state = trackingController.state.copyWith(lastPoint: latePoint);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert: Driver location remains null after cancellation
      expect(sessionController.state.driverLocation, isNull);
      expect(sessionController.state.hasDriverLocation, isFalse);

      // Assert: Map stage remains idle
      expect(sessionController.state.mapStage, RideMapStage.idle);

      await trackingController.stop();
    });

    test('chaos: consecutive trips with continuous tracking stream', () async {
      // Arrange: Start tracking session that persists across trips
      final trackingController = container.read(trackingControllerProvider.notifier);
      await trackingController.start();

      // Trip A
      const draftA = RideDraftUiState(
        pickupPlace: MobilityPlace(
          id: 'pickupA',
          label: 'Pickup A',
          address: '123 Pickup St',
          location: LocationPoint(latitude: 51.5072, longitude: -0.1276),
          type: MobilityPlaceType.searchResult,
        ),
        destinationPlace: MobilityPlace(
          id: 'destA',
          label: 'Destination A',
          address: '456 Dest St',
          location: LocationPoint(latitude: 51.5078, longitude: -0.1282),
          type: MobilityPlaceType.searchResult,
        ),
        paymentMethodId: 'card1',
        selectedOptionId: 'economy',
      );

      sessionController.startFromDraft(draftA);

      // Send tracking points for Trip A
      final pointA1 = LocationPoint(
        latitude: 51.5074,
        longitude: -0.1278,
        timestamp: DateTime.now(),
      );
      final pointA2 = LocationPoint(
        latitude: 51.5075,
        longitude: -0.1279,
        timestamp: DateTime.now().add(const Duration(seconds: 5)),
      );

      trackingController.state = trackingController.state.copyWith(lastPoint: pointA1);
      await Future.delayed(const Duration(milliseconds: 50));
      trackingController.state = trackingController.state.copyWith(lastPoint: pointA2);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert: Driver location is set for Trip A
      expect(sessionController.state.driverLocation, isNotNull);
      expect(sessionController.state.driverLocation!.latitude, 51.5075);
      expect(sessionController.state.driverLocation!.longitude, -0.1279);
      expect(sessionController.state.hasDriverLocation, isTrue);
      final tripADriverLocation = sessionController.state.driverLocation;

      // Complete Trip A
      sessionController.applyEvent(RideTripEvent.driverAccepted);
      sessionController.applyEvent(RideTripEvent.driverArrived);
      sessionController.applyEvent(RideTripEvent.startTrip);
      final completedA = sessionController.completeCurrentTrip(destinationLabel: 'Trip A');
      expect(completedA, isTrue);

      // Assert: Driver location cleared after Trip A completion
      expect(sessionController.state.driverLocation, isNull);
      expect(sessionController.state.activeTrip, isNull);

      // Start Trip B (same container, continuous tracking stream)
      const draftB = RideDraftUiState(
        pickupPlace: MobilityPlace(
          id: 'pickupB',
          label: 'Pickup B',
          address: '789 Pickup St',
          location: LocationPoint(latitude: 51.5080, longitude: -0.1285),
          type: MobilityPlaceType.searchResult,
        ),
        destinationPlace: MobilityPlace(
          id: 'destB',
          label: 'Destination B',
          address: '101 Dest St',
          location: LocationPoint(latitude: 51.5085, longitude: -0.1290),
          type: MobilityPlaceType.searchResult,
        ),
        paymentMethodId: 'card1',
        selectedOptionId: 'economy',
      );

      sessionController.startFromDraft(draftB);

      // Assert: Driver location starts null for new trip
      expect(sessionController.state.driverLocation, isNull);
      expect(sessionController.state.activeTrip, isNotNull);

      // Send new tracking points for Trip B
      final pointB1 = LocationPoint(
        latitude: 51.5082,
        longitude: -0.1287,
        timestamp: DateTime.now().add(const Duration(seconds: 60)),
      );
      final pointB2 = LocationPoint(
        latitude: 51.5083,
        longitude: -0.1288,
        timestamp: DateTime.now().add(const Duration(seconds: 65)),
      );

      trackingController.state = trackingController.state.copyWith(lastPoint: pointB1);
      await Future.delayed(const Duration(milliseconds: 50));
      trackingController.state = trackingController.state.copyWith(lastPoint: pointB2);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert: Driver location updated for Trip B (not carrying over from Trip A)
      expect(sessionController.state.driverLocation, isNotNull);
      expect(sessionController.state.driverLocation!.latitude, 51.5083);
      expect(sessionController.state.driverLocation!.longitude, -0.1288);
      expect(sessionController.state.hasDriverLocation, isTrue);

      // Assert: Trip B driver location is different from Trip A
      expect(sessionController.state.driverLocation, isNot(equals(tripADriverLocation)));

      // Assert: Map shows driver marker for Trip B
      final recordingPort = container.read(rideMapPortProvider) as RecordingMapPort;
      final latestDriverMarkers = recordingPort.recordedCommands
          .whereType<SetMarkersCommand>()
          .cast<SetMarkersCommand>()
          .expand((cmd) => cmd.markers)
          .where((marker) => marker.id.value.contains('driver') || marker.title == 'Driver')
          .toList();

      // Should have driver markers and the last one should match Trip B's location
      expect(latestDriverMarkers, isNotEmpty);
      final lastDriverMarker = latestDriverMarkers.last;
      expect(lastDriverMarker.position.latitude, closeTo(51.5083, 0.001));
      expect(lastDriverMarker.position.longitude, closeTo(-0.1288, 0.001));

      await trackingController.stop();
    });
  });
}

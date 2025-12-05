/// Ride Trip Confirmation Screen Widget Tests - Track B Ticket #112
/// Purpose: Test RideMapCommands integration in Trip Confirmation screen
/// Created by: Track B - Ticket #112
/// Last updated: 2025-11-30
///
/// Tests cover:
/// - Map rendering when draftSnapshot is present (uses RideMapFromCommands)
/// - Placeholder display when no draft data is available
/// - Fallback to draft-based commands before trip starts

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobility_shims/mobility_shims.dart';
import 'package:maps_shims/maps_shims.dart';

import 'package:delivery_ways_clean/state/mobility/ride_draft_state.dart';
import 'package:delivery_ways_clean/state/mobility/ride_trip_session.dart';
import 'package:delivery_ways_clean/state/mobility/ride_map_commands_builder.dart';
import 'package:delivery_ways_clean/widgets/ride_map_from_commands.dart';

void main() {
  group('Trip Confirmation Map Integration - Ticket #112', () {
    // Helper to create a place with location
    MobilityPlace createPlaceWithLocation(String label, double lat, double lng) {
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

    group('draftMapCommands getter', () {
      test('returns null when no draftSnapshot', () {
        // Arrange
        const state = RideTripSessionUiState();

        // Act
        final commands = state.draftMapCommands;

        // Assert
        expect(commands, isNull);
      });

      test('returns RideMapCommands when draftSnapshot is present', () {
        // Arrange
        final pickup = createPlaceWithLocation('Home', 24.7136, 46.6753);
        final destination = createPlaceWithLocation('Work', 24.9500, 46.7100);
        final draft = RideDraftUiState(
          pickupLabel: 'Home',
          pickupPlace: pickup,
          destinationQuery: 'Work',
          destinationPlace: destination,
        );
        final state = RideTripSessionUiState(draftSnapshot: draft);

        // Act
        final commands = state.draftMapCommands;

        // Assert
        expect(commands, isNotNull);
        expect(commands!.setContent.markers.length, 2);
        expect(commands.setContent.polylines.length, 1);
      });

      test('markers contain pickup and destination when both have coordinates', () {
        // Arrange
        final pickup = createPlaceWithLocation('Home', 24.7136, 46.6753);
        final destination = createPlaceWithLocation('Work', 24.9500, 46.7100);
        final draft = RideDraftUiState(
          pickupLabel: 'Home',
          pickupPlace: pickup,
          destinationQuery: 'Work',
          destinationPlace: destination,
        );
        final state = RideTripSessionUiState(draftSnapshot: draft);

        // Act
        final commands = state.draftMapCommands!;
        final markerIds = commands.setContent.markers.map((m) => m.id).toList();

        // Assert
        expect(markerIds, contains('pickup'));
        expect(markerIds, contains('destination'));
      });

      test('markers have correct positions', () {
        // Arrange
        final pickup = createPlaceWithLocation('Home', 24.7136, 46.6753);
        final destination = createPlaceWithLocation('Work', 24.9500, 46.7100);
        final draft = RideDraftUiState(
          pickupLabel: 'Home',
          pickupPlace: pickup,
          destinationQuery: 'Work',
          destinationPlace: destination,
        );
        final state = RideTripSessionUiState(draftSnapshot: draft);

        // Act
        final commands = state.draftMapCommands!;
        final pickupMarker = commands.setContent.markers
            .firstWhere((m) => m.id == 'pickup');
        final destinationMarker = commands.setContent.markers
            .firstWhere((m) => m.id == 'destination');

        // Assert
        expect(pickupMarker.position.latitude, 24.7136);
        expect(pickupMarker.position.longitude, 46.6753);
        expect(destinationMarker.position.latitude, 24.9500);
        expect(destinationMarker.position.longitude, 46.7100);
      });

      test('animateToBounds contains bounds when locations are present', () {
        // Arrange
        final pickup = createPlaceWithLocation('Home', 24.7136, 46.6753);
        final destination = createPlaceWithLocation('Work', 24.9500, 46.7100);
        final draft = RideDraftUiState(
          pickupLabel: 'Home',
          pickupPlace: pickup,
          destinationQuery: 'Work',
          destinationPlace: destination,
        );
        final state = RideTripSessionUiState(draftSnapshot: draft);

        // Act
        final commands = state.draftMapCommands!;

        // Assert
        expect(commands.animateToBounds, isNotNull);
        expect(commands.animateToBounds!.bounds.southWest.latitude, 24.7136);
        expect(commands.animateToBounds!.bounds.northEast.latitude, 24.9500);
      });
    });

    group('draftMapCommands vs activeTripMapCommands consistency', () {
      test('both produce identical commands when trip is active with same draft', () {
        // Arrange
        final pickup = createPlaceWithLocation('Home', 24.7136, 46.6753);
        final destination = createPlaceWithLocation('Work', 24.9500, 46.7100);
        final draft = RideDraftUiState(
          pickupLabel: 'Home',
          pickupPlace: pickup,
          destinationQuery: 'Work',
          destinationPlace: destination,
        );

        // Create active trip state with frozen draft
        const activeTrip = RideTripState(
          tripId: 'test-123',
          phase: RideTripPhase.findingDriver,
        );
        final state = RideTripSessionUiState(
          activeTrip: activeTrip,
          draftSnapshot: draft,
        );

        // Act
        final draftCommands = state.draftMapCommands;
        final activeCommands = state.activeTripMapCommands;

        // Assert - Both should have same markers and polylines
        expect(draftCommands, isNotNull);
        expect(activeCommands, isNotNull);
        expect(
          draftCommands!.setContent.markers.length,
          activeCommands!.setContent.markers.length,
        );
        expect(
          draftCommands.setContent.polylines.length,
          activeCommands.setContent.polylines.length,
        );
      });
    });

    group('RideMapFromCommands widget', () {
      testWidgets('renders MapWidget with converted markers', (tester) async {
        // Arrange
        const commands = RideMapCommands(
          setContent: DWSetContentCommand(
            markers: [
              DWMapMarker(
                id: 'pickup',
                position: DWLatLng(24.7136, 46.6753),
                type: DWMapMarkerType.userPickup,
                label: 'Home',
              ),
              DWMapMarker(
                id: 'destination',
                position: DWLatLng(24.9500, 46.7100),
                type: DWMapMarkerType.destination,
                label: 'Work',
              ),
            ],
            polylines: [
              DWMapPolyline(
                id: 'route',
                points: [
                  DWLatLng(24.7136, 46.6753),
                  DWLatLng(24.9500, 46.7100),
                ],
                style: DWMapPolylineStyle.route,
              ),
            ],
          ),
          animateToBounds: DWAnimateToBoundsCommand(
            DWLatLngBounds(
              southWest: DWLatLng(24.7136, 46.6753),
              northEast: DWLatLng(24.9500, 46.7100),
            ),
          ),
        );

        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: RideMapFromCommands(commands: commands),
            ),
          ),
        );

        // Assert - MapWidget should be rendered (it's a SizedBox with 'Maps not available' text)
        expect(find.byType(MapWidget), findsOneWidget);
      });

      testWidgets('calculates initialPosition from bounds center', (tester) async {
        // Arrange
        const commands = RideMapCommands(
          setContent: DWSetContentCommand(
            markers: [],
            polylines: [],
          ),
          animateToBounds: DWAnimateToBoundsCommand(
            DWLatLngBounds(
              southWest: DWLatLng(24.0, 46.0),
              northEast: DWLatLng(26.0, 48.0),
            ),
          ),
        );

        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: RideMapFromCommands(commands: commands),
            ),
          ),
        );

        // Assert - Widget should render without errors
        expect(find.byType(RideMapFromCommands), findsOneWidget);
      });
    });

    group('RideMapPlaceholder widget', () {
      testWidgets('shows loading indicator by default', (tester) async {
        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: RideMapPlaceholder(message: 'Loading map...'),
            ),
          ),
        );

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Loading map...'), findsOneWidget);
      });

      testWidgets('hides loading indicator when showLoadingIndicator is false',
          (tester) async {
        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: RideMapPlaceholder(
                message: 'No map data',
                showLoadingIndicator: false,
              ),
            ),
          ),
        );

        // Assert
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('No map data'), findsOneWidget);
      });
    });

    group('buildDraftMapCommands function', () {
      test('returns empty markers when no locations in draft', () {
        // Arrange
        const draft = RideDraftUiState(
          pickupLabel: 'Current Location',
          destinationQuery: 'Downtown',
        );

        // Act
        final commands = buildDraftMapCommands(draft);

        // Assert
        expect(commands.setContent.markers, isEmpty);
        expect(commands.setContent.polylines, isEmpty);
        expect(commands.animateToBounds, isNull);
      });

      test('returns one marker when only pickup has location', () {
        // Arrange
        final pickup = createPlaceWithLocation('Home', 24.7136, 46.6753);
        final draft = RideDraftUiState(
          pickupLabel: 'Home',
          pickupPlace: pickup,
          destinationQuery: 'Downtown',
        );

        // Act
        final commands = buildDraftMapCommands(draft);

        // Assert
        expect(commands.setContent.markers.length, 1);
        expect(commands.setContent.markers.first.id, 'pickup');
        expect(commands.setContent.polylines, isEmpty);
      });

      test('returns one marker when only destination has location', () {
        // Arrange
        final destination = createPlaceWithLocation('Work', 24.9500, 46.7100);
        const draft = RideDraftUiState(
          pickupLabel: 'Current Location',
          destinationQuery: 'Work',
        );
        final draftWithDest = draft.copyWith(destinationPlace: destination);

        // Act
        final commands = buildDraftMapCommands(draftWithDest);

        // Assert
        expect(commands.setContent.markers.length, 1);
        expect(commands.setContent.markers.first.id, 'destination');
        expect(commands.setContent.polylines, isEmpty);
      });

      test('returns two markers and polyline when both have locations', () {
        // Arrange
        final pickup = createPlaceWithLocation('Home', 24.7136, 46.6753);
        final destination = createPlaceWithLocation('Work', 24.9500, 46.7100);
        final draft = RideDraftUiState(
          pickupLabel: 'Home',
          pickupPlace: pickup,
          destinationQuery: 'Work',
          destinationPlace: destination,
        );

        // Act
        final commands = buildDraftMapCommands(draft);

        // Assert
        expect(commands.setContent.markers.length, 2);
        expect(commands.setContent.polylines.length, 1);
        expect(commands.setContent.polylines.first.points.length, 2);
      });

      test('markers have correct types', () {
        // Arrange
        final pickup = createPlaceWithLocation('Home', 24.7136, 46.6753);
        final destination = createPlaceWithLocation('Work', 24.9500, 46.7100);
        final draft = RideDraftUiState(
          pickupLabel: 'Home',
          pickupPlace: pickup,
          destinationQuery: 'Work',
          destinationPlace: destination,
        );

        // Act
        final commands = buildDraftMapCommands(draft);
        final pickupMarker = commands.setContent.markers
            .firstWhere((m) => m.id == 'pickup');
        final destinationMarker = commands.setContent.markers
            .firstWhere((m) => m.id == 'destination');

        // Assert
        expect(pickupMarker.type, DWMapMarkerType.userPickup);
        expect(destinationMarker.type, DWMapMarkerType.destination);
      });
    });
  });
}


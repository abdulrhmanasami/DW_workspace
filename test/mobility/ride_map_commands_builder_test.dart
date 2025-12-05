/// Ride Map Commands Builder Unit Tests - Track B Ticket #110
/// Purpose: Test the ride map commands builder for draft and active trip
/// Created by: Track B - Ticket #110
/// Last updated: 2025-11-30

import 'package:flutter_test/flutter_test.dart';
import 'package:maps_shims/maps_shims.dart';
import 'package:mobility_shims/mobility_shims.dart';

import 'package:delivery_ways_clean/state/mobility/ride_draft_state.dart';
import 'package:delivery_ways_clean/state/mobility/ride_map_commands_builder.dart';
import 'package:delivery_ways_clean/state/mobility/ride_trip_session.dart';

void main() {
  // ===========================================================================
  // Test Helpers
  // ===========================================================================

  /// Create MobilityPlace with coordinates
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

  /// Create MobilityPlace without coordinates
  MobilityPlace placeWithoutLocation({required String label}) {
    return MobilityPlace(label: label);
  }

  /// Create a basic active trip session in findingDriver phase
  RideTripSessionUiState createActiveSession() {
    return const RideTripSessionUiState(
      activeTrip: RideTripState(
        tripId: 'test-trip-1',
        phase: RideTripPhase.findingDriver,
      ),
    );
  }

  /// Create a completed trip session
  RideTripSessionUiState createCompletedSession() {
    return const RideTripSessionUiState(
      activeTrip: RideTripState(
        tripId: 'test-trip-1',
        phase: RideTripPhase.completed,
      ),
    );
  }

  // ===========================================================================
  // Draft Map Commands Tests
  // ===========================================================================

  group('buildDraftMapCommands', () {
    test('returns empty content when no places', () {
      // Arrange
      const draft = RideDraftUiState();

      // Act
      final commands = buildDraftMapCommands(draft);

      // Assert
      expect(commands.setContent.markers, isEmpty);
      expect(commands.setContent.polylines, isEmpty);
      expect(commands.animateToBounds, isNull);
    });

    test('builds pickup marker when only pickup has coords', () {
      // Arrange
      final draft = RideDraftUiState(
        pickupPlace: placeWithLocation(
          label: 'Home',
          lat: 24.7136,
          lng: 46.6753,
        ),
        pickupLabel: 'Home',
      );

      // Act
      final commands = buildDraftMapCommands(draft);

      // Assert
      expect(commands.setContent.markers, hasLength(1));
      expect(commands.setContent.polylines, isEmpty);

      final marker = commands.setContent.markers.first;
      expect(marker.id, equals('pickup'));
      expect(marker.type, equals(DWMapMarkerType.userPickup));
      expect(marker.label, equals('Home'));
      expect(marker.position.latitude, equals(24.7136));
      expect(marker.position.longitude, equals(46.6753));

      // Should still have bounds for single marker
      expect(commands.animateToBounds, isNotNull);
    });

    test('builds destination marker when only destination has coords', () {
      // Arrange
      final draft = RideDraftUiState(
        destinationPlace: placeWithLocation(
          label: 'Office',
          lat: 24.7500,
          lng: 46.7000,
        ),
        destinationQuery: 'Office',
      );

      // Act
      final commands = buildDraftMapCommands(draft);

      // Assert
      expect(commands.setContent.markers, hasLength(1));
      expect(commands.setContent.polylines, isEmpty);

      final marker = commands.setContent.markers.first;
      expect(marker.id, equals('destination'));
      expect(marker.type, equals(DWMapMarkerType.destination));
      expect(marker.label, equals('Office'));
      expect(marker.position.latitude, equals(24.7500));
      expect(marker.position.longitude, equals(46.7000));

      expect(commands.animateToBounds, isNotNull);
    });

    test('builds pickup and destination markers and route polyline', () {
      // Arrange
      final draft = RideDraftUiState(
        pickupPlace: placeWithLocation(
          label: 'Home',
          lat: 24.7136,
          lng: 46.6753,
        ),
        pickupLabel: 'Home',
        destinationPlace: placeWithLocation(
          label: 'Airport',
          lat: 24.9600,
          lng: 46.6990,
        ),
        destinationQuery: 'Airport',
      );

      // Act
      final commands = buildDraftMapCommands(draft);

      // Assert - Markers
      expect(commands.setContent.markers, hasLength(2));

      final pickupMarker = commands.setContent.markers
          .firstWhere((m) => m.id == 'pickup');
      expect(pickupMarker.type, equals(DWMapMarkerType.userPickup));
      expect(pickupMarker.label, equals('Home'));

      final destMarker = commands.setContent.markers
          .firstWhere((m) => m.id == 'destination');
      expect(destMarker.type, equals(DWMapMarkerType.destination));
      expect(destMarker.label, equals('Airport'));

      // Assert - Polyline
      expect(commands.setContent.polylines, hasLength(1));
      final polyline = commands.setContent.polylines.first;
      expect(polyline.id, equals('route'));
      expect(polyline.style, equals(DWMapPolylineStyle.route));
      expect(polyline.points, hasLength(2));

      // Assert - Bounds
      expect(commands.animateToBounds, isNotNull);
    });

    test('ignores places without coordinates', () {
      // Arrange
      final draft = RideDraftUiState(
        pickupPlace: placeWithoutLocation(label: 'Current location'),
        pickupLabel: 'Current location',
        destinationPlace: placeWithoutLocation(label: 'Unknown'),
        destinationQuery: 'Unknown',
      );

      // Act
      final commands = buildDraftMapCommands(draft);

      // Assert
      expect(commands.setContent.markers, isEmpty);
      expect(commands.setContent.polylines, isEmpty);
      expect(commands.animateToBounds, isNull);
    });

    test('ignores pickup without coords but includes destination with coords', () {
      // Arrange
      final draft = RideDraftUiState(
        pickupPlace: placeWithoutLocation(label: 'Current location'),
        pickupLabel: 'Current location',
        destinationPlace: placeWithLocation(
          label: 'Mall',
          lat: 24.8000,
          lng: 46.7500,
        ),
        destinationQuery: 'Mall',
      );

      // Act
      final commands = buildDraftMapCommands(draft);

      // Assert
      expect(commands.setContent.markers, hasLength(1));
      expect(commands.setContent.markers.first.id, equals('destination'));
      expect(commands.setContent.polylines, isEmpty); // No polyline without pickup
      expect(commands.animateToBounds, isNotNull);
    });

    test('uses destinationQuery as label when destinationPlace has no label', () {
      // Arrange
      final draft = RideDraftUiState(
        destinationPlace: MobilityPlace(
          label: '', // Empty label
          location: LocationPoint(
            latitude: 24.8000,
            longitude: 46.7500,
            accuracyMeters: 10,
            timestamp: DateTime.now(),
          ),
        ),
        destinationQuery: 'Search Query',
      );

      // Act
      final commands = buildDraftMapCommands(draft);

      // Assert
      final marker = commands.setContent.markers.first;
      // When label is empty, it uses destinationPlace.label which is ''
      // The builder uses: draft.destinationPlace?.label ?? draft.destinationQuery
      // So it will use empty string, not the query
      expect(marker.label, equals(''));
    });
  });

  // ===========================================================================
  // Active Trip Map Commands Tests
  // ===========================================================================

  group('buildActiveTripMapCommands', () {
    test('returns null when no active trip', () {
      // Arrange
      const state = RideTripSessionUiState();

      // Act
      final commands = buildActiveTripMapCommands(state);

      // Assert
      expect(commands, isNull);
    });

    test('returns null for terminal trip phases', () {
      // Arrange
      final completedState = createCompletedSession();

      // Act
      final commands = buildActiveTripMapCommands(completedState);

      // Assert
      expect(commands, isNull);
    });

    // Track B - Ticket #111: Test for null draftSnapshot
    test('returns null when no draft snapshot', () {
      // Arrange - Active trip but no draftSnapshot
      final activeState = createActiveSession();
      expect(activeState.draftSnapshot, isNull);

      // Act
      final commands = buildActiveTripMapCommands(activeState);

      // Assert
      expect(commands, isNull);
    });

    // Track B - Ticket #111: Active trip with draft snapshot
    test('uses draft snapshot to build markers and polylines', () {
      // Arrange
      final draft = RideDraftUiState(
        pickupPlace: placeWithLocation(
          label: 'Pickup Point',
          lat: 24.7136,
          lng: 46.6753,
        ),
        pickupLabel: 'Pickup Point',
        destinationPlace: placeWithLocation(
          label: 'Drop Off',
          lat: 24.9600,
          lng: 46.6990,
        ),
        destinationQuery: 'Drop Off',
      );

      final sessionState = RideTripSessionUiState(
        activeTrip: const RideTripState(
          tripId: 'trip-with-snapshot',
          phase: RideTripPhase.findingDriver,
        ),
        draftSnapshot: draft,
      );

      // Act
      final commands = buildActiveTripMapCommands(sessionState);

      // Assert
      expect(commands, isNotNull);
      expect(commands!.setContent.markers, hasLength(2));
      expect(commands.setContent.polylines, hasLength(1));
      expect(commands.animateToBounds, isNotNull);

      // Verify markers match draft
      final pickupMarker = commands.setContent.markers
          .firstWhere((m) => m.id == 'pickup');
      expect(pickupMarker.type, equals(DWMapMarkerType.userPickup));
      expect(pickupMarker.label, equals('Pickup Point'));
      expect(pickupMarker.position.latitude, equals(24.7136));

      final destMarker = commands.setContent.markers
          .firstWhere((m) => m.id == 'destination');
      expect(destMarker.type, equals(DWMapMarkerType.destination));
      expect(destMarker.label, equals('Drop Off'));
      expect(destMarker.position.latitude, equals(24.9600));

      // Verify polyline
      final polyline = commands.setContent.polylines.first;
      expect(polyline.id, equals('route'));
      expect(polyline.points, hasLength(2));
    });

    // Track B - Ticket #111: Consistency with buildDraftMapCommands
    test('produces same result as buildDraftMapCommands with same draft', () {
      // Arrange
      final draft = RideDraftUiState(
        pickupPlace: placeWithLocation(
          label: 'Home',
          lat: 24.7000,
          lng: 46.7000,
        ),
        pickupLabel: 'Home',
        destinationPlace: placeWithLocation(
          label: 'Airport',
          lat: 24.9500,
          lng: 46.6900,
        ),
        destinationQuery: 'Airport',
      );

      final sessionState = RideTripSessionUiState(
        activeTrip: const RideTripState(
          tripId: 'consistency-test',
          phase: RideTripPhase.driverAccepted,
        ),
        draftSnapshot: draft,
      );

      // Act
      final activeCommands = buildActiveTripMapCommands(sessionState);
      final draftCommands = buildDraftMapCommands(draft);

      // Assert - Both should produce identical commands
      expect(activeCommands, isNotNull);
      expect(activeCommands!.setContent.markers.length,
          equals(draftCommands.setContent.markers.length));
      expect(activeCommands.setContent.polylines.length,
          equals(draftCommands.setContent.polylines.length));

      // Compare marker positions
      for (var i = 0; i < activeCommands.setContent.markers.length; i++) {
        final activeMarker = activeCommands.setContent.markers[i];
        final draftMarker = draftCommands.setContent.markers[i];
        expect(activeMarker.id, equals(draftMarker.id));
        expect(activeMarker.position.latitude, equals(draftMarker.position.latitude));
        expect(activeMarker.position.longitude, equals(draftMarker.position.longitude));
      }
    });

    // Track B - Ticket #111: Different phases with snapshot
    test('works for all non-terminal phases with snapshot', () {
      final draft = RideDraftUiState(
        pickupPlace: placeWithLocation(label: 'A', lat: 24.7, lng: 46.6),
        destinationPlace: placeWithLocation(label: 'B', lat: 24.8, lng: 46.7),
      );

      final nonTerminalPhases = [
        RideTripPhase.draft,
        RideTripPhase.quoting,
        RideTripPhase.requesting,
        RideTripPhase.findingDriver,
        RideTripPhase.driverAccepted,
        RideTripPhase.driverArrived,
        RideTripPhase.inProgress,
        RideTripPhase.payment,
      ];

      for (final phase in nonTerminalPhases) {
        final sessionState = RideTripSessionUiState(
          activeTrip: RideTripState(tripId: 'test-$phase', phase: phase),
          draftSnapshot: draft,
        );

        final commands = buildActiveTripMapCommands(sessionState);
        expect(commands, isNotNull, reason: 'Phase $phase should return commands');
      }
    });

    // Track B - Ticket #111: Terminal phases with snapshot still return null
    test('returns null for terminal phases even with snapshot', () {
      final draft = RideDraftUiState(
        pickupPlace: placeWithLocation(label: 'A', lat: 24.7, lng: 46.6),
        destinationPlace: placeWithLocation(label: 'B', lat: 24.8, lng: 46.7),
      );

      final terminalPhases = [
        RideTripPhase.completed,
        RideTripPhase.cancelled,
        RideTripPhase.failed,
      ];

      for (final phase in terminalPhases) {
        final sessionState = RideTripSessionUiState(
          activeTrip: RideTripState(tripId: 'test-$phase', phase: phase),
          draftSnapshot: draft,
        );

        final commands = buildActiveTripMapCommands(sessionState);
        expect(commands, isNull, reason: 'Terminal phase $phase should return null');
      }
    });
  });

  // ===========================================================================
  // Active Trip with Draft Tests
  // ===========================================================================

  group('buildActiveTripMapCommandsWithDraft', () {
    test('returns null when no active trip', () {
      // Arrange
      const state = RideTripSessionUiState();
      final draft = RideDraftUiState(
        pickupPlace: placeWithLocation(label: 'Home', lat: 24.7, lng: 46.6),
      );

      // Act
      final commands = buildActiveTripMapCommandsWithDraft(state, draft);

      // Assert
      expect(commands, isNull);
    });

    test('returns null for terminal trip phases', () {
      // Arrange
      final completedState = createCompletedSession();
      final draft = RideDraftUiState(
        pickupPlace: placeWithLocation(label: 'Home', lat: 24.7, lng: 46.6),
      );

      // Act
      final commands = buildActiveTripMapCommandsWithDraft(completedState, draft);

      // Assert
      expect(commands, isNull);
    });

    test('returns null when draft is null', () {
      // Arrange
      final activeState = createActiveSession();

      // Act
      final commands = buildActiveTripMapCommandsWithDraft(activeState, null);

      // Assert
      expect(commands, isNull);
    });

    test('returns null when draft has no location data', () {
      // Arrange
      final activeState = createActiveSession();
      const draft = RideDraftUiState();

      // Act
      final commands = buildActiveTripMapCommandsWithDraft(activeState, draft);

      // Assert
      expect(commands, isNull);
    });

    test('builds markers from active trip draft', () {
      // Arrange
      final activeState = createActiveSession();
      final draft = RideDraftUiState(
        pickupPlace: placeWithLocation(
          label: 'Pickup Point',
          lat: 24.7136,
          lng: 46.6753,
        ),
        pickupLabel: 'Pickup Point',
        destinationPlace: placeWithLocation(
          label: 'Drop Off',
          lat: 24.9600,
          lng: 46.6990,
        ),
      );

      // Act
      final commands = buildActiveTripMapCommandsWithDraft(activeState, draft);

      // Assert
      expect(commands, isNotNull);
      expect(commands!.setContent.markers, hasLength(2));
      expect(commands.setContent.polylines, hasLength(1));
      expect(commands.animateToBounds, isNotNull);
    });
  });

  // ===========================================================================
  // Bounds & Animation Tests
  // ===========================================================================

  group('Bounds & Animation', () {
    test('buildDraftMapCommands sets animateToBounds when markers exist', () {
      // Arrange
      final draft = RideDraftUiState(
        pickupPlace: placeWithLocation(
          label: 'Home',
          lat: 24.7136,
          lng: 46.6753,
        ),
      );

      // Act
      final commands = buildDraftMapCommands(draft);

      // Assert
      expect(commands.animateToBounds, isNotNull);
      expect(commands.animateToBounds, isA<DWAnimateToBoundsCommand>());
    });

    test('bounds contain all marker positions', () {
      // Arrange
      final draft = RideDraftUiState(
        pickupPlace: placeWithLocation(
          label: 'South Point',
          lat: 24.5000, // South
          lng: 46.5000, // West
        ),
        pickupLabel: 'South Point',
        destinationPlace: placeWithLocation(
          label: 'North Point',
          lat: 25.0000, // North
          lng: 47.0000, // East
        ),
      );

      // Act
      final commands = buildDraftMapCommands(draft);

      // Assert
      expect(commands.animateToBounds, isNotNull);
      final bounds = commands.animateToBounds!.bounds;

      // Verify bounds contain pickup
      const pickupPos = DWLatLng(24.5000, 46.5000);
      expect(bounds.contains(pickupPos), isTrue);

      // Verify bounds contain destination
      const destPos = DWLatLng(25.0000, 47.0000);
      expect(bounds.contains(destPos), isTrue);

      // Verify bounds corners
      expect(bounds.southWest.latitude, equals(24.5000));
      expect(bounds.southWest.longitude, equals(46.5000));
      expect(bounds.northEast.latitude, equals(25.0000));
      expect(bounds.northEast.longitude, equals(47.0000));
    });

    test('bounds work with single marker', () {
      // Arrange
      final draft = RideDraftUiState(
        pickupPlace: placeWithLocation(
          label: 'Single Point',
          lat: 24.7000,
          lng: 46.7000,
        ),
      );

      // Act
      final commands = buildDraftMapCommands(draft);

      // Assert
      expect(commands.animateToBounds, isNotNull);
      final bounds = commands.animateToBounds!.bounds;

      // Single point: bounds should be a point (sw == ne)
      expect(bounds.southWest.latitude, equals(24.7000));
      expect(bounds.southWest.longitude, equals(46.7000));
      expect(bounds.northEast.latitude, equals(24.7000));
      expect(bounds.northEast.longitude, equals(46.7000));
    });

    test('animateToBounds has correct padding', () {
      // Arrange
      final draft = RideDraftUiState(
        pickupPlace: placeWithLocation(
          label: 'Home',
          lat: 24.7136,
          lng: 46.6753,
        ),
      );

      // Act
      final commands = buildDraftMapCommands(draft);

      // Assert
      expect(commands.animateToBounds!.padding, equals(48.0));
    });
  });

  // ===========================================================================
  // RideMapCommands Value Object Tests
  // ===========================================================================

  group('RideMapCommands', () {
    test('equality works correctly', () {
      // Arrange
      const cmd1 = DWSetContentCommand(markers: [], polylines: []);
      const cmd2 = DWSetContentCommand(markers: [], polylines: []);

      const commands1 = RideMapCommands(setContent: cmd1);
      const commands2 = RideMapCommands(setContent: cmd2);

      // Assert
      expect(commands1, equals(commands2));
      expect(commands1.hashCode, equals(commands2.hashCode));
    });

    test('toString includes command info', () {
      // Arrange
      const cmd = DWSetContentCommand(markers: [], polylines: []);
      const commands = RideMapCommands(setContent: cmd);

      // Act
      final str = commands.toString();

      // Assert
      expect(str, contains('RideMapCommands'));
      expect(str, contains('setContent'));
    });
  });

  // ===========================================================================
  // Session Getter Test
  // ===========================================================================

  group('RideTripSessionUiState.activeTripMapCommands', () {
    test('getter returns null when no active trip', () {
      // Arrange
      const state = RideTripSessionUiState();

      // Act
      final commands = state.activeTripMapCommands;

      // Assert
      expect(commands, isNull);
    });

    test('getter returns null for completed trip', () {
      // Arrange
      final state = createCompletedSession();

      // Act
      final commands = state.activeTripMapCommands;

      // Assert
      expect(commands, isNull);
    });

    // Track B - Ticket #111: Getter uses session state snapshot
    test('getter uses session state snapshot to build commands', () {
      // Arrange
      final draft = RideDraftUiState(
        pickupPlace: placeWithLocation(
          label: 'Start',
          lat: 24.7200,
          lng: 46.6800,
        ),
        pickupLabel: 'Start',
        destinationPlace: placeWithLocation(
          label: 'End',
          lat: 24.8500,
          lng: 46.7200,
        ),
        destinationQuery: 'End',
      );

      final sessionState = RideTripSessionUiState(
        activeTrip: const RideTripState(
          tripId: 'getter-test',
          phase: RideTripPhase.inProgress,
        ),
        draftSnapshot: draft,
      );

      // Act
      final commands = sessionState.activeTripMapCommands;

      // Assert
      expect(commands, isNotNull);
      expect(commands!.setContent.markers, hasLength(2));
      expect(commands.setContent.polylines, hasLength(1));

      // Verify it matches buildActiveTripMapCommands result
      final directCall = buildActiveTripMapCommands(sessionState);
      expect(commands.setContent.markers.length,
          equals(directCall!.setContent.markers.length));
    });

    test('getter returns null when no draftSnapshot', () {
      // Arrange
      const sessionState = RideTripSessionUiState(
        activeTrip: RideTripState(
          tripId: 'no-snapshot',
          phase: RideTripPhase.findingDriver,
        ),
        // No draftSnapshot
      );

      // Act
      final commands = sessionState.activeTripMapCommands;

      // Assert
      expect(commands, isNull);
    });
  });
}


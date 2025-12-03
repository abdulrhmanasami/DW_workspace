/// Ride Active Trip Screen Widget Tests - Track B Ticket #112
/// Purpose: Test RideMapCommands integration in Active Trip screen
/// Created by: Track B - Ticket #112
/// Last updated: 2025-11-30
///
/// Tests cover:
/// - activeTripMapCommands returns correct commands for active phases
/// - activeTripMapCommands returns null for terminal phases
/// - Placeholder display when commands are null
/// - Consistency between draftMapCommands and activeTripMapCommands

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Localization
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';

import 'package:mobility_shims/mobility_shims.dart';
import 'package:maps_shims/maps_shims.dart';

import 'package:delivery_ways_clean/screens/mobility/ride_active_trip_screen.dart';
import 'package:delivery_ways_clean/state/mobility/ride_draft_state.dart';
import 'package:delivery_ways_clean/state/mobility/ride_trip_session.dart';
import 'package:delivery_ways_clean/state/mobility/ride_map_commands_builder.dart';
import 'package:delivery_ways_clean/state/mobility/ride_map_port_providers.dart';
import 'package:delivery_ways_clean/widgets/ride_map_from_commands.dart';
import 'package:delivery_ways_clean/widgets/mobility/ride_trip_map_view.dart';
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
  group('Active Trip Map Integration - Ticket #112', () {
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

    // Helper to create a valid draft with locations
    RideDraftUiState createValidDraft() {
      final pickup = createPlaceWithLocation('Home', 24.7136, 46.6753);
      final destination = createPlaceWithLocation('Work', 24.9500, 46.7100);
      return RideDraftUiState(
        pickupLabel: 'Home',
        pickupPlace: pickup,
        destinationQuery: 'Work',
        destinationPlace: destination,
      );
    }

    group('activeTripMapCommands getter', () {
      test('returns null when no active trip', () {
        // Arrange
        const state = RideTripSessionUiState();

        // Act
        final commands = state.activeTripMapCommands;

        // Assert
        expect(commands, isNull);
      });

      test('returns null when trip is in terminal phase (completed)', () {
        // Arrange
        final completedTrip = RideTripState(
          tripId: 'test-123',
          phase: RideTripPhase.completed,
        );
        final state = RideTripSessionUiState(
          activeTrip: completedTrip,
          draftSnapshot: createValidDraft(),
        );

        // Act
        final commands = state.activeTripMapCommands;

        // Assert
        expect(commands, isNull);
      });

      test('returns null when trip is in terminal phase (cancelled)', () {
        // Arrange
        final cancelledTrip = RideTripState(
          tripId: 'test-123',
          phase: RideTripPhase.cancelled,
        );
        final state = RideTripSessionUiState(
          activeTrip: cancelledTrip,
          draftSnapshot: createValidDraft(),
        );

        // Act
        final commands = state.activeTripMapCommands;

        // Assert
        expect(commands, isNull);
      });

      test('returns null when trip is in terminal phase (failed)', () {
        // Arrange
        final failedTrip = RideTripState(
          tripId: 'test-123',
          phase: RideTripPhase.failed,
        );
        final state = RideTripSessionUiState(
          activeTrip: failedTrip,
          draftSnapshot: createValidDraft(),
        );

        // Act
        final commands = state.activeTripMapCommands;

        // Assert
        expect(commands, isNull);
      });

      test('returns null when no draftSnapshot available', () {
        // Arrange
        final activeTrip = RideTripState(
          tripId: 'test-123',
          phase: RideTripPhase.findingDriver,
        );
        final state = RideTripSessionUiState(activeTrip: activeTrip);

        // Act
        final commands = state.activeTripMapCommands;

        // Assert
        expect(commands, isNull);
      });

      test('returns commands for findingDriver phase', () {
        // Arrange
        final activeTrip = RideTripState(
          tripId: 'test-123',
          phase: RideTripPhase.findingDriver,
        );
        final state = RideTripSessionUiState(
          activeTrip: activeTrip,
          draftSnapshot: createValidDraft(),
        );

        // Act
        final commands = state.activeTripMapCommands;

        // Assert
        expect(commands, isNotNull);
        expect(commands!.setContent.markers.length, 2);
      });

      test('returns commands for driverAccepted phase', () {
        // Arrange
        final activeTrip = RideTripState(
          tripId: 'test-123',
          phase: RideTripPhase.driverAccepted,
        );
        final state = RideTripSessionUiState(
          activeTrip: activeTrip,
          draftSnapshot: createValidDraft(),
        );

        // Act
        final commands = state.activeTripMapCommands;

        // Assert
        expect(commands, isNotNull);
      });

      test('returns commands for driverArrived phase', () {
        // Arrange
        final activeTrip = RideTripState(
          tripId: 'test-123',
          phase: RideTripPhase.driverArrived,
        );
        final state = RideTripSessionUiState(
          activeTrip: activeTrip,
          draftSnapshot: createValidDraft(),
        );

        // Act
        final commands = state.activeTripMapCommands;

        // Assert
        expect(commands, isNotNull);
      });

      test('returns commands for inProgress phase', () {
        // Arrange
        final activeTrip = RideTripState(
          tripId: 'test-123',
          phase: RideTripPhase.inProgress,
        );
        final state = RideTripSessionUiState(
          activeTrip: activeTrip,
          draftSnapshot: createValidDraft(),
        );

        // Act
        final commands = state.activeTripMapCommands;

        // Assert
        expect(commands, isNotNull);
      });

      test('returns commands for payment phase', () {
        // Arrange
        final activeTrip = RideTripState(
          tripId: 'test-123',
          phase: RideTripPhase.payment,
        );
        final state = RideTripSessionUiState(
          activeTrip: activeTrip,
          draftSnapshot: createValidDraft(),
        );

        // Act
        final commands = state.activeTripMapCommands;

        // Assert
        expect(commands, isNotNull);
      });
    });

    group('All non-terminal phases return valid commands', () {
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
        test('phase $phase returns valid commands', () {
          // Arrange
          final activeTrip = RideTripState(tripId: 'test-123', phase: phase);
          final state = RideTripSessionUiState(
            activeTrip: activeTrip,
            draftSnapshot: createValidDraft(),
          );

          // Act
          final commands = state.activeTripMapCommands;

          // Assert
          expect(commands, isNotNull, reason: 'Phase $phase should return commands');
          expect(commands!.setContent.markers.isNotEmpty, isTrue);
        });
      }
    });

    group('All terminal phases return null', () {
      final terminalPhases = [
        RideTripPhase.completed,
        RideTripPhase.cancelled,
        RideTripPhase.failed,
      ];

      for (final phase in terminalPhases) {
        test('phase $phase returns null', () {
          // Arrange
          final activeTrip = RideTripState(tripId: 'test-123', phase: phase);
          final state = RideTripSessionUiState(
            activeTrip: activeTrip,
            draftSnapshot: createValidDraft(),
          );

          // Act
          final commands = state.activeTripMapCommands;

          // Assert
          expect(commands, isNull, reason: 'Terminal phase $phase should return null');
        });
      }
    });

    group('Commands consistency', () {
      test('activeTripMapCommands and draftMapCommands produce identical results', () {
        // Arrange
        final draft = createValidDraft();
        final activeTrip = RideTripState(
          tripId: 'test-123',
          phase: RideTripPhase.findingDriver,
        );
        final state = RideTripSessionUiState(
          activeTrip: activeTrip,
          draftSnapshot: draft,
        );

        // Act
        final activeCommands = state.activeTripMapCommands;
        final draftCommands = state.draftMapCommands;

        // Assert
        expect(activeCommands, isNotNull);
        expect(draftCommands, isNotNull);

        // Both should have the same number of markers
        expect(
          activeCommands!.setContent.markers.length,
          equals(draftCommands!.setContent.markers.length),
        );

        // Both should have the same number of polylines
        expect(
          activeCommands.setContent.polylines.length,
          equals(draftCommands.setContent.polylines.length),
        );

        // Both should have same bounds
        expect(
          activeCommands.animateToBounds?.bounds.southWest.latitude,
          equals(draftCommands.animateToBounds?.bounds.southWest.latitude),
        );
      });

      test('both getters use the same frozen draftSnapshot', () {
        // Arrange - Create state with frozen draft
        final draft = createValidDraft();
        final activeTrip = RideTripState(
          tripId: 'test-123',
          phase: RideTripPhase.inProgress,
        );
        final state = RideTripSessionUiState(
          activeTrip: activeTrip,
          draftSnapshot: draft,
        );

        // Act
        final activeCommands = state.activeTripMapCommands;
        final draftCommands = state.draftMapCommands;

        // Assert - Marker positions should be identical
        final activePickup = activeCommands!.setContent.markers
            .firstWhere((m) => m.id == 'pickup');
        final draftPickup = draftCommands!.setContent.markers
            .firstWhere((m) => m.id == 'pickup');

        expect(activePickup.position.latitude, equals(draftPickup.position.latitude));
        expect(activePickup.position.longitude, equals(draftPickup.position.longitude));
      });
    });

    group('buildActiveTripMapCommands function', () {
      test('returns null when state has no activeTrip', () {
        // Arrange
        const state = RideTripSessionUiState();

        // Act
        final commands = buildActiveTripMapCommands(state);

        // Assert
        expect(commands, isNull);
      });

      test('returns null when state has no draftSnapshot', () {
        // Arrange
        final activeTrip = RideTripState(
          tripId: 'test-123',
          phase: RideTripPhase.findingDriver,
        );
        final state = RideTripSessionUiState(activeTrip: activeTrip);

        // Act
        final commands = buildActiveTripMapCommands(state);

        // Assert
        expect(commands, isNull);
      });

      test('returns commands when activeTrip and draftSnapshot are present', () {
        // Arrange
        final activeTrip = RideTripState(
          tripId: 'test-123',
          phase: RideTripPhase.findingDriver,
        );
        final state = RideTripSessionUiState(
          activeTrip: activeTrip,
          draftSnapshot: createValidDraft(),
        );

        // Act
        final commands = buildActiveTripMapCommands(state);

        // Assert
        expect(commands, isNotNull);
        expect(commands!.setContent.markers.length, 2);
        expect(commands.setContent.polylines.length, 1);
      });
    });

    group('RideMapFromCommands edge cases', () {
      testWidgets('handles empty markers gracefully', (tester) async {
        // Arrange
        final commands = RideMapCommands(
          setContent: const DWSetContentCommand(
            markers: [],
            polylines: [],
          ),
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RideMapFromCommands(commands: commands),
            ),
          ),
        );

        // Assert - Should render without errors
        expect(find.byType(RideMapFromCommands), findsOneWidget);
        expect(find.byType(MapWidget), findsOneWidget);
      });

      testWidgets('uses first marker position when no bounds', (tester) async {
        // Arrange
        final commands = RideMapCommands(
          setContent: DWSetContentCommand(
            markers: [
              DWMapMarker(
                id: 'test',
                position: const DWLatLng(24.7136, 46.6753),
                type: DWMapMarkerType.userPickup,
              ),
            ],
            polylines: const [],
          ),
          // No animateToBounds
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RideMapFromCommands(commands: commands),
            ),
          ),
        );

        // Assert - Should render without errors
        expect(find.byType(MapWidget), findsOneWidget);
      });

      testWidgets('falls back to default location when no data', (tester) async {
        // Arrange
        final commands = RideMapCommands(
          setContent: const DWSetContentCommand(
            markers: [],
            polylines: [],
          ),
          // No animateToBounds and no markers
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RideMapFromCommands(commands: commands),
            ),
          ),
        );

        // Assert - Should render without errors (using Riyadh default)
        expect(find.byType(MapWidget), findsOneWidget);
      });
    });

    group('RideMapPlaceholder for Active Trip', () {
      testWidgets('shows message without spinner for terminal states', (tester) async {
        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: RideMapPlaceholder(
                message: 'Trip ended',
                showLoadingIndicator: false,
              ),
            ),
          ),
        );

        // Assert
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('Trip ended'), findsOneWidget);
      });
    });

    group('RideTripMapView Integration - Ticket #204', () {
      testWidgets('RideActiveTripScreen contains RideTripMapView widget', (tester) async {
        // Create a minimal mock setup - we just need to verify the widget exists
        // The actual functionality is tested separately in ride_trip_map_view_test.dart

        // For this integration test, we create a simple container with basic overrides
        final container = ProviderContainer(
          overrides: [
            // Mock the map port
            rideMapPortProvider.overrideWith((ref) => _RecordingMapPort()),
            // Mock the session with an active trip to show RideTripMapView
            rideTripSessionProvider.overrideWith(
              (ref) => RideTripSessionController(ref)..state = RideTripSessionUiState(
                activeTrip: RideTripState(
                  tripId: 'test-trip-123',
                  phase: RideTripPhase.driverAccepted,
                ),
              ),
            ),
          ],
        );

        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale('en'),
              home: RideActiveTripScreen(),
            ),
          ),
        );

        // Should contain RideTripMapView widget in the layout
        expect(find.byType(RideTripMapView), findsOneWidget);
      });
    });
  });
}


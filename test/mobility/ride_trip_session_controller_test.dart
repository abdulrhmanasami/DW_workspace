/// RideTripSessionController Unit Tests - Track B Tickets #17, #22, #23, #24, #108, #113, #117, #124
/// Purpose: Safety net tests for RideTripSessionController before deeper integration
/// Created by: Track B - Ticket #17
/// Last updated: 2025-12-01
///
/// Extended in Ticket #24 with:
/// - cancelActiveTrip() tests (FSM integration)
/// - rateCurrentTrip() tests
/// - null-safety edge case tests
///
/// Extended in Ticket #108 with:
/// - archiveTrip() tests with extended parameters (serviceName, originLabel, paymentMethodLabel)
///
/// Verified in Ticket #113:
/// - startFromDraft() behavior for Happy Path flow
/// - FSM transitions: draft -> quoting -> requesting -> findingDriver
/// - draftSnapshot population (Ticket #111)
/// - tripSummary population (Ticket #105)
///
/// Extended in Ticket #117 with:
/// - completeCurrentTrip() tests (archive + clear in one API)

import 'package:flutter_test/flutter_test.dart';

import 'package:mobility_shims/mobility_shims.dart' as mobility;
import 'package:mobility_shims/src/ride_trip_fsm.dart';
import 'package:mobility_shims/src/place_models.dart';
import 'package:mobility_shims/location/models.dart';
import 'package:maps_shims/maps_shims.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:delivery_ways_clean/state/mobility/ride_draft_state.dart';
import 'package:delivery_ways_clean/state/mobility/ride_map_port_providers.dart';
import 'package:delivery_ways_clean/state/mobility/ride_map_projection.dart';
import 'package:delivery_ways_clean/state/mobility/ride_trip_session.dart';
import 'package:pricing_shims/pricing_shims.dart' as pricing;
import 'package:payments/models.dart';
import 'package:delivery_ways_clean/state/mobility/ride_pricing_providers.dart';

// Mock RidePricingService for testing
class MockRidePricingService implements pricing.RidePricingService {
  MockRidePricingService({
    this.baseLatency = Duration.zero,
  });

  final Duration baseLatency;

  pricing.RideQuoteResult? result;
  Duration delay = Duration.zero;
  int callCount = 0;

  @override
  Future<pricing.RideQuoteResult> requestQuote(pricing.RideQuoteRequest request) async {
    callCount++;
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    return result ?? const pricing.RideQuoteResult.failure(pricing.RideQuoteFailureReason.networkError);
  }
}

/// Helper to create mobility.RideQuote for testing
mobility.RideQuote createMobilityTestQuote() {
  return mobility.RideQuote(
    quoteId: 'test-quote-123',
    request: const mobility.RideQuoteRequest(
      pickup: mobility.LocationPoint(latitude: 24.7136, longitude: 46.6753),
      dropoff: mobility.LocationPoint(latitude: 24.7236, longitude: 46.6853),
    ),
    options: const [
      mobility.RideQuoteOption(
        id: 'economy',
        category: mobility.RideVehicleCategory.economy,
        displayName: 'Economy',
        etaMinutes: 15,
        priceMinorUnits: 1800,
        currencyCode: 'SAR',
        isRecommended: true,
      ),
      mobility.RideQuoteOption(
        id: 'xl',
        category: mobility.RideVehicleCategory.xl,
        displayName: 'XL',
        etaMinutes: 20,
        priceMinorUnits: 2500,
        currencyCode: 'SAR',
        isRecommended: false,
      ),
    ],
  );
}

// Helper to create RideTripSessionController using ProviderContainer (official way)
RideTripSessionController _createRideTripSessionControllerForTest({
  ProviderContainer? container,
}) {
  // Create container if not provided
  final c = container ?? ProviderContainer();
  if (container == null) {
    // Dispose when test ends
    addTearDown(c.dispose);
  }

  // Get controller from the official provider
  final controller = c.read(rideTripSessionProvider.notifier);
  return controller;
}

// Recording MapPort for testing command recording
class _RecordingMapPort implements MapPort {
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

// Helper to create RideTripSessionController with overridden MapPort for testing
RideTripSessionController _createRideTripSessionControllerWithMapPort(
  _RecordingMapPort port, {
  ProviderContainer? container,
}) {
  final c = container ?? ProviderContainer(
    overrides: [
      // Override the MapPort provider with our recording port
      rideMapPortProvider.overrideWithValue(port),
    ],
  );

  if (container == null) {
    addTearDown(c.dispose);
  }

  return c.read(rideTripSessionProvider.notifier);
}

void main() {
  group('RideTripSessionController', () {
    group('initial state', () {
      test('has null activeTrip', () {
        final controller = _createRideTripSessionControllerForTest();

        expect(controller.state.activeTrip, isNull);
      });

      test('hasActiveTrip is false', () {
        final controller = _createRideTripSessionControllerForTest();

        expect(controller.hasActiveTrip, isFalse);
      });
    });

    group('startFromDraft', () {
      test('creates activeTrip with phase = findingDriver', () {
        final controller = _createRideTripSessionControllerForTest();
        const draft = RideDraftUiState(
          pickupLabel: 'Current location',
          destinationQuery: 'Downtown',
          selectedOptionId: 'economy',
        );

        controller.startFromDraft(draft);
        final state = controller.state;

        expect(state.activeTrip, isNotNull);
        expect(state.activeTrip!.tripId, isNotEmpty);
        expect(state.activeTrip!.phase, RideTripPhase.findingDriver);
      });

      test('generates unique tripId', () {
        final controller1 = _createRideTripSessionControllerForTest();
        final controller2 = _createRideTripSessionControllerForTest();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        controller1.startFromDraft(draft);
        controller2.startFromDraft(draft);

        expect(
          controller1.state.activeTrip!.tripId,
          isNot(equals(controller2.state.activeTrip!.tripId)),
        );
      });

      test('hasActiveTrip becomes true after start', () {
        final controller = _createRideTripSessionControllerForTest();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        expect(controller.hasActiveTrip, isFalse);

        controller.startFromDraft(draft);

        expect(controller.hasActiveTrip, isTrue);
      });

      // Track B - Ticket #111: Draft snapshot freezing tests
      test('freezes draft snapshot on session state', () {
        final controller = _createRideTripSessionControllerForTest();
        final pickupPlace = MobilityPlace(
          label: 'Pickup Location',
          location: LocationPoint(
            latitude: 24.7136,
            longitude: 46.6753,
            accuracyMeters: 10,
            timestamp: DateTime.now(),
          ),
        );
        final destinationPlace = MobilityPlace(
          label: 'Destination',
          location: LocationPoint(
            latitude: 24.9500,
            longitude: 46.7100,
            accuracyMeters: 10,
            timestamp: DateTime.now(),
          ),
        );
        final draft = RideDraftUiState(
          pickupLabel: 'Pickup Location',
          pickupPlace: pickupPlace,
          destinationQuery: 'Destination',
          destinationPlace: destinationPlace,
          selectedOptionId: 'economy',
          paymentMethodId: 'card-123',
        );

        controller.startFromDraft(draft);
        final state = controller.state;

        // Assert draftSnapshot is populated
        expect(state.draftSnapshot, isNotNull);
        expect(state.draftSnapshot!.pickupLabel, equals('Pickup Location'));
        expect(state.draftSnapshot!.pickupPlace, equals(pickupPlace));
        expect(state.draftSnapshot!.destinationQuery, equals('Destination'));
        expect(state.draftSnapshot!.destinationPlace, equals(destinationPlace));
        expect(state.draftSnapshot!.selectedOptionId, equals('economy'));
        expect(state.draftSnapshot!.paymentMethodId, equals('card-123'));
      });

      test('draftSnapshot equals the draft passed to startFromDraft', () {
        final controller = _createRideTripSessionControllerForTest();
        const draft = RideDraftUiState(
          pickupLabel: 'Home',
          destinationQuery: 'Office',
          selectedOptionId: 'xl',
        );

        controller.startFromDraft(draft);

        expect(controller.state.draftSnapshot, equals(draft));
      });
    });

    group('applyEvent', () {
      test('transitions phases correctly through happy path', () {
        final controller = _createRideTripSessionControllerForTest();
        const draft = RideDraftUiState(destinationQuery: 'Downtown');

        controller.startFromDraft(draft);
        expect(controller.state.activeTrip!.phase, RideTripPhase.findingDriver);

        // driverAccepted
        controller.applyEvent(RideTripEvent.driverAccepted);
        expect(controller.state.activeTrip!.phase, RideTripPhase.driverAccepted);

        // driverArrived
        controller.applyEvent(RideTripEvent.driverArrived);
        expect(controller.state.activeTrip!.phase, RideTripPhase.driverArrived);

        // startTrip -> inProgress
        controller.applyEvent(RideTripEvent.startTrip);
        expect(controller.state.activeTrip!.phase, RideTripPhase.inProgress);

        // startPayment
        controller.applyEvent(RideTripEvent.startPayment);
        expect(controller.state.activeTrip!.phase, RideTripPhase.payment);

        // complete
        controller.applyEvent(RideTripEvent.complete);
        expect(controller.state.activeTrip!.phase, RideTripPhase.completed);
      });

      test('preserves tripId across transitions', () {
        final controller = _createRideTripSessionControllerForTest();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        controller.startFromDraft(draft);
        final originalTripId = controller.state.activeTrip!.tripId;

        controller.applyEvent(RideTripEvent.driverAccepted);
        controller.applyEvent(RideTripEvent.driverArrived);
        controller.applyEvent(RideTripEvent.startTrip);

        expect(controller.state.activeTrip!.tripId, equals(originalTripId));
      });

      test('does not throw when applied on null activeTrip', () {
        final controller = _createRideTripSessionControllerForTest();
        expect(controller.state.activeTrip, isNull);

        // Should not throw
        controller.applyEvent(RideTripEvent.complete);

        expect(controller.state.activeTrip, isNull);
      });

      test('ignores invalid transitions silently', () {
        final controller = _createRideTripSessionControllerForTest();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        controller.startFromDraft(draft);
        expect(controller.state.activeTrip!.phase, RideTripPhase.findingDriver);

        // Invalid: startTrip from findingDriver (should be after driverArrived)
        controller.applyEvent(RideTripEvent.startTrip);

        // Phase should remain unchanged
        expect(controller.state.activeTrip!.phase, RideTripPhase.findingDriver);
      });

      test('cancel from findingDriver leads to cancelled', () {
        final controller = _createRideTripSessionControllerForTest();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        controller.startFromDraft(draft);
        expect(controller.state.activeTrip!.phase, RideTripPhase.findingDriver);

        controller.applyEvent(RideTripEvent.cancel);

        expect(controller.state.activeTrip!.phase, RideTripPhase.cancelled);
      });

      test('fail event transitions to failed', () {
        final controller = _createRideTripSessionControllerForTest();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        controller.startFromDraft(draft);
        expect(controller.state.activeTrip!.phase, RideTripPhase.findingDriver);

        controller.applyEvent(RideTripEvent.fail);

        expect(controller.state.activeTrip!.phase, RideTripPhase.failed);
      });
    });

    group('hasActiveTrip', () {
      test('returns false for terminal phase: completed', () {
        final controller = _createRideTripSessionControllerForTest();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        controller.startFromDraft(draft);
        controller.applyEvent(RideTripEvent.driverAccepted);
        controller.applyEvent(RideTripEvent.driverArrived);
        controller.applyEvent(RideTripEvent.startTrip);
        controller.applyEvent(RideTripEvent.startPayment);
        controller.applyEvent(RideTripEvent.complete);

        expect(controller.state.activeTrip!.phase, RideTripPhase.completed);
        expect(controller.hasActiveTrip, isFalse);
      });

      test('returns false for terminal phase: cancelled', () {
        final controller = _createRideTripSessionControllerForTest();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        controller.startFromDraft(draft);
        controller.applyEvent(RideTripEvent.cancel);

        expect(controller.state.activeTrip!.phase, RideTripPhase.cancelled);
        expect(controller.hasActiveTrip, isFalse);
      });

      test('returns false for terminal phase: failed', () {
        final controller = _createRideTripSessionControllerForTest();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        controller.startFromDraft(draft);
        controller.applyEvent(RideTripEvent.fail);

        expect(controller.state.activeTrip!.phase, RideTripPhase.failed);
        expect(controller.hasActiveTrip, isFalse);
      });
    });

    group('clear', () {
      test('resets session to empty state', () {
        final controller = _createRideTripSessionControllerForTest();
        const draft = RideDraftUiState(destinationQuery: 'X');

        controller.startFromDraft(draft);
        expect(controller.state.activeTrip, isNotNull);
        expect(controller.hasActiveTrip, isTrue);

        controller.clear();

        expect(controller.state.activeTrip, isNull);
        expect(controller.hasActiveTrip, isFalse);
      });

      test('clear on fresh controller does nothing harmful', () {
        final controller = _createRideTripSessionControllerForTest();

        controller.clear();

        expect(controller.state.activeTrip, isNull);
      });

      // Track B - Ticket #111: Clear should also clear draftSnapshot
      test('clears draftSnapshot when session is cleared', () {
        final controller = _createRideTripSessionControllerForTest();
        const draft = RideDraftUiState(
          pickupLabel: 'Home',
          destinationQuery: 'Office',
        );

        controller.startFromDraft(draft);
        expect(controller.state.draftSnapshot, isNotNull);

        controller.clear();

        expect(controller.state.draftSnapshot, isNull);
      });
    });

    group('cancelActiveTrip - Track B Ticket #22, #24, #95', () {
      // Ticket #95: cancelActiveTrip now keeps trip in cancelled state instead of clearing
      test('returns true and keeps activeTrip in cancelled phase', () async {
        final controller = _createRideTripSessionControllerForTest();
        const draft = RideDraftUiState(destinationQuery: 'Test Cancel');

        controller.startFromDraft(draft);
        expect(controller.state.activeTrip!.phase, RideTripPhase.findingDriver);

        final result = await controller.cancelActiveTrip();

        expect(result, isTrue);
        // Ticket #95: Trip stays in cancelled state, not cleared
        expect(controller.state.activeTrip, isNotNull);
        expect(controller.state.activeTrip!.phase, RideTripPhase.cancelled);
      });

      test('returns false when activeTrip is null', () async {
        final controller = _createRideTripSessionControllerForTest();
        expect(controller.state.activeTrip, isNull);

        final result = await controller.cancelActiveTrip();

        expect(result, isFalse);
        expect(controller.state.activeTrip, isNull);
      });

      test('returns false when phase is inProgress (not cancellable)', () async {
        final controller = _createRideTripSessionControllerForTest();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        controller.startFromDraft(draft);
        controller.applyEvent(RideTripEvent.driverAccepted);
        controller.applyEvent(RideTripEvent.driverArrived);
        controller.applyEvent(RideTripEvent.startTrip);
        expect(controller.state.activeTrip!.phase, RideTripPhase.inProgress);

        final result = await controller.cancelActiveTrip();

        // Cancel from inProgress is invalid per FSM
        expect(result, isFalse);
        // Trip should remain unchanged (not cleared)
        expect(controller.state.activeTrip!.phase, RideTripPhase.inProgress);
      });

      test('returns false when phase is payment (not cancellable)', () async {
        final controller = _createRideTripSessionControllerForTest();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        controller.startFromDraft(draft);
        controller.applyEvent(RideTripEvent.driverAccepted);
        controller.applyEvent(RideTripEvent.driverArrived);
        controller.applyEvent(RideTripEvent.startTrip);
        controller.applyEvent(RideTripEvent.startPayment);
        expect(controller.state.activeTrip!.phase, RideTripPhase.payment);

        final result = await controller.cancelActiveTrip();

        expect(result, isFalse);
        expect(controller.state.activeTrip!.phase, RideTripPhase.payment);
      });

      test('returns false when already completed', () async {
        final controller = _createRideTripSessionControllerForTest();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        controller.startFromDraft(draft);
        controller.applyEvent(RideTripEvent.driverAccepted);
        controller.applyEvent(RideTripEvent.driverArrived);
        controller.applyEvent(RideTripEvent.startTrip);
        controller.applyEvent(RideTripEvent.startPayment);
        controller.applyEvent(RideTripEvent.complete);
        expect(controller.state.activeTrip!.phase, RideTripPhase.completed);

        final result = await controller.cancelActiveTrip();

        expect(result, isFalse);
        expect(controller.state.activeTrip!.phase, RideTripPhase.completed);
      });

      // Ticket #95: Trip stays in cancelled state after cancel
      test('cancels successfully from driverAccepted phase', () async {
        final controller = _createRideTripSessionControllerForTest();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        controller.startFromDraft(draft);
        controller.applyEvent(RideTripEvent.driverAccepted);
        expect(controller.state.activeTrip!.phase, RideTripPhase.driverAccepted);

        final result = await controller.cancelActiveTrip();

        expect(result, isTrue);
        expect(controller.state.activeTrip, isNotNull);
        expect(controller.state.activeTrip!.phase, RideTripPhase.cancelled);
      });

      // Ticket #95: Trip stays in cancelled state after cancel
      test('cancels successfully from driverArrived phase', () async {
        final controller = _createRideTripSessionControllerForTest();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        controller.startFromDraft(draft);
        controller.applyEvent(RideTripEvent.driverAccepted);
        controller.applyEvent(RideTripEvent.driverArrived);
        expect(controller.state.activeTrip!.phase, RideTripPhase.driverArrived);

        final result = await controller.cancelActiveTrip();

        expect(result, isTrue);
        expect(controller.state.activeTrip, isNotNull);
        expect(controller.state.activeTrip!.phase, RideTripPhase.cancelled);
      });
    });

    group('rateCurrentTrip - Track B Ticket #23, #24', () {
      test('sets driverRating in state', () {
        final controller = _createRideTripSessionControllerForTest();
        const draft = RideDraftUiState(destinationQuery: 'Test Rating');

        controller.startFromDraft(draft);
        expect(controller.state.driverRating, isNull);

        controller.rateCurrentTrip(4);

        expect(controller.state.driverRating, 4);
      });

      test('clamps rating to 1-5 range (minimum)', () {
        final controller = _createRideTripSessionControllerForTest();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        controller.startFromDraft(draft);
        controller.rateCurrentTrip(0);

        expect(controller.state.driverRating, 1);
      });

      test('clamps rating to 1-5 range (maximum)', () {
        final controller = _createRideTripSessionControllerForTest();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        controller.startFromDraft(draft);
        controller.rateCurrentTrip(10);

        expect(controller.state.driverRating, 5);
      });

      test('does nothing when activeTrip is null', () {
        final controller = _createRideTripSessionControllerForTest();
        expect(controller.state.activeTrip, isNull);
        expect(controller.state.driverRating, isNull);

        controller.rateCurrentTrip(5);

        expect(controller.state.driverRating, isNull);
      });

      test('preserves activeTrip when setting rating', () {
        final controller = _createRideTripSessionControllerForTest();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        controller.startFromDraft(draft);
        final tripBefore = controller.state.activeTrip;

        controller.rateCurrentTrip(3);

        expect(controller.state.activeTrip?.tripId, tripBefore?.tripId);
        expect(controller.state.activeTrip?.phase, tripBefore?.phase);
        expect(controller.state.driverRating, 3);
      });

      test('can update rating multiple times', () {
        final controller = _createRideTripSessionControllerForTest();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        controller.startFromDraft(draft);

        controller.rateCurrentTrip(3);
        expect(controller.state.driverRating, 3);

        controller.rateCurrentTrip(5);
        expect(controller.state.driverRating, 5);

        controller.rateCurrentTrip(1);
        expect(controller.state.driverRating, 1);
      });
    });

    // =========================================================================
    // archiveTrip Tests - Track B Ticket #96, #108
    // =========================================================================
    group('archiveTrip - Track B Ticket #96, #108', () {
      test('archives trip to history with basic data', () {
        final controller = _createRideTripSessionControllerForTest();
        const draft = RideDraftUiState(destinationQuery: 'Mall');

        controller.startFromDraft(draft);
        // Move to completed state
        controller.applyEvent(RideTripEvent.driverAccepted);
        controller.applyEvent(RideTripEvent.driverArrived);
        controller.applyEvent(RideTripEvent.startTrip);
        controller.applyEvent(RideTripEvent.startPayment);
        controller.applyEvent(RideTripEvent.complete);

        expect(controller.state.historyTrips, isEmpty);

        controller.archiveTrip(
          destinationLabel: 'Mall',
          amountFormatted: 'SAR 25.00',
        );

        expect(controller.state.historyTrips, hasLength(1));
        expect(controller.state.historyTrips.first.destinationLabel, 'Mall');
        expect(controller.state.historyTrips.first.amountFormatted, 'SAR 25.00');
      });

      test('archives trip with extended data (Ticket #108)', () {
        final controller = _createRideTripSessionControllerForTest();
        const draft = RideDraftUiState(destinationQuery: 'Airport');

        controller.startFromDraft(draft);
        controller.applyEvent(RideTripEvent.driverAccepted);
        controller.applyEvent(RideTripEvent.driverArrived);
        controller.applyEvent(RideTripEvent.startTrip);
        controller.applyEvent(RideTripEvent.startPayment);
        controller.applyEvent(RideTripEvent.complete);

        controller.archiveTrip(
          destinationLabel: 'Airport',
          amountFormatted: 'SAR 45.00',
          serviceName: 'Economy',
          originLabel: 'Home',
          paymentMethodLabel: 'Visa ••4242',
        );

        expect(controller.state.historyTrips, hasLength(1));
        final entry = controller.state.historyTrips.first;
        expect(entry.destinationLabel, 'Airport');
        expect(entry.amountFormatted, 'SAR 45.00');
        expect(entry.serviceName, 'Economy');
        expect(entry.originLabel, 'Home');
        expect(entry.paymentMethodLabel, 'Visa ••4242');
      });

      test('new trips are inserted at top of history list', () {
        final controller = _createRideTripSessionControllerForTest();
        
        // First trip
        const draft1 = RideDraftUiState(destinationQuery: 'Mall');
        controller.startFromDraft(draft1);
        controller.applyEvent(RideTripEvent.driverAccepted);
        controller.applyEvent(RideTripEvent.driverArrived);
        controller.applyEvent(RideTripEvent.startTrip);
        controller.applyEvent(RideTripEvent.startPayment);
        controller.applyEvent(RideTripEvent.complete);
        controller.archiveTrip(
          destinationLabel: 'Mall',
          amountFormatted: 'SAR 20.00',
          serviceName: 'Economy',
        );
        
        // Save history before clearing
        final historyAfterFirst = controller.state.historyTrips;
        expect(historyAfterFirst, hasLength(1));

        // Clear activeTrip only, but manually keep history for next trip
        // Note: clear() resets all state including history
        // For testing purpose, we'll create new controller with existing history
        
        // Second trip - start fresh but history should still work
        const draft2 = RideDraftUiState(destinationQuery: 'Airport');
        controller.startFromDraft(draft2);
        controller.applyEvent(RideTripEvent.driverAccepted);
        controller.applyEvent(RideTripEvent.driverArrived);
        controller.applyEvent(RideTripEvent.startTrip);
        controller.applyEvent(RideTripEvent.startPayment);
        controller.applyEvent(RideTripEvent.complete);
        controller.archiveTrip(
          destinationLabel: 'Airport',
          amountFormatted: 'SAR 50.00',
          serviceName: 'XL',
        );

        // Both trips should be in history, newest first
        expect(controller.state.historyTrips, hasLength(2));
        expect(controller.state.historyTrips[0].destinationLabel, 'Airport');
        expect(controller.state.historyTrips[0].serviceName, 'XL');
        expect(controller.state.historyTrips[1].destinationLabel, 'Mall');
        expect(controller.state.historyTrips[1].serviceName, 'Economy');
      });

      test('does not archive non-terminal trips', () {
        final controller = _createRideTripSessionControllerForTest();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        controller.startFromDraft(draft);
        // Still in findingDriver (non-terminal)
        expect(controller.state.activeTrip!.phase, RideTripPhase.findingDriver);

        controller.archiveTrip(
          destinationLabel: 'Test',
          amountFormatted: 'SAR 10.00',
        );

        // Should not be archived because trip is not terminal
        expect(controller.state.historyTrips, isEmpty);
      });

      test('does not archive when no active trip', () {
        final controller = _createRideTripSessionControllerForTest();
        expect(controller.state.activeTrip, isNull);

        controller.archiveTrip(
          destinationLabel: 'Test',
          amountFormatted: 'SAR 10.00',
        );

        expect(controller.state.historyTrips, isEmpty);
      });
    });

    group('null-safety edge cases - Track B Ticket #24', () {
      test('applyEvent does not throw when activeTrip is null', () {
        final controller = _createRideTripSessionControllerForTest();
        expect(controller.state.activeTrip, isNull);

        // Should not throw
        expect(() => controller.applyEvent(RideTripEvent.complete), returnsNormally);
        expect(controller.state.activeTrip, isNull);
      });

      test('cancelActiveTrip does not throw when activeTrip is null', () async {
        final controller = _createRideTripSessionControllerForTest();
        expect(controller.state.activeTrip, isNull);

        // Should not throw
        final result = await controller.cancelActiveTrip();
        expect(result, isFalse);
      });

      test('rateCurrentTrip does not throw when activeTrip is null', () {
        final controller = _createRideTripSessionControllerForTest();
        expect(controller.state.activeTrip, isNull);

        // Should not throw
        expect(() => controller.rateCurrentTrip(5), returnsNormally);
        expect(controller.state.driverRating, isNull);
      });

      test('hasActiveTrip does not throw when activeTrip is null', () {
        final controller = _createRideTripSessionControllerForTest();
        expect(controller.state.activeTrip, isNull);

        // Should not throw
        expect(() => controller.hasActiveTrip, returnsNormally);
        expect(controller.hasActiveTrip, isFalse);
      });

      test('clear does not throw on already empty state', () {
        final controller = _createRideTripSessionControllerForTest();
        expect(controller.state.activeTrip, isNull);

        // Should not throw
        expect(() => controller.clear(), returnsNormally);
        expect(controller.state.activeTrip, isNull);
      });
    });
  });

  group('RideTripSessionUiState', () {
    test('equality is based on tripId and phase', () {
      const trip = RideTripState(
        tripId: 'trip-1',
        phase: RideTripPhase.findingDriver,
      );

      const state1 = RideTripSessionUiState(activeTrip: trip);
      const state2 = RideTripSessionUiState(activeTrip: trip);

      expect(state1, equals(state2));
    });

    test('copyWith clearActiveTrip sets activeTrip to null', () {
      const trip = RideTripState(
        tripId: 'trip-1',
        phase: RideTripPhase.findingDriver,
      );

      const original = RideTripSessionUiState(activeTrip: trip);
      final cleared = original.copyWith(clearActiveTrip: true);

      expect(cleared.activeTrip, isNull);
    });

    test('copyWith clearDriverRating sets driverRating to null', () {
      const trip = RideTripState(
        tripId: 'trip-1',
        phase: RideTripPhase.findingDriver,
      );

      const original = RideTripSessionUiState(
        activeTrip: trip,
        driverRating: 5,
      );
      final cleared = original.copyWith(clearDriverRating: true);

      expect(cleared.driverRating, isNull);
      expect(cleared.activeTrip, isNotNull);
    });

    test('equality includes driverRating', () {
      const trip = RideTripState(
        tripId: 'trip-1',
        phase: RideTripPhase.findingDriver,
      );

      const state1 = RideTripSessionUiState(activeTrip: trip, driverRating: 5);
      const state2 = RideTripSessionUiState(activeTrip: trip, driverRating: 5);
      const state3 = RideTripSessionUiState(activeTrip: trip, driverRating: 3);

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });

    test('toString includes driverRating', () {
      const trip = RideTripState(
        tripId: 'trip-1',
        phase: RideTripPhase.completed,
      );

      const state = RideTripSessionUiState(
        activeTrip: trip,
        driverRating: 4,
      );

      expect(state.toString(), contains('driverRating: 4'));
      expect(state.toString(), contains('completed'));
    });
  });

  // ==========================================================================
  // End-to-End Integration Tests - Track B Ticket #29
  // ==========================================================================
  group('End-to-End Integration - Ticket #29', () {
    test('happy path from draft to completed with quote + pricing + fsm', () async {
      // 1. Build RideDraftUiState with pickup and destination places
      final pickupPlace = MobilityPlace(
        id: 'pickup_home',
        label: 'Home',
        type: MobilityPlaceType.searchResult,
        location: LocationPoint(
          latitude: 24.7136,
          longitude: 46.6753,
          timestamp: DateTime.now(),
        ),
      );

      const destinationPlace = MobilityPlace(
        id: 'destination_office',
        label: 'Office',
        type: MobilityPlaceType.searchResult,
        location: LocationPoint(
          latitude: 24.7500,
          longitude: 46.7000,
        ),
      );

      final draft = RideDraftUiState(
        pickupLabel: 'Home',
        pickupPlace: pickupPlace,
        destinationQuery: 'Office',
        destinationPlace: destinationPlace,
        selectedOptionId: 'economy',
      );

      // 2. MockRidePricingService setup skipped - we'll set quote directly for this test.

      // 3. For this end-to-end test, we'll simulate the quote being set directly
      // (in a real scenario, this would come from the pricing service)
      final quote = createMobilityTestQuote();

      // 4. Create trip session controller and start trip from draft with selected option
      final tripController = _createRideTripSessionControllerForTest();
      final selectedOption = quote.optionById('economy') ?? quote.recommendedOption;
      expect(selectedOption, isNotNull);
      tripController.startFromDraft(draft, selectedOption: selectedOption);

      // Verify initial phase is findingDriver
      expect(tripController.state.activeTrip?.phase, RideTripPhase.findingDriver);
      expect(tripController.hasActiveTrip, isTrue);
      expect(tripController.state.driverRating, isNull);

      // 6. Simulate FSM progression through all phases
      // driverAccepted
      tripController.applyEvent(RideTripEvent.driverAccepted);
      expect(tripController.state.activeTrip?.phase, RideTripPhase.driverAccepted);

      // driverArrived
      tripController.applyEvent(RideTripEvent.driverArrived);
      expect(tripController.state.activeTrip?.phase, RideTripPhase.driverArrived);

      // startTrip (inProgress)
      tripController.applyEvent(RideTripEvent.startTrip);
      expect(tripController.state.activeTrip?.phase, RideTripPhase.inProgress);

      // startPayment
      tripController.applyEvent(RideTripEvent.startPayment);
      expect(tripController.state.activeTrip?.phase, RideTripPhase.payment);

      // complete (completed)
      tripController.applyEvent(RideTripEvent.complete);
      expect(tripController.state.activeTrip?.phase, RideTripPhase.completed);

      // 7. Verify driver rating is null until rated
      expect(tripController.state.driverRating, isNull);

      // 8. Rate the trip
      tripController.rateCurrentTrip(5);
      expect(tripController.state.driverRating, 5);

      // 9. Verify terminal state - hasActiveTrip should be false
      expect(tripController.hasActiveTrip, isFalse);
    });

    // Ticket #95: cancelActiveTrip keeps trip in cancelled state
    test('full flow with cancellation at findingDriver phase', () async {
      // Setup draft
      final pickupPlace = MobilityPlace(
        label: 'Start',
        location: LocationPoint(
          latitude: 24.7136,
          longitude: 46.6753,
          accuracyMeters: 10,
          timestamp: DateTime.now(),
        ),
      );

      final draft = RideDraftUiState(
        pickupLabel: 'Start',
        pickupPlace: pickupPlace,
        destinationQuery: 'End',
      );

      // Start trip
      final tripController = _createRideTripSessionControllerForTest();
      tripController.startFromDraft(draft);

      expect(tripController.state.activeTrip?.phase, RideTripPhase.findingDriver);

      // Cancel trip
      final result = await tripController.cancelActiveTrip();

      expect(result, isTrue);
      // Ticket #95: cancelActiveTrip keeps trip in cancelled state
      expect(tripController.state.activeTrip, isNotNull);
      expect(tripController.state.activeTrip!.phase, RideTripPhase.cancelled);
      expect(tripController.hasActiveTrip, isFalse);
    });

    test('full flow with failure event', () {
      // Setup draft
      const draft = RideDraftUiState(
        pickupLabel: 'Start',
        destinationQuery: 'End',
      );

      // Start trip
      final tripController = _createRideTripSessionControllerForTest();
      tripController.startFromDraft(draft);

      // Progress to driverAccepted
      tripController.applyEvent(RideTripEvent.driverAccepted);
      expect(tripController.state.activeTrip?.phase, RideTripPhase.driverAccepted);

      // Fail the trip
      tripController.applyEvent(RideTripEvent.fail);
      expect(tripController.state.activeTrip?.phase, RideTripPhase.failed);

      // hasActiveTrip should be false for terminal state
      expect(tripController.hasActiveTrip, isFalse);
    });
  });

  // ===========================================================================
  // Track B - Ticket #117: completeCurrentTrip Tests
  // ===========================================================================

  group('completeCurrentTrip - Track B Ticket #117', () {
    test('moves activeTrip to history and clears session from inProgress', () {
      final controller = _createRideTripSessionControllerForTest();
      const draft = RideDraftUiState(
        pickupLabel: 'Pickup Point',
        destinationQuery: 'Downtown Mall',
      );

      // Start trip and progress to inProgress
      controller.startFromDraft(draft);
      controller.applyEvent(RideTripEvent.driverAccepted);
      controller.applyEvent(RideTripEvent.driverArrived);
      controller.applyEvent(RideTripEvent.startTrip);
      expect(controller.state.activeTrip?.phase, RideTripPhase.inProgress);

      // Complete the trip
      final result = controller.completeCurrentTrip(
        destinationLabel: 'Downtown Mall',
        amountFormatted: 'SAR 25.00',
        serviceName: 'Economy',
        originLabel: 'Pickup Point',
        paymentMethodLabel: 'Cash',
      );

      // Verify result
      expect(result, isTrue);

      // Verify session is cleared
      expect(controller.state.activeTrip, isNull);
      expect(controller.state.draftSnapshot, isNull);
      expect(controller.state.tripSummary, isNull);
      expect(controller.state.completionSummary, isNull);
      expect(controller.state.driverRating, isNull);

      // Verify history has the completed trip
      expect(controller.state.historyTrips, hasLength(1));
      expect(controller.state.historyTrips.first.trip.phase, RideTripPhase.completed);
      expect(controller.state.historyTrips.first.destinationLabel, 'Downtown Mall');
      expect(controller.state.historyTrips.first.amountFormatted, 'SAR 25.00');
      expect(controller.state.historyTrips.first.serviceName, 'Economy');
      expect(controller.state.historyTrips.first.originLabel, 'Pickup Point');
      expect(controller.state.historyTrips.first.paymentMethodLabel, 'Cash');
    });

    test('moves activeTrip to history and clears session from payment phase', () {
      final controller = _createRideTripSessionControllerForTest();
      const draft = RideDraftUiState(
        pickupLabel: 'Home',
        destinationQuery: 'Office',
      );

      // Start trip and progress to payment
      controller.startFromDraft(draft);
      controller.applyEvent(RideTripEvent.driverAccepted);
      controller.applyEvent(RideTripEvent.driverArrived);
      controller.applyEvent(RideTripEvent.startTrip);
      controller.applyEvent(RideTripEvent.startPayment);
      expect(controller.state.activeTrip?.phase, RideTripPhase.payment);

      // Complete the trip
      final result = controller.completeCurrentTrip(
        destinationLabel: 'Office',
      );

      expect(result, isTrue);
      expect(controller.state.activeTrip, isNull);
      expect(controller.state.historyTrips, hasLength(1));
      expect(controller.state.historyTrips.first.trip.phase, RideTripPhase.completed);
    });

    test('is idempotent when no active trip exists', () {
      final controller = _createRideTripSessionControllerForTest();

      // Call twice with no active trip
      final result1 = controller.completeCurrentTrip();
      final result2 = controller.completeCurrentTrip();

      // Both should return false, no exception
      expect(result1, isFalse);
      expect(result2, isFalse);

      // History should remain empty
      expect(controller.state.historyTrips, isEmpty);
    });

    test('preserves existing history entries', () {
      final controller = _createRideTripSessionControllerForTest();
      const draft1 = RideDraftUiState(destinationQuery: 'Trip 1');
      const draft2 = RideDraftUiState(destinationQuery: 'Trip 2');
      const draft3 = RideDraftUiState(destinationQuery: 'Trip 3');

      // Complete first trip
      controller.startFromDraft(draft1);
      controller.applyEvent(RideTripEvent.driverAccepted);
      controller.applyEvent(RideTripEvent.driverArrived);
      controller.applyEvent(RideTripEvent.startTrip);
      controller.completeCurrentTrip(destinationLabel: 'Trip 1');

      // Complete second trip
      controller.startFromDraft(draft2);
      controller.applyEvent(RideTripEvent.driverAccepted);
      controller.applyEvent(RideTripEvent.driverArrived);
      controller.applyEvent(RideTripEvent.startTrip);
      controller.completeCurrentTrip(destinationLabel: 'Trip 2');

      // Complete third trip
      controller.startFromDraft(draft3);
      controller.applyEvent(RideTripEvent.driverAccepted);
      controller.applyEvent(RideTripEvent.driverArrived);
      controller.applyEvent(RideTripEvent.startTrip);
      controller.completeCurrentTrip(destinationLabel: 'Trip 3');

      // Verify all 3 trips are in history (newest first)
      expect(controller.state.historyTrips, hasLength(3));
      expect(controller.state.historyTrips[0].destinationLabel, 'Trip 3');
      expect(controller.state.historyTrips[1].destinationLabel, 'Trip 2');
      expect(controller.state.historyTrips[2].destinationLabel, 'Trip 1');

      // All should be completed
      for (final entry in controller.state.historyTrips) {
        expect(entry.trip.phase, RideTripPhase.completed);
      }
    });

    test('uses draftSnapshot for destination when not provided', () {
      final controller = _createRideTripSessionControllerForTest();
      const draft = RideDraftUiState(
        pickupLabel: 'Current Location',
        destinationQuery: 'King Fahd Road',
      );

      controller.startFromDraft(draft);
      controller.applyEvent(RideTripEvent.driverAccepted);
      controller.applyEvent(RideTripEvent.driverArrived);
      controller.applyEvent(RideTripEvent.startTrip);

      // Complete without providing destinationLabel
      controller.completeCurrentTrip();

      // Should use draftSnapshot.destinationQuery
      expect(controller.state.historyTrips.first.destinationLabel, 'King Fahd Road');
      expect(controller.state.historyTrips.first.originLabel, 'Current Location');
    });

    test('uses tripSummary for fare and service when not provided', () {
      final controller = _createRideTripSessionControllerForTest();
      const draft = RideDraftUiState(
        destinationQuery: 'Airport',
        selectedOptionId: 'xl',
      );

      const option = mobility.RideQuoteOption(
        id: 'xl',
        category: mobility.RideVehicleCategory.xl,
        displayName: 'XL',
        etaMinutes: 8,
        priceMinorUnits: 4500, // 45.00
        currencyCode: 'SAR',
      );

      controller.startFromDraft(draft, selectedOption: option);
      controller.applyEvent(RideTripEvent.driverAccepted);
      controller.applyEvent(RideTripEvent.driverArrived);
      controller.applyEvent(RideTripEvent.startTrip);

      // Complete without providing fare/service
      controller.completeCurrentTrip();

      // Should use tripSummary values (formattedPrice = "45.00")
      expect(controller.state.historyTrips.first.amountFormatted, '45.00');
      expect(controller.state.historyTrips.first.serviceName, 'XL');
    });

    test('handles already completed trip (terminal phase)', () {
      final controller = _createRideTripSessionControllerForTest();
      const draft = RideDraftUiState(destinationQuery: 'Test');

      controller.startFromDraft(draft);
      controller.applyEvent(RideTripEvent.driverAccepted);
      controller.applyEvent(RideTripEvent.driverArrived);
      controller.applyEvent(RideTripEvent.startTrip);
      controller.applyEvent(RideTripEvent.startPayment);
      controller.applyEvent(RideTripEvent.complete);

      // Trip is now in completed phase
      expect(controller.state.activeTrip?.phase, RideTripPhase.completed);

      // completeCurrentTrip should still work (archives the completed trip)
      final result = controller.completeCurrentTrip(destinationLabel: 'Test');

      expect(result, isTrue);
      expect(controller.state.activeTrip, isNull);
      expect(controller.state.historyTrips, hasLength(1));
      expect(controller.state.historyTrips.first.trip.phase, RideTripPhase.completed);
    });

    test('handles cancelled trip (terminal phase)', () {
      final controller = _createRideTripSessionControllerForTest();
      const draft = RideDraftUiState(destinationQuery: 'Test');

      controller.startFromDraft(draft);
      controller.applyEvent(RideTripEvent.cancel);

      // Trip is now in cancelled phase
      expect(controller.state.activeTrip?.phase, RideTripPhase.cancelled);

      // completeCurrentTrip should archive the cancelled trip
      final result = controller.completeCurrentTrip(destinationLabel: 'Test');

      expect(result, isTrue);
      expect(controller.state.activeTrip, isNull);
      expect(controller.state.historyTrips, hasLength(1));
      expect(controller.state.historyTrips.first.trip.phase, RideTripPhase.cancelled);
    });

    test('clears driverRating when completing trip', () {
      final controller = _createRideTripSessionControllerForTest();
      const draft = RideDraftUiState(destinationQuery: 'Test');

      controller.startFromDraft(draft);
      controller.applyEvent(RideTripEvent.driverAccepted);
      controller.applyEvent(RideTripEvent.driverArrived);
      controller.applyEvent(RideTripEvent.startTrip);

      // Rate the driver before completing
      controller.rateCurrentTrip(5);
      expect(controller.state.driverRating, 5);

      // Complete the trip
      controller.completeCurrentTrip(destinationLabel: 'Test');

      // Rating should be cleared
      expect(controller.state.driverRating, isNull);
    });

    test('sets completedAt timestamp', () {
      final controller = _createRideTripSessionControllerForTest();
      const draft = RideDraftUiState(destinationQuery: 'Test');

      controller.startFromDraft(draft);
      controller.applyEvent(RideTripEvent.driverAccepted);
      controller.applyEvent(RideTripEvent.driverArrived);
      controller.applyEvent(RideTripEvent.startTrip);

      final beforeComplete = DateTime.now();
      controller.completeCurrentTrip(destinationLabel: 'Test');
      final afterComplete = DateTime.now();

      final completedAt = controller.state.historyTrips.first.completedAt;
      expect(completedAt.isAfter(beforeComplete) || completedAt.isAtSameMomentAs(beforeComplete), isTrue);
      expect(completedAt.isBefore(afterComplete) || completedAt.isAtSameMomentAs(afterComplete), isTrue);
    });

    test('returns false for findingDriver phase (cannot complete directly)', () {
      final controller = _createRideTripSessionControllerForTest();
      const draft = RideDraftUiState(destinationQuery: 'Test');

      controller.startFromDraft(draft);
      // Still in findingDriver phase
      expect(controller.state.activeTrip?.phase, RideTripPhase.findingDriver);

      // Cannot complete directly from findingDriver
      final result = controller.completeCurrentTrip(destinationLabel: 'Test');

      // Should return false - can't complete from this phase
      expect(result, isFalse);
      expect(controller.state.activeTrip, isNotNull);
      expect(controller.state.historyTrips, isEmpty);
    });
  });

  // ===========================================================================
  // Track B - Ticket #120: cancelCurrentTrip tests
  // ===========================================================================
  group('cancelCurrentTrip (Track B - Ticket #120)', () {
    test('cancels and archives trip from findingDriver phase', () {
      final controller = _createRideTripSessionControllerForTest();
      const draft = RideDraftUiState(
        pickupLabel: 'Home',
        destinationQuery: 'Downtown',
      );

      controller.startFromDraft(draft);
      expect(controller.state.activeTrip?.phase, RideTripPhase.findingDriver);

      final result = controller.cancelCurrentTrip(
        reasonLabel: 'Cancelled by rider',
        destinationLabel: 'Downtown',
      );

      expect(result, isTrue);
      expect(controller.state.activeTrip, isNull);
      expect(controller.state.historyTrips, hasLength(1));
      expect(controller.state.historyTrips.first.trip.phase, RideTripPhase.cancelled);
      expect(controller.state.historyTrips.first.destinationLabel, 'Downtown');
    });

    test('returns false when no active trip', () {
      final controller = _createRideTripSessionControllerForTest();

      final result = controller.cancelCurrentTrip(
        reasonLabel: 'Test',
        destinationLabel: 'Test',
      );

      expect(result, isFalse);
      expect(controller.state.historyTrips, isEmpty);
    });

    test('returns false for non-cancellable phase (inProgress)', () {
      final controller = _createRideTripSessionControllerForTest();
      const draft = RideDraftUiState(destinationQuery: 'Test');

      controller.startFromDraft(draft);
      controller.applyEvent(RideTripEvent.driverAccepted);
      controller.applyEvent(RideTripEvent.driverArrived);
      controller.applyEvent(RideTripEvent.startTrip);
      expect(controller.state.activeTrip?.phase, RideTripPhase.inProgress);

      final result = controller.cancelCurrentTrip(destinationLabel: 'Test');

      expect(result, isFalse);
      expect(controller.state.activeTrip, isNotNull);
      expect(controller.state.activeTrip?.phase, RideTripPhase.inProgress);
      expect(controller.state.historyTrips, isEmpty);
    });

    test('returns false for non-cancellable phase (payment)', () {
      final controller = _createRideTripSessionControllerForTest();
      const draft = RideDraftUiState(destinationQuery: 'Test');

      controller.startFromDraft(draft);
      controller.applyEvent(RideTripEvent.driverAccepted);
      controller.applyEvent(RideTripEvent.driverArrived);
      controller.applyEvent(RideTripEvent.startTrip);
      controller.applyEvent(RideTripEvent.startPayment);
      expect(controller.state.activeTrip?.phase, RideTripPhase.payment);

      final result = controller.cancelCurrentTrip(destinationLabel: 'Test');

      expect(result, isFalse);
      expect(controller.state.activeTrip, isNotNull);
      expect(controller.state.historyTrips, isEmpty);
    });

    test('returns false for already completed trip', () {
      final controller = _createRideTripSessionControllerForTest();
      const draft = RideDraftUiState(destinationQuery: 'Test');

      controller.startFromDraft(draft);
      controller.applyEvent(RideTripEvent.driverAccepted);
      controller.applyEvent(RideTripEvent.driverArrived);
      controller.applyEvent(RideTripEvent.startTrip);
      controller.applyEvent(RideTripEvent.startPayment);
      controller.applyEvent(RideTripEvent.complete);
      expect(controller.state.activeTrip?.phase, RideTripPhase.completed);

      final result = controller.cancelCurrentTrip(destinationLabel: 'Test');

      expect(result, isFalse);
    });

    test('cancels from driverAccepted phase', () {
      final controller = _createRideTripSessionControllerForTest();
      const draft = RideDraftUiState(destinationQuery: 'Mall');

      controller.startFromDraft(draft);
      controller.applyEvent(RideTripEvent.driverAccepted);
      expect(controller.state.activeTrip?.phase, RideTripPhase.driverAccepted);

      final result = controller.cancelCurrentTrip(destinationLabel: 'Mall');

      expect(result, isTrue);
      expect(controller.state.historyTrips.first.trip.phase, RideTripPhase.cancelled);
    });

    test('cancels from driverArrived phase', () {
      final controller = _createRideTripSessionControllerForTest();
      const draft = RideDraftUiState(destinationQuery: 'Airport');

      controller.startFromDraft(draft);
      controller.applyEvent(RideTripEvent.driverAccepted);
      controller.applyEvent(RideTripEvent.driverArrived);
      expect(controller.state.activeTrip?.phase, RideTripPhase.driverArrived);

      final result = controller.cancelCurrentTrip(destinationLabel: 'Airport');

      expect(result, isTrue);
      expect(controller.state.historyTrips.first.trip.phase, RideTripPhase.cancelled);
    });

    test('uses draftSnapshot for destination when not provided', () {
      final controller = _createRideTripSessionControllerForTest();
      const draft = RideDraftUiState(
        pickupLabel: 'Home',
        destinationQuery: 'Office',
      );

      controller.startFromDraft(draft);
      controller.cancelCurrentTrip(); // No destinationLabel

      expect(controller.state.historyTrips.first.destinationLabel, 'Office');
      expect(controller.state.historyTrips.first.originLabel, 'Home');
    });

    test('uses tripSummary for service and fare when not provided', () {
      final controller = _createRideTripSessionControllerForTest();
      const draft = RideDraftUiState(
        destinationQuery: 'Station',
        selectedOptionId: 'economy',
      );

      const option = mobility.RideQuoteOption(
        id: 'economy',
        category: mobility.RideVehicleCategory.economy,
        displayName: 'Economy',
        etaMinutes: 5,
        priceMinorUnits: 1800,
        currencyCode: 'SAR',
      );

      controller.startFromDraft(draft, selectedOption: option);
      controller.cancelCurrentTrip(); // No serviceName/amountFormatted

      expect(controller.state.historyTrips.first.serviceName, 'Economy');
      expect(controller.state.historyTrips.first.amountFormatted, '18.00');
    });

    test('clears session state after cancellation', () {
      final controller = _createRideTripSessionControllerForTest();
      const draft = RideDraftUiState(
        pickupLabel: 'Home',
        destinationQuery: 'Work',
      );

      controller.startFromDraft(draft);
      
      // Verify session state is populated
      expect(controller.state.activeTrip, isNotNull);
      expect(controller.state.draftSnapshot, isNotNull);
      expect(controller.state.tripSummary, isNotNull);

      controller.cancelCurrentTrip(destinationLabel: 'Work');

      // All session state should be cleared
      expect(controller.state.activeTrip, isNull);
      expect(controller.state.draftSnapshot, isNull);
      expect(controller.state.tripSummary, isNull);
      expect(controller.state.completionSummary, isNull);
    });

    test('preserves history from previous trips', () {
      final controller = _createRideTripSessionControllerForTest();
      
      // First trip - complete it
      const draft1 = RideDraftUiState(destinationQuery: 'Trip 1');
      controller.startFromDraft(draft1);
      controller.applyEvent(RideTripEvent.driverAccepted);
      controller.applyEvent(RideTripEvent.driverArrived);
      controller.applyEvent(RideTripEvent.startTrip);
      controller.completeCurrentTrip(destinationLabel: 'Trip 1');

      // Second trip - cancel it
      const draft2 = RideDraftUiState(destinationQuery: 'Trip 2');
      controller.startFromDraft(draft2);
      controller.cancelCurrentTrip(destinationLabel: 'Trip 2');

      // Both trips should be in history
      expect(controller.state.historyTrips, hasLength(2));
      expect(controller.state.historyTrips[0].destinationLabel, 'Trip 2');
      expect(controller.state.historyTrips[0].trip.phase, RideTripPhase.cancelled);
      expect(controller.state.historyTrips[1].destinationLabel, 'Trip 1');
      expect(controller.state.historyTrips[1].trip.phase, RideTripPhase.completed);
    });

    test('sets completedAt timestamp', () {
      final controller = _createRideTripSessionControllerForTest();
      const draft = RideDraftUiState(destinationQuery: 'Test');

      controller.startFromDraft(draft);

      final beforeCancel = DateTime.now();
      controller.cancelCurrentTrip(destinationLabel: 'Test');
      final afterCancel = DateTime.now();

      final completedAt = controller.state.historyTrips.first.completedAt;
      expect(completedAt.isAfter(beforeCancel) || completedAt.isAtSameMomentAs(beforeCancel), isTrue);
      expect(completedAt.isBefore(afterCancel) || completedAt.isAtSameMomentAs(afterCancel), isTrue);
    });
  });

  // ===========================================================================
  // Track B - Ticket #122: failCurrentTrip Tests
  // ===========================================================================

  group('failCurrentTrip - Track B Ticket #122', () {
    test('moves activeTrip to history as failed and clears session from findingDriver', () {
      final controller = _createRideTripSessionControllerForTest();
      const draft = RideDraftUiState(
        pickupLabel: 'Home',
        destinationQuery: 'Airport',
      );

      controller.startFromDraft(draft);
      expect(controller.state.activeTrip?.phase, RideTripPhase.findingDriver);

      final result = controller.failCurrentTrip(
        reasonLabel: 'No driver found',
        destinationLabel: 'Airport',
        originLabel: 'Home',
        serviceName: 'Economy',
      );

      // Verify result
      expect(result, isTrue);

      // Verify session is cleared
      expect(controller.state.activeTrip, isNull);
      expect(controller.state.draftSnapshot, isNull);
      expect(controller.state.tripSummary, isNull);

      // Verify history has the failed trip
      expect(controller.state.historyTrips, hasLength(1));
      expect(controller.state.historyTrips.first.trip.phase, RideTripPhase.failed);
      expect(controller.state.historyTrips.first.destinationLabel, 'Airport');
      expect(controller.state.historyTrips.first.originLabel, 'Home');
      expect(controller.state.historyTrips.first.serviceName, 'Economy');
    });

    test('returns false when no active trip exists', () {
      final controller = _createRideTripSessionControllerForTest();

      final result = controller.failCurrentTrip(
        reasonLabel: 'Test',
        destinationLabel: 'Test',
      );

      expect(result, isFalse);
      expect(controller.state.historyTrips, isEmpty);
    });

    test('returns false for terminal phase (completed)', () {
      final controller = _createRideTripSessionControllerForTest();
      const draft = RideDraftUiState(destinationQuery: 'Test');

      controller.startFromDraft(draft);
      controller.applyEvent(RideTripEvent.driverAccepted);
      controller.applyEvent(RideTripEvent.driverArrived);
      controller.applyEvent(RideTripEvent.startTrip);
      controller.applyEvent(RideTripEvent.startPayment);
      controller.applyEvent(RideTripEvent.complete);
      expect(controller.state.activeTrip?.phase, RideTripPhase.completed);

      final result = controller.failCurrentTrip(destinationLabel: 'Test');

      expect(result, isFalse);
      // History should remain empty (trip is still in activeTrip state)
      expect(controller.state.historyTrips, isEmpty);
    });

    test('returns false for terminal phase (cancelled)', () {
      final controller = _createRideTripSessionControllerForTest();
      const draft = RideDraftUiState(destinationQuery: 'Test');

      controller.startFromDraft(draft);
      controller.applyEvent(RideTripEvent.cancel);
      expect(controller.state.activeTrip?.phase, RideTripPhase.cancelled);

      final result = controller.failCurrentTrip(destinationLabel: 'Test');

      expect(result, isFalse);
    });

    test('returns false for terminal phase (failed)', () {
      final controller = _createRideTripSessionControllerForTest();
      const draft = RideDraftUiState(destinationQuery: 'Test');

      controller.startFromDraft(draft);
      controller.applyEvent(RideTripEvent.fail);
      expect(controller.state.activeTrip?.phase, RideTripPhase.failed);

      final result = controller.failCurrentTrip(destinationLabel: 'Test');

      expect(result, isFalse);
    });

    test('fails from driverAccepted phase', () {
      final controller = _createRideTripSessionControllerForTest();
      const draft = RideDraftUiState(destinationQuery: 'Mall');

      controller.startFromDraft(draft);
      controller.applyEvent(RideTripEvent.driverAccepted);
      expect(controller.state.activeTrip?.phase, RideTripPhase.driverAccepted);

      final result = controller.failCurrentTrip(destinationLabel: 'Mall');

      expect(result, isTrue);
      expect(controller.state.historyTrips.first.trip.phase, RideTripPhase.failed);
    });

    test('fails from driverArrived phase', () {
      final controller = _createRideTripSessionControllerForTest();
      const draft = RideDraftUiState(destinationQuery: 'Office');

      controller.startFromDraft(draft);
      controller.applyEvent(RideTripEvent.driverAccepted);
      controller.applyEvent(RideTripEvent.driverArrived);
      expect(controller.state.activeTrip?.phase, RideTripPhase.driverArrived);

      final result = controller.failCurrentTrip(destinationLabel: 'Office');

      expect(result, isTrue);
      expect(controller.state.historyTrips.first.trip.phase, RideTripPhase.failed);
    });

    test('fails from inProgress phase', () {
      final controller = _createRideTripSessionControllerForTest();
      const draft = RideDraftUiState(destinationQuery: 'Station');

      controller.startFromDraft(draft);
      controller.applyEvent(RideTripEvent.driverAccepted);
      controller.applyEvent(RideTripEvent.driverArrived);
      controller.applyEvent(RideTripEvent.startTrip);
      expect(controller.state.activeTrip?.phase, RideTripPhase.inProgress);

      final result = controller.failCurrentTrip(destinationLabel: 'Station');

      expect(result, isTrue);
      expect(controller.state.historyTrips.first.trip.phase, RideTripPhase.failed);
    });

    test('uses draftSnapshot for destination when not provided', () {
      final controller = _createRideTripSessionControllerForTest();
      const draft = RideDraftUiState(
        pickupLabel: 'Home',
        destinationQuery: 'Downtown',
      );

      controller.startFromDraft(draft);
      controller.failCurrentTrip(); // No destinationLabel

      expect(controller.state.historyTrips.first.destinationLabel, 'Downtown');
      expect(controller.state.historyTrips.first.originLabel, 'Home');
    });

    test('uses tripSummary for service and fare when not provided', () {
      final controller = _createRideTripSessionControllerForTest();
      const draft = RideDraftUiState(
        destinationQuery: 'Airport',
        selectedOptionId: 'premium',
      );

      const option = mobility.RideQuoteOption(
        id: 'premium',
        category: mobility.RideVehicleCategory.premium,
        displayName: 'Premium',
        etaMinutes: 4,
        priceMinorUnits: 5500,
        currencyCode: 'SAR',
      );

      controller.startFromDraft(draft, selectedOption: option);
      controller.failCurrentTrip(); // No serviceName/amountFormatted

      expect(controller.state.historyTrips.first.serviceName, 'Premium');
      expect(controller.state.historyTrips.first.amountFormatted, '55.00');
    });

    test('clears session state after failure', () {
      final controller = _createRideTripSessionControllerForTest();
      const draft = RideDraftUiState(
        pickupLabel: 'Home',
        destinationQuery: 'Work',
      );

      controller.startFromDraft(draft);
      
      // Verify session state is populated
      expect(controller.state.activeTrip, isNotNull);
      expect(controller.state.draftSnapshot, isNotNull);
      expect(controller.state.tripSummary, isNotNull);

      controller.failCurrentTrip(destinationLabel: 'Work');

      // All session state should be cleared
      expect(controller.state.activeTrip, isNull);
      expect(controller.state.draftSnapshot, isNull);
      expect(controller.state.tripSummary, isNull);
      expect(controller.state.completionSummary, isNull);
    });

    test('preserves history from previous trips', () {
      final controller = _createRideTripSessionControllerForTest();
      
      // First trip - complete it
      const draft1 = RideDraftUiState(destinationQuery: 'Trip 1');
      controller.startFromDraft(draft1);
      controller.applyEvent(RideTripEvent.driverAccepted);
      controller.applyEvent(RideTripEvent.driverArrived);
      controller.applyEvent(RideTripEvent.startTrip);
      controller.completeCurrentTrip(destinationLabel: 'Trip 1');

      // Second trip - cancel it
      const draft2 = RideDraftUiState(destinationQuery: 'Trip 2');
      controller.startFromDraft(draft2);
      controller.cancelCurrentTrip(destinationLabel: 'Trip 2');

      // Third trip - fail it
      const draft3 = RideDraftUiState(destinationQuery: 'Trip 3');
      controller.startFromDraft(draft3);
      controller.failCurrentTrip(destinationLabel: 'Trip 3');

      // All three trips should be in history
      expect(controller.state.historyTrips, hasLength(3));
      expect(controller.state.historyTrips[0].destinationLabel, 'Trip 3');
      expect(controller.state.historyTrips[0].trip.phase, RideTripPhase.failed);
      expect(controller.state.historyTrips[1].destinationLabel, 'Trip 2');
      expect(controller.state.historyTrips[1].trip.phase, RideTripPhase.cancelled);
      expect(controller.state.historyTrips[2].destinationLabel, 'Trip 1');
      expect(controller.state.historyTrips[2].trip.phase, RideTripPhase.completed);
    });

    test('sets completedAt timestamp', () {
      final controller = _createRideTripSessionControllerForTest();
      const draft = RideDraftUiState(destinationQuery: 'Test');

      controller.startFromDraft(draft);

      final beforeFail = DateTime.now();
      controller.failCurrentTrip(destinationLabel: 'Test');
      final afterFail = DateTime.now();

      final completedAt = controller.state.historyTrips.first.completedAt;
      expect(completedAt.isAfter(beforeFail) || completedAt.isAtSameMomentAs(beforeFail), isTrue);
      expect(completedAt.isBefore(afterFail) || completedAt.isAtSameMomentAs(afterFail), isTrue);
    });
  });

  // ===========================================================================
  // Track B - Ticket #124: setRatingForMostRecentTrip Tests
  // ===========================================================================

  group('setRatingForMostRecentTrip - Track B Ticket #124', () {
    test('sets rating for most recent history entry', () {
      final controller = _createRideTripSessionControllerForTest();
      const draft = RideDraftUiState(destinationQuery: 'Downtown');

      // Complete a trip to create a history entry
      controller.startFromDraft(draft);
      controller.applyEvent(RideTripEvent.driverAccepted);
      controller.applyEvent(RideTripEvent.driverArrived);
      controller.applyEvent(RideTripEvent.startTrip);
      controller.completeCurrentTrip(destinationLabel: 'Downtown');

      // Verify history has one entry with no rating
      expect(controller.state.historyTrips, hasLength(1));
      expect(controller.state.historyTrips.first.driverRating, isNull);

      // Set rating
      final result = controller.setRatingForMostRecentTrip(4.5);

      expect(result, isTrue);
      expect(controller.state.historyTrips.first.driverRating, 4.5);
    });

    test('returns false when history is empty', () {
      final controller = _createRideTripSessionControllerForTest();

      final result = controller.setRatingForMostRecentTrip(4.0);

      expect(result, isFalse);
    });

    test('rejects rating below 1.0', () {
      final controller = _createRideTripSessionControllerForTest();
      const draft = RideDraftUiState(destinationQuery: 'Test');

      controller.startFromDraft(draft);
      controller.applyEvent(RideTripEvent.driverAccepted);
      controller.applyEvent(RideTripEvent.driverArrived);
      controller.applyEvent(RideTripEvent.startTrip);
      controller.completeCurrentTrip(destinationLabel: 'Test');

      final result = controller.setRatingForMostRecentTrip(0.5);

      expect(result, isFalse);
      expect(controller.state.historyTrips.first.driverRating, isNull);
    });

    test('rejects rating above 5.0', () {
      final controller = _createRideTripSessionControllerForTest();
      const draft = RideDraftUiState(destinationQuery: 'Test');

      controller.startFromDraft(draft);
      controller.applyEvent(RideTripEvent.driverAccepted);
      controller.applyEvent(RideTripEvent.driverArrived);
      controller.applyEvent(RideTripEvent.startTrip);
      controller.completeCurrentTrip(destinationLabel: 'Test');

      final result = controller.setRatingForMostRecentTrip(5.5);

      expect(result, isFalse);
      expect(controller.state.historyTrips.first.driverRating, isNull);
    });

    test('accepts rating at boundary values', () {
      final controller = _createRideTripSessionControllerForTest();

      // First trip - test lower boundary
      const draft1 = RideDraftUiState(destinationQuery: 'Trip 1');
      controller.startFromDraft(draft1);
      controller.applyEvent(RideTripEvent.driverAccepted);
      controller.applyEvent(RideTripEvent.driverArrived);
      controller.applyEvent(RideTripEvent.startTrip);
      controller.completeCurrentTrip(destinationLabel: 'Trip 1');

      var result = controller.setRatingForMostRecentTrip(1.0);
      expect(result, isTrue);
      expect(controller.state.historyTrips.first.driverRating, 1.0);

      // Second trip - test upper boundary
      const draft2 = RideDraftUiState(destinationQuery: 'Trip 2');
      controller.startFromDraft(draft2);
      controller.applyEvent(RideTripEvent.driverAccepted);
      controller.applyEvent(RideTripEvent.driverArrived);
      controller.applyEvent(RideTripEvent.startTrip);
      controller.completeCurrentTrip(destinationLabel: 'Trip 2');

      result = controller.setRatingForMostRecentTrip(5.0);
      expect(result, isTrue);
      expect(controller.state.historyTrips.first.driverRating, 5.0);
    });

    test('allows updating rating multiple times', () {
      final controller = _createRideTripSessionControllerForTest();
      const draft = RideDraftUiState(destinationQuery: 'Test');

      controller.startFromDraft(draft);
      controller.applyEvent(RideTripEvent.driverAccepted);
      controller.applyEvent(RideTripEvent.driverArrived);
      controller.applyEvent(RideTripEvent.startTrip);
      controller.completeCurrentTrip(destinationLabel: 'Test');

      controller.setRatingForMostRecentTrip(3.0);
      expect(controller.state.historyTrips.first.driverRating, 3.0);

      controller.setRatingForMostRecentTrip(5.0);
      expect(controller.state.historyTrips.first.driverRating, 5.0);

      controller.setRatingForMostRecentTrip(1.0);
      expect(controller.state.historyTrips.first.driverRating, 1.0);
    });

    test('sets rating for cancelled trip', () {
      final controller = _createRideTripSessionControllerForTest();
      const draft = RideDraftUiState(destinationQuery: 'Cancelled Trip');

      controller.startFromDraft(draft);
      controller.cancelCurrentTrip(destinationLabel: 'Cancelled Trip');

      expect(controller.state.historyTrips.first.trip.phase, RideTripPhase.cancelled);

      final result = controller.setRatingForMostRecentTrip(2.0);

      expect(result, isTrue);
      expect(controller.state.historyTrips.first.driverRating, 2.0);
    });

    test('sets rating for failed trip', () {
      final controller = _createRideTripSessionControllerForTest();
      const draft = RideDraftUiState(destinationQuery: 'Failed Trip');

      controller.startFromDraft(draft);
      controller.failCurrentTrip(destinationLabel: 'Failed Trip');

      expect(controller.state.historyTrips.first.trip.phase, RideTripPhase.failed);

      final result = controller.setRatingForMostRecentTrip(1.0);

      expect(result, isTrue);
      expect(controller.state.historyTrips.first.driverRating, 1.0);
    });

    test('only updates most recent trip in history', () {
      final controller = _createRideTripSessionControllerForTest();

      // Complete first trip
      const draft1 = RideDraftUiState(destinationQuery: 'First');
      controller.startFromDraft(draft1);
      controller.applyEvent(RideTripEvent.driverAccepted);
      controller.applyEvent(RideTripEvent.driverArrived);
      controller.applyEvent(RideTripEvent.startTrip);
      controller.completeCurrentTrip(destinationLabel: 'First');

      // Complete second trip
      const draft2 = RideDraftUiState(destinationQuery: 'Second');
      controller.startFromDraft(draft2);
      controller.applyEvent(RideTripEvent.driverAccepted);
      controller.applyEvent(RideTripEvent.driverArrived);
      controller.applyEvent(RideTripEvent.startTrip);
      controller.completeCurrentTrip(destinationLabel: 'Second');

      // Set rating - should only affect most recent (Second)
      controller.setRatingForMostRecentTrip(4.0);

      // Verify only the most recent trip has rating
      expect(controller.state.historyTrips[0].destinationLabel, 'Second');
      expect(controller.state.historyTrips[0].driverRating, 4.0);
      expect(controller.state.historyTrips[1].destinationLabel, 'First');
      expect(controller.state.historyTrips[1].driverRating, isNull);
    });

    test('preserves other entry fields when setting rating', () {
      final controller = _createRideTripSessionControllerForTest();
      const draft = RideDraftUiState(
        pickupLabel: 'Home',
        destinationQuery: 'Airport',
        selectedOptionId: 'economy',
      );

      const option = mobility.RideQuoteOption(
        id: 'economy',
        category: mobility.RideVehicleCategory.economy,
        displayName: 'Economy',
        etaMinutes: 5,
        priceMinorUnits: 2500,
        currencyCode: 'SAR',
      );

      controller.startFromDraft(draft, selectedOption: option);
      controller.applyEvent(RideTripEvent.driverAccepted);
      controller.applyEvent(RideTripEvent.driverArrived);
      controller.applyEvent(RideTripEvent.startTrip);
      controller.completeCurrentTrip(
        destinationLabel: 'Airport',
        originLabel: 'Home',
        serviceName: 'Economy',
        amountFormatted: 'SAR 25.00',
        paymentMethodLabel: 'Cash',
      );

      // Set rating
      controller.setRatingForMostRecentTrip(4.5);

      // Verify all fields are preserved
      final entry = controller.state.historyTrips.first;
      expect(entry.destinationLabel, 'Airport');
      expect(entry.originLabel, 'Home');
      expect(entry.serviceName, 'Economy');
      expect(entry.amountFormatted, 'SAR 25.00');
      expect(entry.paymentMethodLabel, 'Cash');
      expect(entry.driverRating, 4.5);
      expect(entry.trip.phase, RideTripPhase.completed);
    });
  });

  // ===========================================================================
  // Track B - Ticket #209: Invariants Tests
  // ===========================================================================
  group('RideTripSessionController Invariants - Track B Ticket #209', () {
    test('invariant: no driverLocation without activeTrip', () {
      final controller = _createRideTripSessionControllerForTest();

      // Initially no active trip, so no driver location
      expect(controller.state.activeTrip, isNull);
      expect(controller.state.driverLocation, isNull);

      // Start a trip
      const draft = RideDraftUiState(destinationQuery: 'Test');
      controller.startFromDraft(draft);
      expect(controller.state.activeTrip, isNotNull);

      // Set driver location - should work
      const driverPoint = GeoPoint(24.7136, 46.6753);
      controller.updateDriverLocation(driverPoint);
      expect(controller.state.driverLocation, equals(driverPoint));

      // Complete the trip using completeCurrentTrip (which clears session state)
      controller.applyEvent(RideTripEvent.driverAccepted);
      controller.applyEvent(RideTripEvent.driverArrived);
      controller.applyEvent(RideTripEvent.startTrip);
      controller.applyEvent(RideTripEvent.startPayment);
      final completed = controller.completeCurrentTrip(destinationLabel: 'Test');
      expect(completed, isTrue);

      // After completeCurrentTrip, session is cleared (activeTrip becomes null)
      expect(controller.state.activeTrip, isNull);
      expect(controller.state.driverLocation, isNull);

      // Verify invariants hold even after clear
      controller.clear();
      expect(controller.state.activeTrip, isNull);
      expect(controller.state.driverLocation, isNull);
    });

    test('invariant: idle mapStage means clean map state', () {
      final controller = _createRideTripSessionControllerForTest();

      // Initially idle with clean state
      expect(controller.state.mapStage, RideMapStage.idle);
      expect(controller.state.mapSnapshot, isNull);
      expect(controller.state.driverLocation, isNull);

      // Start a trip - should change map stage
      const draft = RideDraftUiState(destinationQuery: 'Test');
      controller.startFromDraft(draft);
      expect(controller.state.mapStage, isNot(RideMapStage.idle));
      expect(controller.state.mapSnapshot, isNotNull);

      // Complete the trip - should be completed stage with clean driver location
      controller.applyEvent(RideTripEvent.driverAccepted);
      controller.applyEvent(RideTripEvent.driverArrived);
      controller.applyEvent(RideTripEvent.startTrip);
      controller.applyEvent(RideTripEvent.startPayment);
      controller.applyEvent(RideTripEvent.complete);

      // After completion, should be completed stage with driver location cleared
      expect(controller.state.mapStage, RideMapStage.completed);
      expect(controller.state.driverLocation, isNull);

      // Only after clear() should we return to idle
      controller.clear();
      expect(controller.state.mapStage, RideMapStage.idle);
      expect(controller.state.mapSnapshot, isNull);
      expect(controller.state.driverLocation, isNull);
    });

    test('invariant: trip end cleans driverLocation and mapSnapshot', () {
      final controller = _createRideTripSessionControllerForTest();
      const draft = RideDraftUiState(destinationQuery: 'Test');
      const driverPoint = GeoPoint(24.7136, 46.6753);

      // Test completeCurrentTrip
      controller.startFromDraft(draft);
      controller.applyEvent(RideTripEvent.driverAccepted);
      controller.applyEvent(RideTripEvent.driverArrived);
      controller.applyEvent(RideTripEvent.startTrip);

      // Set driver location
      controller.updateDriverLocation(driverPoint);
      expect(controller.state.driverLocation, equals(driverPoint));
      expect(controller.state.mapSnapshot, isNotNull);

      // Complete trip
      final completed = controller.completeCurrentTrip(destinationLabel: 'Test');
      expect(completed, isTrue);
      expect(controller.state.activeTrip, isNull);
      expect(controller.state.driverLocation, isNull);
      expect(controller.state.mapSnapshot, isNull);
      expect(controller.state.mapStage, RideMapStage.idle);

      // Test cancelCurrentTrip
      controller.startFromDraft(draft);
      controller.updateDriverLocation(driverPoint);
      expect(controller.state.driverLocation, equals(driverPoint));

      final cancelled = controller.cancelCurrentTrip(destinationLabel: 'Test');
      expect(cancelled, isTrue);
      expect(controller.state.activeTrip, isNull);
      expect(controller.state.driverLocation, isNull);
      expect(controller.state.mapSnapshot, isNull);
      expect(controller.state.mapStage, RideMapStage.idle);

      // Test failCurrentTrip
      controller.startFromDraft(draft);
      controller.updateDriverLocation(driverPoint);
      expect(controller.state.driverLocation, equals(driverPoint));

      final failed = controller.failCurrentTrip(destinationLabel: 'Test');
      expect(failed, isTrue);
      expect(controller.state.activeTrip, isNull);
      expect(controller.state.driverLocation, isNull);
      expect(controller.state.mapSnapshot, isNull);
      expect(controller.state.mapStage, RideMapStage.idle);

      // Test clear() - this should also clean everything
      controller.startFromDraft(draft);
      controller.updateDriverLocation(driverPoint);
      expect(controller.state.driverLocation, equals(driverPoint));

      controller.clear();
      expect(controller.state.activeTrip, isNull);
      expect(controller.state.driverLocation, isNull);
      expect(controller.state.mapSnapshot, isNull);
      expect(controller.state.mapStage, RideMapStage.idle);
    });
  });

  // ===========================================================================
  // Track B - Ticket #203: RideTripSessionController ↔ Ride Map Integration
  // ===========================================================================
  group('RideTripSessionController Map Integration - Track B Ticket #203', () {
    group('initial state', () {
      test('has default mapStage idle and mapSnapshot null', () {
        final controller = _createRideTripSessionControllerForTest();

        expect(controller.state.mapStage, RideMapStage.idle);
        expect(controller.state.mapSnapshot, isNull);
        expect(controller.state.hasMap, isFalse);
      });
    });

    group('FSM → RideMapStage mapping', () {
      test('draft phase → RideMapStage.idle', () {
        final controller = _createRideTripSessionControllerForTest();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        controller.startFromDraft(draft);

        expect(controller.state.activeTrip?.phase, RideTripPhase.findingDriver);
        expect(controller.state.mapStage, RideMapStage.waitingForDriver);
        expect(controller.state.mapSnapshot, isNotNull);
        expect(controller.state.hasMap, isTrue);
      });

      test('applying driverAccepted event → RideMapStage.driverEnRouteToPickup', () {
        final controller = _createRideTripSessionControllerForTest();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        controller.startFromDraft(draft);
        controller.applyEvent(RideTripEvent.driverAccepted);

        expect(controller.state.activeTrip?.phase, RideTripPhase.driverAccepted);
        expect(controller.state.mapStage, RideMapStage.driverEnRouteToPickup);
        expect(controller.state.mapSnapshot, isNotNull);
      });

      test('applying driverArrived event → RideMapStage.driverArrived', () {
        final controller = _createRideTripSessionControllerForTest();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        controller.startFromDraft(draft);
        controller.applyEvent(RideTripEvent.driverAccepted);
        controller.applyEvent(RideTripEvent.driverArrived);

        expect(controller.state.activeTrip?.phase, RideTripPhase.driverArrived);
        expect(controller.state.mapStage, RideMapStage.driverArrived);
        expect(controller.state.mapSnapshot, isNotNull);
      });

      test('applying startTrip event → RideMapStage.inProgressToDestination', () {
        final controller = _createRideTripSessionControllerForTest();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        controller.startFromDraft(draft);
        controller.applyEvent(RideTripEvent.driverAccepted);
        controller.applyEvent(RideTripEvent.driverArrived);
        controller.applyEvent(RideTripEvent.startTrip);

        expect(controller.state.activeTrip?.phase, RideTripPhase.inProgress);
        expect(controller.state.mapStage, RideMapStage.inProgressToDestination);
        expect(controller.state.mapSnapshot, isNotNull);
      });

      test('completing trip → RideMapStage.completed', () {
        final controller = _createRideTripSessionControllerForTest();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        controller.startFromDraft(draft);
        controller.applyEvent(RideTripEvent.driverAccepted);
        controller.applyEvent(RideTripEvent.driverArrived);
        controller.applyEvent(RideTripEvent.startTrip);
        controller.applyEvent(RideTripEvent.startPayment);
        controller.applyEvent(RideTripEvent.complete);

        expect(controller.state.activeTrip?.phase, RideTripPhase.completed);
        expect(controller.state.mapStage, RideMapStage.completed);
        expect(controller.state.mapSnapshot, isNotNull);
      });

      test('failing trip → RideMapStage.error', () {
        final controller = _createRideTripSessionControllerForTest();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        controller.startFromDraft(draft);
        controller.applyEvent(RideTripEvent.fail);

        expect(controller.state.activeTrip?.phase, RideTripPhase.failed);
        expect(controller.state.mapStage, RideMapStage.error);
        expect(controller.state.mapSnapshot, isNotNull);
      });

      test('cancelling trip → RideMapStage.error', () {
        final controller = _createRideTripSessionControllerForTest();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        controller.startFromDraft(draft);
        controller.applyEvent(RideTripEvent.cancel);

        expect(controller.state.activeTrip?.phase, RideTripPhase.cancelled);
        expect(controller.state.mapStage, RideMapStage.error);
        expect(controller.state.mapSnapshot, isNotNull);
      });
    });

    group('MapPort command recording', () {
      test('records commands when FSM transitions occur', () {
        final port = _RecordingMapPort();
        final controller = _createRideTripSessionControllerWithMapPort(port);
        const draft = RideDraftUiState(destinationQuery: 'Test');

        // Start trip - should record initial commands
        controller.startFromDraft(draft);
        expect(port.recordedCommands, isNotEmpty);

        // Apply driver accepted - should record more commands
        final commandsBefore = port.recordedCommands.length;
        controller.applyEvent(RideTripEvent.driverAccepted);
        expect(port.recordedCommands.length, greaterThan(commandsBefore));
      });

      test('includes SetMarkersCommand when trip has locations', () {
        final port = _RecordingMapPort();
        final controller = _createRideTripSessionControllerWithMapPort(port);

        final pickupPlace = MobilityPlace(
          label: 'Pickup',
          location: LocationPoint(
            latitude: 24.7136,
            longitude: 46.6753,
            accuracyMeters: 10,
            timestamp: DateTime.now(),
          ),
        );
        final destinationPlace = MobilityPlace(
          label: 'Destination',
          location: LocationPoint(
            latitude: 24.7500,
            longitude: 46.7000,
            accuracyMeters: 10,
            timestamp: DateTime.now(),
          ),
        );

        final draft = RideDraftUiState(
          pickupLabel: 'Pickup',
          pickupPlace: pickupPlace,
          destinationQuery: 'Destination',
          destinationPlace: destinationPlace,
        );

        controller.startFromDraft(draft);

        // Should have recorded SetMarkersCommand with pickup and destination markers
        final setMarkersCommands = port.recordedCommands.whereType<SetMarkersCommand>();
        expect(setMarkersCommands, isNotEmpty);

        final markers = setMarkersCommands.first.markers;
        expect(markers.length, 2); // pickup + destination markers
        expect(markers.any((m) => m.id.value == 'pickup'), isTrue);
        expect(markers.any((m) => m.id.value == 'dropoff'), isTrue);
      });

      test('includes SetCameraCommand in all transitions', () {
        final port = _RecordingMapPort();
        final controller = _createRideTripSessionControllerWithMapPort(port);
        const draft = RideDraftUiState(destinationQuery: 'Test');

        controller.startFromDraft(draft);

        // Should have recorded SetCameraCommand
        final setCameraCommands = port.recordedCommands.whereType<SetCameraCommand>();
        expect(setCameraCommands, isNotEmpty);
      });
    });

    group('location extraction', () {
      test('extracts pickup and dropoff locations from draftSnapshot', () {
        final port = _RecordingMapPort();
        final controller = _createRideTripSessionControllerWithMapPort(port);

        final pickupPlace = MobilityPlace(
          label: 'Home',
          location: LocationPoint(
            latitude: 24.7136,
            longitude: 46.6753,
            accuracyMeters: 10,
            timestamp: DateTime.now(),
          ),
        );
        final destinationPlace = MobilityPlace(
          label: 'Office',
          location: LocationPoint(
            latitude: 24.7500,
            longitude: 46.7000,
            accuracyMeters: 10,
            timestamp: DateTime.now(),
          ),
        );

        final draft = RideDraftUiState(
          pickupLabel: 'Home',
          pickupPlace: pickupPlace,
          destinationQuery: 'Office',
          destinationPlace: destinationPlace,
        );

        controller.startFromDraft(draft);

        // Verify the map snapshot contains the correct locations
        final snapshot = controller.state.mapSnapshot!;
        expect(snapshot.markers.length, 2); // pickup + dropoff

        final pickupMarker = snapshot.markers.firstWhere((m) => m.id.value == 'pickup');
        final dropoffMarker = snapshot.markers.firstWhere((m) => m.id.value == 'dropoff');

        expect(pickupMarker.position.latitude, closeTo(24.7136, 0.001));
        expect(pickupMarker.position.longitude, closeTo(46.6753, 0.001));
        expect(dropoffMarker.position.latitude, closeTo(24.7500, 0.001));
        expect(dropoffMarker.position.longitude, closeTo(46.7000, 0.001));
      });
    });

    // ===========================================================================
    // Track B - Ticket #206: Driver Location & Map Projection Tests
    // ===========================================================================
    group('driver location & map projection - Track B Ticket #206', () {
      test('updateDriverLocation does nothing when no active trip', () {
        final controller = _createRideTripSessionControllerWithMapPort(_RecordingMapPort());

        // No active trip
        expect(controller.state.activeTrip, isNull);
        expect(controller.state.driverLocation, isNull);

        // Try to update driver location
        controller.updateDriverLocation(const GeoPoint(24.7, 46.7));

        // Should remain null and no map sync should occur
        expect(controller.state.driverLocation, isNull);
        expect(controller.state.mapSnapshot, isNull);
      });

      test('updateDriverLocation updates location with active trip and syncs map', () {
        final port = _RecordingMapPort();
        final controller = _createRideTripSessionControllerWithMapPort(port);
        const draft = RideDraftUiState(destinationQuery: 'Test');

        // Start a trip
        controller.startFromDraft(draft);
        expect(controller.state.activeTrip, isNotNull);

        // Initial state
        expect(controller.state.driverLocation, isNull);
        final initialSnapshot = controller.state.mapSnapshot;

        // Update driver location
        const driverPoint = GeoPoint(24.7136, 46.6753);
        controller.updateDriverLocation(driverPoint);

        // Verify location was updated
        expect(controller.state.driverLocation, equals(driverPoint));
        expect(controller.state.hasDriverLocation, isTrue);

        // Verify map was synced (new snapshot created)
        expect(controller.state.mapSnapshot, isNotNull);
        expect(identical(controller.state.mapSnapshot, initialSnapshot), isFalse);

        // Verify MapPort received commands
        expect(port.recordedCommands, isNotEmpty);
      });

      test('clearDriverLocation clears location and syncs map when location exists', () {
        final port = _RecordingMapPort();
        final controller = _createRideTripSessionControllerWithMapPort(port);
        const draft = RideDraftUiState(destinationQuery: 'Test');

        // Start trip and set driver location
        controller.startFromDraft(draft);
        const driverPoint = GeoPoint(24.7136, 46.6753);
        controller.updateDriverLocation(driverPoint);
        expect(controller.state.driverLocation, equals(driverPoint));

        final snapshotWithDriver = controller.state.mapSnapshot;
        final commandsBeforeClear = port.recordedCommands.length;

        // Clear driver location
        controller.clearDriverLocation();

        // Verify location was cleared
        expect(controller.state.driverLocation, isNull);
        expect(controller.state.hasDriverLocation, isFalse);

        // Verify map was synced (new snapshot created)
        expect(controller.state.mapSnapshot, isNotNull);
        expect(identical(controller.state.mapSnapshot, snapshotWithDriver), isFalse);

        // Verify MapPort received more commands
        expect(port.recordedCommands.length, greaterThan(commandsBeforeClear));
      });

      test('clearDriverLocation is idempotent when location is already null', () {
        final port = _RecordingMapPort();
        final controller = _createRideTripSessionControllerWithMapPort(port);

        // No driver location set
        expect(controller.state.driverLocation, isNull);
        final commandsBefore = port.recordedCommands.length;

        // Clear (should do nothing)
        controller.clearDriverLocation();

        // Still null and no map sync
        expect(controller.state.driverLocation, isNull);
        expect(port.recordedCommands.length, equals(commandsBefore));
      });

      test('driver location persists during trip phases', () {
        final controller = _createRideTripSessionControllerForTest();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        // Start trip and set driver location
        controller.startFromDraft(draft);
        const driverPoint = GeoPoint(24.7136, 46.6753);
        controller.updateDriverLocation(driverPoint);
        expect(controller.state.driverLocation, equals(driverPoint));

        // Transition through phases
        controller.applyEvent(RideTripEvent.driverAccepted);
        expect(controller.state.driverLocation, equals(driverPoint));

        controller.applyEvent(RideTripEvent.driverArrived);
        expect(controller.state.driverLocation, equals(driverPoint));

        controller.applyEvent(RideTripEvent.startTrip);
        expect(controller.state.driverLocation, equals(driverPoint));
      });

      test('driver location is cleared when trip completes', () {
        final controller = _createRideTripSessionControllerForTest();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        // Start trip and progress to inProgress phase
        controller.startFromDraft(draft);
        controller.applyEvent(RideTripEvent.driverAccepted);
        controller.applyEvent(RideTripEvent.driverArrived);
        controller.applyEvent(RideTripEvent.startTrip);
        expect(controller.state.activeTrip?.phase, RideTripPhase.inProgress);

        // Set driver location
        const driverPoint = GeoPoint(24.7136, 46.6753);
        controller.updateDriverLocation(driverPoint);
        expect(controller.state.driverLocation, equals(driverPoint));

        // Complete the trip
        final result = controller.completeCurrentTrip();
        expect(result, isTrue);

        // Driver location should be cleared along with other session state
        expect(controller.state.driverLocation, isNull);
        expect(controller.state.activeTrip, isNull);
        expect(controller.state.tripSummary, isNull);
      });

      test('driver location is cleared when trip is cancelled', () {
        final controller = _createRideTripSessionControllerForTest();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        // Start trip and set driver location
        controller.startFromDraft(draft);
        const driverPoint = GeoPoint(24.7136, 46.6753);
        controller.updateDriverLocation(driverPoint);

        // Cancel the trip
        controller.cancelCurrentTrip();

        // Driver location should be cleared
        expect(controller.state.driverLocation, isNull);
        expect(controller.state.activeTrip, isNull);
      });

      test('driver location is cleared when trip fails', () {
        final controller = _createRideTripSessionControllerForTest();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        // Start trip and set driver location
        controller.startFromDraft(draft);
        const driverPoint = GeoPoint(24.7136, 46.6753);
        controller.updateDriverLocation(driverPoint);

        // Fail the trip
        controller.failCurrentTrip();

        // Driver location should be cleared
        expect(controller.state.driverLocation, isNull);
        expect(controller.state.activeTrip, isNull);
      });

      test('driver location is cleared on manual session clear', () {
        final controller = _createRideTripSessionControllerForTest();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        // Start trip and set driver location
        controller.startFromDraft(draft);
        const driverPoint = GeoPoint(24.7136, 46.6753);
        controller.updateDriverLocation(driverPoint);
        expect(controller.state.driverLocation, equals(driverPoint));

        // Clear session
        controller.clear();

        // Driver location should be cleared
        expect(controller.state.driverLocation, isNull);
      });
    });
  });

  // ==========================================================================
  group('RideTripSessionController - Pricing Integration (Ticket #211)', () {
    late MockRidePricingService mockPricingService;

    setUp(() {
      mockPricingService = MockRidePricingService();
    });

    RideTripSessionController createControllerWithMockPricing() {
      final container = ProviderContainer(
        overrides: [
          ridePricingServiceProvider.overrideWithValue(mockPricingService),
          rideMapPortProvider.overrideWithValue(_RecordingMapPort()),
        ],
      );
      addTearDown(container.dispose);
      return container.read(rideTripSessionProvider.notifier);
    }

    test('successful quote request sets activeQuote and clears isQuoting', () async {
      final controller = createControllerWithMockPricing();

      // Create a draft with valid pickup/dropoff
      final draft = RideDraftUiState(
        pickupPlace: MobilityPlace(
          id: 'pickup',
          label: 'Pickup',
          address: 'Pickup Address',
          location: LocationPoint(
            latitude: 24.7136,
            longitude: 46.6753,
            accuracyMeters: 10,
            timestamp: DateTime.now(),
          ),
          type: MobilityPlaceType.recent,
        ),
        destinationPlace: MobilityPlace(
          id: 'dropoff',
          label: 'Dropoff',
          address: 'Dropoff Address',
          location: LocationPoint(
            latitude: 24.7743,
            longitude: 46.7386,
            accuracyMeters: 10,
            timestamp: DateTime.now(),
          ),
          type: MobilityPlaceType.recent,
        ),
        destinationQuery: 'Test destination',
      );

      controller.state = controller.state.copyWith(draftSnapshot: draft);

      // Setup mock to return success
      final mockQuote = createMobilityTestQuote();
      // For the pricing service mock, we need to create a pricing.RideQuote
      // This is only for the mock service - the UI uses mobility.RideQuote
      final pricingQuote = pricing.RideQuote(
        id: mockQuote.quoteId,
        price: Amount(mockQuote.recommendedOption!.priceMinorUnits, mockQuote.recommendedOption!.currencyCode),
        estimatedDuration: Duration(minutes: mockQuote.recommendedOption!.etaMinutes),
        distanceMeters: 5000,
        surgeMultiplier: 1.0,
      );
      mockPricingService.result = pricing.RideQuoteResult.success(pricingQuote);

      // Request quote
      final result = await controller.requestQuoteForCurrentDraft();

      // Verify success
      expect(result, isTrue);
      expect(controller.state.isQuoting, isFalse);
      expect(controller.state.activeQuote, equals(mockQuote));
      expect(controller.state.lastQuoteFailure, isNull);
    });

    test('network error failure sets lastQuoteFailure and clears activeQuote', () async {
      final controller = createControllerWithMockPricing();

      // Create a draft with valid pickup/dropoff
      final draft = RideDraftUiState(
        pickupPlace: MobilityPlace(
          id: 'pickup',
          label: 'Pickup',
          address: 'Pickup Address',
          location: LocationPoint(
            latitude: 24.7136,
            longitude: 46.6753,
            accuracyMeters: 10,
            timestamp: DateTime.now(),
          ),
          type: MobilityPlaceType.recent,
        ),
        destinationPlace: MobilityPlace(
          id: 'dropoff',
          label: 'Dropoff',
          address: 'Dropoff Address',
          location: LocationPoint(
            latitude: 24.7743,
            longitude: 46.7386,
            accuracyMeters: 10,
            timestamp: DateTime.now(),
          ),
          type: MobilityPlaceType.recent,
        ),
        destinationQuery: 'Test destination',
      );

      controller.state = controller.state.copyWith(draftSnapshot: draft);

      // Setup mock to return network error
      mockPricingService.result = const pricing.RideQuoteResult.failure(pricing.RideQuoteFailureReason.networkError);

      // Request quote
      final result = await controller.requestQuoteForCurrentDraft();

      // Verify failure
      expect(result, isFalse);
      expect(controller.state.isQuoting, isFalse);
      expect(controller.state.activeQuote, isNull);
      expect(controller.state.lastQuoteFailure, equals(pricing.RideQuoteFailureReason.networkError));
    });

    test('invalid request (pickup == dropoff) fails immediately', () async {
      final controller = createControllerWithMockPricing();

      // Create a draft with same pickup and dropoff
      final sameLocation = LocationPoint(
        latitude: 24.7136,
        longitude: 46.6753,
        accuracyMeters: 10,
        timestamp: DateTime.now(),
      );
      final draft = RideDraftUiState(
        pickupPlace: MobilityPlace(
          id: 'pickup',
          label: 'Pickup',
          address: 'Pickup Address',
          location: sameLocation,
          type: MobilityPlaceType.recent,
        ),
        destinationPlace: MobilityPlace(
          id: 'dropoff',
          label: 'Dropoff',
          address: 'Dropoff Address',
          location: sameLocation, // Same as pickup
          type: MobilityPlaceType.recent,
        ),
        destinationQuery: 'Test destination',
      );

      controller.state = controller.state.copyWith(draftSnapshot: draft);

      // Request quote - should fail without calling service
      final result = await controller.requestQuoteForCurrentDraft();

      // Verify immediate failure
      expect(result, isFalse);
      expect(controller.state.isQuoting, isFalse);
      expect(controller.state.activeQuote, isNull);
      expect(controller.state.lastQuoteFailure, equals(pricing.RideQuoteFailureReason.invalidRequest));

      // Verify service was not called
      expect(mockPricingService.callCount, equals(0));
    });

    test('stale response is ignored when draft changes', () async {
      final controller = createControllerWithMockPricing();

      // Create initial draft
      final draft1 = RideDraftUiState(
        pickupPlace: MobilityPlace(
          id: 'pickup1',
          label: 'Pickup 1',
          address: 'Pickup Address 1',
          location: LocationPoint(
            latitude: 24.7136,
            longitude: 46.6753,
            accuracyMeters: 10,
            timestamp: DateTime.now(),
          ),
          type: MobilityPlaceType.recent,
        ),
        destinationPlace: MobilityPlace(
          id: 'dropoff1',
          label: 'Dropoff 1',
          address: 'Dropoff Address 1',
          location: LocationPoint(
            latitude: 24.7743,
            longitude: 46.7386,
            accuracyMeters: 10,
            timestamp: DateTime.now(),
          ),
          type: MobilityPlaceType.recent,
        ),
        destinationQuery: 'Test destination 1',
      );

      controller.state = controller.state.copyWith(draftSnapshot: draft1);

      // Setup mock to return success after delay
      const pricingQuote = pricing.RideQuote(
        id: 'stale-quote',
        price: Amount(2500, 'SAR'),
        estimatedDuration: Duration(minutes: 15),
        distanceMeters: 5000,
        surgeMultiplier: 1.0,
      );

      // Create a service that completes after we change the draft
      mockPricingService.result = const pricing.RideQuoteResult.success(pricingQuote);
      mockPricingService.delay = const Duration(milliseconds: 10);

      // Start quote request
      final future = controller.requestQuoteForCurrentDraft();

      // Immediately change the draft (simulating user changing destination)
      final draft2 = RideDraftUiState(
        pickupPlace: MobilityPlace(
          id: 'pickup2',
          label: 'Pickup 2',
          address: 'Pickup Address 2',
          location: LocationPoint(
            latitude: 24.7136,
            longitude: 46.6753,
            accuracyMeters: 10,
            timestamp: DateTime.now(),
          ),
          type: MobilityPlaceType.recent,
        ),
        destinationPlace: MobilityPlace(
          id: 'dropoff2',
          label: 'Dropoff 2',
          address: 'Dropoff Address 2',
          location: LocationPoint(
            latitude: 24.8,
            longitude: 46.8,
            accuracyMeters: 10,
            timestamp: DateTime.now(),
          ),
          type: MobilityPlaceType.recent,
        ),
        destinationQuery: 'Test destination 2',
      );

      controller.state = controller.state.copyWith(draftSnapshot: draft2);

      // Wait for the original request to complete
      final result = await future;

      // The result should be false (stale response ignored)
      expect(result, isFalse);

      // State should not be updated with the stale quote
      expect(controller.state.activeQuote, isNull);
      expect(controller.state.isQuoting, isFalse);
    });

    test('pricing state is cleared when trip completes', () {
      final controller = createControllerWithMockPricing();

      // Start a trip and progress it to inProgress phase
      const draft = RideDraftUiState(destinationQuery: 'Test');
      controller.startFromDraft(draft);
      controller.applyEvent(RideTripEvent.driverAccepted);
      controller.applyEvent(RideTripEvent.driverArrived);
      controller.applyEvent(RideTripEvent.startTrip);
      expect(controller.state.activeTrip?.phase, RideTripPhase.inProgress);

      // Set some pricing state
      final mockQuote = createMobilityTestQuote();

      controller.state = controller.state.copyWith(
        activeQuote: mockQuote,
        lastQuoteFailure: pricing.RideQuoteFailureReason.networkError,
        isQuoting: true,
      );

      // Complete the trip
      final result = controller.completeCurrentTrip();
      expect(result, isTrue);

      // Pricing state should be cleared
      expect(controller.state.activeQuote, isNull);
      expect(controller.state.lastQuoteFailure, isNull);
      expect(controller.state.isQuoting, isFalse);
    });

    test('pricing state is cleared when trip is cancelled', () {
      final controller = createControllerWithMockPricing();

      // Start a trip
      const draft = RideDraftUiState(destinationQuery: 'Test');
      controller.startFromDraft(draft);

      // Set some pricing state
      final mockQuote = createMobilityTestQuote();

      controller.state = controller.state.copyWith(
        activeQuote: mockQuote,
        lastQuoteFailure: pricing.RideQuoteFailureReason.networkError,
        isQuoting: true,
      );

      // Cancel the trip
      final result = controller.cancelCurrentTrip();
      expect(result, isTrue);

      // Pricing state should be cleared
      expect(controller.state.activeQuote, isNull);
      expect(controller.state.lastQuoteFailure, isNull);
      expect(controller.state.isQuoting, isFalse);
    });

    test('pricing state is cleared when trip fails', () {
      final controller = createControllerWithMockPricing();

      // Start a trip
      const draft = RideDraftUiState(destinationQuery: 'Test');
      controller.startFromDraft(draft);

      // Set some pricing state
      final mockQuote = createMobilityTestQuote();

      controller.state = controller.state.copyWith(
        activeQuote: mockQuote,
        lastQuoteFailure: pricing.RideQuoteFailureReason.networkError,
        isQuoting: true,
      );

      // Fail the trip
      final result = controller.failCurrentTrip();
      expect(result, isTrue);

      // Pricing state should be cleared
      expect(controller.state.activeQuote, isNull);
      expect(controller.state.lastQuoteFailure, isNull);
      expect(controller.state.isQuoting, isFalse);
    });

    test('pricing state is cleared when session is cleared', () {
      final controller = createControllerWithMockPricing();

      // Set some pricing state without a trip
      final mockQuote = createMobilityTestQuote();

      controller.state = controller.state.copyWith(
        activeQuote: mockQuote,
        lastQuoteFailure: pricing.RideQuoteFailureReason.networkError,
        isQuoting: true,
      );

      // Clear the session
      controller.clear();

      // Pricing state should be cleared
      expect(controller.state.activeQuote, isNull);
      expect(controller.state.lastQuoteFailure, isNull);
      expect(controller.state.isQuoting, isFalse);
    });
  });
}


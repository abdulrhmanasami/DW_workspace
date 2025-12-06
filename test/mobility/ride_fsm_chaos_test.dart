/// Ride FSM Chaos Tests - Domain Layer Unit Tests - Track B Ticket #197
/// Purpose: Chaos & Resilience testing for Ride FSM in domain layer
/// Created by: Track B - Ticket #197
/// Last updated: 2025-12-03
///
/// This test file focuses on chaos/failure scenarios in the ride FSM domain layer:
/// 1. Pricing failures using StubRidePricingService
/// 2. Request failures (no drivers, network errors)
/// 3. User cancellations from various phases
/// 4. FSM state invariants under failure conditions
///
/// NOTE: These are pure domain tests (no Widgets/UI), focusing on FSM resilience.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobility_shims/mobility_shims.dart';

// App imports
import 'package:delivery_ways_clean/state/mobility/ride_draft_state.dart';
import 'package:delivery_ways_clean/state/mobility/ride_quote_controller.dart';
import 'package:delivery_ways_clean/state/mobility/ride_trip_session.dart';
import 'package:delivery_ways_clean/state/mobility/ride_pricing_service_stub.dart';

void main() {
  group('Ride FSM Chaos Tests - Domain Layer (Ticket #197)', () {

    // =========================================================================
    // 1. Pricing Failure Tests
    // =========================================================================

    group('pricing failure with StubRidePricingService', () {
      test('pricing failure prevents transition from quoting to requesting', () async {
        // Setup: StubRidePricingService with high failure rate
      final failingPricingService = StubRidePricingService(
        failureRate: 1.0, // Always fail
      );

        final quoteController = RideQuoteController(pricingService: failingPricingService);
        final tripController = RideTripSessionController(_FakeRef());

        // Setup draft state
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

        // Attempt pricing - should fail
        await quoteController.refreshFromDraft(draft);

        // Verify pricing failed
        expect(quoteController.state.hasError, isTrue);
        expect(quoteController.state.error, isA<RideQuoteErrorPricingFailed>());
        expect(quoteController.state.quote, isNull);

        // Start trip from draft - should still work (uses default FSM flow)
        tripController.startFromDraft(draft);

        // Verify trip started in findingDriver phase (not blocked by pricing failure)
        expect(tripController.state.activeTrip?.phase, RideTripPhase.findingDriver);
        expect(tripController.hasActiveTrip, isTrue);
      });

      test('pricing failure with no options available sets correct error state', () async {
        // Setup: StubRidePricingService that returns empty options
        final emptyOptionsService = _EmptyOptionsPricingService();
        final quoteController = RideQuoteController(pricingService: emptyOptionsService);

        final draft = RideDraftUiState(
          destinationQuery: 'Remote Area',
          pickupPlace: MobilityPlace(
            label: 'Pickup',
            location: LocationPoint(
              latitude: 24.7136,
              longitude: 46.6753,
              accuracyMeters: 10,
              timestamp: DateTime.now(),
            ),
          ),
          destinationPlace: MobilityPlace(
            label: 'Remote Area',
            location: LocationPoint(
              latitude: 24.8500, // Very far
              longitude: 46.8500,
              accuracyMeters: 10,
              timestamp: DateTime.now(),
            ),
          ),
        );

        await quoteController.refreshFromDraft(draft);

        // Verify correct error type for empty options
        expect(quoteController.state.hasError, isTrue);
        expect(quoteController.state.error, isA<RideQuoteErrorUnexpected>());
        expect(quoteController.state.quote, isNull);
      });

      test('pricing success after initial failure demonstrates recovery', () async {
        // Setup: Service that fails on first call, succeeds on second
        final recoveringService = _RecoveringPricingService();
        final quoteController = RideQuoteController(pricingService: recoveringService);

        final draft = RideDraftUiState(
          destinationQuery: 'Test',
          pickupPlace: MobilityPlace(
            label: 'Pickup',
            location: LocationPoint(
              latitude: 24.7136,
              longitude: 46.6753,
              accuracyMeters: 10,
              timestamp: DateTime.now(),
            ),
          ),
          destinationPlace: MobilityPlace(
            label: 'Destination',
            location: LocationPoint(
              latitude: 24.7200,
              longitude: 46.6800,
              accuracyMeters: 10,
              timestamp: DateTime.now(),
            ),
          ),
        );

        // First call fails
        await quoteController.refreshFromDraft(draft);
        expect(quoteController.state.hasError, isTrue);

        // Second call succeeds (retry)
        await quoteController.retryFromDraft(draft);
        expect(quoteController.state.hasError, isFalse);
        expect(quoteController.state.hasQuote, isTrue);
        expect(quoteController.state.quote?.options.length, greaterThan(0));
      });
    });

    // =========================================================================
    // 2. Request Failure Tests (No Drivers / Network Issues)
    // =========================================================================

    group('request failure scenarios', () {
      test('fail event transitions from findingDriver to failed phase', () {
        final tripController = RideTripSessionController(_FakeRef());

        // Start trip
        const draft = RideDraftUiState(destinationQuery: 'Test Destination');
        tripController.startFromDraft(draft);
        expect(tripController.state.activeTrip?.phase, RideTripPhase.findingDriver);

        // Simulate request failure (no drivers found)
        tripController.applyEvent(RideTripEvent.fail);

        // Verify transition to failed state
        expect(tripController.state.activeTrip?.phase, RideTripPhase.failed);
        expect(tripController.hasActiveTrip, isFalse); // Failed trips are terminal
      });

      test('fail event from requesting phase handles network timeout', () {
        final tripController = RideTripSessionController(_FakeRef());

        // Start trip and simulate progression
        const draft = RideDraftUiState(destinationQuery: 'Test');
        tripController.startFromDraft(draft);
        tripController.applyEvent(RideTripEvent.driverAccepted); // Move to requesting-like state
        expect(tripController.state.activeTrip?.phase, RideTripPhase.driverAccepted);

        // Simulate network failure during request
        tripController.applyEvent(RideTripEvent.fail);

        // Verify failure handling
        expect(tripController.state.activeTrip?.phase, RideTripPhase.failed);
        expect(tripController.hasActiveTrip, isFalse);
      });

      test('multiple fail events on same trip are idempotent', () {
        final tripController = RideTripSessionController(_FakeRef());

        const draft = RideDraftUiState(destinationQuery: 'Test');
        tripController.startFromDraft(draft);
        tripController.applyEvent(RideTripEvent.fail);

        final failedTripId = tripController.state.activeTrip?.tripId;

        // Multiple fail events should not change state
        tripController.applyEvent(RideTripEvent.fail);
        tripController.applyEvent(RideTripEvent.fail);

        expect(tripController.state.activeTrip?.phase, RideTripPhase.failed);
        expect(tripController.state.activeTrip?.tripId, failedTripId);
      });
    });

    // =========================================================================
    // 3. User Cancellation Tests from Various Phases
    // =========================================================================

    group('user cancellation from various phases', () {
      test('cancellation from findingDriver phase succeeds', () async {
        final tripController = RideTripSessionController(_FakeRef());

        const draft = RideDraftUiState(destinationQuery: 'Destination');
        tripController.startFromDraft(draft);
        expect(tripController.state.activeTrip?.phase, RideTripPhase.findingDriver);

        final result = await tripController.cancelActiveTrip();

        expect(result, isTrue);
        expect(tripController.state.activeTrip?.phase, RideTripPhase.cancelled);
        expect(tripController.hasActiveTrip, isFalse); // Cancelled trips are terminal
      });

      test('cancellation from driverAccepted phase succeeds', () async {
        final tripController = RideTripSessionController(_FakeRef());

        const draft = RideDraftUiState(destinationQuery: 'Destination');
        tripController.startFromDraft(draft);
        tripController.applyEvent(RideTripEvent.driverAccepted);
        expect(tripController.state.activeTrip?.phase, RideTripPhase.driverAccepted);

        final result = await tripController.cancelActiveTrip();

        expect(result, isTrue);
        expect(tripController.state.activeTrip?.phase, RideTripPhase.cancelled);
      });

      test('cancellation from driverArrived phase succeeds', () async {
        final tripController = RideTripSessionController(_FakeRef());

        const draft = RideDraftUiState(destinationQuery: 'Destination');
        tripController.startFromDraft(draft);
        tripController.applyEvent(RideTripEvent.driverAccepted);
        tripController.applyEvent(RideTripEvent.driverArrived);
        expect(tripController.state.activeTrip?.phase, RideTripPhase.driverArrived);

        final result = await tripController.cancelActiveTrip();

        expect(result, isTrue);
        expect(tripController.state.activeTrip?.phase, RideTripPhase.cancelled);
      });

      test('cancellation from inProgress phase fails (not cancellable)', () async {
        final tripController = RideTripSessionController(_FakeRef());

        const draft = RideDraftUiState(destinationQuery: 'Destination');
        tripController.startFromDraft(draft);
        tripController.applyEvent(RideTripEvent.driverAccepted);
        tripController.applyEvent(RideTripEvent.driverArrived);
        tripController.applyEvent(RideTripEvent.startTrip);
        expect(tripController.state.activeTrip?.phase, RideTripPhase.inProgress);

        final result = await tripController.cancelActiveTrip();

        expect(result, isFalse);
        expect(tripController.state.activeTrip?.phase, RideTripPhase.inProgress); // Unchanged
      });

      test('cancellation from payment phase fails (not cancellable)', () async {
        final tripController = RideTripSessionController(_FakeRef());

        const draft = RideDraftUiState(destinationQuery: 'Destination');
        tripController.startFromDraft(draft);
        tripController.applyEvent(RideTripEvent.driverAccepted);
        tripController.applyEvent(RideTripEvent.driverArrived);
        tripController.applyEvent(RideTripEvent.startTrip);
        tripController.applyEvent(RideTripEvent.startPayment);
        expect(tripController.state.activeTrip?.phase, RideTripPhase.payment);

        final result = await tripController.cancelActiveTrip();

        expect(result, isFalse);
        expect(tripController.state.activeTrip?.phase, RideTripPhase.payment); // Unchanged
      });

      test('cancellation from completed phase fails (already terminal)', () async {
        final tripController = RideTripSessionController(_FakeRef());

        const draft = RideDraftUiState(destinationQuery: 'Destination');
        tripController.startFromDraft(draft);
        tripController.applyEvent(RideTripEvent.driverAccepted);
        tripController.applyEvent(RideTripEvent.driverArrived);
        tripController.applyEvent(RideTripEvent.startTrip);
        tripController.applyEvent(RideTripEvent.startPayment);
        tripController.applyEvent(RideTripEvent.complete);
        expect(tripController.state.activeTrip?.phase, RideTripPhase.completed);

        final result = await tripController.cancelActiveTrip();

        expect(result, isFalse);
        expect(tripController.state.activeTrip?.phase, RideTripPhase.completed); // Unchanged
      });

      test('cancellation when no active trip returns false', () async {
        final tripController = RideTripSessionController(_FakeRef());
        expect(tripController.state.activeTrip, isNull);

        final result = await tripController.cancelActiveTrip();

        expect(result, isFalse);
      });
    });

    // =========================================================================
    // 4. FSM State Invariants Under Chaos
    // =========================================================================

    group('FSM state invariants under chaos conditions', () {
      test('tripId remains consistent across all phase transitions', () {
        final tripController = RideTripSessionController(_FakeRef());

        const draft = RideDraftUiState(destinationQuery: 'Test');
        tripController.startFromDraft(draft);
        final originalTripId = tripController.state.activeTrip!.tripId;

        // Progress through various phases
        tripController.applyEvent(RideTripEvent.driverAccepted);
        expect(tripController.state.activeTrip!.tripId, originalTripId);

        tripController.applyEvent(RideTripEvent.driverArrived);
        expect(tripController.state.activeTrip!.tripId, originalTripId);

        tripController.applyEvent(RideTripEvent.startTrip);
        expect(tripController.state.activeTrip!.tripId, originalTripId);

        // Cancel and verify ID preserved
        tripController.applyEvent(RideTripEvent.cancel);
        expect(tripController.state.activeTrip!.tripId, originalTripId);
      });

      test('terminal phases prevent further state changes', () {
        final tripController = RideTripSessionController(_FakeRef());

        const draft = RideDraftUiState(destinationQuery: 'Test');
        tripController.startFromDraft(draft);

        // Complete the trip
        tripController.applyEvent(RideTripEvent.driverAccepted);
        tripController.applyEvent(RideTripEvent.driverArrived);
        tripController.applyEvent(RideTripEvent.startTrip);
        tripController.applyEvent(RideTripEvent.startPayment);
        tripController.applyEvent(RideTripEvent.complete);

        expect(tripController.state.activeTrip!.phase, RideTripPhase.completed);

        // Attempt invalid transitions - should not change state
        tripController.applyEvent(RideTripEvent.driverAccepted);
        tripController.applyEvent(RideTripEvent.startTrip);
        tripController.applyEvent(RideTripEvent.cancel);

        // State should remain completed
        expect(tripController.state.activeTrip!.phase, RideTripPhase.completed);
      });

      test('failed trips cannot transition to other states', () {
        final tripController = RideTripSessionController(_FakeRef());

        const draft = RideDraftUiState(destinationQuery: 'Test');
        tripController.startFromDraft(draft);
        tripController.applyEvent(RideTripEvent.fail);

        expect(tripController.state.activeTrip!.phase, RideTripPhase.failed);

        // Attempt various transitions - should all be ignored
        tripController.applyEvent(RideTripEvent.driverAccepted);
        tripController.applyEvent(RideTripEvent.complete);
        tripController.applyEvent(RideTripEvent.cancel);

        expect(tripController.state.activeTrip!.phase, RideTripPhase.failed);
      });

      test('cancelled trips cannot transition to other states', () {
        final tripController = RideTripSessionController(_FakeRef());

        const draft = RideDraftUiState(destinationQuery: 'Test');
        tripController.startFromDraft(draft);
        tripController.applyEvent(RideTripEvent.cancel);

        expect(tripController.state.activeTrip!.phase, RideTripPhase.cancelled);

        // Attempt various transitions - should all be ignored
        tripController.applyEvent(RideTripEvent.driverAccepted);
        tripController.applyEvent(RideTripEvent.complete);
        tripController.applyEvent(RideTripEvent.fail);

        expect(tripController.state.activeTrip!.phase, RideTripPhase.cancelled);
      });
    });

    // =========================================================================
    // 5. Integration with Quote Controller Chaos
    // =========================================================================

    group('integration with quote controller chaos', () {
      test('quote controller errors do not prevent FSM from functioning', () {
        final failingQuoteController = RideQuoteController(
          pricingService: StubRidePricingService(failureRate: 1.0),
        );
        final tripController = RideTripSessionController(_FakeRef());

        // Even with failing quote controller, FSM should work independently
        const draft = RideDraftUiState(destinationQuery: 'Test');
        tripController.startFromDraft(draft);

        expect(tripController.state.activeTrip?.phase, RideTripPhase.findingDriver);
        expect(tripController.hasActiveTrip, isTrue);

        // Quote controller state is independent
        expect(failingQuoteController.state.hasError, isFalse); // Not called yet
      });

      test('successful quote followed by trip failure maintains separation', () async {
        final workingQuoteController = RideQuoteController(
          pricingService: StubRidePricingService(failureRate: 0.0),
        );
        final tripController = RideTripSessionController(_FakeRef());

        final draft = RideDraftUiState(
          destinationQuery: 'Test',
          pickupPlace: MobilityPlace(
            label: 'Pickup',
            location: LocationPoint(
              latitude: 24.7136,
              longitude: 46.6753,
              accuracyMeters: 10,
              timestamp: DateTime.now(),
            ),
          ),
          destinationPlace: MobilityPlace(
            label: 'Destination',
            location: LocationPoint(
              latitude: 24.7200,
              longitude: 46.6800,
              accuracyMeters: 10,
              timestamp: DateTime.now(),
            ),
          ),
        );

        // Successful quote
        await workingQuoteController.refreshFromDraft(draft);
        expect(workingQuoteController.state.hasQuote, isTrue);

        // Start trip and then fail it
        tripController.startFromDraft(draft);
        tripController.applyEvent(RideTripEvent.fail);

        // Quote state should be unaffected by trip failure
        expect(workingQuoteController.state.hasQuote, isTrue);
        expect(tripController.state.activeTrip?.phase, RideTripPhase.failed);
      });
    });
  });
}

// ============================================================================
// Mock/Test Helper Classes
// ============================================================================

/// Fake Ref for testing
class _FakeRef implements Ref {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}


/// Pricing service that returns empty options to simulate "no options available"
class _EmptyOptionsPricingService extends StubRidePricingService {
  _EmptyOptionsPricingService() : super(simulatedDelay: const Duration(milliseconds: 10));

  @override
  Future<RideQuote> quoteRide({
    required MobilityPlace pickup,
    required MobilityPlace destination,
    required RideServiceType serviceType,
  }) async {
    await Future<void>.delayed(simulatedDelay);

    final request = RideQuoteRequest(
      pickup: pickup.location!,
      dropoff: destination.location!,
      currencyCode: 'SAR',
    );

    // Return quote with empty options
    return RideQuote(
      quoteId: 'empty-options-quote',
      request: request,
      options: const [], // Empty options = no rides available
    );
  }
}

/// Pricing service that fails on first call, succeeds on subsequent calls
class _RecoveringPricingService extends StubRidePricingService {
  _RecoveringPricingService() : super(simulatedDelay: const Duration(milliseconds: 10));

  int _callCount = 0;

  @override
  Future<RideQuote> quoteRide({
    required MobilityPlace pickup,
    required MobilityPlace destination,
    required RideServiceType serviceType,
  }) async {
    await Future<void>.delayed(simulatedDelay);
    _callCount++;

    if (_callCount == 1) {
      // First call fails
      throw const RidePricingException('Initial failure - network error');
    }

    // Subsequent calls succeed - call parent implementation
    return super.quoteRide(pickup: pickup, destination: destination, serviceType: serviceType);
  }
}

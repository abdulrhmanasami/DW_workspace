/// RideTripSessionController Unit Tests - Track B Tickets #17, #22, #23, #24
/// Purpose: Safety net tests for RideTripSessionController before deeper integration
/// Created by: Track B - Ticket #17
/// Last updated: 2025-11-28
///
/// Extended in Ticket #24 with:
/// - cancelActiveTrip() tests (FSM integration)
/// - rateCurrentTrip() tests
/// - null-safety edge case tests

import 'package:flutter_test/flutter_test.dart';

import 'package:mobility_shims/mobility_shims.dart';

import 'package:delivery_ways_clean/state/mobility/ride_draft_state.dart';
import 'package:delivery_ways_clean/state/mobility/ride_trip_session.dart';

void main() {
  group('RideTripSessionController', () {
    group('initial state', () {
      test('has null activeTrip', () {
        final controller = RideTripSessionController();

        expect(controller.state.activeTrip, isNull);
      });

      test('hasActiveTrip is false', () {
        final controller = RideTripSessionController();

        expect(controller.hasActiveTrip, isFalse);
      });
    });

    group('startFromDraft', () {
      test('creates activeTrip with phase = findingDriver', () {
        final controller = RideTripSessionController();
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
        final controller1 = RideTripSessionController();
        final controller2 = RideTripSessionController();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        controller1.startFromDraft(draft);
        controller2.startFromDraft(draft);

        expect(
          controller1.state.activeTrip!.tripId,
          isNot(equals(controller2.state.activeTrip!.tripId)),
        );
      });

      test('hasActiveTrip becomes true after start', () {
        final controller = RideTripSessionController();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        expect(controller.hasActiveTrip, isFalse);

        controller.startFromDraft(draft);

        expect(controller.hasActiveTrip, isTrue);
      });
    });

    group('applyEvent', () {
      test('transitions phases correctly through happy path', () {
        final controller = RideTripSessionController();
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
        final controller = RideTripSessionController();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        controller.startFromDraft(draft);
        final originalTripId = controller.state.activeTrip!.tripId;

        controller.applyEvent(RideTripEvent.driverAccepted);
        controller.applyEvent(RideTripEvent.driverArrived);
        controller.applyEvent(RideTripEvent.startTrip);

        expect(controller.state.activeTrip!.tripId, equals(originalTripId));
      });

      test('does not throw when applied on null activeTrip', () {
        final controller = RideTripSessionController();
        expect(controller.state.activeTrip, isNull);

        // Should not throw
        controller.applyEvent(RideTripEvent.complete);

        expect(controller.state.activeTrip, isNull);
      });

      test('ignores invalid transitions silently', () {
        final controller = RideTripSessionController();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        controller.startFromDraft(draft);
        expect(controller.state.activeTrip!.phase, RideTripPhase.findingDriver);

        // Invalid: startTrip from findingDriver (should be after driverArrived)
        controller.applyEvent(RideTripEvent.startTrip);

        // Phase should remain unchanged
        expect(controller.state.activeTrip!.phase, RideTripPhase.findingDriver);
      });

      test('cancel from findingDriver leads to cancelled', () {
        final controller = RideTripSessionController();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        controller.startFromDraft(draft);
        expect(controller.state.activeTrip!.phase, RideTripPhase.findingDriver);

        controller.applyEvent(RideTripEvent.cancel);

        expect(controller.state.activeTrip!.phase, RideTripPhase.cancelled);
      });

      test('fail event transitions to failed', () {
        final controller = RideTripSessionController();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        controller.startFromDraft(draft);
        expect(controller.state.activeTrip!.phase, RideTripPhase.findingDriver);

        controller.applyEvent(RideTripEvent.fail);

        expect(controller.state.activeTrip!.phase, RideTripPhase.failed);
      });
    });

    group('hasActiveTrip', () {
      test('returns false for terminal phase: completed', () {
        final controller = RideTripSessionController();
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
        final controller = RideTripSessionController();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        controller.startFromDraft(draft);
        controller.applyEvent(RideTripEvent.cancel);

        expect(controller.state.activeTrip!.phase, RideTripPhase.cancelled);
        expect(controller.hasActiveTrip, isFalse);
      });

      test('returns false for terminal phase: failed', () {
        final controller = RideTripSessionController();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        controller.startFromDraft(draft);
        controller.applyEvent(RideTripEvent.fail);

        expect(controller.state.activeTrip!.phase, RideTripPhase.failed);
        expect(controller.hasActiveTrip, isFalse);
      });
    });

    group('clear', () {
      test('resets session to empty state', () {
        final controller = RideTripSessionController();
        const draft = RideDraftUiState(destinationQuery: 'X');

        controller.startFromDraft(draft);
        expect(controller.state.activeTrip, isNotNull);
        expect(controller.hasActiveTrip, isTrue);

        controller.clear();

        expect(controller.state.activeTrip, isNull);
        expect(controller.hasActiveTrip, isFalse);
      });

      test('clear on fresh controller does nothing harmful', () {
        final controller = RideTripSessionController();

        controller.clear();

        expect(controller.state.activeTrip, isNull);
      });
    });

    group('cancelActiveTrip - Track B Ticket #22, #24', () {
      test('returns true and clears activeTrip when cancellable phase', () async {
        final controller = RideTripSessionController();
        const draft = RideDraftUiState(destinationQuery: 'Test Cancel');

        controller.startFromDraft(draft);
        expect(controller.state.activeTrip!.phase, RideTripPhase.findingDriver);

        final result = await controller.cancelActiveTrip();

        expect(result, isTrue);
        expect(controller.state.activeTrip, isNull);
      });

      test('returns false when activeTrip is null', () async {
        final controller = RideTripSessionController();
        expect(controller.state.activeTrip, isNull);

        final result = await controller.cancelActiveTrip();

        expect(result, isFalse);
        expect(controller.state.activeTrip, isNull);
      });

      test('returns false when phase is inProgress (not cancellable)', () async {
        final controller = RideTripSessionController();
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
        final controller = RideTripSessionController();
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
        final controller = RideTripSessionController();
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

      test('cancels successfully from driverAccepted phase', () async {
        final controller = RideTripSessionController();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        controller.startFromDraft(draft);
        controller.applyEvent(RideTripEvent.driverAccepted);
        expect(controller.state.activeTrip!.phase, RideTripPhase.driverAccepted);

        final result = await controller.cancelActiveTrip();

        expect(result, isTrue);
        expect(controller.state.activeTrip, isNull);
      });

      test('cancels successfully from driverArrived phase', () async {
        final controller = RideTripSessionController();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        controller.startFromDraft(draft);
        controller.applyEvent(RideTripEvent.driverAccepted);
        controller.applyEvent(RideTripEvent.driverArrived);
        expect(controller.state.activeTrip!.phase, RideTripPhase.driverArrived);

        final result = await controller.cancelActiveTrip();

        expect(result, isTrue);
        expect(controller.state.activeTrip, isNull);
      });
    });

    group('rateCurrentTrip - Track B Ticket #23, #24', () {
      test('sets driverRating in state', () {
        final controller = RideTripSessionController();
        const draft = RideDraftUiState(destinationQuery: 'Test Rating');

        controller.startFromDraft(draft);
        expect(controller.state.driverRating, isNull);

        controller.rateCurrentTrip(4);

        expect(controller.state.driverRating, 4);
      });

      test('clamps rating to 1-5 range (minimum)', () {
        final controller = RideTripSessionController();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        controller.startFromDraft(draft);
        controller.rateCurrentTrip(0);

        expect(controller.state.driverRating, 1);
      });

      test('clamps rating to 1-5 range (maximum)', () {
        final controller = RideTripSessionController();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        controller.startFromDraft(draft);
        controller.rateCurrentTrip(10);

        expect(controller.state.driverRating, 5);
      });

      test('does nothing when activeTrip is null', () {
        final controller = RideTripSessionController();
        expect(controller.state.activeTrip, isNull);
        expect(controller.state.driverRating, isNull);

        controller.rateCurrentTrip(5);

        expect(controller.state.driverRating, isNull);
      });

      test('preserves activeTrip when setting rating', () {
        final controller = RideTripSessionController();
        const draft = RideDraftUiState(destinationQuery: 'Test');

        controller.startFromDraft(draft);
        final tripBefore = controller.state.activeTrip;

        controller.rateCurrentTrip(3);

        expect(controller.state.activeTrip?.tripId, tripBefore?.tripId);
        expect(controller.state.activeTrip?.phase, tripBefore?.phase);
        expect(controller.state.driverRating, 3);
      });

      test('can update rating multiple times', () {
        final controller = RideTripSessionController();
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

    group('null-safety edge cases - Track B Ticket #24', () {
      test('applyEvent does not throw when activeTrip is null', () {
        final controller = RideTripSessionController();
        expect(controller.state.activeTrip, isNull);

        // Should not throw
        expect(() => controller.applyEvent(RideTripEvent.complete), returnsNormally);
        expect(controller.state.activeTrip, isNull);
      });

      test('cancelActiveTrip does not throw when activeTrip is null', () async {
        final controller = RideTripSessionController();
        expect(controller.state.activeTrip, isNull);

        // Should not throw
        final result = await controller.cancelActiveTrip();
        expect(result, isFalse);
      });

      test('rateCurrentTrip does not throw when activeTrip is null', () {
        final controller = RideTripSessionController();
        expect(controller.state.activeTrip, isNull);

        // Should not throw
        expect(() => controller.rateCurrentTrip(5), returnsNormally);
        expect(controller.state.driverRating, isNull);
      });

      test('hasActiveTrip does not throw when activeTrip is null', () {
        final controller = RideTripSessionController();
        expect(controller.state.activeTrip, isNull);

        // Should not throw
        expect(() => controller.hasActiveTrip, returnsNormally);
        expect(controller.hasActiveTrip, isFalse);
      });

      test('clear does not throw on already empty state', () {
        final controller = RideTripSessionController();
        expect(controller.state.activeTrip, isNull);

        // Should not throw
        expect(() => controller.clear(), returnsNormally);
        expect(controller.state.activeTrip, isNull);
      });
    });
  });

  group('RideTripSessionUiState', () {
    test('equality is based on tripId and phase', () {
      final trip = RideTripState(
        tripId: 'trip-1',
        phase: RideTripPhase.findingDriver,
      );

      final state1 = RideTripSessionUiState(activeTrip: trip);
      final state2 = RideTripSessionUiState(activeTrip: trip);

      expect(state1, equals(state2));
    });

    test('copyWith clearActiveTrip sets activeTrip to null', () {
      final trip = RideTripState(
        tripId: 'trip-1',
        phase: RideTripPhase.findingDriver,
      );

      final original = RideTripSessionUiState(activeTrip: trip);
      final cleared = original.copyWith(clearActiveTrip: true);

      expect(cleared.activeTrip, isNull);
    });

    test('copyWith clearDriverRating sets driverRating to null', () {
      final trip = RideTripState(
        tripId: 'trip-1',
        phase: RideTripPhase.findingDriver,
      );

      final original = RideTripSessionUiState(
        activeTrip: trip,
        driverRating: 5,
      );
      final cleared = original.copyWith(clearDriverRating: true);

      expect(cleared.driverRating, isNull);
      expect(cleared.activeTrip, isNotNull);
    });

    test('equality includes driverRating', () {
      final trip = RideTripState(
        tripId: 'trip-1',
        phase: RideTripPhase.findingDriver,
      );

      final state1 = RideTripSessionUiState(activeTrip: trip, driverRating: 5);
      final state2 = RideTripSessionUiState(activeTrip: trip, driverRating: 5);
      final state3 = RideTripSessionUiState(activeTrip: trip, driverRating: 3);

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });

    test('toString includes driverRating', () {
      final trip = RideTripState(
        tripId: 'trip-1',
        phase: RideTripPhase.completed,
      );

      final state = RideTripSessionUiState(
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
        selectedOptionId: 'economy',
      );

      // 2. Create MockRidePricingService with zero latency for fast tests
      const pricingService = MockRidePricingService(
        baseLatency: Duration.zero,
        failureRate: 0.0,
      );

      // 3. Request quote using the pricing service
      final quote = await pricingService.quoteRide(
        pickup: pickupPlace,
        destination: destinationPlace,
        serviceType: RideServiceType.economy,
      );

      expect(quote, isNotNull);
      expect(quote.options, isNotEmpty);

      // 4. Get selected option from quote
      final selectedOption = quote.optionById('economy') ?? quote.recommendedOption;
      expect(selectedOption, isNotNull);

      // 5. Create trip session controller and start trip from draft
      final tripController = RideTripSessionController();
      tripController.startFromDraft(draft);

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

    test('full flow with cancellation at findingDriver phase', () {
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
      final tripController = RideTripSessionController();
      tripController.startFromDraft(draft);

      expect(tripController.state.activeTrip?.phase, RideTripPhase.findingDriver);

      // Cancel trip
      final result = tripController.cancelActiveTrip();

      expect(result, isA<Future<bool>>());
      // cancelActiveTrip clears the active trip
      expect(tripController.state.activeTrip, isNull);
      expect(tripController.hasActiveTrip, isFalse);
    });

    test('full flow with failure event', () {
      // Setup draft
      final draft = RideDraftUiState(
        pickupLabel: 'Start',
        destinationQuery: 'End',
      );

      // Start trip
      final tripController = RideTripSessionController();
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
}


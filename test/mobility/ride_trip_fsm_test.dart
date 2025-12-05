/// RideTrip FSM Unit Tests (App Layer) - Track B Ticket #24, #116
/// Purpose: App-level FSM tests complementing the shims-level tests
/// Created by: Track B - Ticket #24
/// Updated by: Track B - Ticket #116 (Complete FSM validation + isTerminal tests)
/// Last updated: 2025-11-30

import 'package:mobility_shims/mobility_shims.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RideTrip FSM', () {
    test('draft → quoting → requesting → findingDriver → driverAccepted → '
        'driverArrived → inProgress → payment → completed', () {
      var state = const RideTripState(
        tripId: 'trip-1',
        phase: RideTripPhase.draft,
      );

      state = applyRideTripEvent(state, RideTripEvent.requestQuote);
      expect(state.phase, RideTripPhase.quoting);

      state = applyRideTripEvent(state, RideTripEvent.quoteReceived);
      expect(state.phase, RideTripPhase.requesting);

      state = applyRideTripEvent(state, RideTripEvent.submitRequest);
      expect(state.phase, RideTripPhase.findingDriver);

      state = applyRideTripEvent(state, RideTripEvent.driverAccepted);
      expect(state.phase, RideTripPhase.driverAccepted);

      state = applyRideTripEvent(state, RideTripEvent.driverArrived);
      expect(state.phase, RideTripPhase.driverArrived);

      state = applyRideTripEvent(state, RideTripEvent.startTrip);
      expect(state.phase, RideTripPhase.inProgress);

      state = applyRideTripEvent(state, RideTripEvent.startPayment);
      expect(state.phase, RideTripPhase.payment);

      state = applyRideTripEvent(state, RideTripEvent.complete);
      expect(state.phase, RideTripPhase.completed);
    });

    test('cancel from draft leads to cancelled', () {
      const initial = RideTripState(
        tripId: 'trip-2',
        phase: RideTripPhase.draft,
      );

      final cancelled = applyRideTripEvent(initial, RideTripEvent.cancel);

      expect(cancelled.phase, RideTripPhase.cancelled);
      expect(cancelled.tripId, initial.tripId);
    });

    test('fail from quoting leads to failed', () {
      const initial = RideTripState(
        tripId: 'trip-3',
        phase: RideTripPhase.quoting,
      );

      final failed = applyRideTripEvent(initial, RideTripEvent.fail);

      expect(failed.phase, RideTripPhase.failed);
    });

    test('terminal states do not accept further events', () {
      const completed = RideTripState(
        tripId: 'trip-4',
        phase: RideTripPhase.completed,
      );

      expect(
        () => applyRideTripEvent(completed, RideTripEvent.requestQuote),
        throwsA(isA<InvalidRideTransitionException>()),
      );
    });

    test('invalid transition throws InvalidRideTransitionException', () {
      const state = RideTripState(
        tripId: 'trip-5',
        phase: RideTripPhase.draft,
      );

      expect(
        () => applyRideTripEvent(state, RideTripEvent.submitRequest),
        throwsA(isA<InvalidRideTransitionException>()),
      );
    });

    group('cancel transitions', () {
      test('cancel from quoting', () {
        const state = RideTripState(tripId: 't', phase: RideTripPhase.quoting);
        final result = applyRideTripEvent(state, RideTripEvent.cancel);
        expect(result.phase, RideTripPhase.cancelled);
      });

      test('cancel from requesting', () {
        const state =
            RideTripState(tripId: 't', phase: RideTripPhase.requesting);
        final result = applyRideTripEvent(state, RideTripEvent.cancel);
        expect(result.phase, RideTripPhase.cancelled);
      });

      test('cancel from findingDriver', () {
        const state =
            RideTripState(tripId: 't', phase: RideTripPhase.findingDriver);
        final result = applyRideTripEvent(state, RideTripEvent.cancel);
        expect(result.phase, RideTripPhase.cancelled);
      });

      test('cancel from driverAccepted', () {
        const state =
            RideTripState(tripId: 't', phase: RideTripPhase.driverAccepted);
        final result = applyRideTripEvent(state, RideTripEvent.cancel);
        expect(result.phase, RideTripPhase.cancelled);
      });

      test('cancel from driverArrived', () {
        const state =
            RideTripState(tripId: 't', phase: RideTripPhase.driverArrived);
        final result = applyRideTripEvent(state, RideTripEvent.cancel);
        expect(result.phase, RideTripPhase.cancelled);
      });

      test('cannot cancel from inProgress', () {
        const state =
            RideTripState(tripId: 't', phase: RideTripPhase.inProgress);
        expect(
          () => applyRideTripEvent(state, RideTripEvent.cancel),
          throwsA(isA<InvalidRideTransitionException>()),
        );
      });
    });

    group('fail transitions', () {
      test('fail from any non-terminal state', () {
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
          final state = RideTripState(tripId: 't', phase: phase);
          final result = applyRideTripEvent(state, RideTripEvent.fail);
          expect(result.phase, RideTripPhase.failed,
              reason: 'fail from $phase should lead to failed');
        }
      });
    });

    group('RideTripState', () {
      test('copyWith preserves unchanged values', () {
        const original = RideTripState(
          tripId: 'original-id',
          phase: RideTripPhase.draft,
        );

        final copied = original.copyWith(phase: RideTripPhase.quoting);

        expect(copied.tripId, 'original-id');
        expect(copied.phase, RideTripPhase.quoting);
      });

      test('copyWith can update tripId', () {
        const original = RideTripState(
          tripId: 'old-id',
          phase: RideTripPhase.draft,
        );

        final copied = original.copyWith(tripId: 'new-id');

        expect(copied.tripId, 'new-id');
        expect(copied.phase, RideTripPhase.draft);
      });
    });

    group('InvalidRideTransitionException', () {
      test('toString contains useful information', () {
        final exception = InvalidRideTransitionException(
          RideTripPhase.draft,
          RideTripEvent.complete,
        );

        expect(exception.toString(), contains('draft'));
        expect(exception.toString(), contains('complete'));
        expect(exception.toString(), contains('InvalidRideTransitionException'));
      });

      test('exposes from and to fields', () {
        final exception = InvalidRideTransitionException(
          RideTripPhase.quoting,
          RideTripEvent.startTrip,
        );

        expect(exception.from, RideTripPhase.quoting);
        expect(exception.to, RideTripEvent.startTrip);
      });
    });

    // =========================================================================
    // Track B - Ticket #116: isTerminal Tests
    // =========================================================================

    group('isTerminal (Ticket #116)', () {
      test('returns true only for terminal phases', () {
        expect(RideTripPhase.completed.isTerminal, isTrue);
        expect(RideTripPhase.cancelled.isTerminal, isTrue);
        expect(RideTripPhase.failed.isTerminal, isTrue);
      });

      test('returns false for all non-terminal phases', () {
        final nonTerminal = <RideTripPhase>[
          RideTripPhase.draft,
          RideTripPhase.quoting,
          RideTripPhase.requesting,
          RideTripPhase.findingDriver,
          RideTripPhase.driverAccepted,
          RideTripPhase.driverArrived,
          RideTripPhase.inProgress,
          RideTripPhase.payment,
        ];

        for (final phase in nonTerminal) {
          expect(phase.isTerminal, isFalse, reason: '$phase must not be terminal');
        }
      });
    });

    // =========================================================================
    // Track B - Ticket #116: Additional Domain Helpers Tests
    // =========================================================================

    group('isPreDriver (Ticket #116)', () {
      test('returns true for phases before driver assignment', () {
        expect(RideTripPhase.draft.isPreDriver, isTrue);
        expect(RideTripPhase.quoting.isPreDriver, isTrue);
        expect(RideTripPhase.requesting.isPreDriver, isTrue);
        expect(RideTripPhase.findingDriver.isPreDriver, isTrue);
      });

      test('returns false after driver is assigned', () {
        expect(RideTripPhase.driverAccepted.isPreDriver, isFalse);
        expect(RideTripPhase.driverArrived.isPreDriver, isFalse);
        expect(RideTripPhase.inProgress.isPreDriver, isFalse);
        expect(RideTripPhase.payment.isPreDriver, isFalse);
        expect(RideTripPhase.completed.isPreDriver, isFalse);
      });
    });

    group('isWithDriver (Ticket #116)', () {
      test('returns true when driver is actively participating', () {
        expect(RideTripPhase.driverAccepted.isWithDriver, isTrue);
        expect(RideTripPhase.driverArrived.isWithDriver, isTrue);
        expect(RideTripPhase.inProgress.isWithDriver, isTrue);
      });

      test('returns false when driver is not actively participating', () {
        expect(RideTripPhase.draft.isWithDriver, isFalse);
        expect(RideTripPhase.quoting.isWithDriver, isFalse);
        expect(RideTripPhase.requesting.isWithDriver, isFalse);
        expect(RideTripPhase.findingDriver.isWithDriver, isFalse);
        expect(RideTripPhase.payment.isWithDriver, isFalse);
        expect(RideTripPhase.completed.isWithDriver, isFalse);
      });
    });

    group('isPaymentPhase (Ticket #116)', () {
      test('returns true only for payment phase', () {
        expect(RideTripPhase.payment.isPaymentPhase, isTrue);
      });

      test('returns false for all other phases', () {
        final otherPhases = RideTripPhase.values
            .where((p) => p != RideTripPhase.payment)
            .toList();

        for (final phase in otherPhases) {
          expect(phase.isPaymentPhase, isFalse,
              reason: '$phase should not be payment phase');
        }
      });
    });
  });
}


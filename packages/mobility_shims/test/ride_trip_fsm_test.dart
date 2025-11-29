/// RideTrip FSM Unit Tests - Track B Ticket #24
/// Purpose: Comprehensive domain-level tests for the Ride FSM
/// Created by: Track B - Ticket #24
/// Last updated: 2025-11-28
///
/// This file tests the canonical FSM for ride lifecycle transitions.
/// All tests are domain-level and do not depend on UI or backend.

import 'package:mobility_shims/mobility_shims.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RideTrip FSM', () {
    group('Happy Path - Full Journey', () {
      test('draft → quoting → requesting → findingDriver → driverAccepted → '
          'driverArrived → inProgress → payment → completed', () {
        var state = RideTripState(
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

      test('tripId is preserved through all transitions', () {
        const testTripId = 'persistent-trip-id';
        var state = RideTripState(
          tripId: testTripId,
          phase: RideTripPhase.draft,
        );

        state = applyRideTripEvent(state, RideTripEvent.requestQuote);
        expect(state.tripId, testTripId);

        state = applyRideTripEvent(state, RideTripEvent.quoteReceived);
        expect(state.tripId, testTripId);

        state = applyRideTripEvent(state, RideTripEvent.submitRequest);
        expect(state.tripId, testTripId);

        state = applyRideTripEvent(state, RideTripEvent.driverAccepted);
        expect(state.tripId, testTripId);

        state = applyRideTripEvent(state, RideTripEvent.driverArrived);
        expect(state.tripId, testTripId);

        state = applyRideTripEvent(state, RideTripEvent.startTrip);
        expect(state.tripId, testTripId);

        state = applyRideTripEvent(state, RideTripEvent.startPayment);
        expect(state.tripId, testTripId);

        state = applyRideTripEvent(state, RideTripEvent.complete);
        expect(state.tripId, testTripId);
      });

      test('each phase transition creates new state instance', () {
        final initial =
            RideTripState(tripId: 'trip-immutable', phase: RideTripPhase.draft);

        final next =
            applyRideTripEvent(initial, RideTripEvent.requestQuote);

        expect(identical(initial, next), isFalse);
        expect(initial.phase, RideTripPhase.draft); // unchanged
        expect(next.phase, RideTripPhase.quoting);
      });
    });

    group('Invalid Transitions - Explicit Tests', () {
      test('draft → driverArrived is invalid (skipping phases)', () {
        final state =
            RideTripState(tripId: 'trip-invalid-1', phase: RideTripPhase.draft);

        expect(
          () => applyRideTripEvent(state, RideTripEvent.driverArrived),
          throwsA(isA<InvalidRideTransitionException>()),
        );
      });

      test('draft → startTrip is invalid', () {
        final state =
            RideTripState(tripId: 'trip-invalid-2', phase: RideTripPhase.draft);

        expect(
          () => applyRideTripEvent(state, RideTripEvent.startTrip),
          throwsA(isA<InvalidRideTransitionException>()),
        );
      });

      test('draft → complete is invalid', () {
        final state =
            RideTripState(tripId: 'trip-invalid-3', phase: RideTripPhase.draft);

        expect(
          () => applyRideTripEvent(state, RideTripEvent.complete),
          throwsA(isA<InvalidRideTransitionException>()),
        );
      });

      test('inProgress → draft is invalid (backwards transition)', () {
        final state = RideTripState(
            tripId: 'trip-invalid-4', phase: RideTripPhase.inProgress);

        expect(
          () => applyRideTripEvent(state, RideTripEvent.requestQuote),
          throwsA(isA<InvalidRideTransitionException>()),
        );
      });

      test('payment → driverAccepted is invalid (backwards transition)', () {
        final state =
            RideTripState(tripId: 'trip-invalid-5', phase: RideTripPhase.payment);

        expect(
          () => applyRideTripEvent(state, RideTripEvent.driverAccepted),
          throwsA(isA<InvalidRideTransitionException>()),
        );
      });

      test('findingDriver → quoteReceived is invalid (wrong direction)', () {
        final state = RideTripState(
            tripId: 'trip-invalid-6', phase: RideTripPhase.findingDriver);

        expect(
          () => applyRideTripEvent(state, RideTripEvent.quoteReceived),
          throwsA(isA<InvalidRideTransitionException>()),
        );
      });

      test('quoting → driverAccepted is invalid (skipping phases)', () {
        final state =
            RideTripState(tripId: 'trip-invalid-7', phase: RideTripPhase.quoting);

        expect(
          () => applyRideTripEvent(state, RideTripEvent.driverAccepted),
          throwsA(isA<InvalidRideTransitionException>()),
        );
      });

      test('driverArrived → complete is invalid (skipping inProgress and payment)',
          () {
        final state = RideTripState(
            tripId: 'trip-invalid-8', phase: RideTripPhase.driverArrived);

        expect(
          () => applyRideTripEvent(state, RideTripEvent.complete),
          throwsA(isA<InvalidRideTransitionException>()),
        );
      });

      test('requesting → inProgress is invalid (skipping driver phases)', () {
        final state = RideTripState(
            tripId: 'trip-invalid-9', phase: RideTripPhase.requesting);

        expect(
          () => applyRideTripEvent(state, RideTripEvent.startTrip),
          throwsA(isA<InvalidRideTransitionException>()),
        );
      });
    });

    test('cancel from draft leads to cancelled', () {
      final initial = RideTripState(
        tripId: 'trip-2',
        phase: RideTripPhase.draft,
      );

      final cancelled = applyRideTripEvent(initial, RideTripEvent.cancel);

      expect(cancelled.phase, RideTripPhase.cancelled);
      expect(cancelled.tripId, initial.tripId);
    });

    test('fail from quoting leads to failed', () {
      final initial = RideTripState(
        tripId: 'trip-3',
        phase: RideTripPhase.quoting,
      );

      final failed = applyRideTripEvent(initial, RideTripEvent.fail);

      expect(failed.phase, RideTripPhase.failed);
    });

    group('cancel transitions', () {
      test('cancel from draft', () {
        final state = RideTripState(tripId: 't', phase: RideTripPhase.draft);
        final result = applyRideTripEvent(state, RideTripEvent.cancel);
        expect(result.phase, RideTripPhase.cancelled);
      });

      test('cancel from quoting', () {
        final state = RideTripState(tripId: 't', phase: RideTripPhase.quoting);
        final result = applyRideTripEvent(state, RideTripEvent.cancel);
        expect(result.phase, RideTripPhase.cancelled);
      });

      test('cancel from requesting', () {
        final state =
            RideTripState(tripId: 't', phase: RideTripPhase.requesting);
        final result = applyRideTripEvent(state, RideTripEvent.cancel);
        expect(result.phase, RideTripPhase.cancelled);
      });

      test('cancel from findingDriver', () {
        final state =
            RideTripState(tripId: 't', phase: RideTripPhase.findingDriver);
        final result = applyRideTripEvent(state, RideTripEvent.cancel);
        expect(result.phase, RideTripPhase.cancelled);
      });

      test('cancel from driverAccepted', () {
        final state =
            RideTripState(tripId: 't', phase: RideTripPhase.driverAccepted);
        final result = applyRideTripEvent(state, RideTripEvent.cancel);
        expect(result.phase, RideTripPhase.cancelled);
      });

      test('cancel from driverArrived', () {
        final state =
            RideTripState(tripId: 't', phase: RideTripPhase.driverArrived);
        final result = applyRideTripEvent(state, RideTripEvent.cancel);
        expect(result.phase, RideTripPhase.cancelled);
      });

      test('cannot cancel from inProgress', () {
        final state =
            RideTripState(tripId: 't', phase: RideTripPhase.inProgress);
        expect(
          () => applyRideTripEvent(state, RideTripEvent.cancel),
          throwsA(isA<InvalidRideTransitionException>()),
        );
      });

      test('cannot cancel from payment', () {
        final state = RideTripState(tripId: 't', phase: RideTripPhase.payment);
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

      test('exposes from and event fields', () {
        final exception = InvalidRideTransitionException(
          RideTripPhase.quoting,
          RideTripEvent.startTrip,
        );

        expect(exception.from, RideTripPhase.quoting);
        expect(exception.event, RideTripEvent.startTrip);
      });
    });

    group('Terminal States Protection - No-Op/Exception behavior', () {
      final terminalPhases = [
        RideTripPhase.completed,
        RideTripPhase.cancelled,
        RideTripPhase.failed,
      ];

      final allEvents = RideTripEvent.values;

      for (final terminalPhase in terminalPhases) {
        group('from $terminalPhase', () {
          for (final event in allEvents) {
            test('$event throws InvalidRideTransitionException', () {
              final state = RideTripState(
                tripId: 'terminal-test',
                phase: terminalPhase,
              );

              expect(
                () => applyRideTripEvent(state, event),
                throwsA(isA<InvalidRideTransitionException>()),
                reason:
                    'Terminal state $terminalPhase should reject event $event',
              );
            });
          }
        });
      }
    });

    group('Phase sequence validation', () {
      test('requestQuote only valid from draft', () {
        final validPhases = [RideTripPhase.draft];
        final invalidPhases = RideTripPhase.values
            .where((p) => !validPhases.contains(p))
            .toList();

        for (final phase in invalidPhases) {
          if (phase == RideTripPhase.completed ||
              phase == RideTripPhase.cancelled ||
              phase == RideTripPhase.failed) {
            // Terminal phases already tested
            continue;
          }
          final state = RideTripState(tripId: 'seq-test', phase: phase);
          expect(
            () => applyRideTripEvent(state, RideTripEvent.requestQuote),
            throwsA(isA<InvalidRideTransitionException>()),
            reason: 'requestQuote should be invalid from $phase',
          );
        }
      });

      test('quoteReceived only valid from quoting', () {
        final invalidPhases = RideTripPhase.values
            .where((p) =>
                p != RideTripPhase.quoting &&
                p != RideTripPhase.completed &&
                p != RideTripPhase.cancelled &&
                p != RideTripPhase.failed)
            .toList();

        for (final phase in invalidPhases) {
          final state = RideTripState(tripId: 'seq-test', phase: phase);
          expect(
            () => applyRideTripEvent(state, RideTripEvent.quoteReceived),
            throwsA(isA<InvalidRideTransitionException>()),
            reason: 'quoteReceived should be invalid from $phase',
          );
        }
      });

      test('submitRequest only valid from requesting', () {
        final invalidPhases = RideTripPhase.values
            .where((p) =>
                p != RideTripPhase.requesting &&
                p != RideTripPhase.completed &&
                p != RideTripPhase.cancelled &&
                p != RideTripPhase.failed)
            .toList();

        for (final phase in invalidPhases) {
          final state = RideTripState(tripId: 'seq-test', phase: phase);
          expect(
            () => applyRideTripEvent(state, RideTripEvent.submitRequest),
            throwsA(isA<InvalidRideTransitionException>()),
            reason: 'submitRequest should be invalid from $phase',
          );
        }
      });

      test('driverAccepted only valid from findingDriver', () {
        final invalidPhases = RideTripPhase.values
            .where((p) =>
                p != RideTripPhase.findingDriver &&
                p != RideTripPhase.completed &&
                p != RideTripPhase.cancelled &&
                p != RideTripPhase.failed)
            .toList();

        for (final phase in invalidPhases) {
          final state = RideTripState(tripId: 'seq-test', phase: phase);
          expect(
            () => applyRideTripEvent(state, RideTripEvent.driverAccepted),
            throwsA(isA<InvalidRideTransitionException>()),
            reason: 'driverAccepted should be invalid from $phase',
          );
        }
      });

      test('driverArrived only valid from driverAccepted', () {
        final invalidPhases = RideTripPhase.values
            .where((p) =>
                p != RideTripPhase.driverAccepted &&
                p != RideTripPhase.completed &&
                p != RideTripPhase.cancelled &&
                p != RideTripPhase.failed)
            .toList();

        for (final phase in invalidPhases) {
          final state = RideTripState(tripId: 'seq-test', phase: phase);
          expect(
            () => applyRideTripEvent(state, RideTripEvent.driverArrived),
            throwsA(isA<InvalidRideTransitionException>()),
            reason: 'driverArrived should be invalid from $phase',
          );
        }
      });

      test('startTrip only valid from driverArrived', () {
        final invalidPhases = RideTripPhase.values
            .where((p) =>
                p != RideTripPhase.driverArrived &&
                p != RideTripPhase.completed &&
                p != RideTripPhase.cancelled &&
                p != RideTripPhase.failed)
            .toList();

        for (final phase in invalidPhases) {
          final state = RideTripState(tripId: 'seq-test', phase: phase);
          expect(
            () => applyRideTripEvent(state, RideTripEvent.startTrip),
            throwsA(isA<InvalidRideTransitionException>()),
            reason: 'startTrip should be invalid from $phase',
          );
        }
      });

      test('startPayment only valid from inProgress', () {
        final invalidPhases = RideTripPhase.values
            .where((p) =>
                p != RideTripPhase.inProgress &&
                p != RideTripPhase.completed &&
                p != RideTripPhase.cancelled &&
                p != RideTripPhase.failed)
            .toList();

        for (final phase in invalidPhases) {
          final state = RideTripState(tripId: 'seq-test', phase: phase);
          expect(
            () => applyRideTripEvent(state, RideTripEvent.startPayment),
            throwsA(isA<InvalidRideTransitionException>()),
            reason: 'startPayment should be invalid from $phase',
          );
        }
      });

      test('complete only valid from payment', () {
        final invalidPhases = RideTripPhase.values
            .where((p) =>
                p != RideTripPhase.payment &&
                p != RideTripPhase.completed &&
                p != RideTripPhase.cancelled &&
                p != RideTripPhase.failed)
            .toList();

        for (final phase in invalidPhases) {
          final state = RideTripState(tripId: 'seq-test', phase: phase);
          expect(
            () => applyRideTripEvent(state, RideTripEvent.complete),
            throwsA(isA<InvalidRideTransitionException>()),
            reason: 'complete should be invalid from $phase',
          );
        }
      });
    });
  });
}


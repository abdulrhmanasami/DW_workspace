/// RideTrip FSM Unit Tests - Track B Ticket #24, #89, #116
/// Purpose: Comprehensive domain-level tests for the Ride FSM
/// Created by: Track B - Ticket #24
/// Updated by: Track B - Ticket #89 (Domain helpers + tryApply + double events)
/// Updated by: Track B - Ticket #116 (Complete FSM validation + additional helpers)
/// Last updated: 2025-11-30
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

      test('tripId is preserved through all transitions', () {
        const testTripId = 'persistent-trip-id';
        var state = const RideTripState(
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
        const initial =
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
        const state =
            RideTripState(tripId: 'trip-invalid-1', phase: RideTripPhase.draft);

        expect(
          () => applyRideTripEvent(state, RideTripEvent.driverArrived),
          throwsA(isA<InvalidRideTransitionException>()),
        );
      });

      test('draft → startTrip is invalid', () {
        const state =
            RideTripState(tripId: 'trip-invalid-2', phase: RideTripPhase.draft);

        expect(
          () => applyRideTripEvent(state, RideTripEvent.startTrip),
          throwsA(isA<InvalidRideTransitionException>()),
        );
      });

      test('draft → complete is invalid', () {
        const state =
            RideTripState(tripId: 'trip-invalid-3', phase: RideTripPhase.draft);

        expect(
          () => applyRideTripEvent(state, RideTripEvent.complete),
          throwsA(isA<InvalidRideTransitionException>()),
        );
      });

      test('inProgress → draft is invalid (backwards transition)', () {
        const state = RideTripState(
            tripId: 'trip-invalid-4', phase: RideTripPhase.inProgress);

        expect(
          () => applyRideTripEvent(state, RideTripEvent.requestQuote),
          throwsA(isA<InvalidRideTransitionException>()),
        );
      });

      test('payment → driverAccepted is invalid (backwards transition)', () {
        const state =
            RideTripState(tripId: 'trip-invalid-5', phase: RideTripPhase.payment);

        expect(
          () => applyRideTripEvent(state, RideTripEvent.driverAccepted),
          throwsA(isA<InvalidRideTransitionException>()),
        );
      });

      test('findingDriver → quoteReceived is invalid (wrong direction)', () {
        const state = RideTripState(
            tripId: 'trip-invalid-6', phase: RideTripPhase.findingDriver);

        expect(
          () => applyRideTripEvent(state, RideTripEvent.quoteReceived),
          throwsA(isA<InvalidRideTransitionException>()),
        );
      });

      test('quoting → driverAccepted is invalid (skipping phases)', () {
        const state =
            RideTripState(tripId: 'trip-invalid-7', phase: RideTripPhase.quoting);

        expect(
          () => applyRideTripEvent(state, RideTripEvent.driverAccepted),
          throwsA(isA<InvalidRideTransitionException>()),
        );
      });

      test('driverArrived → complete is invalid (skipping inProgress and payment)',
          () {
        const state = RideTripState(
            tripId: 'trip-invalid-8', phase: RideTripPhase.driverArrived);

        expect(
          () => applyRideTripEvent(state, RideTripEvent.complete),
          throwsA(isA<InvalidRideTransitionException>()),
        );
      });

      test('requesting → inProgress is invalid (skipping driver phases)', () {
        const state = RideTripState(
            tripId: 'trip-invalid-9', phase: RideTripPhase.requesting);

        expect(
          () => applyRideTripEvent(state, RideTripEvent.startTrip),
          throwsA(isA<InvalidRideTransitionException>()),
        );
      });
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

    group('cancel transitions', () {
      test('cancel from draft', () {
        const state = RideTripState(tripId: 't', phase: RideTripPhase.draft);
        final result = applyRideTripEvent(state, RideTripEvent.cancel);
        expect(result.phase, RideTripPhase.cancelled);
      });

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

      test('cannot cancel from payment', () {
        const state = RideTripState(tripId: 't', phase: RideTripPhase.payment);
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

      const allEvents = RideTripEvent.values;

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

    // =========================================================================
    // Track B - Ticket #89: Domain Helpers Tests
    // =========================================================================

    group('Domain Helpers (Ticket #89)', () {
      group('isActiveTrip', () {
        test('returns true for findingDriver', () {
          expect(RideTripPhase.findingDriver.isActiveTrip, isTrue);
        });

        test('returns true for driverAccepted', () {
          expect(RideTripPhase.driverAccepted.isActiveTrip, isTrue);
        });

        test('returns true for driverArrived', () {
          expect(RideTripPhase.driverArrived.isActiveTrip, isTrue);
        });

        test('returns true for inProgress', () {
          expect(RideTripPhase.inProgress.isActiveTrip, isTrue);
        });

        test('returns false for draft', () {
          expect(RideTripPhase.draft.isActiveTrip, isFalse);
        });

        test('returns false for quoting', () {
          expect(RideTripPhase.quoting.isActiveTrip, isFalse);
        });

        test('returns false for requesting', () {
          expect(RideTripPhase.requesting.isActiveTrip, isFalse);
        });

        test('returns false for payment', () {
          expect(RideTripPhase.payment.isActiveTrip, isFalse);
        });

        test('returns false for completed', () {
          expect(RideTripPhase.completed.isActiveTrip, isFalse);
        });

        test('returns false for cancelled', () {
          expect(RideTripPhase.cancelled.isActiveTrip, isFalse);
        });

        test('returns false for failed', () {
          expect(RideTripPhase.failed.isActiveTrip, isFalse);
        });
      });

      group('isTerminal', () {
        test('returns true for completed', () {
          expect(RideTripPhase.completed.isTerminal, isTrue);
        });

        test('returns true for cancelled', () {
          expect(RideTripPhase.cancelled.isTerminal, isTrue);
        });

        test('returns true for failed', () {
          expect(RideTripPhase.failed.isTerminal, isTrue);
        });

        test('returns false for all non-terminal phases', () {
          final nonTerminal = [
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
            expect(phase.isTerminal, isFalse,
                reason: '$phase should not be terminal');
          }
        });
      });

      group('isCancellable', () {
        test('returns true for phases before trip starts', () {
          final cancellable = [
            RideTripPhase.draft,
            RideTripPhase.quoting,
            RideTripPhase.requesting,
            RideTripPhase.findingDriver,
            RideTripPhase.driverAccepted,
            RideTripPhase.driverArrived,
          ];

          for (final phase in cancellable) {
            expect(phase.isCancellable, isTrue,
                reason: '$phase should be cancellable');
          }
        });

        test('returns false for inProgress', () {
          expect(RideTripPhase.inProgress.isCancellable, isFalse);
        });

        test('returns false for payment', () {
          expect(RideTripPhase.payment.isCancellable, isFalse);
        });

        test('returns false for terminal phases', () {
          expect(RideTripPhase.completed.isCancellable, isFalse);
          expect(RideTripPhase.cancelled.isCancellable, isFalse);
          expect(RideTripPhase.failed.isCancellable, isFalse);
        });
      });

      group('isPreTrip', () {
        test('returns true for draft', () {
          expect(RideTripPhase.draft.isPreTrip, isTrue);
        });

        test('returns true for quoting', () {
          expect(RideTripPhase.quoting.isPreTrip, isTrue);
        });

        test('returns true for requesting', () {
          expect(RideTripPhase.requesting.isPreTrip, isTrue);
        });

        test('returns false for driver-involved phases', () {
          final driverPhases = [
            RideTripPhase.findingDriver,
            RideTripPhase.driverAccepted,
            RideTripPhase.driverArrived,
            RideTripPhase.inProgress,
            RideTripPhase.payment,
            RideTripPhase.completed,
            RideTripPhase.cancelled,
            RideTripPhase.failed,
          ];

          for (final phase in driverPhases) {
            expect(phase.isPreTrip, isFalse,
                reason: '$phase should not be pre-trip');
          }
        });
      });

      // =========================================================================
      // Track B - Ticket #116: Additional Domain Helpers Tests
      // =========================================================================

      group('isPreDriver (Ticket #116)', () {
        test('returns true for phases before driver assignment', () {
          final preDriverPhases = [
            RideTripPhase.draft,
            RideTripPhase.quoting,
            RideTripPhase.requesting,
            RideTripPhase.findingDriver,
          ];

          for (final phase in preDriverPhases) {
            expect(phase.isPreDriver, isTrue,
                reason: '$phase should be pre-driver');
          }
        });

        test('returns false for driver-assigned phases', () {
          final withDriverPhases = [
            RideTripPhase.driverAccepted,
            RideTripPhase.driverArrived,
            RideTripPhase.inProgress,
            RideTripPhase.payment,
            RideTripPhase.completed,
            RideTripPhase.cancelled,
            RideTripPhase.failed,
          ];

          for (final phase in withDriverPhases) {
            expect(phase.isPreDriver, isFalse,
                reason: '$phase should not be pre-driver');
          }
        });
      });

      group('isWithDriver (Ticket #116)', () {
        test('returns true for phases with active driver', () {
          final withDriverPhases = [
            RideTripPhase.driverAccepted,
            RideTripPhase.driverArrived,
            RideTripPhase.inProgress,
          ];

          for (final phase in withDriverPhases) {
            expect(phase.isWithDriver, isTrue,
                reason: '$phase should be with-driver');
          }
        });

        test('returns false for phases without active driver', () {
          final notWithDriverPhases = [
            RideTripPhase.draft,
            RideTripPhase.quoting,
            RideTripPhase.requesting,
            RideTripPhase.findingDriver,
            RideTripPhase.payment,
            RideTripPhase.completed,
            RideTripPhase.cancelled,
            RideTripPhase.failed,
          ];

          for (final phase in notWithDriverPhases) {
            expect(phase.isWithDriver, isFalse,
                reason: '$phase should not be with-driver');
          }
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

    // =========================================================================
    // Track B - Ticket #89: tryApplyRideTripEvent Tests (Safe/No-throw)
    // =========================================================================

    group('tryApplyRideTripEvent (Ticket #89)', () {
      test('returns new state for valid transition', () {
        const state = RideTripState(
          tripId: 'try-apply-1',
          phase: RideTripPhase.draft,
        );

        final result = tryApplyRideTripEvent(state, RideTripEvent.requestQuote);

        expect(result, isNotNull);
        expect(result!.phase, RideTripPhase.quoting);
        expect(result.tripId, 'try-apply-1');
      });

      test('returns null for invalid transition (no exception)', () {
        const state = RideTripState(
          tripId: 'try-apply-2',
          phase: RideTripPhase.draft,
        );

        final result = tryApplyRideTripEvent(state, RideTripEvent.complete);

        expect(result, isNull);
      });

      test('returns null for double events (idempotency)', () {
        var state = const RideTripState(
          tripId: 'try-apply-3',
          phase: RideTripPhase.draft,
        );

        // First event: valid
        final result1 = tryApplyRideTripEvent(state, RideTripEvent.requestQuote);
        expect(result1, isNotNull);
        state = result1!;

        // Second event (same): no-op, returns null
        final result2 = tryApplyRideTripEvent(state, RideTripEvent.requestQuote);
        expect(result2, isNull);
        expect(state.phase, RideTripPhase.quoting); // unchanged
      });

      test('handles terminal state gracefully', () {
        const state = RideTripState(
          tripId: 'try-apply-4',
          phase: RideTripPhase.completed,
        );

        final result = tryApplyRideTripEvent(state, RideTripEvent.cancel);

        expect(result, isNull); // No exception, just null
      });

      test('Happy Path with tryApply - no exceptions thrown', () {
        var state = const RideTripState(
          tripId: 'try-apply-happy',
          phase: RideTripPhase.draft,
        );

        // Apply all events in sequence using tryApply
        final events = [
          RideTripEvent.requestQuote,
          RideTripEvent.quoteReceived,
          RideTripEvent.submitRequest,
          RideTripEvent.driverAccepted,
          RideTripEvent.driverArrived,
          RideTripEvent.startTrip,
          RideTripEvent.startPayment,
          RideTripEvent.complete,
        ];

        for (final event in events) {
          final result = tryApplyRideTripEvent(state, event);
          expect(result, isNotNull, reason: '$event should succeed');
          state = result!;
        }

        expect(state.phase, RideTripPhase.completed);
      });
    });

    // =========================================================================
    // Track B - Ticket #89: isValidTransition Tests
    // =========================================================================

    group('isValidTransition (Ticket #89)', () {
      test('returns true for valid draft -> quoting', () {
        expect(
          isValidTransition(RideTripPhase.draft, RideTripEvent.requestQuote),
          isTrue,
        );
      });

      test('returns false for invalid draft -> complete', () {
        expect(
          isValidTransition(RideTripPhase.draft, RideTripEvent.complete),
          isFalse,
        );
      });

      test('returns false for terminal states', () {
        for (final event in RideTripEvent.values) {
          expect(
            isValidTransition(RideTripPhase.completed, event),
            isFalse,
            reason: 'completed should reject $event',
          );
          expect(
            isValidTransition(RideTripPhase.cancelled, event),
            isFalse,
            reason: 'cancelled should reject $event',
          );
          expect(
            isValidTransition(RideTripPhase.failed, event),
            isFalse,
            reason: 'failed should reject $event',
          );
        }
      });

      test('validates cancel from cancellable phases', () {
        final cancellablePhases = [
          RideTripPhase.draft,
          RideTripPhase.quoting,
          RideTripPhase.requesting,
          RideTripPhase.findingDriver,
          RideTripPhase.driverAccepted,
          RideTripPhase.driverArrived,
        ];

        for (final phase in cancellablePhases) {
          expect(
            isValidTransition(phase, RideTripEvent.cancel),
            isTrue,
            reason: '$phase should allow cancel',
          );
        }
      });

      test('validates fail from all non-terminal phases', () {
        final nonTerminal = [
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
          expect(
            isValidTransition(phase, RideTripEvent.fail),
            isTrue,
            reason: '$phase should allow fail',
          );
        }
      });
    });

    // =========================================================================
    // Track B - Ticket #89: Double Events / Network Delay Resilience
    // =========================================================================

    group('Double Events Resilience (Ticket #89)', () {
      test('quoteReceived twice does not change state after first apply', () {
        var state = const RideTripState(
          tripId: 'double-event-1',
          phase: RideTripPhase.draft,
        );

        // Move to quoting first
        state = applyRideTripEvent(state, RideTripEvent.requestQuote);
        expect(state.phase, RideTripPhase.quoting);

        // Apply quoteReceived
        state = applyRideTripEvent(state, RideTripEvent.quoteReceived);
        expect(state.phase, RideTripPhase.requesting);

        // Try quoteReceived again - should be no-op (using tryApply)
        final result = tryApplyRideTripEvent(state, RideTripEvent.quoteReceived);
        expect(result, isNull);
        expect(state.phase, RideTripPhase.requesting); // unchanged
      });

      test('driverAccepted twice is idempotent with tryApply', () {
        var state = const RideTripState(
          tripId: 'double-event-2',
          phase: RideTripPhase.findingDriver,
        );

        // First driverAccepted
        state = applyRideTripEvent(state, RideTripEvent.driverAccepted);
        expect(state.phase, RideTripPhase.driverAccepted);

        // Second driverAccepted - no-op
        final result = tryApplyRideTripEvent(state, RideTripEvent.driverAccepted);
        expect(result, isNull);
      });

      test('complete twice is idempotent with tryApply', () {
        var state = const RideTripState(
          tripId: 'double-event-3',
          phase: RideTripPhase.payment,
        );

        // First complete
        state = applyRideTripEvent(state, RideTripEvent.complete);
        expect(state.phase, RideTripPhase.completed);

        // Second complete - no-op (terminal state)
        final result = tryApplyRideTripEvent(state, RideTripEvent.complete);
        expect(result, isNull);
      });
    });
  });
}


/// Parcel FSM Unit Tests - Ticket #39
/// Purpose: Comprehensive domain-level tests for the Parcel FSM
/// Created by: Ticket #39
///
/// This file tests the canonical FSM for parcel lifecycle transitions.
/// All tests are domain-level and do not depend on UI or backend.

import 'package:parcels_shims/parcels_shims.dart';
import 'package:test/test.dart';

void main() {
  group('Parcel FSM', () {
    group('Happy Path - Full Journey', () {
      test(
          'draft → quoting → awaitingPickup → pickedUp → inTransit → delivered',
          () {
        var state = const ParcelState(
          parcelId: 'p-1',
          phase: ParcelPhase.draft,
        );

        state = applyParcelEvent(state, ParcelEvent.requestQuote);
        expect(state.phase, ParcelPhase.quoting);

        state = applyParcelEvent(state, ParcelEvent.quoteReceived);
        expect(state.phase, ParcelPhase.awaitingPickup);

        state = applyParcelEvent(state, ParcelEvent.pickupSucceeded);
        expect(state.phase, ParcelPhase.pickedUp);

        state = applyParcelEvent(state, ParcelEvent.startTransit);
        expect(state.phase, ParcelPhase.inTransit);

        state = applyParcelEvent(state, ParcelEvent.markDelivered);
        expect(state.phase, ParcelPhase.delivered);
      });

      test('parcelId is preserved through all transitions', () {
        const testParcelId = 'persistent-parcel-id';
        var state = const ParcelState(
          parcelId: testParcelId,
          phase: ParcelPhase.draft,
        );

        state = applyParcelEvent(state, ParcelEvent.requestQuote);
        expect(state.parcelId, testParcelId);

        state = applyParcelEvent(state, ParcelEvent.quoteReceived);
        expect(state.parcelId, testParcelId);

        state = applyParcelEvent(state, ParcelEvent.pickupSucceeded);
        expect(state.parcelId, testParcelId);

        state = applyParcelEvent(state, ParcelEvent.startTransit);
        expect(state.parcelId, testParcelId);

        state = applyParcelEvent(state, ParcelEvent.markDelivered);
        expect(state.parcelId, testParcelId);
      });

      test('each phase transition creates new state instance', () {
        const initial = ParcelState(
          parcelId: 'parcel-immutable',
          phase: ParcelPhase.draft,
        );

        final next = applyParcelEvent(initial, ParcelEvent.requestQuote);

        expect(identical(initial, next), isFalse);
        expect(initial.phase, ParcelPhase.draft); // unchanged
        expect(next.phase, ParcelPhase.quoting);
      });

      test('awaitingPickup → pickedUp via schedulePickup', () {
        var state = const ParcelState(
          parcelId: 'p-schedule',
          phase: ParcelPhase.awaitingPickup,
        );

        state = applyParcelEvent(state, ParcelEvent.schedulePickup);
        expect(state.phase, ParcelPhase.pickedUp);
      });
    });

    group('Invalid Transitions - Explicit Tests', () {
      test('draft → markDelivered throws', () {
        const state = ParcelState(
          parcelId: 'p-1',
          phase: ParcelPhase.draft,
        );

        expect(
          () => applyParcelEvent(state, ParcelEvent.markDelivered),
          throwsA(isA<InvalidParcelTransitionException>()),
        );
      });

      test('draft → startTransit throws', () {
        const state = ParcelState(
          parcelId: 'p-2',
          phase: ParcelPhase.draft,
        );

        expect(
          () => applyParcelEvent(state, ParcelEvent.startTransit),
          throwsA(isA<InvalidParcelTransitionException>()),
        );
      });

      test('draft → pickupSucceeded throws', () {
        const state = ParcelState(
          parcelId: 'p-3',
          phase: ParcelPhase.draft,
        );

        expect(
          () => applyParcelEvent(state, ParcelEvent.pickupSucceeded),
          throwsA(isA<InvalidParcelTransitionException>()),
        );
      });

      test('quoting → startTransit throws (skipping phases)', () {
        const state = ParcelState(
          parcelId: 'p-4',
          phase: ParcelPhase.quoting,
        );

        expect(
          () => applyParcelEvent(state, ParcelEvent.startTransit),
          throwsA(isA<InvalidParcelTransitionException>()),
        );
      });

      test('inTransit → requestQuote throws (backwards transition)', () {
        const state = ParcelState(
          parcelId: 'p-5',
          phase: ParcelPhase.inTransit,
        );

        expect(
          () => applyParcelEvent(state, ParcelEvent.requestQuote),
          throwsA(isA<InvalidParcelTransitionException>()),
        );
      });

      test('pickedUp → quoteReceived throws (backwards transition)', () {
        const state = ParcelState(
          parcelId: 'p-6',
          phase: ParcelPhase.pickedUp,
        );

        expect(
          () => applyParcelEvent(state, ParcelEvent.quoteReceived),
          throwsA(isA<InvalidParcelTransitionException>()),
        );
      });
    });

    group('Cancel Transitions', () {
      test('cancel from draft', () {
        const state = ParcelState(parcelId: 'p', phase: ParcelPhase.draft);
        final result = applyParcelEvent(state, ParcelEvent.cancel);
        expect(result.phase, ParcelPhase.cancelled);
      });

      test('cancel from quoting', () {
        const state = ParcelState(parcelId: 'p', phase: ParcelPhase.quoting);
        final result = applyParcelEvent(state, ParcelEvent.cancel);
        expect(result.phase, ParcelPhase.cancelled);
      });

      test('cancel from awaitingPickup', () {
        const state =
            ParcelState(parcelId: 'p', phase: ParcelPhase.awaitingPickup);
        final result = applyParcelEvent(state, ParcelEvent.cancel);
        expect(result.phase, ParcelPhase.cancelled);
      });

      test('cancel from pickedUp', () {
        const state = ParcelState(parcelId: 'p', phase: ParcelPhase.pickedUp);
        final result = applyParcelEvent(state, ParcelEvent.cancel);
        expect(result.phase, ParcelPhase.cancelled);
      });

      test('cannot cancel from inTransit', () {
        const state = ParcelState(parcelId: 'p', phase: ParcelPhase.inTransit);
        expect(
          () => applyParcelEvent(state, ParcelEvent.cancel),
          throwsA(isA<InvalidParcelTransitionException>()),
        );
      });
    });

    group('Fail Transitions', () {
      test('fail from quoting', () {
        const state = ParcelState(parcelId: 'p', phase: ParcelPhase.quoting);
        final result = applyParcelEvent(state, ParcelEvent.fail);
        expect(result.phase, ParcelPhase.failed);
      });

      test('fail from inTransit', () {
        const state = ParcelState(parcelId: 'p', phase: ParcelPhase.inTransit);
        final result = applyParcelEvent(state, ParcelEvent.fail);
        expect(result.phase, ParcelPhase.failed);
      });

      test('cannot fail from draft', () {
        const state = ParcelState(parcelId: 'p', phase: ParcelPhase.draft);
        expect(
          () => applyParcelEvent(state, ParcelEvent.fail),
          throwsA(isA<InvalidParcelTransitionException>()),
        );
      });
    });

    group('ParcelState', () {
      test('copyWith preserves unchanged values', () {
        const original = ParcelState(
          parcelId: 'original-id',
          phase: ParcelPhase.draft,
        );

        final copied = original.copyWith(phase: ParcelPhase.quoting);

        expect(copied.parcelId, 'original-id');
        expect(copied.phase, ParcelPhase.quoting);
      });

      test('copyWith with no args returns equivalent state', () {
        const original = ParcelState(
          parcelId: 'test-id',
          phase: ParcelPhase.awaitingPickup,
        );

        final copied = original.copyWith();

        expect(copied.parcelId, original.parcelId);
        expect(copied.phase, original.phase);
      });
    });

    group('InvalidParcelTransitionException', () {
      test('toString contains useful information', () {
        final exception =
            InvalidParcelTransitionException('Cannot apply markDelivered from draft');

        expect(exception.toString(), contains('markDelivered'));
        expect(exception.toString(), contains('draft'));
        expect(exception.toString(), contains('InvalidParcelTransitionException'));
      });

      test('message field is accessible', () {
        final exception =
            InvalidParcelTransitionException('Test message');

        expect(exception.message, 'Test message');
      });
    });

    group('Terminal States Protection', () {
      final terminalPhases = [
        ParcelPhase.delivered,
        ParcelPhase.cancelled,
        ParcelPhase.failed,
      ];

      const allEvents = ParcelEvent.values;

      for (final terminalPhase in terminalPhases) {
        group('from $terminalPhase', () {
          for (final event in allEvents) {
            test('$event throws InvalidParcelTransitionException', () {
              final state = ParcelState(
                parcelId: 'terminal-test',
                phase: terminalPhase,
              );

              expect(
                () => applyParcelEvent(state, event),
                throwsA(isA<InvalidParcelTransitionException>()),
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
        final invalidPhases = ParcelPhase.values
            .where((p) =>
                p != ParcelPhase.draft &&
                p != ParcelPhase.delivered &&
                p != ParcelPhase.cancelled &&
                p != ParcelPhase.failed)
            .toList();

        for (final phase in invalidPhases) {
          final state = ParcelState(parcelId: 'seq-test', phase: phase);
          expect(
            () => applyParcelEvent(state, ParcelEvent.requestQuote),
            throwsA(isA<InvalidParcelTransitionException>()),
            reason: 'requestQuote should be invalid from $phase',
          );
        }
      });

      test('quoteReceived only valid from quoting', () {
        final invalidPhases = ParcelPhase.values
            .where((p) =>
                p != ParcelPhase.quoting &&
                p != ParcelPhase.delivered &&
                p != ParcelPhase.cancelled &&
                p != ParcelPhase.failed)
            .toList();

        for (final phase in invalidPhases) {
          final state = ParcelState(parcelId: 'seq-test', phase: phase);
          expect(
            () => applyParcelEvent(state, ParcelEvent.quoteReceived),
            throwsA(isA<InvalidParcelTransitionException>()),
            reason: 'quoteReceived should be invalid from $phase',
          );
        }
      });

      test('startTransit only valid from pickedUp', () {
        final invalidPhases = ParcelPhase.values
            .where((p) =>
                p != ParcelPhase.pickedUp &&
                p != ParcelPhase.delivered &&
                p != ParcelPhase.cancelled &&
                p != ParcelPhase.failed)
            .toList();

        for (final phase in invalidPhases) {
          final state = ParcelState(parcelId: 'seq-test', phase: phase);
          expect(
            () => applyParcelEvent(state, ParcelEvent.startTransit),
            throwsA(isA<InvalidParcelTransitionException>()),
            reason: 'startTransit should be invalid from $phase',
          );
        }
      });

      test('markDelivered only valid from inTransit', () {
        final invalidPhases = ParcelPhase.values
            .where((p) =>
                p != ParcelPhase.inTransit &&
                p != ParcelPhase.delivered &&
                p != ParcelPhase.cancelled &&
                p != ParcelPhase.failed)
            .toList();

        for (final phase in invalidPhases) {
          final state = ParcelState(parcelId: 'seq-test', phase: phase);
          expect(
            () => applyParcelEvent(state, ParcelEvent.markDelivered),
            throwsA(isA<InvalidParcelTransitionException>()),
            reason: 'markDelivered should be invalid from $phase',
          );
        }
      });
    });
  });
}


/// Ride FSM Tests - Track B Ticket #241
/// Purpose: Comprehensive unit tests for ride booking FSM
/// Created by: Track B - Ticket #241
/// Last updated: 2025-12-04

import 'package:test/test.dart';

import 'package:mobility_shims/src/place_models.dart';
import 'package:mobility_shims/src/ride_fsm.dart';
import 'package:mobility_shims/src/ride_models.dart';
import 'package:mobility_shims/src/ride_status.dart';

void main() {
  group('RideFsm', () {
    late RideRequest draftRequest;
    late MobilityPlace pickup;
    late MobilityPlace destination;

    setUp(() {
      pickup = MobilityPlace.saved(
        id: 'pickup_1',
        label: 'Home',
        address: '123 Home St',
      );
      destination = MobilityPlace.saved(
        id: 'dest_1',
        label: 'Work',
        address: '456 Office Ave',
      );

      draftRequest = RideRequest(
        id: 'request_1',
        status: RideStatus.draft,
        pickup: pickup,
        destination: destination,
        createdAt: DateTime.now().toUtc(),
      );
    });

    group('Valid Transitions', () {
      test('draft -> quoting should be valid', () {
        expect(RideFsm.canTransition(RideStatus.draft, RideStatus.quoting), isTrue);
      });

      test('quoting -> quoteReady should be valid', () {
        expect(RideFsm.canTransition(RideStatus.quoting, RideStatus.quoteReady), isTrue);
      });

      test('quoteReady -> requesting should be valid', () {
        expect(RideFsm.canTransition(RideStatus.quoteReady, RideStatus.requesting), isTrue);
      });

      test('requesting -> findingDriver should be valid', () {
        expect(RideFsm.canTransition(RideStatus.requesting, RideStatus.findingDriver), isTrue);
      });

      test('findingDriver -> driverAccepted should be valid', () {
        expect(RideFsm.canTransition(RideStatus.findingDriver, RideStatus.driverAccepted), isTrue);
      });

      test('driverAccepted -> driverArrived should be valid', () {
        expect(RideFsm.canTransition(RideStatus.driverAccepted, RideStatus.driverArrived), isTrue);
      });

      test('driverArrived -> inProgress should be valid', () {
        expect(RideFsm.canTransition(RideStatus.driverArrived, RideStatus.inProgress), isTrue);
      });

      test('inProgress -> payment should be valid', () {
        expect(RideFsm.canTransition(RideStatus.inProgress, RideStatus.payment), isTrue);
      });

      test('payment -> completed should be valid', () {
        expect(RideFsm.canTransition(RideStatus.payment, RideStatus.completed), isTrue);
      });

      test('draft -> cancelled should be valid', () {
        expect(RideFsm.canTransition(RideStatus.draft, RideStatus.cancelled), isTrue);
      });

      test('quoting -> cancelled should be valid', () {
        expect(RideFsm.canTransition(RideStatus.quoting, RideStatus.cancelled), isTrue);
      });

      test('quoting -> failed should be valid', () {
        expect(RideFsm.canTransition(RideStatus.quoting, RideStatus.failed), isTrue);
      });
    });

    group('Invalid Transitions', () {
      test('draft -> driverAccepted should be invalid', () {
        expect(RideFsm.canTransition(RideStatus.draft, RideStatus.driverAccepted), isFalse);
      });

      test('completed -> inProgress should be invalid', () {
        expect(RideFsm.canTransition(RideStatus.completed, RideStatus.inProgress), isFalse);
      });

      test('cancelled -> findingDriver should be invalid', () {
        expect(RideFsm.canTransition(RideStatus.cancelled, RideStatus.findingDriver), isFalse);
      });

      test('failed -> payment should be invalid', () {
        expect(RideFsm.canTransition(RideStatus.failed, RideStatus.payment), isFalse);
      });

      test('draft -> draft should be invalid', () {
        expect(RideFsm.canTransition(RideStatus.draft, RideStatus.draft), isFalse);
      });
    });

    group('Terminal States', () {
      test('completed should not allow any transitions', () {
        for (final status in RideStatus.values) {
          if (status != RideStatus.completed) {
            expect(RideFsm.canTransition(RideStatus.completed, status), isFalse);
          }
        }
      });

      test('cancelled should not allow any transitions', () {
        for (final status in RideStatus.values) {
          if (status != RideStatus.cancelled) {
            expect(RideFsm.canTransition(RideStatus.cancelled, status), isFalse);
          }
        }
      });

      test('failed should not allow any transitions', () {
        for (final status in RideStatus.values) {
          if (status != RideStatus.failed) {
            expect(RideFsm.canTransition(RideStatus.failed, status), isFalse);
          }
        }
      });
    });

    group('Successful Transitions', () {
      test('transition() should succeed for valid transitions', () {
        final quotedRequest = RideFsm.transition(draftRequest, RideStatus.quoting);
        expect(quotedRequest.status, RideStatus.quoting);
        expect(quotedRequest.updatedAt, isNotNull);
        expect(quotedRequest.updatedAt!.isAfter(draftRequest.createdAt), isTrue);
      });

      test('tryTransition() should return new request for valid transitions', () {
        final quotedRequest = RideFsm.tryTransition(draftRequest, RideStatus.quoting);
        expect(quotedRequest, isNotNull);
        expect(quotedRequest!.status, RideStatus.quoting);
      });

      test('tryTransition() should return null for invalid transitions', () {
        final result = RideFsm.tryTransition(draftRequest, RideStatus.driverAccepted);
        expect(result, isNull);
      });
    });

    group('Failed Transitions', () {
      test('transition() should throw InvalidRideTransitionException for invalid transitions', () {
        expect(
          () => RideFsm.transition(draftRequest, RideStatus.driverAccepted),
          throwsA(isA<InvalidRideTransitionException>()),
        );
      });

      test('InvalidRideTransitionException should contain correct from/to values', () {
        try {
          RideFsm.transition(draftRequest, RideStatus.driverAccepted);
          fail('Expected exception was not thrown');
        } catch (e) {
          expect(e, isA<InvalidRideTransitionException>());
          final exception = e as InvalidRideTransitionException;
          expect(exception.from, RideStatus.draft);
          expect(exception.to, RideStatus.driverAccepted);
        }
      });
    });

    group('Happy Path Flow', () {
      test('complete happy path should work', () {
        // Draft -> Quoting
        var request = RideFsm.transition(draftRequest, RideStatus.quoting);
        expect(request.status, RideStatus.quoting);

        // Quoting -> QuoteReady
        request = RideFsm.transition(request, RideStatus.quoteReady);
        expect(request.status, RideStatus.quoteReady);

        // QuoteReady -> Requesting
        request = RideFsm.transition(request, RideStatus.requesting);
        expect(request.status, RideStatus.requesting);

        // Requesting -> FindingDriver
        request = RideFsm.transition(request, RideStatus.findingDriver);
        expect(request.status, RideStatus.findingDriver);

        // FindingDriver -> DriverAccepted
        request = RideFsm.transition(request, RideStatus.driverAccepted);
        expect(request.status, RideStatus.driverAccepted);

        // DriverAccepted -> DriverArrived
        request = RideFsm.transition(request, RideStatus.driverArrived);
        expect(request.status, RideStatus.driverArrived);

        // DriverArrived -> InProgress
        request = RideFsm.transition(request, RideStatus.inProgress);
        expect(request.status, RideStatus.inProgress);

        // InProgress -> Payment
        request = RideFsm.transition(request, RideStatus.payment);
        expect(request.status, RideStatus.payment);

        // Payment -> Completed
        request = RideFsm.transition(request, RideStatus.completed);
        expect(request.status, RideStatus.completed);
      });
    });

    group('Cancellation Flows', () {
      test('can cancel from draft', () {
        final cancelledRequest = RideFsm.transition(draftRequest, RideStatus.cancelled);
        expect(cancelledRequest.status, RideStatus.cancelled);
      });

      test('can cancel from quoting', () {
        final quotingRequest = RideFsm.transition(draftRequest, RideStatus.quoting);
        final cancelledRequest = RideFsm.transition(quotingRequest, RideStatus.cancelled);
        expect(cancelledRequest.status, RideStatus.cancelled);
      });

      test('can cancel from driverAccepted', () {
        final request = RideFsm.transition(draftRequest, RideStatus.quoting);
        final quoteReadyRequest = RideFsm.transition(request, RideStatus.quoteReady);
        final requestingRequest = RideFsm.transition(quoteReadyRequest, RideStatus.requesting);
        final findingDriverRequest = RideFsm.transition(requestingRequest, RideStatus.findingDriver);
        final driverAcceptedRequest = RideFsm.transition(findingDriverRequest, RideStatus.driverAccepted);

        final cancelledRequest = RideFsm.transition(driverAcceptedRequest, RideStatus.cancelled);
        expect(cancelledRequest.status, RideStatus.cancelled);
      });

      test('cannot cancel from inProgress', () {
        final request = RideFsm.transition(draftRequest, RideStatus.quoting);
        final quoteReadyRequest = RideFsm.transition(request, RideStatus.quoteReady);
        final requestingRequest = RideFsm.transition(quoteReadyRequest, RideStatus.requesting);
        final findingDriverRequest = RideFsm.transition(requestingRequest, RideStatus.findingDriver);
        final driverAcceptedRequest = RideFsm.transition(findingDriverRequest, RideStatus.driverAccepted);
        final driverArrivedRequest = RideFsm.transition(driverAcceptedRequest, RideStatus.driverArrived);
        final inProgressRequest = RideFsm.transition(driverArrivedRequest, RideStatus.inProgress);

        expect(
          () => RideFsm.transition(inProgressRequest, RideStatus.cancelled),
          throwsA(isA<InvalidRideTransitionException>()),
        );
      });
    });
  });

  group('RideStatus Extensions', () {
    test('isTerminal should work correctly', () {
      expect(RideStatus.completed.isTerminal, isTrue);
      expect(RideStatus.cancelled.isTerminal, isTrue);
      expect(RideStatus.failed.isTerminal, isTrue);
      expect(RideStatus.draft.isTerminal, isFalse);
      expect(RideStatus.inProgress.isTerminal, isFalse);
    });

    test('isActiveTrip should work correctly', () {
      expect(RideStatus.findingDriver.isActiveTrip, isTrue);
      expect(RideStatus.driverAccepted.isActiveTrip, isTrue);
      expect(RideStatus.driverArrived.isActiveTrip, isTrue);
      expect(RideStatus.inProgress.isActiveTrip, isTrue);
      expect(RideStatus.draft.isActiveTrip, isFalse);
      expect(RideStatus.completed.isActiveTrip, isFalse);
    });

    test('isCancellable should work correctly', () {
      expect(RideStatus.draft.isCancellable, isTrue);
      expect(RideStatus.quoting.isCancellable, isTrue);
      expect(RideStatus.driverAccepted.isCancellable, isTrue);
      expect(RideStatus.inProgress.isCancellable, isFalse);
      expect(RideStatus.payment.isCancellable, isFalse);
      expect(RideStatus.completed.isCancellable, isFalse);
    });

    test('isPreTrip should work correctly', () {
      expect(RideStatus.draft.isPreTrip, isTrue);
      expect(RideStatus.quoting.isPreTrip, isTrue);
      expect(RideStatus.findingDriver.isPreTrip, isTrue);
      expect(RideStatus.driverAccepted.isPreTrip, isFalse);
      expect(RideStatus.inProgress.isPreTrip, isFalse);
    });

    test('isWithDriver should work correctly', () {
      expect(RideStatus.driverAccepted.isWithDriver, isTrue);
      expect(RideStatus.driverArrived.isWithDriver, isTrue);
      expect(RideStatus.inProgress.isWithDriver, isTrue);
      expect(RideStatus.findingDriver.isWithDriver, isFalse);
      expect(RideStatus.draft.isWithDriver, isFalse);
    });

    test('isPaymentPhase should work correctly', () {
      expect(RideStatus.payment.isPaymentPhase, isTrue);
      expect(RideStatus.completed.isPaymentPhase, isFalse);
      expect(RideStatus.draft.isPaymentPhase, isFalse);
    });

    test('terminal state helpers should work correctly', () {
      expect(RideStatus.completed.isCompleted, isTrue);
      expect(RideStatus.cancelled.isCancelled, isTrue);
      expect(RideStatus.failed.isFailed, isTrue);
      expect(RideStatus.draft.isCompleted, isFalse);
    });
  });
}

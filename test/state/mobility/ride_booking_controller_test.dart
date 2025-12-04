/// Ride Booking Controller Tests - Track B Ticket #242
/// Purpose: Unit tests for RideBookingController
/// Created by: Track B - Ticket #242
/// Last updated: 2025-12-04

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobility_shims/mobility_shims.dart';

import '../../../lib/state/mobility/ride_booking_controller.dart';
import '../../../lib/state/mobility/ride_booking_state.dart';

void main() {
  group('RideBookingController', () {
    late ProviderContainer container;
    late InMemoryRideRepository repository;
    late RideBookingController controller;

    setUp(() {
      repository = InMemoryRideRepository();
      container = ProviderContainer(
        overrides: [
          rideRepositoryProvider.overrideWithValue(repository),
        ],
      );
      controller = container.read(rideBookingControllerProvider.notifier);
    });

    tearDown(() {
      container.dispose();
      repository.clear();
    });

    group('startNewRide', () {
      test('creates new draft request', () {
        controller.startNewRide();

        final state = container.read(rideBookingControllerProvider);
        expect(state.currentRequest, isNotNull);
        expect(state.status, RideStatus.draft);
        expect(state.lastErrorMessage, isNull);
      });

      test('creates draft with initial pickup', () {
        final pickup = MobilityPlace.currentLocation();
        controller.startNewRide(initialPickup: pickup);

        final state = container.read(rideBookingControllerProvider);
        expect(state.currentRequest?.pickup, pickup);
      });

      test('replaces existing request', () {
        controller.startNewRide();
        final firstRequest = container.read(rideBookingControllerProvider).currentRequest;

        controller.startNewRide();
        final secondRequest = container.read(rideBookingControllerProvider).currentRequest;

        expect(secondRequest?.id, isNot(equals(firstRequest?.id)));
      });
    });

    group('updatePickup and updateDestination', () {
      test('updatePickup creates new draft if none exists', () {
        final pickup = MobilityPlace.currentLocation();
        controller.updatePickup(pickup);

        final state = container.read(rideBookingControllerProvider);
        expect(state.currentRequest?.pickup, pickup);
        expect(state.currentRequest?.destination, isNull);
      });

      test('updateDestination creates new draft if none exists', () {
        final destination = MobilityPlace.saved(id: 'dest', label: 'Work');
        controller.updateDestination(destination);

        final state = container.read(rideBookingControllerProvider);
        expect(state.currentRequest?.destination, destination);
        expect(state.currentRequest?.pickup, isNull);
      });

      test('updatePickup updates existing request', () {
        controller.startNewRide();
        final pickup = MobilityPlace.currentLocation();
        controller.updatePickup(pickup);

        final state = container.read(rideBookingControllerProvider);
        expect(state.currentRequest?.pickup, pickup);
      });

      test('updateDestination updates existing request', () {
        controller.startNewRide();
        final destination = MobilityPlace.saved(id: 'dest', label: 'Work');
        controller.updateDestination(destination);

        final state = container.read(rideBookingControllerProvider);
        expect(state.currentRequest?.destination, destination);
      });

      test('updates clear error messages', () {
        // First set an error
        controller.startNewRide(); // Creates draft without locations
        controller.requestQuoteIfPossible(); // Should fail and set error

        var state = container.read(rideBookingControllerProvider);
        expect(state.lastErrorMessage, isNotNull);

        // Now update destination
        final destination = MobilityPlace.saved(id: 'dest', label: 'Work');
        controller.updateDestination(destination);

        state = container.read(rideBookingControllerProvider);
        expect(state.lastErrorMessage, isNull);
      });

      test('populates pricing when both locations are set', () {
        controller.startNewRide();
        final pickup = MobilityPlace.currentLocation();
        final destination = MobilityPlace.saved(id: 'dest', label: 'Work');

        controller.updatePickup(pickup);
        controller.updateDestination(destination);

        final state = container.read(rideBookingControllerProvider);
        expect(state.currentRequest?.hasValidLocations, isTrue);
        expect(state.currentRequest?.hasPricing, isTrue);
        expect(state.formattedPrice, '18.50');
        expect(state.formattedDuration, '10 min');
      });
    });

    group('requestQuoteIfPossible', () {
      test('succeeds when locations are complete', () async {
        controller.startNewRide();
        final pickup = MobilityPlace.currentLocation();
        final destination = MobilityPlace.saved(id: 'dest', label: 'Work');

        controller.updatePickup(pickup);
        controller.updateDestination(destination);

        await controller.requestQuoteIfPossible();

        final state = container.read(rideBookingControllerProvider);
        expect(state.status, RideStatus.quoteReady);
        expect(state.hasQuote, isTrue);
        expect(state.isRequestingQuote, isFalse);
        expect(state.lastErrorMessage, isNull);
      });

      test('fails when no request exists', () async {
        await controller.requestQuoteIfPossible();

        final state = container.read(rideBookingControllerProvider);
        expect(state.lastErrorMessage, contains('select pickup and destination'));
      });

      test('fails when locations are incomplete', () async {
        controller.startNewRide();
        final pickup = MobilityPlace.currentLocation();
        controller.updatePickup(pickup);
        // No destination

        await controller.requestQuoteIfPossible();

        final state = container.read(rideBookingControllerProvider);
        expect(state.lastErrorMessage, contains('both pickup and destination'));
      });

      test('fails when already requesting quote', () async {
        controller.startNewRide();
        final pickup = MobilityPlace.currentLocation();
        final destination = MobilityPlace.saved(id: 'dest', label: 'Work');
        controller.updatePickup(pickup);
        controller.updateDestination(destination);

        // Start first request
        controller.requestQuoteIfPossible();

        // Try second request while first is in progress
        await controller.requestQuoteIfPossible();

        final state = container.read(rideBookingControllerProvider);
        expect(state.lastErrorMessage, contains('already in progress'));
      });

      test('sets loading state during request', () async {
        controller.startNewRide();
        final pickup = MobilityPlace.currentLocation();
        final destination = MobilityPlace.saved(id: 'dest', label: 'Work');
        controller.updatePickup(pickup);
        controller.updateDestination(destination);

        // Start the async operation
        final future = controller.requestQuoteIfPossible();

        // Check loading state immediately
        var state = container.read(rideBookingControllerProvider);
        expect(state.isRequestingQuote, isTrue);

        // Wait for completion
        await future;
        state = container.read(rideBookingControllerProvider);
        expect(state.isRequestingQuote, isFalse);
      });
    });

    group('confirmRide', () {
      test('succeeds when quote is ready', () async {
        // Setup: create draft, set locations, get quote
        controller.startNewRide();
        final pickup = MobilityPlace.currentLocation();
        final destination = MobilityPlace.saved(id: 'dest', label: 'Work');
        controller.updatePickup(pickup);
        controller.updateDestination(destination);
        await controller.requestQuoteIfPossible();

        // Confirm ride
        await controller.confirmRide();

        final state = container.read(rideBookingControllerProvider);
        expect(state.status, RideStatus.findingDriver);
        expect(state.isConfirmingRide, isFalse);
        expect(state.lastErrorMessage, isNull);
      });

      test('fails when no quote available', () async {
        controller.startNewRide();

        await controller.confirmRide();

        final state = container.read(rideBookingControllerProvider);
        expect(state.lastErrorMessage, contains('No quote available'));
      });

      test('sets loading state during confirmation', () async {
        // Setup with quote ready
        controller.startNewRide();
        final pickup = MobilityPlace.currentLocation();
        final destination = MobilityPlace.saved(id: 'dest', label: 'Work');
        controller.updatePickup(pickup);
        controller.updateDestination(destination);
        await controller.requestQuoteIfPossible();

        // Start confirmation
        final future = controller.confirmRide();

        // Check loading state
        var state = container.read(rideBookingControllerProvider);
        expect(state.isConfirmingRide, isTrue);

        // Wait for completion
        await future;
        state = container.read(rideBookingControllerProvider);
        expect(state.isConfirmingRide, isFalse);
      });
    });

    group('cancelRide', () {
      test('cancels draft request', () async {
        controller.startNewRide();

        await controller.cancelRide();

        final state = container.read(rideBookingControllerProvider);
        expect(state.status, RideStatus.cancelled);
        expect(state.isCancelling, isFalse);
      });

      test('cancels quoting request', () async {
        controller.startNewRide();
        final pickup = MobilityPlace.currentLocation();
        final destination = MobilityPlace.saved(id: 'dest', label: 'Work');
        controller.updatePickup(pickup);
        controller.updateDestination(destination);

        // Start quoting
        controller.requestQuoteIfPossible();
        // Cancel immediately (should work even while quoting)
        await controller.cancelRide();

        final state = container.read(rideBookingControllerProvider);
        expect(state.status, RideStatus.cancelled);
      });

      test('does nothing when no request exists', () async {
        await controller.cancelRide();

        final state = container.read(rideBookingControllerProvider);
        expect(state.currentRequest, isNull);
      });

      test('fails to cancel inProgress request', () async {
        // Setup: get to inProgress state
        controller.startNewRide();
        final pickup = MobilityPlace.currentLocation();
        final destination = MobilityPlace.saved(id: 'dest', label: 'Work');
        controller.updatePickup(pickup);
        controller.updateDestination(destination);
        await controller.requestQuoteIfPossible();
        await controller.confirmRide();

        // Manually set to inProgress for testing
        final inProgressRequest = container.read(rideBookingControllerProvider).currentRequest!.copyWith(status: RideStatus.inProgress);
        repository.applyStatusUpdate(current: container.read(rideBookingControllerProvider).currentRequest!, newStatus: RideStatus.inProgress);
        // Update controller state manually for test
        (controller as dynamic).state = RideBookingState(currentRequest: inProgressRequest);

        await controller.cancelRide();

        final state = container.read(rideBookingControllerProvider);
        expect(state.lastErrorMessage, contains('cannot be cancelled'));
      });

      test('sets loading state during cancellation', () async {
        controller.startNewRide();

        final future = controller.cancelRide();

        var state = container.read(rideBookingControllerProvider);
        expect(state.isCancelling, isTrue);

        await future;
        state = container.read(rideBookingControllerProvider);
        expect(state.isCancelling, isFalse);
      });
    });

    group('State properties', () {
      test('canRequestQuote returns true when conditions are met', () {
        controller.startNewRide();
        final pickup = MobilityPlace.currentLocation();
        final destination = MobilityPlace.saved(id: 'dest', label: 'Work');
        controller.updatePickup(pickup);
        controller.updateDestination(destination);

        final state = container.read(rideBookingControllerProvider);
        expect(state.canRequestQuote, isTrue);
      });

      test('canRequestQuote returns false when requesting', () async {
        controller.startNewRide();
        final pickup = MobilityPlace.currentLocation();
        final destination = MobilityPlace.saved(id: 'dest', label: 'Work');
        controller.updatePickup(pickup);
        controller.updateDestination(destination);

        // Start request
        controller.requestQuoteIfPossible();

        final state = container.read(rideBookingControllerProvider);
        expect(state.canRequestQuote, isFalse);
      });

      test('hasQuote returns true after successful quote request', () async {
        controller.startNewRide();
        final pickup = MobilityPlace.currentLocation();
        final destination = MobilityPlace.saved(id: 'dest', label: 'Work');
        controller.updatePickup(pickup);
        controller.updateDestination(destination);

        await controller.requestQuoteIfPossible();

        final state = container.read(rideBookingControllerProvider);
        expect(state.hasQuote, isTrue);
      });

      test('formattedPrice and formattedDuration work correctly', () async {
        controller.startNewRide();
        final pickup = MobilityPlace.currentLocation();
        final destination = MobilityPlace.saved(id: 'dest', label: 'Work');
        controller.updatePickup(pickup);
        controller.updateDestination(destination);

        final state = container.read(rideBookingControllerProvider);
        expect(state.formattedPrice, '18.50');
        expect(state.formattedDuration, '10 min');
      });

      test('isLoading returns true when any operation is in progress', () {
        controller.startNewRide();

        controller.cancelRide(); // Start cancellation

        final state = container.read(rideBookingControllerProvider);
        expect(state.isLoading, isTrue);
      });
    });
  });
}

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
      test('creates new draft request', () async {
        await controller.startNewRide();

        final state = container.read(rideBookingControllerProvider);
        expect(state.ride, isNotNull);
        expect(state.status, RideStatus.draft);
        expect(state.errorMessage, isNull);
        expect(state.uiStatus, RideBookingUiStatus.idle);
      });

      test('creates draft with initial pickup', () async {
        final pickup = MobilityPlace.currentLocation();
        await controller.startNewRide(initialPickup: pickup);

        final state = container.read(rideBookingControllerProvider);
        expect(state.ride?.pickup, pickup);
      });

      test('replaces existing request', () async {
        await controller.startNewRide();
        final firstRequest = container.read(rideBookingControllerProvider).ride;

        await controller.startNewRide();
        final secondRequest = container.read(rideBookingControllerProvider).ride;

        expect(secondRequest?.id, isNot(equals(firstRequest?.id)));
      });
    });

    group('updatePickup and updateDestination', () {
      test('updatePickup updates existing request', () async {
        await controller.startNewRide();
        final pickup = MobilityPlace.currentLocation();
        await controller.updatePickup(pickup);

        final state = container.read(rideBookingControllerProvider);
        expect(state.ride?.pickup, pickup);
        expect(state.uiStatus, RideBookingUiStatus.idle);
      });

      test('updateDestination updates existing request', () async {
        await controller.startNewRide();
        final destination = MobilityPlace.saved(id: 'dest', label: 'Work');
        await controller.updateDestination(destination);

        final state = container.read(rideBookingControllerProvider);
        expect(state.ride?.destination, destination);
        expect(state.uiStatus, RideBookingUiStatus.idle);
      });

      test('updates clear error messages', () async {
        // First set an error
        await controller.startNewRide(); // Creates draft without locations
        await controller.requestQuoteIfPossible(); // Should fail and set error

        var state = container.read(rideBookingControllerProvider);
        expect(state.errorMessage, isNotNull);

        // Now update destination
        final destination = MobilityPlace.saved(id: 'dest', label: 'Work');
        await controller.updateDestination(destination);

        state = container.read(rideBookingControllerProvider);
        expect(state.errorMessage, isNull);
        expect(state.uiStatus, RideBookingUiStatus.idle);
      });

      test('populates pricing when both locations are set', () async {
        await controller.startNewRide();
        final pickup = MobilityPlace.currentLocation();
        final destination = MobilityPlace.saved(id: 'dest', label: 'Work');

        await controller.updatePickup(pickup);
        await controller.updateDestination(destination);

        final state = container.read(rideBookingControllerProvider);
        expect(state.ride?.hasValidLocations, isTrue);
        expect(state.ride?.hasPricing, isTrue);
        expect(state.formattedPrice, '18.00');
        expect(state.formattedDuration, '10 min');
      });
    });

    group('requestQuoteIfPossible', () {
      test('succeeds when locations are complete', () async {
        await controller.startNewRide();
        final pickup = MobilityPlace.currentLocation();
        final destination = MobilityPlace.saved(id: 'dest', label: 'Work');

        await controller.updatePickup(pickup);
        await controller.updateDestination(destination);

        await controller.requestQuoteIfPossible();

        final state = container.read(rideBookingControllerProvider);
        expect(state.status, RideStatus.quoteReady);
        expect(state.hasPricing, isTrue);
        expect(state.uiStatus, RideBookingUiStatus.idle);
        expect(state.errorMessage, isNull);
      });

      test('fails when no request exists', () async {
        await controller.requestQuoteIfPossible();

        final state = container.read(rideBookingControllerProvider);
        expect(state.errorMessage, 'quote_not_allowed');
        expect(state.uiStatus, RideBookingUiStatus.error);
      });

      test('fails when locations are incomplete', () async {
        await controller.startNewRide();
        final pickup = MobilityPlace.currentLocation();
        await controller.updatePickup(pickup);
        // No destination

        await controller.requestQuoteIfPossible();

        final state = container.read(rideBookingControllerProvider);
        expect(state.errorMessage, 'quote_not_allowed');
        expect(state.uiStatus, RideBookingUiStatus.error);
      });

      test('sets loading state during request', () async {
        await controller.startNewRide();
        final pickup = MobilityPlace.currentLocation();
        final destination = MobilityPlace.saved(id: 'dest', label: 'Work');
        await controller.updatePickup(pickup);
        await controller.updateDestination(destination);

        // Start the async operation
        final future = controller.requestQuoteIfPossible();

        // Check loading state immediately
        var state = container.read(rideBookingControllerProvider);
        expect(state.uiStatus, RideBookingUiStatus.loading);

        // Wait for completion
        await future;
        state = container.read(rideBookingControllerProvider);
        expect(state.uiStatus, RideBookingUiStatus.idle);
      });
    });

    group('confirmRide', () {
      test('succeeds when quote is ready', () async {
        // Setup: create draft, set locations, get quote
        await controller.startNewRide();
        final pickup = MobilityPlace.currentLocation();
        final destination = MobilityPlace.saved(id: 'dest', label: 'Work');
        await controller.updatePickup(pickup);
        await controller.updateDestination(destination);
        await controller.requestQuoteIfPossible();

        // Confirm ride
        await controller.confirmRide();

        final state = container.read(rideBookingControllerProvider);
        expect(state.status, RideStatus.findingDriver);
        expect(state.uiStatus, RideBookingUiStatus.idle);
        expect(state.errorMessage, isNull);
      });

      test('fails when no quote available', () async {
        await controller.startNewRide();

        await controller.confirmRide();

        final state = container.read(rideBookingControllerProvider);
        expect(state.errorMessage, 'confirm_not_allowed');
        expect(state.uiStatus, RideBookingUiStatus.error);
      });

      test('sets loading state during confirmation', () async {
        // Setup with quote ready
        await controller.startNewRide();
        final pickup = MobilityPlace.currentLocation();
        final destination = MobilityPlace.saved(id: 'dest', label: 'Work');
        await controller.updatePickup(pickup);
        await controller.updateDestination(destination);
        await controller.requestQuoteIfPossible();

        // Start confirmation
        final future = controller.confirmRide();

        // Check loading state
        var state = container.read(rideBookingControllerProvider);
        expect(state.uiStatus, RideBookingUiStatus.loading);

        // Wait for completion
        await future;
        state = container.read(rideBookingControllerProvider);
        expect(state.uiStatus, RideBookingUiStatus.idle);
      });
    });

    group('cancelRide', () {
      test('cancels draft request', () async {
        await controller.startNewRide();

        await controller.cancelRide();

        final state = container.read(rideBookingControllerProvider);
        expect(state.status, RideStatus.cancelled);
        expect(state.uiStatus, RideBookingUiStatus.idle);
      });

      test('cancels draft request', () async {
        await controller.startNewRide();

        await controller.cancelRide();

        final state = container.read(rideBookingControllerProvider);
        expect(state.status, RideStatus.cancelled);
        expect(state.uiStatus, RideBookingUiStatus.idle);
      });

      test('does nothing when no request exists', () async {
        await controller.cancelRide();

        final state = container.read(rideBookingControllerProvider);
        expect(state.ride, isNull);
      });

      test('cancels findingDriver request', () async {
        // Setup: get to findingDriver state (which is cancellable)
        await controller.startNewRide();
        final pickup = MobilityPlace.currentLocation();
        final destination = MobilityPlace.saved(id: 'dest', label: 'Work');
        await controller.updatePickup(pickup);
        await controller.updateDestination(destination);
        await controller.requestQuoteIfPossible();
        await controller.confirmRide();

        // findingDriver status should be cancellable
        final stateBeforeCancel = container.read(rideBookingControllerProvider);
        expect(stateBeforeCancel.status, RideStatus.findingDriver);
        expect(stateBeforeCancel.canCancel, isTrue);

        await controller.cancelRide();

        final state = container.read(rideBookingControllerProvider);
        expect(state.status, RideStatus.cancelled);
        expect(state.uiStatus, RideBookingUiStatus.idle);
      });
    });

    group('submitRating', () {
      test('stores rating when ride is completed', () async {
        final repository = InMemoryRideRepository();
        final controller = RideBookingController(repository);

        // Create a completed ride
        final completedRide = RideRequest(
          id: 'test-ride-id',
          status: RideStatus.completed,
          pickup: MobilityPlace.currentLocation(),
          destination: MobilityPlace.saved(id: 'work', label: 'Work'),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          estimatedDurationSeconds: 600,
          estimatedPrice: 1850,
          currencyCode: 'SAR',
        );

        controller.state = RideBookingState(
          rideId: 'ride-1',
          ride: completedRide,
        );

        await controller.submitRating(rating: 4, comment: 'nice_driver');

        expect(controller.state.rating, 4);
        expect(controller.state.ratingComment, 'nice_driver');
        expect(controller.state.uiStatus, RideBookingUiStatus.success);
        expect(controller.state.errorMessage, isNull);
      });

      test('sets error when rating is called in non-completed state', () async {
        final repository = InMemoryRideRepository();
        final controller = RideBookingController(repository);

        // Create a draft ride
        final draftRide = RideRequest(
          id: 'test-ride-id',
          status: RideStatus.draft,
          pickup: MobilityPlace.currentLocation(),
          destination: MobilityPlace.saved(id: 'work', label: 'Work'),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          estimatedDurationSeconds: 600,
          estimatedPrice: 1850,
          currencyCode: 'SAR',
        );

        controller.state = RideBookingState(
          rideId: 'ride-1',
          ride: draftRide,
        );

        await controller.submitRating(rating: 5);

        expect(controller.state.uiStatus, RideBookingUiStatus.error);
        expect(controller.state.errorMessage, 'rating_not_allowed');
        expect(controller.state.rating, isNull);
      });

      test('sets error for invalid rating values', () async {
        final repository = InMemoryRideRepository();
        final controller = RideBookingController(repository);

        // Create a completed ride
        final completedRide = RideRequest(
          id: 'test-ride-id',
          status: RideStatus.completed,
          pickup: MobilityPlace.currentLocation(),
          destination: MobilityPlace.saved(id: 'work', label: 'Work'),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          estimatedDurationSeconds: 600,
          estimatedPrice: 1850,
          currencyCode: 'SAR',
        );

        controller.state = RideBookingState(
          rideId: 'ride-1',
          ride: completedRide,
        );

        await controller.submitRating(rating: 6); // Invalid rating

        expect(controller.state.uiStatus, RideBookingUiStatus.error);
        expect(controller.state.errorMessage, 'rating_invalid_value');
        expect(controller.state.rating, isNull);
      });
    });

    group('State properties', () {
      test('canRequestQuote returns true when conditions are met', () async {
        await controller.startNewRide();
        final pickup = MobilityPlace.currentLocation();
        final destination = MobilityPlace.saved(id: 'dest', label: 'Work');
        await controller.updatePickup(pickup);
        await controller.updateDestination(destination);

        final state = container.read(rideBookingControllerProvider);
        expect(state.canRequestQuote, isTrue);
      });

      test('canConfirmRide returns true after successful quote request', () async {
        await controller.startNewRide();
        final pickup = MobilityPlace.currentLocation();
        final destination = MobilityPlace.saved(id: 'dest', label: 'Work');
        await controller.updatePickup(pickup);
        await controller.updateDestination(destination);

        await controller.requestQuoteIfPossible();

        final state = container.read(rideBookingControllerProvider);
        expect(state.canConfirmRide, isTrue);
      });

      test('formattedPrice and formattedDuration work correctly', () async {
        await controller.startNewRide();
        final pickup = MobilityPlace.currentLocation();
        final destination = MobilityPlace.saved(id: 'dest', label: 'Work');
        await controller.updatePickup(pickup);
        await controller.updateDestination(destination);

        final state = container.read(rideBookingControllerProvider);
        expect(state.formattedPrice, '18.00');
        expect(state.formattedDuration, '10 min');
      });

      test('isLoading returns true when any operation is in progress', () async {
        await controller.startNewRide();
        final pickup = MobilityPlace.currentLocation();
        final destination = MobilityPlace.saved(id: 'dest', label: 'Work');
        await controller.updatePickup(pickup);
        await controller.updateDestination(destination);

        // Start the async operation
        final future = controller.requestQuoteIfPossible();

        // Check loading state immediately
        final state = container.read(rideBookingControllerProvider);
        expect(state.isLoading, isTrue);

        // Wait for completion
        await future;
      });
    });
  });
}

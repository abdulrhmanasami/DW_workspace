/// Ride Booking Controller - Track B Ticket #242
/// Purpose: State management for ride booking UI
/// Created by: Track B - Ticket #242
/// Last updated: 2025-12-04
///
/// Controller that manages ride booking state and coordinates
/// with RideRepository for business operations.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobility_shims/mobility_shims.dart';

import 'ride_booking_state.dart';

/// Controller for ride booking operations.
///
/// This controller manages the UI state for ride booking and coordinates
/// with the RideRepository for all business operations. It handles
/// loading states, error handling, and state transitions.
class RideBookingController extends StateNotifier<RideBookingState> {
  /// Creates a ride booking controller with the given repository.
  RideBookingController({
    required RideRepository repository,
  })  : _repository = repository,
        super(const RideBookingState());

  final RideRepository _repository;

  /// Starts a new ride booking request.
  ///
  /// If there's already an active request, this will replace it.
  /// If [initialPickup] is provided, it will be set as the pickup location.
  void startNewRide({MobilityPlace? initialPickup}) {
    final newRequest = _repository.createDraft(initialPickup: initialPickup);
    state = state.copyWith(
      currentRequest: newRequest,
      lastErrorMessage: null, // Clear any previous errors
    );
  }

  /// Updates the pickup location for the current request.
  ///
  /// If no current request exists, automatically starts a new one.
  void updatePickup(MobilityPlace? pickup) {
    final currentRequest = state.currentRequest ?? _createNewDraft();
    final updatedRequest = _repository.updateLocations(
      request: currentRequest,
      pickup: pickup,
    );

    state = state.copyWith(
      currentRequest: updatedRequest,
      lastErrorMessage: null,
    );
  }

  /// Updates the destination location for the current request.
  ///
  /// If no current request exists, automatically starts a new one.
  void updateDestination(MobilityPlace? destination) {
    final currentRequest = state.currentRequest ?? _createNewDraft();
    final updatedRequest = _repository.updateLocations(
      request: currentRequest,
      destination: destination,
    );

    state = state.copyWith(
      currentRequest: updatedRequest,
      lastErrorMessage: null,
    );
  }

  /// Requests a quote for the current request if possible.
  ///
  /// This will fail if:
  /// - No current request exists
  /// - Locations are not complete
  /// - Request is not in draft status
  /// - A quote request is already in progress
  Future<void> requestQuoteIfPossible() async {
    if (!state.canRequestQuote) {
      final errorMessage = _getQuoteRequestErrorMessage();
      state = state.copyWith(lastErrorMessage: errorMessage);
      return;
    }

    state = state.copyWith(
      isRequestingQuote: true,
      lastErrorMessage: null,
    );

    try {
      final quotedRequest = await _repository.requestQuote(state.currentRequest!);
      state = state.copyWith(
        currentRequest: quotedRequest,
        isRequestingQuote: false,
      );
    } catch (e) {
      state = state.copyWith(
        isRequestingQuote: false,
        lastErrorMessage: _formatErrorMessage(e),
      );
    }
  }

  /// Confirms the current ride request.
  ///
  /// This will transition the request to findingDriver status.
  /// Requires that a quote has been successfully obtained.
  Future<void> confirmRide() async {
    if (!state.hasQuote) {
      state = state.copyWith(
        lastErrorMessage: 'No quote available. Please request a quote first.',
      );
      return;
    }

    state = state.copyWith(
      isConfirmingRide: true,
      lastErrorMessage: null,
    );

    try {
      final confirmedRequest = await _repository.confirmRide(state.currentRequest!);
      state = state.copyWith(
        currentRequest: confirmedRequest,
        isConfirmingRide: false,
      );
    } catch (e) {
      state = state.copyWith(
        isConfirmingRide: false,
        lastErrorMessage: _formatErrorMessage(e),
      );
    }
  }

  /// Cancels the current ride request if possible.
  ///
  /// This will only work for requests that are still cancellable
  /// (not inProgress or later stages).
  Future<void> cancelRide() async {
    final currentRequest = state.currentRequest;
    if (currentRequest == null) {
      return; // Nothing to cancel
    }

    if (!currentRequest.status.isCancellable) {
      state = state.copyWith(
        lastErrorMessage: 'This ride cannot be cancelled at this stage.',
      );
      return;
    }

    state = state.copyWith(
      isCancelling: true,
      lastErrorMessage: null,
    );

    try {
      final cancelledRequest = _repository.cancelRide(currentRequest);
      state = state.copyWith(
        currentRequest: cancelledRequest,
        isCancelling: false,
      );
    } catch (e) {
      state = state.copyWith(
        isCancelling: false,
        lastErrorMessage: _formatErrorMessage(e),
      );
    }
  }

  /// Helper method to create a new draft request.
  RideRequest _createNewDraft() {
    final newRequest = _repository.createDraft();
    state = state.copyWith(currentRequest: newRequest);
    return newRequest;
  }

  /// Gets appropriate error message for quote request failures.
  String _getQuoteRequestErrorMessage() {
    final currentRequest = state.currentRequest;
    if (currentRequest == null) {
      return 'Please select pickup and destination locations first.';
    }

    if (!currentRequest.hasValidLocations) {
      return 'Please select both pickup and destination locations.';
    }

    if (currentRequest.status != RideStatus.draft) {
      return 'Cannot request quote for this ride at this stage.';
    }

    if (state.isRequestingQuote) {
      return 'Quote request already in progress.';
    }

    return 'Unable to request quote. Please try again.';
  }

  /// Formats exceptions into user-friendly error messages.
  String _formatErrorMessage(Object error) {
    if (error is InvalidRideTransitionException) {
      return 'Invalid operation for current ride status.';
    }

    if (error is ArgumentError) {
      return error.message ?? 'Invalid request parameters.';
    }

    // For other exceptions, provide a generic message
    return 'An error occurred. Please try again.';
  }
}

/// Riverpod providers for ride booking.

/// Provider for the ride repository implementation.
final rideRepositoryProvider = Provider<RideRepository>((ref) {
  return InMemoryRideRepository();
});

/// Provider for the ride booking controller.
final rideBookingControllerProvider =
    StateNotifierProvider<RideBookingController, RideBookingState>((ref) {
  final repository = ref.watch(rideRepositoryProvider);
  return RideBookingController(repository: repository);
});

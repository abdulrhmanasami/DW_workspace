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
  RideBookingController(this._rideRepository)
      : super(RideBookingState.initial());

  final RideRepository _rideRepository;

  /// Starts a new ride booking request.
  ///
  /// If there's already an active request, this will replace it.
  /// If [initialPickup] is provided, it will be set as the pickup location.
  Future<void> startNewRide({MobilityPlace? initialPickup}) async {
    state = state.copyWith(
      uiStatus: RideBookingUiStatus.loading,
      clearError: true,
    );

    try {
    final draft = _rideRepository.createDraft(
      initialPickup: initialPickup,
    );

    state = RideBookingState(
      rideId: draft.id,
      ride: draft,
      uiStatus: RideBookingUiStatus.idle,
    );
    } catch (e) {
      state = state.copyWith(
        uiStatus: RideBookingUiStatus.error,
        errorMessage: 'ride_start_failed',
      );
    }
  }

  /// Updates the pickup location for the current request.
  ///
  /// If no current request exists, automatically starts a new one.
  Future<void> updatePickup(MobilityPlace pickup) async {
    if (state.ride == null) return;
    state = state.copyWith(uiStatus: RideBookingUiStatus.loading, clearError: true);

    try {
    final updated = _rideRepository.updateLocations(
        request: state.ride!,
      pickup: pickup,
        destination: state.ride!.destination,
    );

    state = state.copyWith(
      ride: updated,
      uiStatus: RideBookingUiStatus.idle,
      );
    } catch (e) {
      state = state.copyWith(
        uiStatus: RideBookingUiStatus.error,
        errorMessage: 'update_pickup_failed',
    );
    }
  }

  /// Updates the destination location for the current request.
  ///
  /// If no current request exists, automatically starts a new one.
  Future<void> updateDestination(MobilityPlace destination) async {
    if (state.ride == null) return;
    state = state.copyWith(uiStatus: RideBookingUiStatus.loading, clearError: true);

    try {
    final updated = _rideRepository.updateLocations(
        request: state.ride!,
        pickup: state.ride!.pickup,
      destination: destination,
    );

    state = state.copyWith(
      ride: updated,
      uiStatus: RideBookingUiStatus.idle,
      );
    } catch (e) {
      state = state.copyWith(
        uiStatus: RideBookingUiStatus.error,
        errorMessage: 'update_destination_failed',
    );
    }
  }

  /// Requests a quote for the current request if possible.
  ///
  /// This will fail if:
  /// - No current request exists
  /// - Locations are not complete
  /// - Request is not in draft status
  Future<void> requestQuoteIfPossible() async {
    if (!state.canRequestQuote) {
      state = state.copyWith(
        uiStatus: RideBookingUiStatus.error,
        errorMessage: 'quote_not_allowed',
      );
      return;
    }

    state = state.copyWith(
      uiStatus: RideBookingUiStatus.loading,
      clearError: true,
    );

    try {
      final quotedRequest = await _rideRepository.requestQuote(state.ride!);
      state = state.copyWith(
        ride: quotedRequest,
        uiStatus: RideBookingUiStatus.idle,
      );
    } on ArgumentError {
      state = state.copyWith(
        uiStatus: RideBookingUiStatus.error,
        errorMessage: 'quote_argument_error',
      );
    } catch (e) {
      state = state.copyWith(
        uiStatus: RideBookingUiStatus.error,
        errorMessage: 'quote_failed',
      );
    }
  }

  /// Confirms the current ride request.
  ///
  /// This will transition the request to findingDriver status.
  /// Requires that a quote has been successfully obtained.
  Future<void> confirmRide() async {
    if (!state.canConfirmRide) {
      state = state.copyWith(
        uiStatus: RideBookingUiStatus.error,
        errorMessage: 'confirm_not_allowed',
      );
      return;
    }

    state = state.copyWith(
      uiStatus: RideBookingUiStatus.loading,
      clearError: true,
    );

    try {
      final confirmedRequest = await _rideRepository.confirmRide(state.ride!);
      state = state.copyWith(
        ride: confirmedRequest,
        uiStatus: RideBookingUiStatus.idle,
      );
    } on ArgumentError {
      state = state.copyWith(
        uiStatus: RideBookingUiStatus.error,
        errorMessage: 'confirm_argument_error',
      );
    } catch (e) {
      state = state.copyWith(
        uiStatus: RideBookingUiStatus.error,
        errorMessage: 'confirm_failed',
      );
    }
  }

  /// Cancels the current ride request if possible.
  ///
  /// This will only work for requests that are still cancellable
  /// (not inProgress or later stages).
  Future<void> cancelRide() async {
    if (!state.canCancel || state.ride == null) {
      state = state.copyWith(
        uiStatus: RideBookingUiStatus.error,
        errorMessage: 'cancel_not_allowed',
      );
      return;
    }

    state = state.copyWith(uiStatus: RideBookingUiStatus.loading, clearError: true);

    try {
      final cancelled = _rideRepository.cancelRide(state.ride!);

      state = state.copyWith(
        ride: cancelled,
        uiStatus: RideBookingUiStatus.idle,
      );
    } on InvalidRideTransitionException {
      state = state.copyWith(
        uiStatus: RideBookingUiStatus.error,
        errorMessage: 'cancel_invalid_transition',
      );
    } catch (e) {
      state = state.copyWith(
        uiStatus: RideBookingUiStatus.error,
        errorMessage: 'cancel_failed',
      );
    }
  }

  /// Submits a rating for the current ride (1–5 stars) with optional comment.
  ///
  /// For now this is stored locally in [RideBookingState] only.
  /// In a future phase it can call a dedicated ratings repository shim.
  Future<void> submitRating({
    required int rating,
    String? comment,
  }) async {
    // Must have a completed ride to rate.
    if (state.ride == null || state.status != RideStatus.completed) {
      state = state.copyWith(
        uiStatus: RideBookingUiStatus.error,
        errorMessage: 'rating_not_allowed',
      );
      return;
    }

    // Basic validation on rating value.
    if (rating < 1 || rating > 5) {
      state = state.copyWith(
        uiStatus: RideBookingUiStatus.error,
        errorMessage: 'rating_invalid_value',
      );
      return;
    }

    // Local-only update; no backend call for now.
    state = state.copyWith(
      uiStatus: RideBookingUiStatus.loading,
      clearError: true,
    );

    try {
      // If we want async-feel without real IO.
      // await Future<void>.delayed(const Duration(milliseconds: 150));

      state = state.copyWith(
        uiStatus: RideBookingUiStatus.success,
        rating: rating,
        ratingComment: comment,
      );
    } catch (_) {
      state = state.copyWith(
        uiStatus: RideBookingUiStatus.error,
        errorMessage: 'rating_submit_failed',
      );
    }
  }

}

/// Riverpod providers for ride booking.

/// Provider for the ride repository implementation.
final rideRepositoryProvider = Provider<RideRepository>((ref) {
  // استخدم InMemoryRideRepository للآن، لحين ربط Backend حقيقي
  return InMemoryRideRepository();
});

/// Provider for the ride booking controller.
final rideBookingControllerProvider =
    StateNotifierProvider<RideBookingController, RideBookingState>((ref) {
  final repo = ref.watch(rideRepositoryProvider);
  return RideBookingController(repo);
});

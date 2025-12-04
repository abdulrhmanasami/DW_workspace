/// Ride Booking State - Track B Ticket #242
/// Purpose: UI state for ride booking controller
/// Created by: Track B - Ticket #242
/// Last updated: 2025-12-04
///
/// State object for RideBookingController.
/// Contains current request and loading states.

import 'package:mobility_shims/mobility_shims.dart';

/// Immutable state for the ride booking UI.
///
/// This state represents the current status of the ride booking process
/// from the UI perspective. It contains the current ride request and
/// various loading states for different operations.
class RideBookingState {
  /// Creates a ride booking state.
  const RideBookingState({
    this.currentRequest,
    this.isRequestingQuote = false,
    this.isConfirmingRide = false,
    this.isCancelling = false,
    this.lastErrorMessage,
  });

  /// The current ride request being worked on.
  /// Null if no request has been started yet.
  final RideRequest? currentRequest;

  /// Whether a quote request is currently in progress.
  final bool isRequestingQuote;

  /// Whether ride confirmation is currently in progress.
  final bool isConfirmingRide;

  /// Whether ride cancellation is currently in progress.
  final bool isCancelling;

  /// Last error message to display to the user.
  /// Null if no error has occurred.
  final String? lastErrorMessage;

  /// Gets the current status of the ride request.
  RideStatus get status => currentRequest?.status ?? RideStatus.draft;

  /// Whether the current request can have a quote requested.
  bool get canRequestQuote =>
      currentRequest?.hasValidLocations == true &&
      status == RideStatus.draft &&
      !isRequestingQuote;

  /// Whether the current request has a ready quote.
  bool get hasQuote => currentRequest?.status == RideStatus.quoteReady;

  /// Formatted price string for display (e.g., "18.50 SAR").
  String? get formattedPrice => currentRequest?.formattedEstimatedPrice;

  /// Formatted duration string for display (e.g., "10 min").
  String? get formattedDuration => currentRequest?.formattedEstimatedDuration;

  /// Whether any loading operation is in progress.
  bool get isLoading =>
      isRequestingQuote || isConfirmingRide || isCancelling;

  /// Creates a copy of this state with the given fields replaced.
  RideBookingState copyWith({
    RideRequest? currentRequest,
    bool? isRequestingQuote,
    bool? isConfirmingRide,
    bool? isCancelling,
    String? lastErrorMessage,
  }) {
    return RideBookingState(
      currentRequest: currentRequest ?? this.currentRequest,
      isRequestingQuote: isRequestingQuote ?? this.isRequestingQuote,
      isConfirmingRide: isConfirmingRide ?? this.isConfirmingRide,
      isCancelling: isCancelling ?? this.isCancelling,
      lastErrorMessage: lastErrorMessage ?? this.lastErrorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RideBookingState &&
        other.currentRequest == currentRequest &&
        other.isRequestingQuote == isRequestingQuote &&
        other.isConfirmingRide == isConfirmingRide &&
        other.isCancelling == isCancelling &&
        other.lastErrorMessage == lastErrorMessage;
  }

  @override
  int get hashCode => Object.hash(
        currentRequest,
        isRequestingQuote,
        isConfirmingRide,
        isCancelling,
        lastErrorMessage,
      );

  @override
  String toString() {
    return 'RideBookingState('
        'status: $status, '
        'isLoading: $isLoading, '
        'canRequestQuote: $canRequestQuote, '
        'hasQuote: $hasQuote, '
        'error: $lastErrorMessage'
        ')';
  }
}

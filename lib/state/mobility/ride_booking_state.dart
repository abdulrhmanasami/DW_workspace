/// Ride Booking State - Track B Ticket #242
/// Purpose: UI state for ride booking controller
/// Created by: Track B - Ticket #242
/// Last updated: 2025-12-04
///
/// State object for RideBookingController.
/// Contains current request and UI status states.

import 'package:maps_shims/maps_shims.dart';
import 'package:mobility_shims/mobility_shims.dart';

/// UI status for ride booking operations.
enum RideBookingUiStatus {
  /// No operation is currently in progress.
  idle,

  /// An operation is currently loading.
  loading,

  /// The last operation completed successfully.
  success,

  /// The last operation failed with an error.
  error,
}

/// Immutable state for the ride booking UI.
///
/// This state represents the current status of the ride booking process
/// from the UI perspective. It contains the current ride request and
/// UI status for different operations.
class RideBookingState {
  /// Creates a ride booking state.
  const RideBookingState({
    this.rideId,
    this.ride,
    this.uiStatus = RideBookingUiStatus.idle,
    this.errorMessage,
    this.polylines,
    this.quotes,
    this.selectedQuote,
    this.rating,
    this.ratingComment,
  });

  /// Factory for initial state.
  factory RideBookingState.initial() => const RideBookingState();

  /// The ID of the current ride request.
  final String? rideId;

  /// The current ride request being worked on.
  /// Null if no request has been started yet.
  final RideRequest? ride;

  /// Current UI status for operations.
  final RideBookingUiStatus uiStatus;

  /// Last error message to display to the user.
  /// Null if no error has occurred.
  final String? errorMessage;

  /// The route polylines to display on the map.
  /// Null if no route has been calculated yet.
  final List<MapPolyline>? polylines;

  /// The available ride quotes for the current route.
  /// Null if quotes have not been requested yet.
  final RideQuote? quotes;

  /// Currently selected ride quote option.
  /// Null if no option has been selected yet.
  final RideQuoteOption? selectedQuote;

  /// User rating for the completed ride (1–5 stars).
  final int? rating;

  /// Optional user comment for the completed ride.
  final String? ratingComment;

  /// Whether there is an active ride request.
  bool get hasRide => ride != null;

  /// Gets the current status of the ride request.
  RideStatus? get status => ride?.status;

  /// Whether the ride has valid locations set.
  bool get hasValidLocations => ride?.hasValidLocations ?? false;

  /// Whether the ride has pricing information.
  bool get hasPricing => ride?.hasPricing ?? false;

  /// Whether the current request can have a quote requested.
  bool get canRequestQuote =>
      status == RideStatus.draft && hasValidLocations && hasPricing;

  /// Whether the current request can be confirmed.
  bool get canConfirmRide =>
      status == RideStatus.quoteReady && hasPricing;

  /// Whether the current request can be cancelled.
  bool get canCancel =>
      status == RideStatus.draft ||
      status == RideStatus.quoting ||
      status == RideStatus.quoteReady ||
      status == RideStatus.findingDriver;

  /// Whether the ride has a quote (for UI compatibility).
  bool get hasQuote => status == RideStatus.quoteReady ||
      status == RideStatus.findingDriver ||
      status == RideStatus.inProgress ||
      status == RideStatus.completed;

  /// Alias for errorMessage for UI compatibility.
  String? get lastErrorMessage => errorMessage;

  /// Whether a quote is currently being requested.
  bool get isRequestingQuote => status == RideStatus.quoting;

  /// Formatted price string for display (e.g., "18.50 SAR").
  String? get formattedPrice => ride?.formattedEstimatedPrice;

  /// Formatted duration string for display (e.g., "10 min").
  String? get formattedDuration => ride?.formattedEstimatedDuration;

  /// Whether any loading operation is in progress.
  bool get isLoading => uiStatus == RideBookingUiStatus.loading;

  /// Whether the user has already submitted a rating for this ride.
  bool get hasSubmittedRating => rating != null;

  /// Whether route polylines are available for display.
  bool get hasPolylines => polylines != null && polylines!.isNotEmpty;

  /// Whether ride quotes are available for selection.
  bool get hasQuotes => quotes != null && quotes!.options.isNotEmpty;

  /// Creates a copy of this state with the given fields replaced.
  RideBookingState copyWith({
    String? rideId,
    RideRequest? ride,
    RideBookingUiStatus? uiStatus,
    String? errorMessage,
    bool clearError = false,
    List<MapPolyline>? polylines,
    RideQuote? quotes,
    RideQuoteOption? selectedQuote,
    bool clearQuotes = false,
    int? rating,
    String? ratingComment,
    bool clearRating = false,
  }) {
    return RideBookingState(
      rideId: rideId ?? this.rideId,
      ride: ride ?? this.ride,
      uiStatus: uiStatus ?? this.uiStatus,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      polylines: polylines ?? this.polylines,
      quotes: clearQuotes ? null : (quotes ?? this.quotes),
      selectedQuote: selectedQuote ?? this.selectedQuote,
      rating: clearRating ? null : (rating ?? this.rating),
      ratingComment: clearRating ? null : (ratingComment ?? this.ratingComment),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RideBookingState &&
        other.rideId == rideId &&
        other.ride == ride &&
        other.uiStatus == uiStatus &&
        other.errorMessage == errorMessage &&
        other.polylines == polylines &&
        other.quotes == quotes &&
        other.selectedQuote == selectedQuote &&
        other.rating == rating &&
        other.ratingComment == ratingComment;
  }

  @override
  int get hashCode => Object.hash(
        rideId,
        ride,
        uiStatus,
        errorMessage,
        polylines,
        quotes,
        selectedQuote,
        rating,
        ratingComment,
      );

  @override
  String toString() {
    return 'RideBookingState('
        'rideId: $rideId, '
        'status: $status, '
        'uiStatus: $uiStatus, '
        'canRequestQuote: $canRequestQuote, '
        'canConfirmRide: $canConfirmRide, '
        'canCancel: $canCancel, '
        'hasPolylines: ${polylines != null}, '
        'hasQuotes: ${quotes != null}, '
        'selectedQuote: $selectedQuote, '
        'error: $errorMessage, '
        'rating: $rating, '
        'hasSubmittedRating: $hasSubmittedRating'
        ')';
  }
}

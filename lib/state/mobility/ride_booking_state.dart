/// Ride Booking State - Track B Ticket #242
/// Purpose: UI state for ride booking controller
/// Created by: Track B - Ticket #242
/// Updated by: Track B - Ticket B-3 (Driver location simulation)
/// Updated by: Track B - Ticket B-4 (ETA, Driver Rating, Navigation Guard)
/// Last updated: 2025-12-05
///
/// State object for RideBookingController.
/// Contains current request and UI status states.
///
/// Track B - Ticket B-3: Added driver location tracking for live simulation.
/// Track B - Ticket B-4: Added ETA calculation and driver rating.

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
///
/// Track B - Ticket B-3: Added driver location and info for live tracking.
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
    this.driverLocation,
    this.driverName,
    this.driverCarInfo,
    this.estimatedMinutesAway,
    this.driverRating,
    this.driverAvatarUrl,
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

  /// Track B - Ticket B-3: Current driver location during tracking.
  /// Updated periodically during simulation or from real-time backend.
  final LocationPoint? driverLocation;

  /// Track B - Ticket B-3: Name of the assigned driver.
  final String? driverName;

  /// Track B - Ticket B-3: Driver's car information (model, plate, etc).
  final String? driverCarInfo;

  /// Track B - Ticket B-4: Estimated time of arrival in minutes.
  /// Updated dynamically based on driver distance.
  final int? estimatedMinutesAway;

  /// Track B - Ticket B-4: Driver's rating (1.0 - 5.0).
  final double? driverRating;

  /// Track B - Ticket B-4: Driver's profile image URL.
  final String? driverAvatarUrl;

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

  /// Track B - Ticket B-3: Whether driver info is available.
  bool get hasDriverInfo => driverName != null || driverLocation != null;

  /// Track B - Ticket B-3: Whether we have a valid driver location for display.
  bool get hasDriverLocation => driverLocation != null;

  /// Track B - Ticket B-4: Whether ETA is available for display.
  bool get hasEta => estimatedMinutesAway != null && estimatedMinutesAway! > 0;

  /// Track B - Ticket B-4: Formatted ETA string for display (e.g., "5 mins away").
  String? get formattedEta {
    if (!hasEta) return null;
    final mins = estimatedMinutesAway!;
    if (mins == 1) return '1 min away';
    return '$mins mins away';
  }

  /// Track B - Ticket B-4: Whether driver rating is available.
  bool get hasDriverRating => driverRating != null;

  /// Track B - Ticket B-4: Formatted driver rating for display (e.g., "4.8").
  String? get formattedDriverRating {
    if (!hasDriverRating) return null;
    return driverRating!.toStringAsFixed(1);
  }

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
    LocationPoint? driverLocation,
    bool clearDriverLocation = false,
    String? driverName,
    String? driverCarInfo,
    int? estimatedMinutesAway,
    bool clearEta = false,
    double? driverRating,
    String? driverAvatarUrl,
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
      driverLocation: clearDriverLocation ? null : (driverLocation ?? this.driverLocation),
      driverName: driverName ?? this.driverName,
      driverCarInfo: driverCarInfo ?? this.driverCarInfo,
      estimatedMinutesAway: clearEta ? null : (estimatedMinutesAway ?? this.estimatedMinutesAway),
      driverRating: driverRating ?? this.driverRating,
      driverAvatarUrl: driverAvatarUrl ?? this.driverAvatarUrl,
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
        other.ratingComment == ratingComment &&
        other.driverLocation == driverLocation &&
        other.driverName == driverName &&
        other.driverCarInfo == driverCarInfo &&
        other.estimatedMinutesAway == estimatedMinutesAway &&
        other.driverRating == driverRating &&
        other.driverAvatarUrl == driverAvatarUrl;
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
        driverLocation,
        driverName,
        driverCarInfo,
        estimatedMinutesAway,
        driverRating,
        driverAvatarUrl,
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
        'hasSubmittedRating: $hasSubmittedRating, '
        'driverLocation: $driverLocation, '
        'driverName: $driverName, '
        'estimatedMinutesAway: $estimatedMinutesAway, '
        'driverRating: $driverRating'
        ')';
  }
}

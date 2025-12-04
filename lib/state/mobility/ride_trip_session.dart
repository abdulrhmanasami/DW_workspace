/// Ride Trip Session Controller - Track B Ticket #12
/// Purpose: Bridge between RideDraftUiState and RideTrip FSM (mobility_shims)
/// Created by: Track B - Ticket #12
/// Updated by: Track B - Ticket #96 (historyTrips + archiveTrip for Orders History)
/// Updated by: Track B - Ticket #113 (Request Ride CTA integration docs)
/// Updated by: Track B - Ticket #117 (completeCurrentTrip API for domain-level archiving)
/// Updated by: Track B - Ticket #122 (failCurrentTrip API for No Driver Found / Request Failed)
/// Updated by: Track B - Ticket #124 (driverRating in RideHistoryEntry + setRatingForMostRecentTrip)
/// Last updated: 2025-12-01
///
/// This controller manages the active ride trip session in memory,
/// using the canonical FSM from mobility_shims.
///
/// Track B - Ticket #113: Happy Path Flow (Request Ride CTA):
/// 1. UI calls startFromDraft(draft, selectedOption) from Trip Confirmation
/// 2. Controller creates initial RideTripState in draft phase
/// 3. FSM transitions: draft -> quoting -> requesting -> findingDriver
/// 4. State updates with activeTrip, tripSummary, and draftSnapshot
/// 5. UI navigates to Active Trip screen which reads from this provider
///
/// IMPORTANT:
/// - No Backend/SDK calls in this ticket - purely client-side state management.
/// - Later, this will integrate with quote/dispatch services via events.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// From mobility_shims package (quote models and FSM):
import 'package:mobility_shims/mobility_shims.dart';

// From maps_shims package (map integration):
import 'package:maps_shims/maps_shims.dart';

// From pricing_shims package (pricing integration):
import 'package:pricing_shims/pricing_shims.dart' as pricing;

// From app:
import 'ride_draft_state.dart';
import 'ride_map_commands_builder.dart';
import 'ride_map_port_providers.dart';
import 'ride_map_projection.dart';
import 'ride_pricing_providers.dart';
import 'ride_recent_locations_providers.dart';
import 'tracking_controller.dart';

/// Entry in the ride history list.
///
/// Contains the canonical [RideTripState] plus UI-relevant metadata
/// captured at the time the trip was archived.
///
/// Track B - Ticket #96: Orders History support
/// Track B - Ticket #108: Extended with serviceName, originLabel, paymentMethodLabel
/// Track B - Ticket #124: Extended with driverRating for driver rating persistence
@immutable
class RideHistoryEntry {
  const RideHistoryEntry({
    required this.trip,
    required this.destinationLabel,
    required this.completedAt,
    this.amountFormatted,
    this.serviceName,
    this.originLabel,
    this.paymentMethodLabel,
    this.driverRating,
  });

  /// The canonical trip state from mobility_shims.
  final RideTripState trip;

  /// Human-readable destination label (e.g. "King Fahd Road").
  final String destinationLabel;

  /// When the trip reached a terminal state.
  final DateTime completedAt;

  /// Formatted price (e.g. "SAR 24.50") if available.
  final String? amountFormatted;

  /// Track B - Ticket #108: Service name (e.g. "Economy", "XL", "Premium").
  final String? serviceName;

  /// Track B - Ticket #108: Human-readable pickup/origin label.
  final String? originLabel;

  /// Track B - Ticket #108: Payment method label (e.g. "Visa ••4242", "Cash").
  final String? paymentMethodLabel;

  /// Track B - Ticket #124: Optional driver rating (1.0–5.0 stars).
  /// Set by user after trip completion via setRatingForMostRecentTrip.
  final double? driverRating;

  /// Track B - Ticket #124: Creates a copy of this entry with updated fields.
  RideHistoryEntry copyWith({
    RideTripState? trip,
    String? destinationLabel,
    DateTime? completedAt,
    String? amountFormatted,
    String? serviceName,
    String? originLabel,
    String? paymentMethodLabel,
    double? driverRating,
  }) {
    return RideHistoryEntry(
      trip: trip ?? this.trip,
      destinationLabel: destinationLabel ?? this.destinationLabel,
      completedAt: completedAt ?? this.completedAt,
      amountFormatted: amountFormatted ?? this.amountFormatted,
      serviceName: serviceName ?? this.serviceName,
      originLabel: originLabel ?? this.originLabel,
      paymentMethodLabel: paymentMethodLabel ?? this.paymentMethodLabel,
      driverRating: driverRating ?? this.driverRating,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RideHistoryEntry &&
        other.trip.tripId == trip.tripId &&
        other.trip.phase == trip.phase &&
        other.driverRating == driverRating;
  }

  @override
  int get hashCode => Object.hash(trip.tripId, trip.phase, driverRating);
}

/// Unified summary of the active ride trip.
///
/// Track B - Ticket #105: Single source of truth for trip summary data
/// (service name, price, payment method) used by Active Trip screen and
/// Home Hub active ride card.
///
/// Populated from RideDraftUiState + RideQuote when trip starts via startFromDraft.
@immutable
class RideTripSummary {
  const RideTripSummary({
    this.selectedServiceId,
    this.selectedServiceName,
    this.fareDisplayText,
    this.selectedPaymentMethodId,
    this.etaMinutes,
  });

  /// The quote option id selected for this trip (e.g. 'economy', 'xl')
  final String? selectedServiceId;

  /// Display name of the selected service (e.g. "Economy", "XL", "Premium")
  final String? selectedServiceName;

  /// Formatted estimated fare (e.g. "≈ 18.00 SAR")
  final String? fareDisplayText;

  /// Payment method id selected for this trip (from RideDraftUiState.paymentMethodId)
  final String? selectedPaymentMethodId;

  /// Estimated arrival time in minutes (from RideQuoteOption.etaMinutes)
  final int? etaMinutes;

  RideTripSummary copyWith({
    String? selectedServiceId,
    String? selectedServiceName,
    String? fareDisplayText,
    String? selectedPaymentMethodId,
    int? etaMinutes,
    bool clearServiceId = false,
    bool clearServiceName = false,
    bool clearFare = false,
    bool clearPaymentMethod = false,
    bool clearEta = false,
  }) {
    return RideTripSummary(
      selectedServiceId: clearServiceId ? null : (selectedServiceId ?? this.selectedServiceId),
      selectedServiceName: clearServiceName ? null : (selectedServiceName ?? this.selectedServiceName),
      fareDisplayText: clearFare ? null : (fareDisplayText ?? this.fareDisplayText),
      selectedPaymentMethodId: clearPaymentMethod ? null : (selectedPaymentMethodId ?? this.selectedPaymentMethodId),
      etaMinutes: clearEta ? null : (etaMinutes ?? this.etaMinutes),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RideTripSummary &&
        other.selectedServiceId == selectedServiceId &&
        other.selectedServiceName == selectedServiceName &&
        other.fareDisplayText == fareDisplayText &&
        other.selectedPaymentMethodId == selectedPaymentMethodId &&
        other.etaMinutes == etaMinutes;
  }

  @override
  int get hashCode => Object.hash(
        selectedServiceId,
        selectedServiceName,
        fareDisplayText,
        selectedPaymentMethodId,
        etaMinutes,
      );

  @override
  String toString() =>
      'RideTripSummary(service: $selectedServiceName, fare: $fareDisplayText, paymentId: $selectedPaymentMethodId)';
}

/// UI state for the current ride trip session.
///
/// This wraps the canonical [RideTripState] from mobility_shims
/// for use in the app's UI layer.
///
/// Track B - Ticket #96: Added historyTrips for Orders History.
/// Track B - Ticket #105: Added tripSummary for unified trip summary.
/// Track B - Ticket #107: Added completionSummary for ride completion screen.
/// Track B - Ticket #111: Added draftSnapshot for frozen draft at session start.
/// Track B - Ticket #127: Added isLoading for Skeleton Loader support.
@immutable
class RideTripSessionUiState {
  const RideTripSessionUiState({
    this.activeTrip,
    this.driverRating,
    this.historyTrips = const [],
    this.tripSummary,
    this.completionSummary,
    this.draftSnapshot,
    this.isLoading = false,
    this.mapStage = RideMapStage.idle,
    this.mapSnapshot,
    this.driverLocation,
    this.activeQuote,
    this.lastQuoteFailure,
    this.isQuoting = false,
  });

  /// The currently active ride trip, or null if no trip is running.
  final RideTripState? activeTrip;

  /// Driver rating (1-5) for the current/completed trip.
  /// Track B - Ticket #23
  final int? driverRating;

  /// List of past ride trips (completed, cancelled, or failed).
  /// Track B - Ticket #96
  final List<RideHistoryEntry> historyTrips;

  /// Track B - Ticket #105: Unified trip summary (service, price, payment)
  /// Single source of truth populated when trip starts from draft.
  final RideTripSummary? tripSummary;

  /// Track B - Ticket #107: Frozen snapshot of trip summary at completion time.
  /// Non-null only right after a trip is completed, used by the completion screen.
  /// This preserves the summary data even after tripSummary might be cleared.
  final RideTripSummary? completionSummary;

  /// Track B - Ticket #111: Frozen snapshot of the ride draft at session start.
  /// Contains pickup/destination locations for map commands and history projections.
  /// Populated when trip starts via startFromDraft, cleared when session is reset.
  final RideDraftUiState? draftSnapshot;

  /// Track B - Ticket #127: Loading state for skeleton display.
  final bool isLoading;

  /// Track B - Ticket #203: Current stage of the map presentation.
  /// Derived from FSM state, controls what the map should show.
  final RideMapStage mapStage;

  /// Track B - Ticket #203: Current snapshot of map data (markers, polylines, camera).
  /// Computed by RideMapProjector from current ride state and locations.
  final RideMapSnapshot? mapSnapshot;

  /// Track B - Ticket #206: Current driver location for map display.
  /// Updated via updateDriverLocation() when live driver location becomes available.
  /// Cleared when trip ends or is reset. Used only for map projection.
  final GeoPoint? driverLocation;

  /// Track B - Ticket #211: Current active quote from pricing service.
  /// Non-null when a quote has been successfully obtained for the current draft.
  /// Cleared when trip ends or pricing state is reset.
  final RideQuote? activeQuote;

  /// Track B - Ticket #211: Last pricing failure reason.
  /// Non-null when the most recent quote request failed.
  /// Cleared when a new quote is requested or trip ends.
  final pricing.RideQuoteFailureReason? lastQuoteFailure;

  /// Track B - Ticket #211: Whether a quote request is currently in progress.
  /// True when waiting for pricing service response, false otherwise.
  final bool isQuoting;

  RideTripSessionUiState copyWith({
    RideTripState? activeTrip,
    int? driverRating,
    List<RideHistoryEntry>? historyTrips,
    RideTripSummary? tripSummary,
    RideTripSummary? completionSummary,
    RideDraftUiState? draftSnapshot,
    bool? isLoading,
    RideMapStage? mapStage,
    RideMapSnapshot? mapSnapshot,
    GeoPoint? driverLocation,
    RideQuote? activeQuote,
    pricing.RideQuoteFailureReason? lastQuoteFailure,
    bool? isQuoting,
    bool clearActiveTrip = false,
    bool clearDriverRating = false,
    bool clearTripSummary = false,
    bool clearCompletionSummary = false,
    bool clearDraftSnapshot = false,
    bool clearDriverLocation = false,
    bool clearActiveQuote = false,
    bool clearLastQuoteFailure = false,
  }) {
    return RideTripSessionUiState(
      activeTrip: clearActiveTrip ? null : (activeTrip ?? this.activeTrip),
      driverRating: clearDriverRating ? null : (driverRating ?? this.driverRating),
      historyTrips: historyTrips ?? this.historyTrips,
      tripSummary: clearTripSummary ? null : (tripSummary ?? this.tripSummary),
      completionSummary: clearCompletionSummary ? null : (completionSummary ?? this.completionSummary),
      draftSnapshot: clearDraftSnapshot ? null : (draftSnapshot ?? this.draftSnapshot),
      isLoading: isLoading ?? this.isLoading,
      mapStage: mapStage ?? this.mapStage,
      mapSnapshot: mapSnapshot ?? this.mapSnapshot,
      driverLocation: clearDriverLocation ? null : (driverLocation ?? this.driverLocation),
      activeQuote: clearActiveQuote ? null : (activeQuote ?? this.activeQuote),
      lastQuoteFailure: clearLastQuoteFailure ? null : (lastQuoteFailure ?? this.lastQuoteFailure),
      isQuoting: isQuoting ?? this.isQuoting,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RideTripSessionUiState &&
        other.activeTrip?.tripId == activeTrip?.tripId &&
        other.activeTrip?.phase == activeTrip?.phase &&
        other.driverRating == driverRating &&
        other.historyTrips.length == historyTrips.length &&
        other.tripSummary == tripSummary &&
        other.completionSummary == completionSummary &&
        other.draftSnapshot == draftSnapshot &&
        other.isLoading == isLoading &&
        other.mapStage == mapStage &&
        other.mapSnapshot == mapSnapshot &&
        other.driverLocation == driverLocation &&
        other.activeQuote == activeQuote &&
        other.lastQuoteFailure == lastQuoteFailure &&
        other.isQuoting == isQuoting;
  }

  @override
  int get hashCode => Object.hash(
        activeTrip?.tripId,
        driverRating,
        historyTrips.length,
        tripSummary,
        completionSummary,
        draftSnapshot,
        isLoading,
        mapStage,
        mapSnapshot,
        driverLocation,
        activeQuote,
        lastQuoteFailure,
        isQuoting,
      );

  @override
  String toString() =>
      'RideTripSessionUiState(activeTrip: ${activeTrip?.phase}, driverRating: $driverRating, historyCount: ${historyTrips.length}, summary: $tripSummary, completion: $completionSummary, hasDraft: ${draftSnapshot != null}, isLoading: $isLoading, mapStage: $mapStage, hasMap: $hasMap, hasDriverLocation: $hasDriverLocation, activeQuote: ${activeQuote != null}, lastQuoteFailure: $lastQuoteFailure, isQuoting: $isQuoting)';

  /// Track B - Ticket #203: Whether the map has data to display.
  bool get hasMap => mapSnapshot != null;

  /// Track B - Ticket #206: Whether the driver location is available for display.
  bool get hasDriverLocation => driverLocation != null;

  /// Track B - Ticket #211: Whether there is an active quote available.
  bool get hasActiveQuote => activeQuote != null;

  /// Track B - Ticket #211: Whether the last quote request failed.
  bool get hasQuoteFailure => lastQuoteFailure != null;

  /// Track B - Ticket #110: Map commands for the current active trip, if any.
  ///
  /// Returns [RideMapCommands] built from the active trip state.
  /// Returns null when no active trip, terminal phase, or no draftSnapshot.
  ///
  /// Track B - Ticket #111: Now uses frozen draftSnapshot for location data.
  /// The getter delegates to buildActiveTripMapCommands which reuses
  /// buildDraftMapCommands internally for consistency.
  RideMapCommands? get activeTripMapCommands {
    return buildActiveTripMapCommands(this);
  }

  /// Track B - Ticket #112: Map commands for the draft preview (Trip Confirmation).
  ///
  /// Returns [RideMapCommands] built from the frozen draftSnapshot.
  /// Used by Trip Confirmation screen (Screen 9) to display pickup/destination
  /// markers and route preview.
  ///
  /// Returns null when no draftSnapshot is available.
  RideMapCommands? get draftMapCommands {
    if (draftSnapshot == null) return null;
    return buildDraftMapCommands(draftSnapshot!);
  }
}

/// Extension to provide pricing state clearing functionality.
extension RideTripSessionUiStatePricingX on RideTripSessionUiState {
  /// Returns a new state with pricing fields cleared.
  ///
  /// Track B - Ticket #211: Used when trip ends or session is cleared to ensure
  /// pricing state (activeQuote, lastQuoteFailure, isQuoting) is reset.
  RideTripSessionUiState clearedPricing() {
    return copyWith(
      clearActiveQuote: true,
      clearLastQuoteFailure: true,
      isQuoting: false,
    );
  }
}

/// FSM for ride lifecycle (Draft -> Quoting -> Requesting -> FindingDriver -> DriverAccepted -> DriverArrived -> InProgress -> Payment -> Completed/Cancelled).
///
/// This controller manages the active ride trip session using the canonical FSM from mobility_shims.
/// The FSM supports edge cases like pricing failures, network errors, and user/driver cancellations.
///
/// ## Supported Phases:
/// - **draft**: Initial state before any processing
/// - **quoting**: Fetching pricing options from service
/// - **requesting**: Submitting trip request to backend
/// - **findingDriver**: Waiting for driver assignment
/// - **driverAccepted**: Driver accepted the trip
/// - **driverArrived**: Driver arrived at pickup location
/// - **inProgress**: Trip is actively in progress
/// - **payment**: Processing payment (terminal phase)
/// - **completed**: Trip successfully completed
/// - **cancelled**: Trip cancelled by user/driver
/// - **failed**: Trip failed due to errors (no driver, network issues, etc.)
///
/// ## Key Transitions:
/// - `draft -> quoting` (via requestQuote event)
/// - `quoting -> requesting` (via quoteReceived event)
/// - `requesting -> findingDriver` (via submitRequest event)
/// - `findingDriver -> driverAccepted` (via driverAccepted event)
/// - `driverAccepted -> driverArrived` (via driverArrived event)
/// - `driverArrived -> inProgress` (via startTrip event)
/// - `inProgress -> payment` (via startPayment event)
/// - `payment -> completed` (via complete event)
/// - Any phase except payment -> cancelled (via cancel event)
/// - Any non-terminal phase -> failed (via fail event)
///
/// This FSM is intentionally kept in the domain layer so we can unit-test edge cases
/// like pricing failures, network errors, and user/driver cancellations.
///
class RideTripSessionController extends StateNotifier<RideTripSessionUiState> {
  RideTripSessionController(this._ref) : super(const RideTripSessionUiState()) {
    _setupTrackingSubscription();
  }

  final Ref _ref;

  // Track B - Ticket #208: Subscription to tracking controller for driver location updates
  late final ProviderSubscription<TrackingSessionState?> _trackingSubscription;

  // Track B - Ticket #211: Counter for quote request tokens to handle stale responses
  int _lastQuoteRequestToken = 0;

  /// Track B - Ticket #208: Setup subscription to tracking controller for driver location updates.
  ///
  /// This listens to tracking state changes and updates driver location when:
  /// - There's an active trip (non-terminal phase)
  /// - New location points arrive from tracking uplink
  void _setupTrackingSubscription() {
    _trackingSubscription = _ref.listen<TrackingSessionState?>(
      trackingControllerProvider,
      (previous, next) {
        _handleTrackingUpdate(next);
      },
    );
  }

  /// Track B - Ticket #208: Handle tracking state updates from uplink.
  ///
  /// Only updates driver location when there's an active trip.
  /// Ignores updates when no active trip exists.
  void _handleTrackingUpdate(TrackingSessionState? trackingState) {
    // Only update driver location if there's an active trip
    if (state.activeTrip == null) return;

    // Extract last point from tracking state
    final lastPoint = trackingState?.lastPoint;
    if (lastPoint == null) return;

    // Convert to GeoPoint and update driver location
    final driverGeoPoint = GeoPoint(lastPoint.latitude, lastPoint.longitude);
    updateDriverLocation(driverGeoPoint);
  }

  MapPort get _mapPort => _ref.read(rideMapPortProvider);

  /// Track B - Ticket #211: Gets the pricing service for quote requests.
  pricing.RidePricingService get _pricingService =>
      _ref.read(ridePricingServiceProvider);

  /// Starts a new trip from quote and selected option.
  ///
  /// Track B - Ticket #156: Alternative API that takes quote and option directly
  /// instead of requiring a full draft state.
  ///
  /// For now, this is purely client-side and does not talk to backend.
  /// Later, this will call a quote/dispatch service before moving the FSM.
  ///
  /// The flow simulated here:
  /// draft -> quoting -> requesting -> findingDriver
  void startRideFromQuote({
    required RideQuoteOption selectedOption,
    required RideDraftUiState draft,
  }) {
    // Generate a local trip ID
    final tripId = 'local-${DateTime.now().microsecondsSinceEpoch}';

    // Create initial trip state in draft phase
    var tripState = RideTripState(
      tripId: tripId,
      phase: RideTripPhase.draft,
    );

    // Simulate the basic flow up to findingDriver:
    // draft -> quoting -> requesting -> findingDriver
    tripState = applyRideTripEvent(tripState, RideTripEvent.requestQuote);
    tripState = applyRideTripEvent(tripState, RideTripEvent.quoteReceived);
    tripState = applyRideTripEvent(tripState, RideTripEvent.submitRequest);

    // Build trip summary from selected option and draft
    final summary = RideTripSummary(
      selectedServiceId: selectedOption.id,
      selectedServiceName: selectedOption.displayName,
      fareDisplayText: selectedOption.formattedPrice,
      selectedPaymentMethodId: draft.paymentMethodId,
      etaMinutes: selectedOption.etaMinutes,
    );

    // Update state with the new active trip, summary, and frozen draft
    state = state.copyWith(
      activeTrip: tripState,
      tripSummary: summary,
      draftSnapshot: draft,
    );
  }

  /// Track B - Ticket #212: Prepares confirmation by freezing draft and requesting quote.
  ///
  /// This method saves the draft as draftSnapshot and requests pricing without
  /// starting the actual trip. Used by confirmation screen to get pricing
  /// before the user commits to the ride.
  ///
  /// Returns true if preparation succeeded (draft saved and quote request initiated).
  Future<bool> prepareConfirmation(RideDraftUiState draft) async {
    // Save draft snapshot for pricing
    state = state.copyWith(draftSnapshot: draft);

    // Request quote for the draft
    return await requestQuoteForCurrentDraft();
  }

  /// Request quote for a specific draft (used by prepareConfirmation)

  /// Starts a new trip from the current draft.
  ///
  /// For now, this is purely client-side and does not talk to backend.
  /// Later, this will call a quote/dispatch service before moving the FSM.
  ///
  /// The flow simulated here:
  /// draft -> quoting -> requesting -> findingDriver
  ///
  /// Track B - Ticket #105: Updated to accept optional summary parameters
  /// for unified trip summary (service, price, payment method).
  void startFromDraft(
    RideDraftUiState draft, {
    RideQuoteOption? selectedOption,
  }) {
    // Save draft snapshot when actually starting the trip
    state = state.copyWith(draftSnapshot: draft);

    // Generate a local trip ID
    final tripId = 'local-${DateTime.now().microsecondsSinceEpoch}';

    // Create initial trip state in draft phase
    var tripState = RideTripState(
      tripId: tripId,
      phase: RideTripPhase.draft,
    );

    // Simulate the basic flow up to findingDriver:
    // draft -> quoting -> requesting -> findingDriver
    tripState = applyRideTripEvent(tripState, RideTripEvent.requestQuote);
    tripState = applyRideTripEvent(tripState, RideTripEvent.quoteReceived);
    tripState = applyRideTripEvent(tripState, RideTripEvent.submitRequest);

    // Track B - Ticket #105: Build trip summary from draft + selected option
    final summary = RideTripSummary(
      selectedServiceId: draft.selectedOptionId ?? selectedOption?.id,
      selectedServiceName: selectedOption?.displayName,
      fareDisplayText: selectedOption?.formattedPrice,
      selectedPaymentMethodId: draft.paymentMethodId,
      etaMinutes: selectedOption?.etaMinutes,
    );

    // Update state with the new active trip, summary, and frozen draft
    // Track B - Ticket #111: freeze the draft at session start
    state = state.copyWith(
      activeTrip: tripState,
      tripSummary: summary,
      draftSnapshot: draft,
    );

    // Track B - Ticket #203: Sync map state after trip start
    _syncMap();

    // Track B - Ticket #209: Assert invariants after state change
    _debugAssertInvariants();
  }

  /// Apply a single event to the active trip, if any.
  ///
  /// Invalid transitions are silently ignored (can be logged later).
  void applyEvent(RideTripEvent event) {
    final current = state.activeTrip;
    if (current == null) return;

    try {
      final next = applyRideTripEvent(current, event);
      state = state.copyWith(activeTrip: next);

      // Track B - Ticket #203: Sync map state after FSM transition
      _syncMap();

      // Track B - Ticket #209: Assert invariants after state change
      _debugAssertInvariants();
    } on InvalidRideTransitionException {
      // For now, silently ignore invalid transitions.
      // TODO(Track B - Future): Log to error tracker or show user feedback.
    }
  }

  /// Track B - Ticket #211: Requests a quote for the current draft.
  ///
  /// This method validates the current draft state, sets isQuoting to true,
  /// builds a RideQuoteRequest, and calls the pricing service.
  ///
  /// Returns true if the request was initiated successfully, false if:
  /// - No draft exists
  /// - Draft is missing required data (pickup, dropoff)
  /// - Pickup and dropoff are the same location
  ///
  /// The result of the pricing request will update the state asynchronously:
  /// - Success: activeQuote is set, isQuoting becomes false, lastQuoteFailure is cleared
  /// - Failure: activeQuote is cleared, isQuoting becomes false, lastQuoteFailure is set
  ///
  /// Uses request ID tracking to handle stale responses (responses that arrive
  /// after the draft state has changed).
  Future<bool> requestQuoteForCurrentDraft() async {
    final draft = state.draftSnapshot;
    if (draft == null) return false;

    final pickup = draft.pickupPlace?.location;
    final dropoff = draft.destinationPlace?.location;
    if (pickup == null || dropoff == null) return false;

    // Validate that pickup and dropoff are different
    // Compare coordinates instead of object identity since LocationPoint doesn't override ==
    if (pickup.latitude == dropoff.latitude && pickup.longitude == dropoff.longitude) {
      // Set failure state for invalid request
      state = state.copyWith(
        activeQuote: null,
        lastQuoteFailure: pricing.RideQuoteFailureReason.invalidRequest,
        isQuoting: false,
        clearLastQuoteFailure: false,
      );
      return false;
    }

    // Take snapshot of draft for comparison later
    final draftSnapshot = draft;

    // Increment request token to handle stale responses
    final requestToken = ++_lastQuoteRequestToken;

    // Set quoting state
    state = state.copyWith(
      isQuoting: true,
      clearActiveQuote: false,
      clearLastQuoteFailure: true,
    );

    // Build quote request from draft snapshot
    final request = pricing.RideQuoteRequest(
      pickup: GeoPoint(pickup.latitude, pickup.longitude),
      dropoff: GeoPoint(dropoff.latitude, dropoff.longitude),
      requestedAt: DateTime.now(),
      serviceTierCode: draftSnapshot.selectedOptionId,
    );

    try {
      final result = await _pricingService.requestQuote(request);

      // First check: if there's a newer request, ignore this response completely
      if (requestToken != _lastQuoteRequestToken) {
        // Stale response - ignore it completely, don't touch state
        return false;
      }

      // Second check: if draft changed since snapshot, stop quoting but don't update quote/failure
      final currentDraft = state.draftSnapshot;
      if (currentDraft == null || !_isSameDraft(currentDraft, draftSnapshot)) {
        // Draft changed - just stop quoting, don't update activeQuote or lastQuoteFailure
        state = state.copyWith(
          isQuoting: false,
        );
        return false;
      }

      // Only update state if both checks pass
      if (result.isSuccess) {
        // Success: convert pricing.RideQuote to RideQuote and set active quote
        final pricingQuote = result.quote!;
        final quoteOptions = _createQuoteOptionsFromPricingQuote(pricingQuote, request.serviceTierCode);
        final mobilityQuote = RideQuote(
          quoteId: pricingQuote.id,
          request: RideQuoteRequest(
            pickup: LocationPoint(
              latitude: request.pickup.latitude,
              longitude: request.pickup.longitude,
            ),
            dropoff: LocationPoint(
              latitude: request.dropoff.latitude,
              longitude: request.dropoff.longitude,
            ),
          ),
          options: quoteOptions,
        );

        state = state.copyWith(
          activeQuote: mobilityQuote,
          isQuoting: false,
          clearLastQuoteFailure: true,
        );
      } else {
        // Failure: set failure reason
        state = state.copyWith(
          activeQuote: null,
          lastQuoteFailure: result.failure!,
          isQuoting: false,
          clearActiveQuote: false,
        );
      }

      // Track B - Ticket #209: Assert invariants after state change
      _debugAssertInvariants();

      return result.isSuccess;
    } catch (error) {
      // First check: if there's a newer request, ignore this response completely
      if (requestToken != _lastQuoteRequestToken) {
        // Stale response - ignore it completely, don't touch state
        return false;
      }

      // Second check: if draft changed since snapshot, stop quoting but don't update quote/failure
      final currentDraft = state.draftSnapshot;
      if (currentDraft == null || !_isSameDraft(currentDraft, draftSnapshot)) {
        // Draft changed - just stop quoting, don't update activeQuote or lastQuoteFailure
        state = state.copyWith(
          isQuoting: false,
        );
        return false;
      }

      // Handle unexpected errors as network errors
      state = state.copyWith(
        activeQuote: null,
        lastQuoteFailure: pricing.RideQuoteFailureReason.networkError,
        isQuoting: false,
        clearActiveQuote: false,
      );

      // Track B - Ticket #209: Assert invariants after state change
      _debugAssertInvariants();

      return false;
    }
  }

  /// Clear the current session (e.g., after trip completion or logout).
  ///
  /// Track B - Ticket #96: Preserves historyTrips when clearing.
  /// Track B - Ticket #105: Also clears tripSummary to prevent leakage.
  /// Track B - Ticket #107: Also clears completionSummary.
  /// Track B - Ticket #111: Also clears draftSnapshot.
  /// Track B - Ticket #211: Also clears pricing state (activeQuote, lastQuoteFailure, isQuoting).
  void clear() {
    state = RideTripSessionUiState(historyTrips: state.historyTrips).clearedPricing();

    // Track B - Ticket #209: Assert invariants after state change
    _debugAssertInvariants();
  }

  /// Complete the current trip and freeze the summary snapshot.
  ///
  /// Track B - Ticket #107: This method transitions the FSM to completed phase
  /// and captures a frozen snapshot of tripSummary as completionSummary.
  /// The completionSummary is used by the ride completion screen to display
  /// the trip details even after the active trip state changes.
  ///
  /// Returns true if the trip was successfully completed.
  bool completeTrip() {
    final current = state.activeTrip;
    if (current == null) return false;

    try {
      // Transition through payment phase if needed
      RideTripState next = current;
      if (next.phase == RideTripPhase.inProgress) {
        next = applyRideTripEvent(next, RideTripEvent.startPayment);
      }
      if (next.phase == RideTripPhase.payment) {
        next = applyRideTripEvent(next, RideTripEvent.complete);
      }

      // Freeze the trip summary as completion snapshot
      final completionSnapshot = state.tripSummary;

      state = state.copyWith(
        activeTrip: next,
        completionSummary: completionSnapshot,
      );
      return true;
    } on InvalidRideTransitionException {
      return false;
    }
  }

  /// Clear the completion summary after user acknowledges it.
  ///
  /// Track B - Ticket #107: Called when user leaves the completion screen
  /// (e.g., presses "Done" CTA) to clean up the completion state.
  void clearCompletionSummary() {
    state = state.copyWith(clearCompletionSummary: true);
  }

  /// Archive a completed/cancelled/failed trip to history.
  ///
  /// Call this before clearing the active trip to preserve it in history.
  /// The [destinationLabel] and optional [amountFormatted] are captured
  /// from the UI layer (draft state / quote) at the time of archiving.
  ///
  /// Track B - Ticket #96
  /// Track B - Ticket #108: Extended with serviceName, originLabel, paymentMethodLabel
  void archiveTrip({
    required String destinationLabel,
    String? amountFormatted,
    String? serviceName,
    String? originLabel,
    String? paymentMethodLabel,
  }) {
    final trip = state.activeTrip;
    if (trip == null) return;

    // Only archive terminal trips
    if (!trip.phase.isTerminal) return;

    final entry = RideHistoryEntry(
      trip: trip,
      destinationLabel: destinationLabel,
      completedAt: DateTime.now(),
      amountFormatted: amountFormatted,
      serviceName: serviceName,
      originLabel: originLabel,
      paymentMethodLabel: paymentMethodLabel,
    );

    // Add to history (newest first)
    final updatedHistory = [entry, ...state.historyTrips];
    state = state.copyWith(historyTrips: updatedHistory);
  }

  /// Check if there's an active trip in a non-terminal phase.
  bool get hasActiveTrip {
    final trip = state.activeTrip;
    if (trip == null) return false;

    // Terminal phases
    return trip.phase != RideTripPhase.completed &&
        trip.phase != RideTripPhase.cancelled &&
        trip.phase != RideTripPhase.failed;
  }

  /// Cancel the currently active trip.
  ///
  /// Returns `true` if the cancellation was successful, `false` otherwise.
  /// This method applies [RideTripEvent.cancel] to the FSM.
  ///
  /// Track B - Ticket #22, Updated: Ticket #95 (keep trip in cancelled state for UI)
  Future<bool> cancelActiveTrip() async {
    final current = state.activeTrip;
    if (current == null) return false;

    // Check if cancellation is allowed for current phase (Ticket #95)
    if (!current.phase.isCancellable) return false;

    try {
      final next = applyRideTripEvent(current, RideTripEvent.cancel);
      state = state.copyWith(activeTrip: next);
      // Ticket #95: Keep trip in cancelled state so UI can show terminal view.
      // User returns to Home via "Back to home" CTA, which calls clear().
      return true;
    } on InvalidRideTransitionException {
      // Cannot cancel from current phase (e.g., already completed/cancelled)
      return false;
    }
  }

  /// Set rating for the currently active/completed trip.
  ///
  /// Track B - Ticket #23
  void rateCurrentTrip(int rating) {
    final current = state.activeTrip;
    if (current == null) return;

    // Clamp rating to valid range [1..5]
    final clamped = rating.clamp(1, 5);

    state = state.copyWith(driverRating: clamped);
  }

  /// Track B - Ticket #124: Set driver rating for the most recent history entry.
  ///
  /// This API is called from the Trip Summary screen to persist the user's
  /// rating into the history entry, making it available for Orders History.
  ///
  /// Returns true if rating was applied, false if:
  /// - history is empty
  /// - rating is out of supported range [1.0, 5.0]
  /// - latest trip is not in a terminal phase
  bool setRatingForMostRecentTrip(double rating) {
    // Guard: rating must be between 1.0 and 5.0
    if (rating < 1.0 || rating > 5.0) {
      return false;
    }

    if (state.historyTrips.isEmpty) {
      return false;
    }

    final entries = List<RideHistoryEntry>.from(state.historyTrips);
    final latest = entries.first;

    // Only allow rating for terminal trips (completed, cancelled, or failed)
    if (!latest.trip.phase.isTerminal) {
      return false;
    }

    // Update the rating in the most recent entry
    entries[0] = latest.copyWith(driverRating: rating);

    state = state.copyWith(historyTrips: entries);
    return true;
  }

  /// Track B - Ticket #206: Update the current driver location for map display.
  ///
  /// This method updates the driver location used by the map projection system.
  /// It only works when there's an active trip (non-terminal phase).
  /// When no active trip exists, the update is silently ignored.
  ///
  /// The driver location is cleared automatically when trips complete, cancel, or fail.
  /// This provides a clean API for future integration with tracking/uplink systems.
  void updateDriverLocation(GeoPoint newLocation) {
    // Don't show driver marker without an active trip
    if (state.activeTrip == null) return;

    state = state.copyWith(driverLocation: newLocation);
    _syncMap();

    // Track B - Ticket #209: Assert invariants after state change
    _debugAssertInvariants();
  }

  /// Track B - Ticket #206: Clear the current driver location.
  ///
  /// This method clears the driver location from the map projection system.
  /// It's typically called when a trip ends (completes, cancels, or fails)
  /// to ensure the driver marker is removed from the map.
  ///
  /// Idempotent - does nothing if driver location is already null.
  void clearDriverLocation() {
    if (state.driverLocation == null) return;

    state = state.copyWith(clearDriverLocation: true);
    _syncMap();
  }

  /// Track B - Ticket #209: Debug assert invariants for driver location and map state.
  /// Track B - Ticket #211: Also validates pricing state invariants.
  ///
  /// Validates key invariants:
  /// 1. No driverLocation without activeTrip
  /// 2. Idle state means clean map (mapSnapshot == null && driverLocation == null)
  /// 3. No activeQuote without draftSnapshot (pricing state should be tied to draft)
  /// 4. isQuoting should only be true when there's a valid draft and no active trip
  ///
  /// Called from critical points in debug mode only.
  void _debugAssertInvariants() {
    assert(() {
      // Invariant 1: No driverLocation without activeTrip
      if (state.activeTrip == null) {
        assert(state.driverLocation == null,
            'driverLocation must be null when no activeTrip exists');
      }

      // Invariant 2: Idle state means clean map
      if (state.mapStage == RideMapStage.idle) {
        assert(state.mapSnapshot == null,
            'mapSnapshot must be null in idle state');
        assert(state.driverLocation == null,
            'driverLocation must be null in idle state');
      }

      // Invariant 3: Track B - Ticket #211: Pricing state invariants
      // No activeQuote without draftSnapshot - pricing should be tied to draft
      if (state.activeQuote != null) {
        assert(state.draftSnapshot != null,
            'activeQuote should not exist without draftSnapshot');
      }

      // isQuoting should only be true when there's a valid draft and no conflicting state
      if (state.isQuoting) {
        assert(state.draftSnapshot != null,
            'isQuoting should not be true without draftSnapshot');
        // Could also check that there's no activeTrip, but for now just check draft exists
      }

      return true;
    }());
  }

  /// Track B - Ticket #120: Cancel the current active trip, archive it into
  /// historyTrips with a cancelled phase, and clear the live session state.
  ///
  /// This is the canonical API for cancelling a trip at the domain level.
  /// It combines:
  /// 1. FSM transition to cancelled phase (if in a cancellable phase)
  /// 2. Archiving the trip to historyTrips with metadata
  /// 3. Clearing all temporary session state (activeTrip, tripSummary, draftSnapshot)
  ///
  /// [reasonLabel] - Human-readable reason for cancellation
  /// [destinationLabel] - Human-readable destination for history display
  /// [originLabel] - Optional pickup/origin label
  /// [serviceName] - Optional service name (e.g. "Economy", "XL")
  /// [amountFormatted] - Optional formatted price (may be null for cancelled trips)
  /// [paymentMethodLabel] - Optional payment method label
  ///
  /// Returns true if the trip was successfully cancelled and archived.
  /// Returns false if no active trip exists or trip is not cancellable.
  bool cancelCurrentTrip({
    String? reasonLabel,
    String? destinationLabel,
    String? originLabel,
    String? serviceName,
    String? amountFormatted,
    String? paymentMethodLabel,
  }) {
    final current = state.activeTrip;
    if (current == null) {
      // No active trip - idempotent, return false
      return false;
    }

    // Step 1: Only cancellable phases can be cancelled
    if (!current.phase.isCancellable) {
      // Cannot cancel from non-cancellable phases (e.g., inProgress, payment, completed)
      return false;
    }

    // Step 2: Transition to cancelled phase
    RideTripState cancelledState;
    try {
      cancelledState = applyRideTripEvent(current, RideTripEvent.cancel);
    } on InvalidRideTransitionException {
      // Should not happen if isCancellable is true, but be defensive
      return false;
    }

    // Step 3: Build history entry with metadata
    final effectiveDestination = destinationLabel ??
        state.draftSnapshot?.destinationQuery ??
        'Unknown destination';
    final effectiveOrigin = originLabel ??
        state.draftSnapshot?.pickupLabel ??
        'Unknown origin';
    final effectiveService = serviceName ?? state.tripSummary?.selectedServiceName;
    final effectiveAmount = amountFormatted ?? state.tripSummary?.fareDisplayText;
    final effectivePayment = paymentMethodLabel;

    final entry = RideHistoryEntry(
      trip: cancelledState,
      destinationLabel: effectiveDestination,
      completedAt: DateTime.now(),
      amountFormatted: effectiveAmount,
      serviceName: effectiveService,
      originLabel: effectiveOrigin,
      paymentMethodLabel: effectivePayment,
    );

    // Step 4: Add to history (newest first) and clear session
    final updatedHistory = [entry, ...state.historyTrips];

    // Step 5: Clear temporary state while preserving history
    // Track B - Ticket #211: Also clears pricing state (activeQuote, lastQuoteFailure, isQuoting)
    state = RideTripSessionUiState(historyTrips: updatedHistory).clearedPricing();

    return true;
  }

  /// Track B - Ticket #117: Mark the current active trip as completed,
  /// archive it to historyTrips, and clear the live session state.
  ///
  /// This is the canonical API for completing a trip at the domain level.
  /// It combines:
  /// 1. FSM transition to completed phase (if not already terminal)
  /// 2. Archiving the trip to historyTrips with metadata
  /// 3. Clearing all temporary session state (activeTrip, tripSummary, draftSnapshot)
  ///
  /// [destinationLabel] - Human-readable destination for history display
  /// [amountFormatted] - Optional formatted price (e.g. "SAR 24.50")
  /// [serviceName] - Optional service name (e.g. "Economy", "XL")
  /// [originLabel] - Optional pickup/origin label
  /// [paymentMethodLabel] - Optional payment method label
  ///
  /// Returns true if the trip was successfully completed and archived.
  /// Returns false if no active trip exists (idempotent behavior).
  bool completeCurrentTrip({
    String? destinationLabel,
    String? amountFormatted,
    String? serviceName,
    String? originLabel,
    String? paymentMethodLabel,
  }) {
    final current = state.activeTrip;
    if (current == null) {
      // No active trip - idempotent, return false but no error
      return false;
    }

    // Step 1: Transition to completed phase if not already terminal
    RideTripState completedState = current;
    if (!completedState.phase.isTerminal) {
      try {
        // Transition through remaining phases to completed
        if (completedState.phase == RideTripPhase.inProgress) {
          completedState = applyRideTripEvent(completedState, RideTripEvent.startPayment);
        }
        if (completedState.phase == RideTripPhase.payment) {
          completedState = applyRideTripEvent(completedState, RideTripEvent.complete);
        } else if (!completedState.phase.isTerminal) {
          // For other non-terminal phases that can't directly complete,
          // we need to handle gracefully - this shouldn't happen in normal flow
          // but let's be defensive
          return false;
        }
      } on InvalidRideTransitionException {
        // Cannot complete from current phase
        return false;
      }
    }

    // Step 2: Build history entry with metadata
    // Use draftSnapshot for destination/origin if not provided
    final effectiveDestination = destinationLabel ??
        state.draftSnapshot?.destinationQuery ??
        'Unknown destination';
    final effectiveOrigin = originLabel ??
        state.draftSnapshot?.pickupLabel ??
        'Unknown origin';
    final effectiveService = serviceName ?? state.tripSummary?.selectedServiceName;
    final effectiveAmount = amountFormatted ?? state.tripSummary?.fareDisplayText;
    final effectivePayment = paymentMethodLabel;

    final entry = RideHistoryEntry(
      trip: completedState,
      destinationLabel: effectiveDestination,
      completedAt: DateTime.now(),
      amountFormatted: effectiveAmount,
      serviceName: effectiveService,
      originLabel: effectiveOrigin,
      paymentMethodLabel: effectivePayment,
    );

    // Step 3: Add to history (newest first) and clear session
    final updatedHistory = [entry, ...state.historyTrips];

    // Step 4: Clear temporary state while preserving history
    // Track B - Ticket #211: Also clears pricing state (activeQuote, lastQuoteFailure, isQuoting)
    state = RideTripSessionUiState(historyTrips: updatedHistory).clearedPricing();

    // Track B - Ticket #145: Add destination to recent locations
    _addToRecentLocations();

    // Track B - Ticket #209: Assert invariants after state change
    _debugAssertInvariants();

    return true;
  }

  /// Track B - Ticket #122: Mark the current active trip as failed,
  /// archive it into historyTrips with a failed phase, and clear session.
  ///
  /// This is the canonical API for failing a trip at the domain level when:
  /// - No driver was found after timeout
  /// - The ride request was rejected
  /// - Any other failure that prevents the trip from proceeding
  ///
  /// It combines:
  /// 1. FSM transition to failed phase (via RideTripEvent.fail)
  /// 2. Archiving the trip to historyTrips with metadata
  /// 3. Clearing all temporary session state (activeTrip, tripSummary, draftSnapshot)
  ///
  /// [reasonLabel] - Human-readable reason for failure (e.g., "No driver found")
  /// [destinationLabel] - Human-readable destination for history display
  /// [originLabel] - Optional pickup/origin label
  /// [serviceName] - Optional service name (e.g. "Economy", "XL")
  /// [amountFormatted] - Optional formatted price (may be null for failed trips)
  /// [paymentMethodLabel] - Optional payment method label
  ///
  /// Returns true if the trip was successfully failed and archived.
  /// Returns false if no active trip exists or trip is already terminal.
  bool failCurrentTrip({
    String? reasonLabel,
    String? destinationLabel,
    String? originLabel,
    String? serviceName,
    String? amountFormatted,
    String? paymentMethodLabel,
  }) {
    final current = state.activeTrip;
    if (current == null) {
      // No active trip - idempotent, return false
      return false;
    }

    // Step 1: Don't fail trips that are already terminal
    if (current.phase.isTerminal) {
      // Cannot fail trips that are already completed/cancelled/failed
      return false;
    }

    // Step 2: Transition to failed phase
    RideTripState failedState;
    try {
      failedState = applyRideTripEvent(current, RideTripEvent.fail);
    } on InvalidRideTransitionException {
      // Should not happen for non-terminal phases, but be defensive
      return false;
    }

    // Step 3: Build history entry with metadata
    final effectiveDestination = destinationLabel ??
        state.draftSnapshot?.destinationQuery ??
        'Unknown destination';
    final effectiveOrigin = originLabel ??
        state.draftSnapshot?.pickupLabel ??
        'Unknown origin';
    final effectiveService = serviceName ?? state.tripSummary?.selectedServiceName;
    final effectiveAmount = amountFormatted ?? state.tripSummary?.fareDisplayText;
    final effectivePayment = paymentMethodLabel;

    final entry = RideHistoryEntry(
      trip: failedState,
      destinationLabel: effectiveDestination,
      completedAt: DateTime.now(),
      amountFormatted: effectiveAmount,
      serviceName: effectiveService,
      originLabel: effectiveOrigin,
      paymentMethodLabel: effectivePayment,
    );

    // Step 4: Add to history (newest first) and clear session
    final updatedHistory = [entry, ...state.historyTrips];

    // Step 5: Clear temporary state while preserving history
    // Track B - Ticket #211: Also clears pricing state (activeQuote, lastQuoteFailure, isQuoting)
    state = RideTripSessionUiState(historyTrips: updatedHistory).clearedPricing();

    // Track B - Ticket #209: Assert invariants after state change
    _debugAssertInvariants();

    return true;
  }

  /// Track B - Ticket #203: Sync map state with FSM state and push commands to MapPort.
  ///
  /// This method:
  /// 1. Derives RideMapStage from current FSM state
  /// 2. Projects map snapshot using RideMapProjector
  /// 3. Updates state with new mapStage/mapSnapshot
  /// 4. Pumps commands to MapPort
  void _syncMap() {
    final stage = _deriveMapStage();

    final snapshot = RideMapProjector.project(
      stage: stage,
      userLocation: _buildUserLocationOrNull(),
      pickupLocation: _buildPickupLocationOrNull(),
      dropoffLocation: _buildDropoffLocationOrNull(),
      driverLocation: _buildDriverLocationOrNull(),
      routePolyline: _buildRoutePolylineOrNull(),
    );

    // Update the state
    state = state.copyWith(
      mapStage: stage,
      mapSnapshot: snapshot,
    );

    // Push commands to MapPort (even if NoOp in runtime)
    RideMapProjector.pumpToPort(
      snapshot: snapshot,
      port: _mapPort,
    );

    // Track B - Ticket #209: Assert invariants after map sync
    _debugAssertInvariants();
  }

  /// Track B - Ticket #203: Derive RideMapStage from current FSM state.
  RideMapStage _deriveMapStage() {
    final fsmState = state.activeTrip?.phase;

    if (fsmState == null) return RideMapStage.idle;

    switch (fsmState) {
      case RideTripPhase.draft:
        return RideMapStage.idle;
      case RideTripPhase.quoting:
        return RideMapStage.confirmingQuote;
      case RideTripPhase.requesting:
      case RideTripPhase.findingDriver:
        return RideMapStage.waitingForDriver;
      case RideTripPhase.driverAccepted:
        return RideMapStage.driverEnRouteToPickup;
      case RideTripPhase.driverArrived:
        return RideMapStage.driverArrived;
      case RideTripPhase.inProgress:
      case RideTripPhase.payment:
        return RideMapStage.inProgressToDestination;
      case RideTripPhase.completed:
        return RideMapStage.completed;
      case RideTripPhase.cancelled:
      case RideTripPhase.failed:
        return RideMapStage.error;
    }
  }

  /// Track B - Ticket #203: Extract user location as GeoPoint, or null if unavailable.
  GeoPoint? _buildUserLocationOrNull() {
    // TODO: Extract from user location provider/state when available
    // For now, return null as user location is not yet available in session state
    return null;
  }

  /// Track B - Ticket #203: Extract pickup location from draftSnapshot as GeoPoint.
  GeoPoint? _buildPickupLocationOrNull() {
    final pickup = state.draftSnapshot?.pickupPlace?.location;
    if (pickup == null) return null;
    return GeoPoint(pickup.latitude, pickup.longitude);
  }

  /// Track B - Ticket #203: Extract dropoff location from draftSnapshot as GeoPoint.
  GeoPoint? _buildDropoffLocationOrNull() {
    final dropoff = state.draftSnapshot?.destinationPlace?.location;
    if (dropoff == null) return null;
    return GeoPoint(dropoff.latitude, dropoff.longitude);
  }

  /// Track B - Ticket #206: Extract driver location as GeoPoint, or null if unavailable.
  GeoPoint? _buildDriverLocationOrNull() {
    return state.driverLocation;
  }

  /// Track B - Ticket #203: Extract route polyline, or null if unavailable.
  MapPolyline? _buildRoutePolylineOrNull() {
    // TODO: Extract from route data when available
    // For now, return null as route data is not yet available in session state
    return null;
  }

  /// Track B - Ticket #145: Helper to add current destination to recent locations
  void _addToRecentLocations() {
    final draftSnapshot = state.draftSnapshot;
    if (draftSnapshot == null) return;

    // Get destination from draft
    final destinationPlace = draftSnapshot.destinationPlace;
    if (destinationPlace == null) return;

    // Create RecentLocation from the destination
    final recentLocation = RecentLocation(
      id: 'loc_${DateTime.now().microsecondsSinceEpoch}',
      title: destinationPlace.label,
      subtitle: destinationPlace.address,
      type: MobilityPlaceType.recent,
      location: destinationPlace.location,
    );

    // Add to recent locations repository
    try {
      final repo = _ref.read(recentLocationsRepositoryProvider);
      repo.upsertRecentLocation(recentLocation);
    } catch (e) {
      // Fail silently - recent locations is not critical
      debugPrint('Failed to add recent location: $e');
    }
  }

  /// Track B - Ticket #212: Creates quote options from pricing quote.
  ///
  /// For now, creates a single option based on the pricing quote.
  /// Later, this could be extended to create multiple service tiers.
  List<RideQuoteOption> _createQuoteOptionsFromPricingQuote(
      pricing.RideQuote pricingQuote, String? serviceTierCode) {
    // Determine category based on service tier
    final category = _getCategoryFromServiceTier(serviceTierCode);

    // Convert pricing data to quote option
    final option = RideQuoteOption(
      id: serviceTierCode ?? 'economy',
      category: category,
      displayName: _getDisplayNameFromCategory(category),
      etaMinutes: (pricingQuote.estimatedDuration.inMinutes).clamp(1, 60),
      priceMinorUnits: pricingQuote.price.value,
      currencyCode: pricingQuote.price.currency,
      isRecommended: true, // For now, single option is always recommended
    );

    return [option];
  }

  /// Track B - Ticket #212: Gets vehicle category from service tier code.
  RideVehicleCategory _getCategoryFromServiceTier(String? serviceTier) {
    switch (serviceTier?.toLowerCase()) {
      case 'economy':
        return RideVehicleCategory.economy;
      case 'xl':
        return RideVehicleCategory.xl;
      case 'premium':
        return RideVehicleCategory.premium;
      default:
        return RideVehicleCategory.economy;
    }
  }

  /// Track B - Ticket #212: Gets display name from category.
  String _getDisplayNameFromCategory(RideVehicleCategory category) {
    switch (category) {
      case RideVehicleCategory.economy:
        return 'Economy';
      case RideVehicleCategory.xl:
        return 'XL';
      case RideVehicleCategory.premium:
        return 'Premium';
    }
  }

  /// Track B - Ticket #211: Helper to compare draft snapshots for pricing relevance.
  ///
  /// Returns true if both drafts have the same pickup, dropoff location,
  /// and service tier that affect pricing calculations.
  bool _isSameDraft(RideDraftUiState a, RideDraftUiState b) {
    // Compare locations (pickup and dropoff)
    final pickupA = a.pickupPlace?.location;
    final pickupB = b.pickupPlace?.location;
    final dropoffA = a.destinationPlace?.location;
    final dropoffB = b.destinationPlace?.location;

    if (pickupA?.latitude != pickupB?.latitude ||
        pickupA?.longitude != pickupB?.longitude ||
        dropoffA?.latitude != dropoffB?.latitude ||
        dropoffA?.longitude != dropoffB?.longitude) {
      return false;
    }

    // Compare service tier
    return a.selectedOptionId == b.selectedOptionId;
  }

  /// Track B - Ticket #208: Dispose tracking subscription when controller is disposed.
  @override
  void dispose() {
    _trackingSubscription.close();
    super.dispose();
  }
}

/// Global provider for ride trip session state.
final rideTripSessionProvider =
    StateNotifierProvider<RideTripSessionController, RideTripSessionUiState>(
        (ref) {
  return RideTripSessionController(ref);
});


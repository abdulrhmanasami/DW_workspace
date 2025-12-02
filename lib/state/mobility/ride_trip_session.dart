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

// From mobility_shims package (canonical FSM):
import 'package:mobility_shims/mobility_shims.dart';

// From app:
import 'package:delivery_ways_clean/state/mobility/ride_draft_state.dart';
import 'package:delivery_ways_clean/state/mobility/ride_map_commands_builder.dart';

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

  RideTripSessionUiState copyWith({
    RideTripState? activeTrip,
    int? driverRating,
    List<RideHistoryEntry>? historyTrips,
    RideTripSummary? tripSummary,
    RideTripSummary? completionSummary,
    RideDraftUiState? draftSnapshot,
    bool? isLoading,
    bool clearActiveTrip = false,
    bool clearDriverRating = false,
    bool clearTripSummary = false,
    bool clearCompletionSummary = false,
    bool clearDraftSnapshot = false,
  }) {
    return RideTripSessionUiState(
      activeTrip: clearActiveTrip ? null : (activeTrip ?? this.activeTrip),
      driverRating: clearDriverRating ? null : (driverRating ?? this.driverRating),
      historyTrips: historyTrips ?? this.historyTrips,
      tripSummary: clearTripSummary ? null : (tripSummary ?? this.tripSummary),
      completionSummary: clearCompletionSummary ? null : (completionSummary ?? this.completionSummary),
      draftSnapshot: clearDraftSnapshot ? null : (draftSnapshot ?? this.draftSnapshot),
      isLoading: isLoading ?? this.isLoading,
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
        other.isLoading == isLoading;
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
      );

  @override
  String toString() =>
      'RideTripSessionUiState(activeTrip: ${activeTrip?.phase}, driverRating: $driverRating, historyCount: ${historyTrips.length}, summary: $tripSummary, completion: $completionSummary, hasDraft: ${draftSnapshot != null}, isLoading: $isLoading)';

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

/// Controller for managing the active ride trip session.
///
/// Uses the canonical FSM types from mobility_shims:
/// - [RideTripState] - immutable trip state
/// - [RideTripPhase] - trip lifecycle phases
/// - [RideTripEvent] - events that transition the FSM
/// - [applyRideTripEvent] - pure transition function
class RideTripSessionController extends StateNotifier<RideTripSessionUiState> {
  RideTripSessionController() : super(const RideTripSessionUiState());

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
    } on InvalidRideTransitionException {
      // For now, silently ignore invalid transitions.
      // TODO(Track B - Future): Log to error tracker or show user feedback.
    }
  }

  /// Clear the current session (e.g., after trip completion or logout).
  ///
  /// Track B - Ticket #96: Preserves historyTrips when clearing.
  /// Track B - Ticket #105: Also clears tripSummary to prevent leakage.
  /// Track B - Ticket #107: Also clears completionSummary.
  /// Track B - Ticket #111: Also clears draftSnapshot.
  void clear() {
    state = RideTripSessionUiState(historyTrips: state.historyTrips);
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
    state = RideTripSessionUiState(historyTrips: updatedHistory);

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
    state = RideTripSessionUiState(historyTrips: updatedHistory);

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
    state = RideTripSessionUiState(historyTrips: updatedHistory);

    return true;
  }
}

/// Global provider for ride trip session state.
final rideTripSessionProvider =
    StateNotifierProvider<RideTripSessionController, RideTripSessionUiState>(
        (ref) {
  return RideTripSessionController();
});


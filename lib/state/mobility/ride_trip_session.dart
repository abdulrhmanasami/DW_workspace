/// Ride Trip Session Controller - Track B Ticket #12
/// Purpose: Bridge between RideDraftUiState and RideTrip FSM (mobility_shims)
/// Created by: Track B - Ticket #12
/// Updated by: Track B - Ticket #96 (historyTrips + archiveTrip for Orders History)
/// Last updated: 2025-11-30
///
/// This controller manages the active ride trip session in memory,
/// using the canonical FSM from mobility_shims.
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

/// Entry in the ride history list.
///
/// Contains the canonical [RideTripState] plus UI-relevant metadata
/// captured at the time the trip was archived.
///
/// Track B - Ticket #96: Orders History support
@immutable
class RideHistoryEntry {
  const RideHistoryEntry({
    required this.trip,
    required this.destinationLabel,
    required this.completedAt,
    this.amountFormatted,
  });

  /// The canonical trip state from mobility_shims.
  final RideTripState trip;

  /// Human-readable destination label (e.g. "King Fahd Road").
  final String destinationLabel;

  /// When the trip reached a terminal state.
  final DateTime completedAt;

  /// Formatted price (e.g. "SAR 24.50") if available.
  final String? amountFormatted;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RideHistoryEntry &&
        other.trip.tripId == trip.tripId &&
        other.trip.phase == trip.phase;
  }

  @override
  int get hashCode => Object.hash(trip.tripId, trip.phase);
}

/// UI state for the current ride trip session.
///
/// This wraps the canonical [RideTripState] from mobility_shims
/// for use in the app's UI layer.
///
/// Track B - Ticket #96: Added historyTrips for Orders History.
@immutable
class RideTripSessionUiState {
  const RideTripSessionUiState({
    this.activeTrip,
    this.driverRating,
    this.historyTrips = const [],
  });

  /// The currently active ride trip, or null if no trip is running.
  final RideTripState? activeTrip;

  /// Driver rating (1-5) for the current/completed trip.
  /// Track B - Ticket #23
  final int? driverRating;

  /// List of past ride trips (completed, cancelled, or failed).
  /// Track B - Ticket #96
  final List<RideHistoryEntry> historyTrips;

  RideTripSessionUiState copyWith({
    RideTripState? activeTrip,
    int? driverRating,
    List<RideHistoryEntry>? historyTrips,
    bool clearActiveTrip = false,
    bool clearDriverRating = false,
  }) {
    return RideTripSessionUiState(
      activeTrip: clearActiveTrip ? null : (activeTrip ?? this.activeTrip),
      driverRating: clearDriverRating ? null : (driverRating ?? this.driverRating),
      historyTrips: historyTrips ?? this.historyTrips,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RideTripSessionUiState &&
        other.activeTrip?.tripId == activeTrip?.tripId &&
        other.activeTrip?.phase == activeTrip?.phase &&
        other.driverRating == driverRating &&
        other.historyTrips.length == historyTrips.length;
  }

  @override
  int get hashCode => Object.hash(activeTrip?.tripId, driverRating, historyTrips.length);

  @override
  String toString() =>
      'RideTripSessionUiState(activeTrip: ${activeTrip?.phase}, driverRating: $driverRating, historyCount: ${historyTrips.length})';
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
  void startFromDraft(RideDraftUiState draft) {
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

    // Update state with the new active trip
    state = state.copyWith(activeTrip: tripState);
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
  void clear() {
    state = RideTripSessionUiState(historyTrips: state.historyTrips);
  }

  /// Archive a completed/cancelled/failed trip to history.
  ///
  /// Call this before clearing the active trip to preserve it in history.
  /// The [destinationLabel] and optional [amountFormatted] are captured
  /// from the UI layer (draft state / quote) at the time of archiving.
  ///
  /// Track B - Ticket #96
  void archiveTrip({
    required String destinationLabel,
    String? amountFormatted,
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
}

/// Global provider for ride trip session state.
final rideTripSessionProvider =
    StateNotifierProvider<RideTripSessionController, RideTripSessionUiState>(
        (ref) {
  return RideTripSessionController();
});


/// Ride Trip Session Controller - Track B Ticket #12
/// Purpose: Bridge between RideDraftUiState and RideTrip FSM (mobility_shims)
/// Created by: Track B - Ticket #12
/// Last updated: 2025-11-28
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

/// UI state for the current ride trip session.
///
/// This wraps the canonical [RideTripState] from mobility_shims
/// for use in the app's UI layer.
@immutable
class RideTripSessionUiState {
  const RideTripSessionUiState({
    this.activeTrip,
    this.driverRating,
  });

  /// The currently active ride trip, or null if no trip is running.
  final RideTripState? activeTrip;

  /// Driver rating (1-5) for the current/completed trip.
  /// Track B - Ticket #23
  final int? driverRating;

  RideTripSessionUiState copyWith({
    RideTripState? activeTrip,
    int? driverRating,
    bool clearActiveTrip = false,
    bool clearDriverRating = false,
  }) {
    return RideTripSessionUiState(
      activeTrip: clearActiveTrip ? null : (activeTrip ?? this.activeTrip),
      driverRating: clearDriverRating ? null : (driverRating ?? this.driverRating),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RideTripSessionUiState &&
        other.activeTrip?.tripId == activeTrip?.tripId &&
        other.activeTrip?.phase == activeTrip?.phase &&
        other.driverRating == driverRating;
  }

  @override
  int get hashCode => Object.hash(activeTrip?.tripId, driverRating);

  @override
  String toString() =>
      'RideTripSessionUiState(activeTrip: ${activeTrip?.phase}, driverRating: $driverRating)';
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
  void clear() {
    state = const RideTripSessionUiState();
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
  /// Track B - Ticket #22
  Future<bool> cancelActiveTrip() async {
    final current = state.activeTrip;
    if (current == null) return false;

    try {
      final next = applyRideTripEvent(current, RideTripEvent.cancel);
      state = state.copyWith(activeTrip: next);
      // For now, just clear the trip after cancel (simulates backend confirmation)
      // In production, this would await a backend response before clearing.
      state = state.copyWith(clearActiveTrip: true);
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


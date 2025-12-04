/// Ride FSM Logic - Track B Ticket #241
/// Purpose: State transition validation for ride booking lifecycle
/// Created by: Track B - Ticket #241
/// Last updated: 2025-12-04
///
/// Provides validation and transition logic for ride booking FSM.
/// Ensures only valid state transitions are allowed.
///
/// This follows the FSM pattern: Draft -> Quoting -> Requesting ->
/// FindingDriver -> DriverAccepted -> DriverArrived -> InProgress ->
/// Payment -> Complete

import 'ride_models.dart';
import 'ride_status.dart';
import 'ride_exceptions.dart';

/// Pure functions for ride booking FSM operations.
///
/// This class provides validation and transition logic for the ride booking
/// state machine. All methods are pure functions with no side effects.
class RideFsm {
  /// Checks if a transition from [from] status to [to] status is valid.
  ///
  /// Returns true if the transition is allowed, false otherwise.
  ///
  /// Valid transitions follow the ride booking lifecycle:
  /// - draft -> quoting | cancelled
  /// - quoting -> quoteReady | cancelled | failed
  /// - quoteReady -> requesting | cancelled
  /// - requesting -> findingDriver | cancelled | failed
  /// - findingDriver -> driverAccepted | cancelled | failed
  /// - driverAccepted -> driverArrived | cancelled | failed
  /// - driverArrived -> inProgress | cancelled | failed
  /// - inProgress -> payment | cancelled | failed
  /// - payment -> completed | failed
  /// - completed, cancelled, failed are terminal states (no transitions)
  static bool canTransition(RideStatus from, RideStatus to) {
    return _nextStatus(from, to) != null;
  }

  /// Attempts to transition a ride request to a new status.
  ///
  /// Validates the transition first, then creates a new RideRequest
  /// with the updated status and timestamp.
  ///
  /// Parameters:
  /// - [request]: The current ride request
  /// - [newStatus]: The target status to transition to
  ///
  /// Returns a new RideRequest with the updated status and updatedAt timestamp.
  ///
  /// Throws [InvalidRideTransitionException] if the transition is not allowed.
  static RideRequest transition(RideRequest request, RideStatus newStatus) {
    if (!canTransition(request.status, newStatus)) {
      throw InvalidRideTransitionException(request.status, newStatus);
    }

    return request.copyWith(
      status: newStatus,
      updatedAt: DateTime.now().toUtc(),
    );
  }

  /// Tries to transition a ride request without throwing.
  ///
  /// This is useful for handling duplicate/idempotent events gracefully,
  /// e.g., when a network callback fires multiple times.
  ///
  /// Returns a new RideRequest if the transition is valid, null otherwise.
  /// No exceptions are thrown.
  static RideRequest? tryTransition(RideRequest request, RideStatus newStatus) {
    if (!canTransition(request.status, newStatus)) {
      return null; // No-op: invalid transition
    }

    return request.copyWith(
      status: newStatus,
      updatedAt: DateTime.now().toUtc(),
    );
  }

  /// Internal transition validation table.
  ///
  /// This is intentionally explicit (switch/switch) to make it easy to audit
  /// and reason about in code reviews. Each case represents a valid transition.
  static RideStatus? _nextStatus(RideStatus from, RideStatus to) {
    switch (from) {
      case RideStatus.draft:
        switch (to) {
          case RideStatus.quoting:
          case RideStatus.cancelled:
            return to;
          default:
            return null;
        }

      case RideStatus.quoting:
        switch (to) {
          case RideStatus.quoteReady:
          case RideStatus.cancelled:
          case RideStatus.failed:
            return to;
          default:
            return null;
        }

      case RideStatus.quoteReady:
        switch (to) {
          case RideStatus.requesting:
          case RideStatus.cancelled:
            return to;
          default:
            return null;
        }

      case RideStatus.requesting:
        switch (to) {
          case RideStatus.findingDriver:
          case RideStatus.cancelled:
          case RideStatus.failed:
            return to;
          default:
            return null;
        }

      case RideStatus.findingDriver:
        switch (to) {
          case RideStatus.driverAccepted:
          case RideStatus.cancelled:
          case RideStatus.failed:
            return to;
          default:
            return null;
        }

      case RideStatus.driverAccepted:
        switch (to) {
          case RideStatus.driverArrived:
          case RideStatus.cancelled:
          case RideStatus.failed:
            return to;
          default:
            return null;
        }

      case RideStatus.driverArrived:
        switch (to) {
          case RideStatus.inProgress:
          case RideStatus.cancelled:
          case RideStatus.failed:
            return to;
          default:
            return null;
        }

      case RideStatus.inProgress:
        switch (to) {
          case RideStatus.payment:
          case RideStatus.failed:
            return to;
          default:
            return null;
        }

      case RideStatus.payment:
        switch (to) {
          case RideStatus.completed:
          case RideStatus.failed:
            return to;
          default:
            return null;
        }

      // Terminal states - no further transitions allowed
      case RideStatus.completed:
      case RideStatus.cancelled:
      case RideStatus.failed:
        return null;
    }
  }
}

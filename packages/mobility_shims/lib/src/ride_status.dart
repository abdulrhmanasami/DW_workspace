/// Ride Status Enum - Track B Ticket #241
/// Purpose: FSM states for ride booking lifecycle
/// Created by: Track B - Ticket #241
/// Last updated: 2025-12-04
///
/// Defines the complete lifecycle states of a ride booking request,
/// from initial draft through completion or failure.
///
/// This follows the FSM pattern described in Manus roadmap:
/// Draft -> Quoting -> Requesting -> FindingDriver -> DriverAccepted ->
/// DriverArrived -> InProgress -> Payment -> Complete
///
/// Terminal states: completed, cancelled, failed

/// Represents the current status of a ride booking request.
///
/// This enum defines the complete lifecycle of a ride from initial draft
/// through completion. Each state represents a distinct phase in the
/// booking and execution process.
enum RideStatus {
  /// Initial state: User is selecting pickup/destination locations.
  /// No quote requested yet. This is the starting state for all bookings.
  draft,

  /// Quote is being requested from the pricing service.
  /// System is calculating fares and availability.
  quoting,

  /// Quote has been successfully received and is ready for user review.
  /// User can now see pricing options and confirm the booking.
  quoteReady,

  /// User has confirmed the booking and request is being submitted.
  /// System is preparing to assign a driver.
  requesting,

  /// Booking submitted, system is actively searching for an available driver.
  /// This is typically a brief transitional state.
  findingDriver,

  /// A driver has been assigned and has accepted the trip.
  /// Driver is on the way to pickup location.
  driverAccepted,

  /// Driver has arrived at the pickup location.
  /// Passenger should prepare to board.
  driverArrived,

  /// Trip is in progress - passenger is in the vehicle.
  /// Driver is transporting to destination.
  inProgress,

  /// Trip completed on the road, now in payment/settlement phase.
  /// Final calculations and payment processing.
  payment,

  /// Trip fully completed including payment.
  /// This is a terminal state - no further transitions allowed.
  completed,

  /// Trip was cancelled by user or system before completion.
  /// This is a terminal state - no further transitions allowed.
  cancelled,

  /// Trip failed due to an unrecoverable error (network, pricing, fraud, etc.).
  /// This is a terminal state - no further transitions allowed.
  failed,
}

/// Extension providing helper methods for RideStatus.
extension RideStatusHelpers on RideStatus {
  /// Returns true if this status represents an "active" trip that should
  /// be tracked (driver is involved or trip is in progress).
  ///
  /// Active phases: findingDriver, driverAccepted, driverArrived, inProgress
  bool get isActiveTrip {
    return this == RideStatus.findingDriver ||
        this == RideStatus.driverAccepted ||
        this == RideStatus.driverArrived ||
        this == RideStatus.inProgress;
  }

  /// Returns true if this status is a terminal state (no further transitions).
  ///
  /// Terminal phases: completed, cancelled, failed
  bool get isTerminal {
    return this == RideStatus.completed ||
        this == RideStatus.cancelled ||
        this == RideStatus.failed;
  }

  /// Returns true if this status allows cancellation by the user.
  ///
  /// Cancellation is allowed before the trip starts (not during inProgress or payment).
  bool get isCancellable {
    return this == RideStatus.draft ||
        this == RideStatus.quoting ||
        this == RideStatus.quoteReady ||
        this == RideStatus.requesting ||
        this == RideStatus.findingDriver ||
        this == RideStatus.driverAccepted ||
        this == RideStatus.driverArrived;
  }

  /// Returns true if this is a pre-trip phase (before driver involvement).
  ///
  /// Pre-trip phases: draft, quoting, quoteReady, requesting, findingDriver
  bool get isPreTrip {
    return this == RideStatus.draft ||
        this == RideStatus.quoting ||
        this == RideStatus.quoteReady ||
        this == RideStatus.requesting ||
        this == RideStatus.findingDriver;
  }

  /// Returns true if driver is involved (assigned and actively participating).
  ///
  /// With-driver phases: driverAccepted, driverArrived, inProgress
  bool get isWithDriver {
    return this == RideStatus.driverAccepted ||
        this == RideStatus.driverArrived ||
        this == RideStatus.inProgress;
  }

  /// Returns true if this is the payment phase.
  bool get isPaymentPhase {
    return this == RideStatus.payment;
  }

  /// Returns true if this status represents a completed trip.
  bool get isCompleted {
    return this == RideStatus.completed;
  }

  /// Returns true if this status represents a cancelled trip.
  bool get isCancelled {
    return this == RideStatus.cancelled;
  }

  /// Returns true if this status represents a failed trip.
  bool get isFailed {
    return this == RideStatus.failed;
  }
}

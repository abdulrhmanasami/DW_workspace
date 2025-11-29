import 'package:meta/meta.dart';

/// Ride Trip lifecycle phases.
///
/// This is the *canonical* state machine for a single ride trip.
/// It is intentionally SDK-agnostic and backend-agnostic.
enum RideTripPhase {
  /// No quote requested yet. User is still editing pickup/destination.
  draft,

  /// Quote requested, waiting for pricing/availability.
  quoting,

  /// Quote received, user can review and confirm.
  requesting,

  /// Trip request sent, system is looking for a driver.
  findingDriver,

  /// A driver has accepted the trip.
  driverAccepted,

  /// Driver has arrived at pickup.
  driverArrived,

  /// Passenger is in the car and the trip is in progress.
  inProgress,

  /// Trip finished on the road, payment is pending/being processed.
  payment,

  /// Trip fully completed (including payment).
  completed,

  /// Trip was cancelled by user/system before completion.
  cancelled,

  /// Trip failed due to an unrecoverable error.
  failed,
}

/// Events that move a ride trip from one phase to another.
///
/// These events are "intent" level – they do not know about network/SDKs.
/// Adapters are responsible for turning SDK callbacks/webhooks into these events.
enum RideTripEvent {
  /// User (or system) requests a quote for the given route.
  requestQuote,

  /// A quote was successfully received and the user can review it.
  quoteReceived,

  /// User confirms and submits the trip request.
  submitRequest,

  /// Backend / dispatch found a driver and the driver accepted the trip.
  driverAccepted,

  /// Driver arrived at pickup location.
  driverArrived,

  /// Passenger got in the car and the trip started.
  startTrip,

  /// Trip ended on the road, move to payment/settlement phase.
  startPayment,

  /// Payment successfully completed and the trip is fully done.
  complete,

  /// User or system cancelled the trip.
  cancel,

  /// Trip failed (e.g. hard error, fraud, unrecoverable backend issue).
  fail,
}

/// Immutable state for a single ride trip.
///
/// This is *not* a persistence or API model; it's an in-memory state object.
/// Storage/backends can map to/from this model as needed.
@immutable
class RideTripState {
  const RideTripState({
    required this.tripId,
    required this.phase,
  });

  /// Client-side identifier for the trip.
  ///
  /// This can be mapped to a backend ID or a local UUID.
  final String tripId;

  /// Current phase of the trip FSM.
  final RideTripPhase phase;

  RideTripState copyWith({
    String? tripId,
    RideTripPhase? phase,
  }) {
    return RideTripState(
      tripId: tripId ?? this.tripId,
      phase: phase ?? this.phase,
    );
  }
}

/// Exception thrown when an invalid transition is attempted.
class InvalidRideTransitionException implements Exception {
  InvalidRideTransitionException(this.from, this.event);

  final RideTripPhase from;
  final RideTripEvent event;

  @override
  String toString() =>
      'InvalidRideTransitionException: cannot apply $event from $from';
}

/// Pure function that applies a [RideTripEvent] to a [RideTripState].
///
/// - Returns a **new** state with the updated phase when the transition is valid.
/// - Throws [InvalidRideTransitionException] if the transition is not allowed.
RideTripState applyRideTripEvent(
  RideTripState state,
  RideTripEvent event,
) {
  final nextPhase = _nextPhase(state.phase, event);
  if (nextPhase == null) {
    throw InvalidRideTransitionException(state.phase, event);
  }
  return state.copyWith(phase: nextPhase);
}

/// Internal transition table.
///
/// This is intentionally explicit (switch/switch) to make it easy to audit
/// and reason about in code reviews.
RideTripPhase? _nextPhase(RideTripPhase phase, RideTripEvent event) {
  switch (phase) {
    case RideTripPhase.draft:
      switch (event) {
        case RideTripEvent.requestQuote:
          return RideTripPhase.quoting;
        case RideTripEvent.cancel:
          return RideTripPhase.cancelled;
        case RideTripEvent.fail:
          return RideTripPhase.failed;
        default:
          return null;
      }

    case RideTripPhase.quoting:
      switch (event) {
        case RideTripEvent.quoteReceived:
          return RideTripPhase.requesting;
        case RideTripEvent.cancel:
          return RideTripPhase.cancelled;
        case RideTripEvent.fail:
          return RideTripPhase.failed;
        default:
          return null;
      }

    case RideTripPhase.requesting:
      switch (event) {
        case RideTripEvent.submitRequest:
          return RideTripPhase.findingDriver;
        case RideTripEvent.cancel:
          return RideTripPhase.cancelled;
        case RideTripEvent.fail:
          return RideTripPhase.failed;
        default:
          return null;
      }

    case RideTripPhase.findingDriver:
      switch (event) {
        case RideTripEvent.driverAccepted:
          return RideTripPhase.driverAccepted;
        case RideTripEvent.cancel:
          return RideTripPhase.cancelled;
        case RideTripEvent.fail:
          return RideTripPhase.failed;
        default:
          return null;
      }

    case RideTripPhase.driverAccepted:
      switch (event) {
        case RideTripEvent.driverArrived:
          return RideTripPhase.driverArrived;
        case RideTripEvent.cancel:
          return RideTripPhase.cancelled;
        case RideTripEvent.fail:
          return RideTripPhase.failed;
        default:
          return null;
      }

    case RideTripPhase.driverArrived:
      switch (event) {
        case RideTripEvent.startTrip:
          return RideTripPhase.inProgress;
        case RideTripEvent.cancel:
          return RideTripPhase.cancelled;
        case RideTripEvent.fail:
          return RideTripPhase.failed;
        default:
          return null;
      }

    case RideTripPhase.inProgress:
      switch (event) {
        case RideTripEvent.startPayment:
          return RideTripPhase.payment;
        case RideTripEvent.fail:
          return RideTripPhase.failed;
        default:
          return null;
      }

    case RideTripPhase.payment:
      switch (event) {
        case RideTripEvent.complete:
          return RideTripPhase.completed;
        case RideTripEvent.fail:
          return RideTripPhase.failed;
        default:
          return null;
      }

    case RideTripPhase.completed:
    case RideTripPhase.cancelled:
    case RideTripPhase.failed:
      // Terminal states – no further transitions allowed.
      return null;
  }
}


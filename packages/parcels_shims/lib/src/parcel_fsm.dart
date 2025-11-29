import 'package:meta/meta.dart';

import 'parcel_models.dart';

/// Internal FSM phases for parcel lifecycle.
///
/// More narrow and technical than the UI-visible ParcelStatus.
enum ParcelPhase {
  draft,
  quoting,
  awaitingPickup,
  pickedUp,
  inTransit,
  delivered,
  cancelled,
  failed,
}

/// Events that drive the Parcel FSM.
enum ParcelEvent {
  requestQuote,
  quoteReceived,
  schedulePickup,
  pickupSucceeded,
  startTransit,
  markDelivered,
  cancel,
  fail,
}

/// Immutable state for parcel FSM.
@immutable
class ParcelState {
  const ParcelState({
    required this.parcelId,
    required this.phase,
  });

  final ParcelId parcelId;
  final ParcelPhase phase;

  ParcelState copyWith({
    ParcelPhase? phase,
  }) {
    return ParcelState(
      parcelId: parcelId,
      phase: phase ?? this.phase,
    );
  }
}

/// Exception thrown when an invalid transition is attempted.
class InvalidParcelTransitionException implements Exception {
  InvalidParcelTransitionException(this.message);

  final String message;

  @override
  String toString() => 'InvalidParcelTransitionException: $message';
}

/// Returns the next state given the current state and event.
///
/// Throws [InvalidParcelTransitionException] on invalid transitions.
ParcelState applyParcelEvent(ParcelState state, ParcelEvent event) {
  final current = state.phase;

  switch (current) {
    case ParcelPhase.draft:
      switch (event) {
        case ParcelEvent.requestQuote:
          return state.copyWith(phase: ParcelPhase.quoting);
        case ParcelEvent.cancel:
          return state.copyWith(phase: ParcelPhase.cancelled);
        default:
          throw InvalidParcelTransitionException(
            'Cannot apply $event from $current',
          );
      }

    case ParcelPhase.quoting:
      switch (event) {
        case ParcelEvent.quoteReceived:
          return state.copyWith(phase: ParcelPhase.awaitingPickup);
        case ParcelEvent.cancel:
          return state.copyWith(phase: ParcelPhase.cancelled);
        case ParcelEvent.fail:
          return state.copyWith(phase: ParcelPhase.failed);
        default:
          throw InvalidParcelTransitionException(
            'Cannot apply $event from $current',
          );
      }

    case ParcelPhase.awaitingPickup:
      switch (event) {
        case ParcelEvent.schedulePickup:
        case ParcelEvent.pickupSucceeded:
          return state.copyWith(phase: ParcelPhase.pickedUp);
        case ParcelEvent.cancel:
          return state.copyWith(phase: ParcelPhase.cancelled);
        default:
          throw InvalidParcelTransitionException(
            'Cannot apply $event from $current',
          );
      }

    case ParcelPhase.pickedUp:
      switch (event) {
        case ParcelEvent.startTransit:
          return state.copyWith(phase: ParcelPhase.inTransit);
        case ParcelEvent.cancel:
          return state.copyWith(phase: ParcelPhase.cancelled);
        default:
          throw InvalidParcelTransitionException(
            'Cannot apply $event from $current',
          );
      }

    case ParcelPhase.inTransit:
      switch (event) {
        case ParcelEvent.markDelivered:
          return state.copyWith(phase: ParcelPhase.delivered);
        case ParcelEvent.fail:
          return state.copyWith(phase: ParcelPhase.failed);
        default:
          throw InvalidParcelTransitionException(
            'Cannot apply $event from $current',
          );
      }

    case ParcelPhase.delivered:
    case ParcelPhase.cancelled:
    case ParcelPhase.failed:
      // Terminal states: no more transitions
      throw InvalidParcelTransitionException(
        'Cannot apply $event from terminal phase $current',
      );
  }
}


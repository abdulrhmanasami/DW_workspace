/// Ride Status Utilities
/// Created by: Track B - Ticket #85
/// Purpose: Single source of truth for ride trip phase behavior (terminal + localized labels)
/// Last updated: 2025-11-29
///
/// This file consolidates all ride phase status logic:
/// - isRidePhaseTerminal: Determines if a phase is a terminal (final) state
/// - localizedRidePhaseStatusShort: Compact labels for lists/details
/// - localizedRidePhaseStatusLong: Verbose labels for hero cards (Home Hub, Active Trip)
///
/// Design pattern matches parcel_status_utils.dart (Track C - Ticket #78).

import 'package:mobility_shims/mobility_shims.dart' show RideTripPhase;

import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';

/// True if the phase is considered terminal (no more transitions allowed).
///
/// Terminal phases indicate the ride trip flow has ended (successfully or not).
/// Non-terminal phases mean the trip is still in progress or pending.
///
/// Terminal phases (per FSM + Manus): completed, cancelled, failed.
///
/// Track B - Ticket #85: Central terminal check for ride phases.
bool isRidePhaseTerminal(RideTripPhase phase) {
  return phase == RideTripPhase.completed ||
      phase == RideTripPhase.cancelled ||
      phase == RideTripPhase.failed;
}

/// Localized short label for a given ride trip phase.
///
/// Uses the short L10n keys (rideStatusShort*):
/// - rideStatusShortDraft
/// - rideStatusShortQuoting
/// - rideStatusShortRequesting
/// - rideStatusShortFindingDriver
/// - rideStatusShortDriverAccepted
/// - rideStatusShortDriverArrived
/// - rideStatusShortInProgress
/// - rideStatusShortPayment
/// - rideStatusShortCompleted
/// - rideStatusShortCancelled
/// - rideStatusShortFailed
///
/// Intended for: Details screens, lists, compact contexts.
/// Track B - Ticket #85: Consolidated from various ride UI files.
String localizedRidePhaseStatusShort(AppLocalizations? l10n, RideTripPhase phase) {
  switch (phase) {
    case RideTripPhase.draft:
      return l10n?.rideStatusShortDraft ?? 'Draft';
    case RideTripPhase.quoting:
      return l10n?.rideStatusShortQuoting ?? 'Getting price';
    case RideTripPhase.requesting:
      return l10n?.rideStatusShortRequesting ?? 'Requesting ride';
    case RideTripPhase.findingDriver:
      return l10n?.rideStatusShortFindingDriver ?? 'Finding driver';
    case RideTripPhase.driverAccepted:
      return l10n?.rideStatusShortDriverAccepted ?? 'Driver accepted';
    case RideTripPhase.driverArrived:
      return l10n?.rideStatusShortDriverArrived ?? 'Driver arrived';
    case RideTripPhase.inProgress:
      return l10n?.rideStatusShortInProgress ?? 'In progress';
    case RideTripPhase.payment:
      return l10n?.rideStatusShortPayment ?? 'Payment in progress';
    case RideTripPhase.completed:
      return l10n?.rideStatusShortCompleted ?? 'Completed';
    case RideTripPhase.cancelled:
      return l10n?.rideStatusShortCancelled ?? 'Cancelled';
    case RideTripPhase.failed:
      return l10n?.rideStatusShortFailed ?? 'Failed';
  }
}

/// Localized verbose/long label for a given ride trip phase.
///
/// Uses the verbose L10n keys (homeActiveRideStatus*):
/// - homeActiveRideStatusPreparing (for draft, quoting, requesting)
/// - homeActiveRideStatusFindingDriver
/// - homeActiveRideStatusDriverAccepted
/// - homeActiveRideStatusDriverArrived
/// - homeActiveRideStatusInProgress
/// - homeActiveRideStatusPayment
/// - homeActiveRideStatusCompleted
/// - homeActiveRideStatusCancelled
/// - homeActiveRideStatusFailed
///
/// Intended for: Home hub cards, active trip displays, hero contexts.
/// Track B - Ticket #85: Consolidated from app_shell.dart and ride screens.
String localizedRidePhaseStatusLong(AppLocalizations l10n, RideTripPhase phase) {
  switch (phase) {
    case RideTripPhase.draft:
    case RideTripPhase.quoting:
    case RideTripPhase.requesting:
      return l10n.homeActiveRideStatusPreparing;
    case RideTripPhase.findingDriver:
      return l10n.homeActiveRideStatusFindingDriver;
    case RideTripPhase.driverAccepted:
      return l10n.homeActiveRideStatusDriverAccepted;
    case RideTripPhase.driverArrived:
      return l10n.homeActiveRideStatusDriverArrived;
    case RideTripPhase.inProgress:
      return l10n.homeActiveRideStatusInProgress;
    case RideTripPhase.payment:
      return l10n.homeActiveRideStatusPayment;
    case RideTripPhase.completed:
      return l10n.homeActiveRideStatusCompleted;
    case RideTripPhase.cancelled:
      return l10n.homeActiveRideStatusCancelled;
    case RideTripPhase.failed:
      return l10n.homeActiveRideStatusFailed;
  }
}


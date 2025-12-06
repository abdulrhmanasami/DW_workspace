/// Parcel Status Utilities
/// Created by: Track C - Ticket #78
/// Updated by: Track C - Ticket #81 (isParcelStatusUserCancellable)
/// Purpose: Single source of truth for parcel status behavior (terminal + localized labels)
/// Last updated: 2025-11-29

import 'package:parcels_shims/parcels_shims.dart' show ParcelStatus;

import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';

/// True if the status is considered terminal (no longer active).
///
/// Terminal statuses indicate the shipment flow has ended (successfully or not).
/// Non-terminal statuses mean the shipment is still in progress.
///
/// Track C - Ticket #78: Moved from app_shell.dart to single source of truth.
bool isParcelStatusTerminal(ParcelStatus status) {
  return status == ParcelStatus.delivered ||
      status == ParcelStatus.cancelled ||
      status == ParcelStatus.failed;
}

/// True if the user is allowed to cancel a parcel in this status.
///
/// Business rule (Ticket #81):
/// - User can cancel while the shipment is still being prepared/scheduled/pending pickup.
/// - Once parcel is picked up or in transit, cancellation from the app is not allowed.
/// - All terminal statuses (delivered/cancelled/failed) are NOT cancellable.
///
/// Track C - Ticket #81: Central can-cancel logic for ParcelShipmentDetailsScreen.
bool isParcelStatusUserCancellable(ParcelStatus status) {
  // Terminal statuses cannot be cancelled
  if (isParcelStatusTerminal(status)) return false;

  // Disallow cancel after pickup - parcel is already with driver
  if (status == ParcelStatus.pickedUp || status == ParcelStatus.inTransit) {
    return false;
  }

  // Draft / quoting / scheduled / pickupPending are cancellable
  return true;
}

/// Localized short label for a given parcel status.
///
/// Uses the short L10n keys (parcelsStatus*):
/// - parcelsStatusScheduled
/// - parcelsStatusPickupPending
/// - parcelsStatusPickedUp
/// - parcelsStatusInTransit
/// - parcelsStatusDelivered
/// - parcelsStatusCancelled
/// - parcelsStatusFailed
///
/// Intended for: Details screens, lists where space is limited.
/// Track C - Ticket #78: Consolidated from parcel_shipment_details_screen.dart
String localizedParcelStatusShort(AppLocalizations? l10n, ParcelStatus status) {
  switch (status) {
    case ParcelStatus.draft:
      return l10n?.parcelsStatusScheduled ?? 'Draft';
    case ParcelStatus.quoting:
      return l10n?.parcelsStatusScheduled ?? 'Quoting';
    case ParcelStatus.scheduled:
      return l10n?.parcelsStatusScheduled ?? 'Scheduled';
    case ParcelStatus.pickupPending:
      return l10n?.parcelsStatusPickupPending ?? 'Pickup pending';
    case ParcelStatus.pickedUp:
      return l10n?.parcelsStatusPickedUp ?? 'Picked up';
    case ParcelStatus.inTransit:
      return l10n?.parcelsStatusInTransit ?? 'In transit';
    case ParcelStatus.delivered:
      return l10n?.parcelsStatusDelivered ?? 'Delivered';
    case ParcelStatus.cancelled:
      return l10n?.parcelsStatusCancelled ?? 'Cancelled';
    case ParcelStatus.failed:
      return l10n?.parcelsStatusFailed ?? 'Failed';
  }
}

/// Localized verbose/long label for a given parcel status.
///
/// Uses the verbose L10n keys (homeActiveParcelStatus*):
/// - homeActiveParcelStatusPreparing
/// - homeActiveParcelStatusScheduled
/// - homeActiveParcelStatusPickupPending
/// - homeActiveParcelStatusPickedUp
/// - homeActiveParcelStatusInTransit
/// - homeActiveParcelStatusDelivered
/// - homeActiveParcelStatusCancelled
/// - homeActiveParcelStatusFailed
///
/// Intended for: Home hub cards, active shipment displays.
/// Track C - Ticket #78: Consolidated from app_shell.dart and parcels_list_screen.dart
String localizedParcelStatusLong(AppLocalizations l10n, ParcelStatus status) {
  switch (status) {
    case ParcelStatus.draft:
    case ParcelStatus.quoting:
      return l10n.homeActiveParcelStatusPreparing;
    case ParcelStatus.scheduled:
      return l10n.homeActiveParcelStatusScheduled;
    case ParcelStatus.pickupPending:
      return l10n.homeActiveParcelStatusPickupPending;
    case ParcelStatus.pickedUp:
      return l10n.homeActiveParcelStatusPickedUp;
    case ParcelStatus.inTransit:
      return l10n.homeActiveParcelStatusInTransit;
    case ParcelStatus.delivered:
      return l10n.homeActiveParcelStatusDelivered;
    case ParcelStatus.cancelled:
      return l10n.homeActiveParcelStatusCancelled;
    case ParcelStatus.failed:
      return l10n.homeActiveParcelStatusFailed;
  }
}


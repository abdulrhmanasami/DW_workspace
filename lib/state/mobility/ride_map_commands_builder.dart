/// Ride Map Commands Builder - Track B Ticket #110
/// Purpose: Pure Dart layer to convert ride state into DWMap commands
/// Created by: Track B - Ticket #110
/// Last updated: 2025-11-30
///
/// This builder transforms RideDraftUiState and RideTripSessionUiState
/// into DWMapCommands for rendering on the map widget.
///
/// IMPORTANT:
/// - Pure Dart - no Flutter dependencies
/// - No SDK or UI coupling - only uses maps_shims types
/// - Fully testable without Flutter test harness

import 'package:meta/meta.dart';

// From maps_shims package (pure Dart types)
import 'package:maps_shims/maps_shims.dart';

// From mobility_shims package (domain models)
import 'package:mobility_shims/mobility_shims.dart';

// From app state
import 'package:delivery_ways_clean/state/mobility/ride_draft_state.dart';
import 'package:delivery_ways_clean/state/mobility/ride_trip_session.dart';

// =============================================================================
// Track B - Ticket #110: Result Value Object
// =============================================================================

/// Immutable container for map commands built from ride state.
///
/// Contains the commands needed to render a ride on the map:
/// - [setContent]: Markers and polylines to display
/// - [animateToBounds]: Optional camera animation to fit content
@immutable
class RideMapCommands {
  const RideMapCommands({
    required this.setContent,
    this.animateToBounds,
  });

  /// Command to set markers and polylines on the map.
  final DWSetContentCommand setContent;

  /// Optional command to animate camera to fit all content.
  /// Null when there are no markers/points to bound.
  final DWAnimateToBoundsCommand? animateToBounds;

  @override
  String toString() =>
      'RideMapCommands(setContent: $setContent, animateToBounds: $animateToBounds)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RideMapCommands &&
        other.setContent == setContent &&
        other.animateToBounds == animateToBounds;
  }

  @override
  int get hashCode => Object.hash(setContent, animateToBounds);
}

// =============================================================================
// Track B - Ticket #110: Builder Functions
// =============================================================================

/// Track B - Ticket #110: Build map commands for a ride draft.
/// This is used for pickup/destination preview before requesting.
///
/// Returns [RideMapCommands] with:
/// - Markers for pickup and/or destination (if coordinates available)
/// - Polyline connecting pickup to destination (if both have coordinates)
/// - Bounds animation to fit all content
///
/// If no coordinates are available, returns empty content with no animation.
RideMapCommands buildDraftMapCommands(RideDraftUiState draft) {
  final markers = <DWMapMarker>[];
  final polylines = <DWMapPolyline>[];
  final allPoints = <DWLatLng>[];

  // Convert places to coordinates
  final pickupLatLng = _toLatLngFromPlace(draft.pickupPlace);
  final destinationLatLng = _toLatLngFromPlace(draft.destinationPlace);

  // Build pickup marker
  if (pickupLatLng != null) {
    markers.add(DWMapMarker(
      id: 'pickup',
      position: pickupLatLng,
      type: DWMapMarkerType.userPickup,
      label: draft.pickupLabel,
    ));
    allPoints.add(pickupLatLng);
  }

  // Build destination marker
  if (destinationLatLng != null) {
    markers.add(DWMapMarker(
      id: 'destination',
      position: destinationLatLng,
      type: DWMapMarkerType.destination,
      label: draft.destinationPlace?.label ?? draft.destinationQuery,
    ));
    allPoints.add(destinationLatLng);
  }

  // Build route polyline (simple straight line for now)
  if (pickupLatLng != null && destinationLatLng != null) {
    polylines.add(DWMapPolyline(
      id: 'route',
      points: [pickupLatLng, destinationLatLng],
      style: DWMapPolylineStyle.route,
    ));
  }

  // Build content command
  final contentCommand = DWSetContentCommand(
    markers: markers,
    polylines: polylines,
  );

  // Build bounds animation command
  DWAnimateToBoundsCommand? animateCommand;
  if (allPoints.isNotEmpty) {
    final bounds = _calculateBounds(allPoints);
    if (bounds != null) {
      animateCommand = DWAnimateToBoundsCommand(
        bounds,
        padding: 48.0,
      );
    }
  }

  return RideMapCommands(
    setContent: contentCommand,
    animateToBounds: animateCommand,
  );
}

/// Track B - Ticket #110: Build map commands for an active trip session.
/// This is used for driver tracking + route preview while ride is in progress.
///
/// Returns [RideMapCommands] with markers for pickup, destination, and
/// optionally the driver's location (if available in state).
///
/// Returns `null` when:
/// - No active trip exists
/// - Trip is in a terminal phase (completed/cancelled/failed)
/// - No draftSnapshot available (insufficient location data)
///
/// Track B - Ticket #111: Enhanced to use frozen draftSnapshot from session.
/// Reuses buildDraftMapCommands to ensure single source of truth.
RideMapCommands? buildActiveTripMapCommands(RideTripSessionUiState state) {
  // No active trip
  if (state.activeTrip == null) return null;

  // Skip terminal phases (completed, cancelled, failed)
  if (state.activeTrip!.phase.isTerminal) return null;

  // Track B - Ticket #111: Use frozen draft snapshot for location data
  if (state.draftSnapshot == null) return null;

  // Reuse the same draft-based builder to ensure consistency.
  // This avoids duplicating markers/polylines logic.
  return buildDraftMapCommands(state.draftSnapshot!);
}

/// Track B - Ticket #110: Build map commands for active trip with explicit draft.
///
/// This overload accepts the original draft state to provide location data
/// when the session doesn't store it internally.
///
/// Use this when you have access to both the session and the original draft.
RideMapCommands? buildActiveTripMapCommandsWithDraft(
  RideTripSessionUiState state,
  RideDraftUiState? draft,
) {
  // No active trip
  if (state.activeTrip == null) return null;

  // Skip terminal phases
  if (state.activeTrip!.phase.isTerminal) return null;

  // No draft data available
  if (draft == null) return null;

  final markers = <DWMapMarker>[];
  final polylines = <DWMapPolyline>[];
  final allPoints = <DWLatLng>[];

  // Convert places to coordinates
  final pickupLatLng = _toLatLngFromPlace(draft.pickupPlace);
  final destinationLatLng = _toLatLngFromPlace(draft.destinationPlace);

  // Build pickup marker
  if (pickupLatLng != null) {
    markers.add(DWMapMarker(
      id: 'pickup',
      position: pickupLatLng,
      type: DWMapMarkerType.userPickup,
      label: draft.pickupLabel,
    ));
    allPoints.add(pickupLatLng);
  }

  // Build destination marker
  if (destinationLatLng != null) {
    markers.add(DWMapMarker(
      id: 'destination',
      position: destinationLatLng,
      type: DWMapMarkerType.destination,
      label: draft.destinationPlace?.label ?? draft.destinationQuery,
    ));
    allPoints.add(destinationLatLng);
  }

  // Build route polyline
  if (pickupLatLng != null && destinationLatLng != null) {
    polylines.add(DWMapPolyline(
      id: 'route',
      points: [pickupLatLng, destinationLatLng],
      style: DWMapPolylineStyle.route,
    ));
  }

  // If no location data, return null
  if (markers.isEmpty) return null;

  // Build content command
  final contentCommand = DWSetContentCommand(
    markers: markers,
    polylines: polylines,
  );

  // Build bounds animation
  DWAnimateToBoundsCommand? animateCommand;
  if (allPoints.isNotEmpty) {
    final bounds = _calculateBounds(allPoints);
    if (bounds != null) {
      animateCommand = DWAnimateToBoundsCommand(
        bounds,
        padding: 48.0,
      );
    }
  }

  return RideMapCommands(
    setContent: contentCommand,
    animateToBounds: animateCommand,
  );
}

// =============================================================================
// Track B - Ticket #110: Helper Functions
// =============================================================================

/// Convert a [MobilityPlace] to [DWLatLng].
///
/// Returns null if:
/// - place is null
/// - place.location is null (no coordinates resolved)
DWLatLng? _toLatLngFromPlace(MobilityPlace? place) {
  if (place == null) return null;

  final location = place.location;
  if (location == null) return null;

  return DWLatLng(location.latitude, location.longitude);
}

/// Calculate bounding box for a list of points.
///
/// Returns null if the list is empty.
DWLatLngBounds? _calculateBounds(List<DWLatLng> points) {
  if (points.isEmpty) return null;

  double minLat = points.first.latitude;
  double maxLat = points.first.latitude;
  double minLng = points.first.longitude;
  double maxLng = points.first.longitude;

  for (final point in points) {
    if (point.latitude < minLat) minLat = point.latitude;
    if (point.latitude > maxLat) maxLat = point.latitude;
    if (point.longitude < minLng) minLng = point.longitude;
    if (point.longitude > maxLng) maxLng = point.longitude;
  }

  return DWLatLngBounds(
    southWest: DWLatLng(minLat, minLng),
    northEast: DWLatLng(maxLat, maxLng),
  );
}


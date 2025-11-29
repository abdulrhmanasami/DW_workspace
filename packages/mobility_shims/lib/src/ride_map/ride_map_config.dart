/// Ride Map Configuration - Track B Ticket #28
/// Purpose: Domain helper for building map configurations for ride screens
/// Created by: Track B - Ticket #28
/// Last updated: 2025-11-28
///
/// This module provides:
/// - RideMapConfig model (camera target, zoom, markers, polylines)
/// - buildDestinationPreviewMap - for Screen 8 (Destination) and Screen 9 (Confirmation)
/// - buildActiveTripMap - for Screen 10 (Active Trip)
///
/// IMPORTANT:
/// - Uses maps_shims types (LatLng, MapMarker, MapPolyline, MapPoint)
/// - Does NOT depend on Flutter or UI widgets
/// - mobility_shims depends on maps_shims (allowed by B-STYLE)

import 'package:meta/meta.dart';
import 'package:maps_shims/maps_shims.dart';

import '../place_models.dart';
import '../ride_trip_fsm.dart';
import '../../location/models.dart';

/// Configuration model for ride maps.
///
/// Contains all data needed to render a map for ride screens:
/// - Camera target and zoom level
/// - Markers (pickup, destination, driver)
/// - Polylines (route between pickup and destination)
@immutable
class RideMapConfig {
  const RideMapConfig({
    required this.cameraTarget,
    required this.cameraZoom,
    required this.markers,
    required this.polylines,
  });

  /// Camera center position.
  final LatLng cameraTarget;

  /// Camera zoom level.
  final double cameraZoom;

  /// Map markers (pickup, destination, driver, etc.).
  final List<MapMarker> markers;

  /// Map polylines (route path).
  final List<MapPolyline> polylines;

  /// Default zoom level for ride maps.
  static const defaultZoom = 14.0;

  /// Default location (Riyadh, Saudi Arabia).
  static const defaultLocation = LatLng(24.7136, 46.6753);

  /// Creates a copy with updated fields.
  RideMapConfig copyWith({
    LatLng? cameraTarget,
    double? cameraZoom,
    List<MapMarker>? markers,
    List<MapPolyline>? polylines,
  }) {
    return RideMapConfig(
      cameraTarget: cameraTarget ?? this.cameraTarget,
      cameraZoom: cameraZoom ?? this.cameraZoom,
      markers: markers ?? this.markers,
      polylines: polylines ?? this.polylines,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RideMapConfig &&
        other.cameraTarget.lat == cameraTarget.lat &&
        other.cameraTarget.lng == cameraTarget.lng &&
        other.cameraZoom == cameraZoom &&
        other.markers.length == markers.length &&
        other.polylines.length == polylines.length;
  }

  @override
  int get hashCode => Object.hash(
        cameraTarget.lat,
        cameraTarget.lng,
        cameraZoom,
        markers.length,
        polylines.length,
      );
}

// ============================================================================
// Builder Functions
// ============================================================================

/// Builds a map configuration for destination preview screens (Screen 8, 9).
///
/// This is used by:
/// - RideDestinationScreen (Screen 8)
/// - RideConfirmationScreen (Screen 9)
///
/// Shows:
/// - Pickup marker (blue dot or current location)
/// - Destination marker (red pin)
/// - Route polyline between pickup and destination (if both have coordinates)
RideMapConfig buildDestinationPreviewMap({
  required MobilityPlace? pickup,
  required MobilityPlace? destination,
}) {
  final pickupLatLng = _toLatLng(pickup?.location);
  final destLatLng = _toLatLng(destination?.location);

  final markers = <MapMarker>[
    if (pickupLatLng != null)
      _createMarker(
        id: 'pickup',
        latLng: pickupLatLng,
        title: pickup?.label ?? 'Pickup',
      ),
    if (destLatLng != null)
      _createMarker(
        id: 'destination',
        latLng: destLatLng,
        title: destination?.label ?? 'Destination',
      ),
  ];

  final polylines = <MapPolyline>[];
  if (pickupLatLng != null && destLatLng != null) {
    polylines.add(MapPolyline(
      id: 'route-pickup-destination',
      points: [pickupLatLng, destLatLng],
      width: 4.0,
    ));
  }

  // Camera target: prefer destination, fallback to pickup, then default
  final cameraTarget =
      destLatLng ?? pickupLatLng ?? RideMapConfig.defaultLocation;

  return RideMapConfig(
    cameraTarget: cameraTarget,
    cameraZoom: RideMapConfig.defaultZoom,
    markers: markers,
    polylines: polylines,
  );
}

/// Builds a map configuration for active trip screen (Screen 10).
///
/// Shows:
/// - All markers from destination preview
/// - Driver marker (when driver is assigned or in progress)
/// - Route polyline
///
/// Camera focuses on driver when available, otherwise on destination.
RideMapConfig buildActiveTripMap({
  required RideTripState activeTrip,
  required MobilityPlace? pickup,
  required MobilityPlace? destination,
  LocationPoint? driverLocation,
}) {
  // Start with base preview config
  final base = buildDestinationPreviewMap(
    pickup: pickup,
    destination: destination,
  );

  // Build markers list starting with base markers
  final markers = <MapMarker>[...base.markers];

  // Add driver marker if location is available and phase is appropriate
  final driverLatLng = _toLatLng(driverLocation);
  if (driverLatLng != null && _shouldShowDriverMarker(activeTrip.phase)) {
    markers.add(_createMarker(
      id: 'driver',
      latLng: driverLatLng,
      title: 'Driver',
    ));
  }

  // Camera focuses on driver when available, otherwise use base target
  final cameraTarget = driverLatLng ?? base.cameraTarget;

  return RideMapConfig(
    cameraTarget: cameraTarget,
    cameraZoom: base.cameraZoom,
    markers: markers,
    polylines: base.polylines,
  );
}

/// Builds a simple map configuration with just pickup location.
///
/// Used for Home Hub map when no active trip exists.
RideMapConfig buildPickupOnlyMap({
  required MobilityPlace? pickup,
}) {
  final pickupLatLng = _toLatLng(pickup?.location);

  final markers = <MapMarker>[
    if (pickupLatLng != null)
      _createMarker(
        id: 'pickup',
        latLng: pickupLatLng,
        title: pickup?.label ?? 'Current Location',
      ),
  ];

  final cameraTarget = pickupLatLng ?? RideMapConfig.defaultLocation;

  return RideMapConfig(
    cameraTarget: cameraTarget,
    cameraZoom: RideMapConfig.defaultZoom,
    markers: markers,
    polylines: const [],
  );
}

// ============================================================================
// Helper Functions
// ============================================================================

/// Converts LocationPoint to LatLng.
LatLng? _toLatLng(LocationPoint? location) {
  if (location == null) return null;
  return LatLng(location.latitude, location.longitude);
}

/// Creates a MapMarker from LatLng.
MapMarker _createMarker({
  required String id,
  required LatLng latLng,
  required String title,
}) {
  return MapMarker(
    id: id,
    point: MapPoint(
      latitude: latLng.lat,
      longitude: latLng.lng,
    ),
    title: title,
  );
}

/// Determines if driver marker should be shown based on trip phase.
bool _shouldShowDriverMarker(RideTripPhase phase) {
  return phase == RideTripPhase.driverAccepted ||
      phase == RideTripPhase.driverArrived ||
      phase == RideTripPhase.inProgress;
}


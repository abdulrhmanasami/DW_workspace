/// Ride Map Projection V1 - Track B Ticket #199
/// Purpose: Clear layer between FSM and Maps via Map Snapshot + MapPort Helper
/// Created by: Track B - Ticket #199
/// Last updated: 2025-12-03
///
/// This file provides a presentation-oriented mapping from ride FSM states to map snapshots.
/// It transforms RideMapStage + key locations into RideMapSnapshot, then converts to MapCommands.
///
/// Track B - Ticket #199: Ride Map Projection V1 – من FSM إلى Map Snapshot + MapPort Helper
/// - Domain/UI-Oriented Mapping (Pure Dart, فوق MapPort، بدون Widgets)
/// - No integration with RideTripSessionController yet (will be in next ticket)
/// - Uses InMemoryMapPort for testing

import 'package:meta/meta.dart';
import 'package:maps_shims/maps_shims.dart';

/// Presentation-oriented stages for how the Ride should appear on the map.
/// These stages can be derived from the RideTripSession FSM states.
///
/// Recommended mapping from FSM -> RideMapStage:
/// - draft           -> RideMapStage.idle
/// - quoting         -> RideMapStage.searchingDestination
/// - requesting      -> RideMapStage.confirmingQuote
/// - findingDriver   -> RideMapStage.waitingForDriver
/// - driverAccepted  -> RideMapStage.driverEnRouteToPickup
/// - driverArrived   -> RideMapStage.driverArrived
/// - inProgress      -> RideMapStage.inProgressToDestination
/// - payment         -> RideMapStage.inProgressToDestination
/// - completed       -> RideMapStage.completed
/// - cancelled/failed-> RideMapStage.error
enum RideMapStage {
  idle,
  searchingDestination,
  confirmingQuote,
  waitingForDriver,
  driverEnRouteToPickup,
  driverArrived,
  inProgressToDestination,
  completed,
  error,
}

@immutable
class RideMapSnapshot {
  final MapCameraTarget cameraTarget;
  final List<MapMarker> markers;
  final List<MapPolyline> polylines;

  RideMapSnapshot({
    required this.cameraTarget,
    required List<MapMarker> markers,
    required List<MapPolyline> polylines,
  })  : markers = List.unmodifiable(markers),
        polylines = List.unmodifiable(polylines);
}

class RideMapProjector {
  const RideMapProjector._();

  /// Compute a map snapshot for the given ride stage and key locations.
  static RideMapSnapshot project({
    required RideMapStage stage,
    GeoPoint? userLocation,
    GeoPoint? pickupLocation,
    GeoPoint? dropoffLocation,
    GeoPoint? driverLocation,
    MapPolyline? routePolyline,
  }) {
    final markers = <MapMarker>[];
    final polylines = <MapPolyline>[];

    // Markers: pickup/dropoff are shown whenever provided.
    if (pickupLocation != null) {
      markers.add(
        MapMarker(
          id: const MapMarkerId('pickup'),
          position: pickupLocation,
          label: 'Pickup',
        ),
      );
    }

    if (dropoffLocation != null &&
        stage.index >= RideMapStage.confirmingQuote.index) {
      markers.add(
        MapMarker(
          id: const MapMarkerId('dropoff'),
          position: dropoffLocation,
          label: 'Dropoff',
        ),
      );
    }

    // Driver marker appears only once we are actually dealing with a driver.
    if (driverLocation != null &&
        stage.index >= RideMapStage.waitingForDriver.index &&
        stage != RideMapStage.completed &&
        stage != RideMapStage.error) {
      markers.add(
        MapMarker(
          id: const MapMarkerId('driver'),
          position: driverLocation,
          label: 'Driver',
        ),
      );
    }

    // Polyline (route) shown once pickup + dropoff are known.
    if (routePolyline != null &&
        stage.index >= RideMapStage.confirmingQuote.index &&
        stage != RideMapStage.error) {
      polylines.add(routePolyline);
    }

    final cameraTarget = _buildCameraTarget(
      stage: stage,
      userLocation: userLocation,
      pickupLocation: pickupLocation,
      dropoffLocation: dropoffLocation,
      driverLocation: driverLocation,
    );

    return RideMapSnapshot(
      cameraTarget: cameraTarget,
      markers: markers,
      polylines: polylines,
    );
  }

  /// Convert the snapshot into the set of MapCommands that should be pushed
  /// to a MapPort implementation.
  static List<MapCommand> toCommands(RideMapSnapshot snapshot) {
    final commands = <MapCommand>[
      SetCameraCommand(snapshot.cameraTarget),
      SetMarkersCommand(snapshot.markers),
    ];

    if (snapshot.polylines.isNotEmpty) {
      commands.add(SetPolylinesCommand(snapshot.polylines));
    }

    return commands;
  }

  /// Convenience helper for integration with MapPort.
  static void pumpToPort({
    required RideMapSnapshot snapshot,
    required MapPort port,
  }) {
    for (final command in toCommands(snapshot)) {
      port.commands.add(command);
    }
  }

  static MapCameraTarget _buildCameraTarget({
    required RideMapStage stage,
    GeoPoint? userLocation,
    GeoPoint? pickupLocation,
    GeoPoint? dropoffLocation,
    GeoPoint? driverLocation,
  }) {
    final points = <GeoPoint>[];

    // Priority 1: pickup/dropoff/driver if available.
    if (pickupLocation != null) points.add(pickupLocation);
    if (dropoffLocation != null) points.add(dropoffLocation);

    // Driver location becomes important once we are waiting for / tracking driver.
    if (driverLocation != null &&
        stage.index >= RideMapStage.waitingForDriver.index &&
        stage != RideMapStage.completed &&
        stage != RideMapStage.error) {
      points.add(driverLocation);
    }

    // Fallback to user location.
    if (points.isEmpty && userLocation != null) {
      points.add(userLocation);
    }

    if (points.isEmpty) {
      // Last-resort fallback (0,0) – should not happen in real flows.
    return const MapCameraTarget(
      center: GeoPoint(0.0, 0.0),
      zoom: MapZoom(2.0),
    );
    }

    final center = _average(points);

    // Simple zoom heuristic:
    // - single point -> closer zoom
    // - multiple points -> slightly wider zoom
    final zoomValue = points.length == 1 ? 15.0 : 13.0;

    return MapCameraTarget(
      center: center,
      zoom: MapZoom(zoomValue),
    );
  }

  static GeoPoint _average(List<GeoPoint> points) {
    var lat = 0.0;
    var lng = 0.0;
    for (final p in points) {
      lat += p.latitude;
      lng += p.longitude;
    }
    return GeoPoint(
      lat / points.length,
      lng / points.length,
    );
  }
}

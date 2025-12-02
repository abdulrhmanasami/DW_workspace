/// Ride Map From Commands Widget - Track B Ticket #112
/// Purpose: Adapter widget to render RideMapCommands on legacy MapWidget
/// Created by: Track B - Ticket #112
/// Last updated: 2025-11-30
///
/// This widget bridges the pure Dart RideMapCommands model to the legacy
/// MapWidget interface used in the app. It handles the type conversion
/// between DWMap* types and legacy Map* types.
///
/// IMPORTANT:
/// - Does NOT import any SDK directly - only uses maps_shims
/// - Acts as a thin adapter layer between state and presentation
/// - Follows B-STYLE architecture rules

import 'package:flutter/material.dart';

// Shims only - no direct SDK imports
import 'package:maps_shims/maps_shims.dart';

// App imports
import '../state/mobility/ride_map_commands_builder.dart';

/// Widget that renders [RideMapCommands] using the legacy [MapWidget].
///
/// This adapter converts:
/// - [DWMapMarker] → [MapMarker]
/// - [DWMapPolyline] → [MapPolyline]
/// - [DWAnimateToBoundsCommand] bounds center → [LatLng] initialPosition
///
/// Track B - Ticket #112: Bridge RideMapCommands to Trip Confirmation and Active Trip.
class RideMapFromCommands extends StatelessWidget {
  const RideMapFromCommands({
    super.key,
    required this.commands,
    this.onMapCreated,
  });

  /// The map commands to render.
  final RideMapCommands commands;

  /// Optional callback when map is created (for controller access).
  final void Function(MapController)? onMapCreated;

  @override
  Widget build(BuildContext context) {
    // Convert DW types to legacy types
    final markers = _convertMarkers(commands.setContent.markers);
    final polylines = _convertPolylines(commands.setContent.polylines);
    final initialPosition = _calculateInitialPosition(commands);

    return MapWidget(
      initialPosition: initialPosition,
      markers: markers,
      polylines: polylines,
      onMapCreated: onMapCreated,
    );
  }

  /// Converts [DWMapMarker] list to [MapMarker] list.
  List<MapMarker> _convertMarkers(List<DWMapMarker> dwMarkers) {
    return dwMarkers.map((dwMarker) {
      return MapMarker(
        id: dwMarker.id,
        point: MapPoint(
          latitude: dwMarker.position.latitude,
          longitude: dwMarker.position.longitude,
        ),
        title: dwMarker.label,
      );
    }).toList();
  }

  /// Converts [DWMapPolyline] list to [MapPolyline] list.
  List<MapPolyline> _convertPolylines(List<DWMapPolyline> dwPolylines) {
    return dwPolylines.map((dwPolyline) {
      return MapPolyline(
        id: dwPolyline.id,
        points: dwPolyline.points
            .map((p) => LatLng(p.latitude, p.longitude))
            .toList(),
        width: 4.0, // Default route width
      );
    }).toList();
  }

  /// Calculates the initial camera position from commands.
  ///
  /// Priority:
  /// 1. Center of bounds (if animateToBounds is present)
  /// 2. First marker position
  /// 3. Default location (Riyadh)
  LatLng _calculateInitialPosition(RideMapCommands commands) {
    // If bounds animation is present, use bounds center
    if (commands.animateToBounds != null) {
      final bounds = commands.animateToBounds!.bounds;
      return LatLng(
        (bounds.southWest.latitude + bounds.northEast.latitude) / 2,
        (bounds.southWest.longitude + bounds.northEast.longitude) / 2,
      );
    }

    // Fallback to first marker position
    final markers = commands.setContent.markers;
    if (markers.isNotEmpty) {
      final firstMarker = markers.first;
      return LatLng(
        firstMarker.position.latitude,
        firstMarker.position.longitude,
      );
    }

    // Default: Riyadh, Saudi Arabia
    return const LatLng(24.7136, 46.6753);
  }
}

/// Placeholder widget shown when map commands are not available.
///
/// Track B - Ticket #112: Displays a skeleton/loading state instead of
/// a mock map when the state is not ready.
class RideMapPlaceholder extends StatelessWidget {
  const RideMapPlaceholder({
    super.key,
    this.message,
    this.showLoadingIndicator = true,
  });

  /// Optional message to display.
  final String? message;

  /// Whether to show a loading spinner.
  final bool showLoadingIndicator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showLoadingIndicator) ...[
              CircularProgressIndicator(
                color: colorScheme.primary,
                strokeWidth: 2,
              ),
              const SizedBox(height: 16),
            ],
            if (message != null)
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}


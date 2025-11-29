/// Component: Map View Interface - Unified Map Display
/// Created by: Cursor B-ux
/// Purpose: Neutral interface for map display widgets
/// Last updated: 2025-11-11

import 'package:flutter/widgets.dart';
import 'models.dart';
import 'legacy/aliases.dart' show MapController;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Callback when map is ready with controller
typedef OnMapReady = void Function(MapController controller);

/// Parameters for map view construction
class MapViewParams {
  final MapCamera initialCameraPosition;
  final OnMapReady onMapReady;

  const MapViewParams({
    required this.initialCameraPosition,
    required this.onMapReady,
  });
}

/// Builder function that returns appropriate map widget
typedef MapViewBuilder = Widget Function(MapViewParams params);

/// Provider for map view builder - must be overridden with concrete implementation
final mapViewBuilderProvider = Provider<MapViewBuilder>((ref) {
  throw UnimplementedError('MapViewBuilder is not provided');
});

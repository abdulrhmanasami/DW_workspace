/// Component: Maps Models
/// Created by: Cursor (auto-generated)
/// Purpose: Common models for maps operations
/// Last updated: 2025-11-01

import 'package:flutter/material.dart';
import 'map_controller.dart' show NoOpMapController;
import 'map_models.dart';
import 'legacy/aliases.dart' show MapController;

export 'map_models.dart';

/// Map style configuration
abstract class MapStyle {
  String get styleJson;
  String get name;
  bool get isDefault;
}

/// No-Op map widget for safe fallback when maps are not available
class MapWidget extends StatelessWidget {
  final LatLng initialPosition;
  final List<MapMarker> markers;
  final List<MapPolyline> polylines;
  final void Function(MapController)? onMapCreated;

  const MapWidget({
    super.key,
    required this.initialPosition,
    this.markers = const [],
    this.polylines = const [],
    this.onMapCreated,
  });

  @override
  Widget build(BuildContext context) {
    // Create No-Op controller and call callback
    final controller = NoOpMapController();
    onMapCreated?.call(controller);

    return Container(
      color: Colors.grey[200],
      child: const Center(child: Text('Maps not available')),
    );
  }
}

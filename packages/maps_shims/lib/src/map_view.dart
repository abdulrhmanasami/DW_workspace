/// Component: Map View
/// Created by: Cursor (auto-generated)
/// Purpose: Unified map view interface and props for cross-platform map rendering
/// Last updated: 2025-11-11

import 'package:flutter/material.dart';
import 'legacy/aliases.dart' show MapController;

/// Props for map view rendering
class MapViewProps {
  final MapController controller;
  final double? initialLatitude;
  final double? initialLongitude;
  final double? initialZoom;

  const MapViewProps({
    required this.controller,
    this.initialLatitude,
    this.initialLongitude,
    this.initialZoom,
  });
}

/// Unified map view widget that can be rendered by different adapters
class MapView extends StatelessWidget {
  static Widget Function(MapViewProps)? _builder;

  /// Register a builder function for map rendering (called by adapters)
  static void register(Widget Function(MapViewProps) builder) {
    _builder = builder;
  }

  /// Render the map using the registered builder
  static Widget render(MapViewProps props) {
    if (_builder == null) {
      // Return a placeholder if no builder is registered
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Text('Map not available - no adapter registered'),
        ),
      );
    }
    return _builder!(props);
  }

  final MapViewProps props;

  const MapView({super.key, required this.props});

  @override
  Widget build(BuildContext context) {
    return render(props);
  }
}

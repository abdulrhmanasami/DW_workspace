import 'package:flutter/material.dart';

import 'map_models.dart';

/// Placeholder map widget that renders marker metadata while native map
/// integrations are stubbed out in the canonical package.
class MapViewWidget extends StatelessWidget {
  final List<MapMarker> markers;
  final MapCamera camera;

  const MapViewWidget({super.key, required this.markers, required this.camera});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey.shade100,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.map, size: 48),
          Text(
            'Map center: '
            '${camera.target.latitude.toStringAsFixed(4)}, '
            '${camera.target.longitude.toStringAsFixed(4)}',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text('Markers: ${markers.length}'),
          if (markers.isNotEmpty)
            ...markers.take(3).map(
              (marker) => Text(
                '${marker.title ?? marker.id}: '
                '${marker.point.latitude.toStringAsFixed(4)}, '
                '${marker.point.longitude.toStringAsFixed(4)}',
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

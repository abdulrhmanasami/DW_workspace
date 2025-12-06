library maps_stub_impl;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maps_shims/maps.dart';

/// Stub MapViewBuilder that shows a placeholder when maps are disabled
Widget stubMapViewBuilder(MapViewParams params) {
  return Container(
    color: Colors.grey[200],
    child: const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'خريطة غير متاحة حالياً',
            style: TextStyle(fontSize: 18, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'الخدمة معطلة مؤقتاً',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

/// Stub MapViewBuilder provider
final stubMapViewBuilderProvider = Provider<MapViewBuilder>((ref) {
  return stubMapViewBuilder;
});

class StubMapController implements MapController {
  @override
  Future<void> moveCamera(MapCamera camera) async {}

  @override
  Future<void> setMarkers(List<MapMarker> markers) async {}

  @override
  Future<void> setPolylines(List<MapPolyline> polylines) async {}

  @override
  void dispose() {}
}

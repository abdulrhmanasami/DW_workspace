/// Component: Polyline Manager
/// Created by: Cursor (auto-generated)
/// Purpose: Interface for polyline management on maps
/// Last updated: 2025-10-24

import 'package:flutter/material.dart';
import 'models.dart' show LatLng;

abstract class PolylineManager {
  Future<String> addPolyline({
    required String id,
    required List<LatLng> points,
    Color? color,
    double? width,
    bool? geodesic,
  });

  Future<void> removePolyline(String polylineId);
  Future<void> updatePolyline({
    required String polylineId,
    List<LatLng>? points,
    Color? color,
    double? width,
    bool? geodesic,
  });

  Future<void> clearAllPolylines();
}

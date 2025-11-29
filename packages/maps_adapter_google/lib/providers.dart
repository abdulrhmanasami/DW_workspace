// Re-export the view builder provider
export 'google_map_view_builder.dart' show googleMapViewBuilderProvider;

/// Component: Google Maps Adapter Providers
/// Created by: Cursor B-ux
/// Purpose: Riverpod providers for Google Maps adapter
/// Last updated: 2025-11-11

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maps_shims/maps.dart';

/// Completer provider for Google Maps controller initialization
final googleMapControllerCompleterProvider = Provider<Completer<dynamic>>(
  (_) => Completer(),
);

/// Provider for Google Maps controller
final googleMapControllerProvider = Provider<MapController>((ref) {
  throw UnimplementedError('Provided by GoogleMapView on creation');
});

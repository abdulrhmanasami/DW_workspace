import 'package:maps_shims/maps.dart';
import 'package:mobility_shims/mobility.dart';

class TrackingMapState {
  final String? activeTripId;
  final LocationPoint? lastPoint;
  final List<MapMarker> markers;

  const TrackingMapState({
    this.activeTripId,
    this.lastPoint,
    this.markers = const [],
  });

  TrackingMapState copyWith({
    String? activeTripId,
    LocationPoint? lastPoint,
    List<MapMarker>? markers,
  }) => TrackingMapState(
    activeTripId: activeTripId ?? this.activeTripId,
    lastPoint: lastPoint ?? this.lastPoint,
    markers: markers ?? this.markers,
  );
}

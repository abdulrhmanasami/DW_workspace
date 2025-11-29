import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maps_shims/maps.dart' show MapCamera, MapController, MapMarker, MapPoint;
import 'package:mobility_shims/mobility.dart';
import '../infra/mobility_providers.dart' show mapControllerProvider, tripRecorderProvider;
import 'tracking_map_state.dart';

class TrackingMapController extends StateNotifier<TrackingMapState> {
  final TripRecorder _recorder;
  final MapController _map;
  StreamSubscription<LocationPoint>? _sub;

  TrackingMapController(this._recorder, this._map)
    : super(const TrackingMapState());

  Future<void> begin(String tripId) async {
    state = state.copyWith(activeTripId: tripId);
    await _recorder.beginTrip(tripId);
    _sub = _recorder.points.listen((point) async {
      final marker = MapMarker(
        id: 'last',
        point: MapPoint(
          latitude: point.latitude,
          longitude: point.longitude,
        ),
        title: 'Current Location',
        snippet: 'Live tracking',
      );
      await _map.moveCamera(
        MapCamera(
          target: MapPoint(
            latitude: point.latitude,
            longitude: point.longitude,
          ),
          zoom: 14,
        ),
      );
      state = state.copyWith(lastPoint: point, markers: [marker]);
    });
  }

  Future<void> end() async {
    await _sub?.cancel();
    if (state.activeTripId != null) {
      await _recorder.endTrip();
    }
    state = const TrackingMapState();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final trackingMapProvider =
    StateNotifierProvider<TrackingMapController, TrackingMapState>((ref) {
      final rec = ref.read(tripRecorderProvider);
      final map = ref.read(mapControllerProvider);
      return TrackingMapController(rec, map);
    });

import 'models.dart';

abstract class RouteCalculator {
  Future<RouteData> calculateRoute({
    required LatLng origin,
    required LatLng destination,
    List<LatLng>? waypoints,
    RouteMode? mode,
    bool avoidTolls = false,
    bool avoidHighways = false,
  });

  Stream<RouteData> get routeStream;
}

enum RouteMode { driving, walking, cycling, transit }

class RouteData {
  final String polyline;
  final List<RouteStep> steps;
  final Duration duration;
  final double distance;
  final List<LatLng> points;

  const RouteData({
    required this.polyline,
    required this.steps,
    required this.duration,
    required this.distance,
    required this.points,
  });
}

class RouteStep {
  final String instruction;
  final double distance;
  final Duration duration;
  final LatLng startLocation;
  final LatLng endLocation;

  const RouteStep({
    required this.instruction,
    required this.distance,
    required this.duration,
    required this.startLocation,
    required this.endLocation,
  });
}

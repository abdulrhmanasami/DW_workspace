class GeoPoint {
  final double lat;
  final double lng;
  const GeoPoint(this.lat, this.lng);
}

class TripData {
  final String id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final List<GeoPoint> path;
  const TripData({
    required this.id,
    required this.startedAt,
    this.endedAt,
    this.path = const [],
  });
}

class LatLng {
  final double latitude;
  final double longitude;
  const LatLng(this.latitude, this.longitude);
}

class MarkerId {
  final String value;
  const MarkerId(this.value);
}

class Marker {
  final MarkerId markerId;
  final LatLng position;
  final String? infoWindow;
  const Marker({
    required this.markerId,
    required this.position,
    this.infoWindow,
  });
}

class PolylineId {
  final String value;
  const PolylineId(this.value);
}

class Polyline {
  final PolylineId polylineId;
  final List<LatLng> points;
  const Polyline({required this.polylineId, required this.points});
}

enum MapType { normal, satellite, terrain, hybrid }

class CameraPosition {
  final LatLng target;
  final double zoom;
  const CameraPosition({required this.target, this.zoom = 14});
}

enum CameraUpdateType { newLatLng, newLatLngZoom, newBounds }

class CameraUpdate {
  final CameraUpdateType type;
  final LatLng? target;
  final double? zoom;
  final List<LatLng>? bounds; // [southWest, northEast]

  const CameraUpdate._(this.type, {this.target, this.zoom, this.bounds});

  factory CameraUpdate.newLatLng(LatLng target) =>
      CameraUpdate._(CameraUpdateType.newLatLng, target: target);

  factory CameraUpdate.newLatLngZoom(LatLng target, double zoom) =>
      CameraUpdate._(
        CameraUpdateType.newLatLngZoom,
        target: target,
        zoom: zoom,
      );

  factory CameraUpdate.newBounds(LatLng southWest, LatLng northEast) =>
      CameraUpdate._(
        CameraUpdateType.newBounds,
        bounds: [southWest, northEast],
      );
}

class LatLngBounds {
  final LatLng southwest;
  final LatLng northeast;
  const LatLngBounds(this.southwest, this.northeast);
}

class MapCameraPosition {
  final LatLng target;
  final double zoom;
  const MapCameraPosition({required this.target, this.zoom = 14});
}

class MapMarker {
  final String id;
  final LatLng position;
  final String? title;
  final String? snippet;
  const MapMarker({
    required this.id,
    required this.position,
    this.title,
    this.snippet,
  });
}

class MapPolyline {
  final String id;
  final List<LatLng> points;
  const MapPolyline({required this.id, required this.points});
}

class MapPolygon {
  final String id;
  final List<LatLng> points;
  const MapPolygon({required this.id, required this.points});
}

class MapCircle {
  final String id;
  final LatLng center;
  final double radiusMeters;
  const MapCircle({
    required this.id,
    required this.center,
    required this.radiusMeters,
  });
}

enum MapStyle { standard, dark, light, satellite }

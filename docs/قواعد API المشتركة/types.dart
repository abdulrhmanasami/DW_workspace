// Core domain types for mobility shims — عقد فقط، بدون أي SDK

import '../location/models.dart';

class TripPoint {
  final String tripId;
  final LocationPoint location;
  const TripPoint({required this.tripId, required this.location});
}

enum TripEventType { started, stopped, pointAdded, error }

class TripEvent {
  final TripEventType type;
  final String tripId;
  final Object? data;
  const TripEvent({required this.type, required this.tripId, this.data});
}

class TripConfig {
  final bool highAccuracy;
  final Duration? minInterval;
  final double? minDistanceMeters;
  const TripConfig({
    this.highAccuracy = false,
    this.minInterval,
    this.minDistanceMeters,
  });
}

class BackgroundNotificationConfig {
  final String? title;
  final String? text;
  const BackgroundNotificationConfig({this.title, this.text});
}

class Geofence {
  final String id;
  final LocationPoint center;
  final double radiusMeters;
  const Geofence({
    required this.id,
    required this.center,
    required this.radiusMeters,
  });
}

enum GeofenceEventType { enter, exit, dwell }

class GeofenceEvent {
  final String id;
  final GeofenceEventType type;
  final DateTime? timestamp;
  final LocationPoint? location;
  const GeofenceEvent({
    required this.id,
    required this.type,
    this.timestamp,
    this.location,
  });
}

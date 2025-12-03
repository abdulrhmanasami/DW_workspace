/// Map Port Interface - Reactive Interface Between App and Map
/// Track B - Ticket #198: MapInterface تفاعلي (Streams/Sinks) + Stub Implementation
/// Purpose: Define the canonical reactive map interface using Streams/Sinks

import 'dart:async';

import 'map_events.dart';
import 'map_commands.dart';

/// Reactive port between the app (Ride/Parcels/Food flows) and the map implementation.
///
/// This is the **single source of truth** for map integration in the DW app.
/// Any map implementation (Google Maps, Mapbox, stub) must implement this.
///
/// ## Architecture (per Manus recommendations)
///
/// Uses a **reactive** approach with Streams/Sinks:
/// - [commands]: App sends commands **to** the map (Sink).
/// - [events]: Map sends events **to** the app (Stream).
///
/// This avoids leaky abstractions and enables:
/// - Easy mocking in tests.
/// - Swappable implementations.
/// - Clear separation of concerns.
///
/// ## Pure Dart
///
/// This interface has **no Flutter dependencies** and can be implemented
/// purely in Dart. Widget integration is handled separately.
///
/// ## Usage
///
/// ```dart
/// // Send command
/// port.commands.add(SetCameraCommand(target));
///
/// // Listen to events
/// port.events.listen((event) {
///   if (event is MarkerTappedEvent) {
///     // handle marker tap
///   }
/// });
/// ```
abstract class MapPort {
  /// Commands from app → map implementation.
  ///
  /// Use this sink to send instructions to the map:
  /// - [SetCameraCommand] to move camera
  /// - [FitBoundsCommand] to fit bounds
  /// - [SetMarkersCommand] to set markers
  /// - [SetPolylinesCommand] to set polylines
  Sink<MapCommand> get commands;

  /// Events from map implementation → app.
  ///
  /// Listen to this stream for user interactions:
  /// - [MarkerTappedEvent] when user taps a marker
  /// - [MapTappedEvent] when user taps the map
  /// - [CameraMovedEvent] when camera animation finishes
  /// - [MapReadyEvent] when map is initialized
  Stream<MapEvent> get events;

  /// Dispose of resources.
  ///
  /// Call this when the map is no longer needed to clean up streams.
  void dispose();
}

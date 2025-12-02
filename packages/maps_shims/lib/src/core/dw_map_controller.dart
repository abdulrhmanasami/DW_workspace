/// DW Map Shims - Core Map Controller Interface
/// Track B - Ticket #109: Pure Dart Map Shim v1
/// Purpose: Define the canonical map interface using Streams/Sinks

import 'dart:async';

import 'dw_map_commands.dart';
import 'dw_map_events.dart';

/// Core Map interface exposed by maps_shims.
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
/// controller.commands.add(DWSetContentCommand(...));
///
/// // Listen to events
/// controller.events.listen((event) {
///   if (event is DWMarkerTappedEvent) {
///     // handle marker tap
///   }
/// });
/// ```
abstract class DWMapController {
  /// Commands from app → map implementation.
  ///
  /// Use this sink to send instructions to the map:
  /// - [DWSetContentCommand] to set markers/polylines
  /// - [DWAnimateToBoundsCommand] to fit bounds
  /// - [DWAnimateToPositionCommand] to move camera
  /// - [DWClearCommand] to clear all overlays
  Sink<DWMapCommand> get commands;

  /// Events from map implementation → app.
  ///
  /// Listen to this stream for user interactions:
  /// - [DWMarkerTappedEvent] when user taps a marker
  /// - [DWMapTappedEvent] when user taps the map
  /// - [DWCameraMovedEvent] when camera animation finishes
  /// - [DWMapReadyEvent] when map is initialized
  Stream<DWMapEvent> get events;

  /// Dispose of resources.
  ///
  /// Call this when the map is no longer needed to clean up streams.
  void dispose();
}


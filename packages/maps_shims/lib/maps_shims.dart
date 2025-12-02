// Maps Shims - Main Library Export
// Created by: Cursor B-mobility
// Purpose: Unified export for maps shims package
// Last updated: 2025-11-30
// Updated by: Track B - Ticket #109 (DW Map Shim v1 with Streams/Sinks)

// =============================================================================
// Track B - Ticket #109: New Pure Dart Map Shim v1 (Streams/Sinks)
// =============================================================================

// Core types (Pure Dart - no Flutter dependencies)
export 'src/core/dw_lat_lng.dart' show DWLatLng, DWLatLngBounds;
export 'src/core/dw_map_marker.dart' show DWMapMarker, DWMapMarkerType;
export 'src/core/dw_map_polyline.dart' show DWMapPolyline, DWMapPolylineStyle;
export 'src/core/dw_map_camera.dart' show DWMapCameraPosition;

// Commands & Events (Pure Dart - no Flutter dependencies)
export 'src/core/dw_map_commands.dart'
    show
        DWMapCommand,
        DWSetContentCommand,
        DWAnimateToBoundsCommand,
        DWAnimateToPositionCommand,
        DWClearCommand;
export 'src/core/dw_map_events.dart'
    show
        DWMapEvent,
        DWMarkerTappedEvent,
        DWCameraMovedEvent,
        DWMapTappedEvent,
        DWMapReadyEvent,
        DWCameraMoveStartedEvent;

// Core controller interface (Pure Dart - no Flutter dependencies)
export 'src/core/dw_map_controller.dart' show DWMapController;

// Testing implementation (Pure Dart - no Flutter dependencies)
export 'src/testing/in_memory_map_controller.dart' show InMemoryMapController;

// =============================================================================
// Legacy exports (existing implementation - may have Flutter dependencies)
// =============================================================================

export 'src/map_models.dart'
    show
        LatLng,
        MapMarker,
        MapPolyline,
        MapConfig,
        MapCamera,
        CameraPosition,
        LatLngBounds;
export 'src/models.dart' show MapStyle, MapWidget;
export 'src/geo_types.dart' show MapPoint, MapMobilityConverters;
export 'src/geo_adapters.dart' show GeoAdapters;
export 'src/map_providers.dart' show mapControllerProvider;
export 'src/maps_contracts.dart' show MapViewController;
export 'src/map_controller.dart' show NoOpMapController;
export 'src/legacy/aliases.dart'
    show GoogleLatLng, MapLatLng, LatLngCompat, MapController;
export 'src/marker_manager.dart' show MarkerManager, MarkerOptions;
export 'src/polyline_manager.dart' show PolylineManager, PolylineOptions;
export 'src/route_calculator.dart' show RouteCalculator, RouteSegment;
export 'src/map_style_manager.dart' show MapStyleManager;
export 'src/map_view_widget.dart' show MapView, OnMapTap;
export 'src/view.dart'
    show MapViewParams, MapViewBuilder, OnMapReady, mapViewBuilderProvider;

// Maps Shims - Main Library Export
// Created by: Cursor B-mobility
// Purpose: Unified export for maps shims package
// Last updated: 2025-11-11

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

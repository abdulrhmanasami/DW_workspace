// Mobility Shims - Main Library Export
// Created by: Cursor B-mobility
// Purpose: Unified export for mobility shims package
// Last updated: 2025-11-14

// Primary API - New contracts and models
export 'src/contracts.dart';
export 'src/providers.dart';
export 'src/background_contracts.dart'
    show TrackingStatus, TrackingSessionState;
export 'src/types.dart' show TripPoint, GeofenceEvent, Geofence, GeofenceEventType;

// Location data types
export 'src/location_contracts.dart' show LocationPermissionService;
export 'location/models.dart'
    show LocationPoint, PositionFix, PositionSettings, LocationPermission;
export 'location/location_source.dart' show LocationSource;

// Stub implementations for safe fallbacks
export 'src/impl/stub_impl.dart' show StubLocationProvider, StubBackgroundTracker;
export 'src/location_permission_service.dart' show NoOpLocationPermissionService;

// Legacy compatibility (selective exports to avoid conflicts)
// Note: These may be removed in future versions - use new API above
export 'src/background_tracking_controller.dart'
    show BackgroundTrackingController, NoOpBackgroundTrackingController;
export 'src/geofence_manager.dart'
    show GeofenceManager, NoOpGeofenceManager;
export 'src/geolocation_port.dart';
export 'src/location_service.dart'
    show LocationService, NoOpLocationService;
export 'src/trips_contracts.dart';

// Ride Trip FSM - canonical state machine for ride lifecycle
export 'src/ride_trip_fsm.dart';

// Ride Quote - pricing/quote domain models and service
export 'src/ride_quote_models.dart';
export 'src/ride_quote_service.dart';

// Place models for ride booking flow (Track B - Ticket #20)
export 'src/place_models.dart';

// Ride Pricing Service - Track B Ticket #27: MockPricingService Stub
export 'src/pricing/ride_pricing_service.dart';
export 'src/pricing/mock_ride_pricing_service.dart';

// Ride Map Configuration - Track B Ticket #28: Map Shim for Ride
export 'src/ride_map/ride_map_config.dart';

// Recent Locations Repository - Track B Ticket #145: Real Recent Locations
export 'src/recent_locations/recent_locations_repository.dart';

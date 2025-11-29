library mobility_shims;

/// Canonical mobility contracts - single source of truth
export 'src/location_contracts.dart' show LocationPermissionService;
export 'location/models.dart'
    show LocationPoint, PositionFix, PositionSettings, LocationPermission;
export 'location/location_source.dart' show LocationSource;
export 'src/types.dart' show TripPoint, GeofenceEvent, Geofence, GeofenceEventType;
export 'src/contracts.dart' show LocationProvider, BackgroundTracker;
export 'src/contracts.dart'
    show
        TrackingDisabledException,
        ConsentDeniedException,
        PermissionDeniedException;
export 'src/background_contracts.dart'
    show PermissionStatus, TrackingStatus, TrackingSessionState;
export 'src/geofence_contracts.dart' show GeofenceManager, GeofenceRegion, GeofenceConfig;
export 'src/trips_contracts.dart';
export 'src/providers.dart'
    show
        mobilityConfigProvider,
        consentBackgroundLocationProvider,
        locationProvider,
        backgroundTrackerProvider;
export 'src/background_tracking_controller.dart'
    show BackgroundTrackingController, NoOpBackgroundTrackingController;

// Ride Trip FSM - canonical state machine for ride lifecycle
export 'src/ride_trip_fsm.dart';

// Ride Quote - pricing/quote domain models and service
export 'src/ride_quote_models.dart';
export 'src/ride_quote_service.dart';

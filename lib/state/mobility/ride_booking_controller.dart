/// Ride Booking Controller - Track B Ticket #242
/// Purpose: State management for ride booking UI
/// Created by: Track B - Ticket #242
/// Updated by: Track B - Ticket B-3 (Driver simulation & location tracking)
/// Updated by: Track B - Ticket B-4 (ETA calculation & driver enhancements)
/// Last updated: 2025-12-05
///
/// Controller that manages ride booking state and coordinates
/// with RideRepository for business operations.
///
/// Track B - Ticket B-3: Added driver location simulation for real-time
/// tracking visualization during the ride lifecycle.
/// Track B - Ticket B-4: Added dynamic ETA calculation and driver rating.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maps_shims/maps_shims.dart';
import 'package:mobility_shims/mobility_shims.dart' as mobility;

import 'ride_booking_state.dart';
import 'ride_pricing_service_stub.dart';

/// Controller for ride booking operations.
///
/// This controller manages the UI state for ride booking and coordinates
/// with the RideRepository for all business operations. It handles
/// loading states, error handling, and state transitions.
///
/// Track B - Ticket B-3: Added driver location simulation for real-time
/// tracking during the ride lifecycle.
class RideBookingController extends StateNotifier<RideBookingState> {
  /// Creates a ride booking controller with the given repository.
  RideBookingController(this._rideRepository, this._locationProvider, this._pricingService)
      : super(RideBookingState.initial());

  final mobility.RideRepository _rideRepository;
  final mobility.LocationProvider _locationProvider;
  final mobility.RidePricingService _pricingService;

  /// Track B - Ticket B-3: Timer for driver location updates.
  Timer? _driverLocationTimer;

  /// Track B - Ticket B-4: Custom mounted flag for lifecycle tracking.
  /// StateNotifier doesn't have a built-in mounted property like Flutter's State.
  bool _isMounted = true;

  /// Track B - Ticket B-3: Clean up resources when controller is disposed.
  @override
  void dispose() {
    _isMounted = false;
    _driverLocationTimer?.cancel();
    super.dispose();
  }

  /// Starts a new ride booking request.
  ///
  /// If there's already an active request, this will replace it.
  /// If [initialPickup] is provided, it will be set as the pickup location.
  Future<void> startNewRide({mobility.MobilityPlace? initialPickup}) async {
    state = state.copyWith(
      uiStatus: RideBookingUiStatus.loading,
      clearError: true,
    );

    try {
    final draft = _rideRepository.createDraft(
      initialPickup: initialPickup,
    );

    state = RideBookingState(
      rideId: draft.id,
      ride: draft,
      uiStatus: RideBookingUiStatus.idle,
    );
    } catch (e) {
      state = state.copyWith(
        uiStatus: RideBookingUiStatus.error,
        errorMessage: 'ride_start_failed',
      );
    }
  }

  /// Initializes the ride booking by getting the user's current location.
  ///
  /// This should be called when the ride booking screen opens.
  /// It will start a new ride and set the pickup location to current location.
  Future<void> initialize() async {
    state = state.copyWith(uiStatus: RideBookingUiStatus.loading, clearError: true);

    try {
      // Get current location
      final currentLocation = await _locationProvider.getCurrent();
      final pickupPlace = mobility.MobilityPlace(
        label: 'Current Location',
        type: mobility.MobilityPlaceType.currentLocation,
        location: currentLocation,
      );

      // Start new ride with current location as pickup
      final draft = _rideRepository.createDraft(initialPickup: pickupPlace);

      state = RideBookingState(
        rideId: draft.id,
        ride: draft,
        uiStatus: RideBookingUiStatus.idle,
      );
    } catch (e) {
      // If location fails, start with empty ride
      final draft = _rideRepository.createDraft();

      state = RideBookingState(
        rideId: draft.id,
        ride: draft,
        uiStatus: RideBookingUiStatus.idle,
        errorMessage: 'failed_to_get_location',
      );
    }
  }

  /// Updates the pickup location for the current request.
  ///
  /// If no current request exists, automatically starts a new one.
  Future<void> updatePickup(mobility.MobilityPlace pickup) async {
    if (state.ride == null) return;
    state = state.copyWith(uiStatus: RideBookingUiStatus.loading, clearError: true);

    try {
    final updated = _rideRepository.updateLocations(
        request: state.ride!,
      pickup: pickup,
        destination: state.ride!.destination,
    );

    state = state.copyWith(
      ride: updated,
      uiStatus: RideBookingUiStatus.idle,
      );
    } catch (e) {
      state = state.copyWith(
        uiStatus: RideBookingUiStatus.error,
        errorMessage: 'update_pickup_failed',
    );
    }
  }

  /// Updates the destination location for the current request.
  ///
  /// If no current request exists, automatically starts a new one.
  Future<void> updateDestination(mobility.MobilityPlace destination) async {
    if (state.ride == null) return;
    state = state.copyWith(uiStatus: RideBookingUiStatus.loading, clearError: true);

    try {
      final updated = _rideRepository.updateLocations(
          request: state.ride!,
          pickup: state.ride!.pickup,
        destination: destination,
      );

      // Update the state with new destination
      state = state.copyWith(
        ride: updated,
        uiStatus: RideBookingUiStatus.idle,
      );

      // Fetch route and quotes if both locations are available
      if (updated.hasValidLocations) {
        await _fetchRouteAndQuotes(updated.pickup!, updated.destination!);
      }
    } catch (e) {
      state = state.copyWith(
        uiStatus: RideBookingUiStatus.error,
        errorMessage: 'update_destination_failed',
      );
    }
  }

  /// Requests a quote for the current request if possible.
  ///
  /// This will fail if:
  /// - No current request exists
  /// - Locations are not complete
  /// - Request is not in draft status
  Future<void> requestQuoteIfPossible() async {
    if (!state.canRequestQuote) {
      state = state.copyWith(
        uiStatus: RideBookingUiStatus.error,
        errorMessage: 'quote_not_allowed',
      );
      return;
    }

    state = state.copyWith(
      uiStatus: RideBookingUiStatus.loading,
      clearError: true,
    );

    try {
      final quotedRequest = await _rideRepository.requestQuote(state.ride!);
      state = state.copyWith(
        ride: quotedRequest,
        uiStatus: RideBookingUiStatus.idle,
      );
    } on ArgumentError {
      state = state.copyWith(
        uiStatus: RideBookingUiStatus.error,
        errorMessage: 'quote_argument_error',
      );
    } catch (e) {
      state = state.copyWith(
        uiStatus: RideBookingUiStatus.error,
        errorMessage: 'quote_failed',
      );
    }
  }

  /// Confirms the current ride request.
  ///
  /// This will transition the request to findingDriver status.
  /// Requires that a quote has been successfully obtained.
  Future<void> confirmRide() async {
    if (!state.canConfirmRide) {
      state = state.copyWith(
        uiStatus: RideBookingUiStatus.error,
        errorMessage: 'confirm_not_allowed',
      );
      return;
    }

    state = state.copyWith(
      uiStatus: RideBookingUiStatus.loading,
      clearError: true,
    );

    try {
      final confirmedRequest = await _rideRepository.confirmRide(state.ride!);
      state = state.copyWith(
        ride: confirmedRequest,
        uiStatus: RideBookingUiStatus.idle,
      );
    } on ArgumentError {
      state = state.copyWith(
        uiStatus: RideBookingUiStatus.error,
        errorMessage: 'confirm_argument_error',
      );
    } catch (e) {
      state = state.copyWith(
        uiStatus: RideBookingUiStatus.error,
        errorMessage: 'confirm_failed',
      );
    }
  }

  /// Cancels the current ride request if possible.
  ///
  /// This will only work for requests that are still cancellable
  /// (not inProgress or later stages).
  Future<void> cancelRide() async {
    if (!state.canCancel || state.ride == null) {
      state = state.copyWith(
        uiStatus: RideBookingUiStatus.error,
        errorMessage: 'cancel_not_allowed',
      );
      return;
    }

    state = state.copyWith(uiStatus: RideBookingUiStatus.loading, clearError: true);

    try {
      final cancelled = _rideRepository.cancelRide(state.ride!);

      state = state.copyWith(
        ride: cancelled,
        uiStatus: RideBookingUiStatus.idle,
      );
    } on mobility.InvalidRideTransitionException {
      state = state.copyWith(
        uiStatus: RideBookingUiStatus.error,
        errorMessage: 'cancel_invalid_transition',
      );
    } catch (e) {
      state = state.copyWith(
        uiStatus: RideBookingUiStatus.error,
        errorMessage: 'cancel_failed',
      );
    }
  }

  /// Fetches route polylines and pricing quotes for the given locations.
  ///
  /// This is called automatically when both pickup and destination are set.
  Future<void> _fetchRouteAndQuotes(mobility.MobilityPlace pickup, mobility.MobilityPlace destination) async {
    // Set loading state for route and quotes
    state = state.copyWith(uiStatus: RideBookingUiStatus.loading, clearError: true);

    try {
      // Get quotes from pricing service
      final quotes = await _pricingService.quoteRide(
        pickup: pickup,
        destination: destination,
        serviceType: mobility.RideServiceType.ride, // Generic ride type to get all options
      );

      // Create simple polyline between pickup and destination
      final polylines = _createSimpleRoutePolyline(pickup, destination);

      state = state.copyWith(
        polylines: polylines,
        quotes: quotes,
        uiStatus: RideBookingUiStatus.idle,
      );
    } catch (e) {
      state = state.copyWith(
        uiStatus: RideBookingUiStatus.error,
        errorMessage: 'fetch_route_quotes_failed',
      );
    }
  }

  /// Creates a simple straight-line polyline between pickup and destination.
  ///
  /// For MVP, we use a simple straight line. In production, this would
  /// come from a routing service.
  List<MapPolyline> _createSimpleRoutePolyline(mobility.MobilityPlace pickup, mobility.MobilityPlace destination) {
    if (pickup.location == null || destination.location == null) {
      return [];
    }

    final pickupPoint = GeoPoint(
      pickup.location!.latitude,
      pickup.location!.longitude,
    );

    final destinationPoint = GeoPoint(
      destination.location!.latitude,
      destination.location!.longitude,
    );

    final polyline = MapPolyline(
      id: const MapPolylineId('route'),
      points: [pickupPoint, destinationPoint],
    );

    return [polyline];
  }

  /// Selects a ride quote option.
  ///
  /// This updates the selected quote in the state for UI display.
  void selectQuote(mobility.RideQuoteOption quoteOption) {
    state = state.copyWith(selectedQuote: quoteOption);
  }

  /// Simulates the driver matching process for the current ride.
  ///
  /// This is a stub implementation that simulates:
  /// 1. Finding a driver (3-5 seconds)
  /// 2. Driver accepting the trip
  /// 3. Driver arriving at pickup (with location updates)
  /// 4. Trip starting (in progress)
  ///
  /// In production, these transitions would come from backend events.
  /// Track B - Ticket B-3: Driver Matching Simulation with location updates.
  Future<void> simulateDriverMatch() async {
    if (state.status != mobility.RideStatus.findingDriver) {
      // Only simulate when in findingDriver state
      return;
    }

    // Simulate finding driver (3-5 seconds)
    await Future<void>.delayed(const Duration(seconds: 3));
    
    // Check if still in findingDriver (user might have cancelled)
    if (state.status != mobility.RideStatus.findingDriver || state.ride == null) {
      return;
    }

    // Transition to driverAccepted with driver info
    final driverAccepted = _rideRepository.applyStatusUpdate(
      current: state.ride!,
      newStatus: mobility.RideStatus.driverAccepted,
    );
    
    // Track B - Ticket B-3 & B-4: Set driver info when driver accepts
    state = state.copyWith(
      ride: driverAccepted,
      driverName: 'سامي المحمد', // Mock driver name
      driverCarInfo: 'Toyota Camry • أ ب ت ١٢٣٤', // Mock car info
      driverRating: 4.8, // Track B-4: Mock driver rating
      driverAvatarUrl: null, // Track B-4: No avatar for now, will use placeholder
      estimatedMinutesAway: 5, // Track B-4: Initial ETA
    );

    // Track B - Ticket B-3: Start driver location simulation
    _startDriverLocationSimulation();

    // Simulate driver en route (5 seconds for more realistic experience)
    await Future<void>.delayed(const Duration(seconds: 5));
    
    if (state.status != mobility.RideStatus.driverAccepted || state.ride == null) {
      return;
    }

    // Transition to driverArrived
    final driverArrived = _rideRepository.applyStatusUpdate(
      current: state.ride!,
      newStatus: mobility.RideStatus.driverArrived,
    );
    state = state.copyWith(ride: driverArrived);

    // Stop location simulation when arrived
    _driverLocationTimer?.cancel();

    // Simulate pickup (2 seconds)
    await Future<void>.delayed(const Duration(seconds: 2));
    
    if (state.status != mobility.RideStatus.driverArrived || state.ride == null) {
      return;
    }

    // Transition to inProgress
    final inProgress = _rideRepository.applyStatusUpdate(
      current: state.ride!,
      newStatus: mobility.RideStatus.inProgress,
    );
    state = state.copyWith(ride: inProgress);

    // Track B - Ticket B-3: Start location simulation for trip progress
    _startTripProgressSimulation();
  }

  /// Track B - Ticket B-3: Simulates driver moving towards pickup location.
  ///
  /// Creates a timer that updates driver location every second,
  /// moving the driver closer to the pickup point.
  void _startDriverLocationSimulation() {
    _driverLocationTimer?.cancel();

    final pickupLocation = state.ride?.pickup?.location;
    if (pickupLocation == null) return;

    // Start driver 0.01 degrees away (approximately 1km) from pickup
    double driverLat = pickupLocation.latitude + 0.008;
    double driverLng = pickupLocation.longitude + 0.006;

    // Update every 1 second, moving driver closer
    _driverLocationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isMounted || 
          state.status == mobility.RideStatus.cancelled ||
          state.status == mobility.RideStatus.driverArrived ||
          state.status == mobility.RideStatus.inProgress) {
        timer.cancel();
        return;
      }

      // Move driver 20% closer to pickup each tick
      driverLat = driverLat + (pickupLocation.latitude - driverLat) * 0.2;
      driverLng = driverLng + (pickupLocation.longitude - driverLng) * 0.2;

      // Track B - Ticket B-4: Calculate ETA based on distance
      final eta = _calculateEtaMinutes(
        driverLat: driverLat,
        driverLng: driverLng,
        targetLat: pickupLocation.latitude,
        targetLng: pickupLocation.longitude,
      );

      state = state.copyWith(
        driverLocation: mobility.LocationPoint(
          latitude: driverLat,
          longitude: driverLng,
        ),
        estimatedMinutesAway: eta,
      );
    });
  }

  /// Track B - Ticket B-3: Simulates driver moving towards destination during trip.
  ///
  /// Updates driver location to simulate movement from pickup to destination.
  void _startTripProgressSimulation() {
    _driverLocationTimer?.cancel();

    final pickupLocation = state.ride?.pickup?.location;
    final destinationLocation = state.ride?.destination?.location;
    if (pickupLocation == null || destinationLocation == null) return;

    // Start at pickup location
    double driverLat = pickupLocation.latitude;
    double driverLng = pickupLocation.longitude;

    // Update every 2 seconds, moving driver towards destination
    _driverLocationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_isMounted || 
          state.status == mobility.RideStatus.cancelled ||
          state.status == mobility.RideStatus.completed ||
          state.status == mobility.RideStatus.payment) {
        timer.cancel();
        return;
      }

      // Move driver 15% closer to destination each tick
      driverLat = driverLat + (destinationLocation.latitude - driverLat) * 0.15;
      driverLng = driverLng + (destinationLocation.longitude - driverLng) * 0.15;

      // Track B - Ticket B-4: Calculate ETA to destination during trip
      final eta = _calculateEtaMinutes(
        driverLat: driverLat,
        driverLng: driverLng,
        targetLat: destinationLocation.latitude,
        targetLng: destinationLocation.longitude,
      );

      state = state.copyWith(
        driverLocation: mobility.LocationPoint(
          latitude: driverLat,
          longitude: driverLng,
        ),
        estimatedMinutesAway: eta,
      );
    });
  }

  /// Track B - Ticket B-4: Calculates estimated time of arrival in minutes.
  ///
  /// Uses Haversine formula to calculate distance, then estimates time
  /// based on average urban driving speed (~30 km/h).
  int _calculateEtaMinutes({
    required double driverLat,
    required double driverLng,
    required double targetLat,
    required double targetLng,
  }) {
    // Calculate distance using Haversine formula
    const earthRadiusKm = 6371.0;
    final dLat = _degreesToRadians(targetLat - driverLat);
    final dLng = _degreesToRadians(targetLng - driverLng);
    
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(driverLat)) *
            math.cos(_degreesToRadians(targetLat)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final distanceKm = earthRadiusKm * c;

    // Estimate time based on average urban speed (30 km/h)
    const averageSpeedKmPerHour = 30.0;
    final timeHours = distanceKm / averageSpeedKmPerHour;
    final timeMinutes = (timeHours * 60).ceil();

    // Minimum 1 minute, maximum reasonable ETA
    return timeMinutes.clamp(1, 60);
  }

  /// Converts degrees to radians for Haversine calculation.
  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  /// Simulates trip completion.
  ///
  /// This transitions the ride from inProgress through payment to completed.
  /// Track B - Ticket B-3: Trip Completion Simulation with cleanup.
  Future<void> simulateTripCompletion() async {
    if (state.status != mobility.RideStatus.inProgress || state.ride == null) {
      return;
    }

    // Track B - Ticket B-3: Stop location simulation
    _driverLocationTimer?.cancel();

    // Transition to payment
    final payment = _rideRepository.applyStatusUpdate(
      current: state.ride!,
      newStatus: mobility.RideStatus.payment,
    );
    state = state.copyWith(ride: payment);

    // Simulate payment processing (1 second)
    await Future<void>.delayed(const Duration(seconds: 1));
    
    if (state.status != mobility.RideStatus.payment || state.ride == null) {
      return;
    }

    // Transition to completed
    final completed = _rideRepository.applyStatusUpdate(
      current: state.ride!,
      newStatus: mobility.RideStatus.completed,
    );
    state = state.copyWith(ride: completed);
  }

  /// Submits a rating for the current ride (1–5 stars) with optional comment.
  ///
  /// For now this is stored locally in [RideBookingState] only.
  /// In a future phase it can call a dedicated ratings repository shim.
  Future<void> submitRating({
    required int rating,
    String? comment,
  }) async {
    // Must have a completed ride to rate.
    if (state.ride == null || state.status != mobility.RideStatus.completed) {
      state = state.copyWith(
        uiStatus: RideBookingUiStatus.error,
        errorMessage: 'rating_not_allowed',
      );
      return;
    }

    // Basic validation on rating value.
    if (rating < 1 || rating > 5) {
      state = state.copyWith(
        uiStatus: RideBookingUiStatus.error,
        errorMessage: 'rating_invalid_value',
      );
      return;
    }

    // Local-only update; no backend call for now.
    state = state.copyWith(
      uiStatus: RideBookingUiStatus.loading,
      clearError: true,
    );

    try {
      // If we want async-feel without real IO.
      // await Future<void>.delayed(const Duration(milliseconds: 150));

      state = state.copyWith(
        uiStatus: RideBookingUiStatus.success,
        rating: rating,
        ratingComment: comment,
      );
    } catch (_) {
      state = state.copyWith(
        uiStatus: RideBookingUiStatus.error,
        errorMessage: 'rating_submit_failed',
      );
    }
  }

}

/// Riverpod providers for ride booking.

/// Provider for the ride repository implementation.
final rideRepositoryProvider = Provider<mobility.RideRepository>((ref) {
  // استخدم InMemoryRideRepository للآن، لحين ربط Backend حقيقي
  return mobility.InMemoryRideRepository();
});

/// Provider for the ride booking controller.
final rideBookingControllerProvider =
    StateNotifierProvider<RideBookingController, RideBookingState>((ref) {
  final repo = ref.watch(rideRepositoryProvider);
  final locationProviderInstance = ref.watch(mobility.locationProvider);
  // Use StubRidePricingService directly for now
  final pricingService = StubRidePricingService();
  return RideBookingController(repo, locationProviderInstance, pricingService);
});

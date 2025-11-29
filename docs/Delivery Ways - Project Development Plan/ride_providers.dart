import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Component: Ride State Providers
/// Created by: Track B - Ride Vertical Implementation
/// Purpose: State management for ride booking and tracking
/// Last updated: 2025-11-27

// ─────────────────────────────────────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────────────────────────────────────

/// Represents a location (pickup or destination)
class Location {
  final String address;
  final double latitude;
  final double longitude;

  const Location({
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}

/// Represents a ride option
class RideOption {
  final String id;
  final String name;
  final String description;
  final double estimatedFare;
  final int estimatedMinutes;
  final String vehicleType;

  const RideOption({
    required this.id,
    required this.name,
    required this.description,
    required this.estimatedFare,
    required this.estimatedMinutes,
    required this.vehicleType,
  });
}

/// Represents a ride booking
class RideBooking {
  final Location pickupLocation;
  final Location destinationLocation;
  final RideOption selectedRideOption;
  final DateTime bookingTime;

  const RideBooking({
    required this.pickupLocation,
    required this.destinationLocation,
    required this.selectedRideOption,
    required this.bookingTime,
  });
}

/// Represents trip status
enum TripStatus {
  idle,
  searching,
  driverAssigned,
  driverArriving,
  tripInProgress,
  completed,
  cancelled,
}

/// Represents a trip
class Trip {
  final String id;
  final RideBooking booking;
  final TripStatus status;
  final String? driverId;
  final String? driverName;
  final double? driverRating;
  final String? vehicleInfo;
  final Location? driverLocation;
  final int? estimatedArrivalMinutes;
  final double? totalFare;

  const Trip({
    required this.id,
    required this.booking,
    required this.status,
    this.driverId,
    this.driverName,
    this.driverRating,
    this.vehicleInfo,
    this.driverLocation,
    this.estimatedArrivalMinutes,
    this.totalFare,
  });

  Trip copyWith({
    String? id,
    RideBooking? booking,
    TripStatus? status,
    String? driverId,
    String? driverName,
    double? driverRating,
    String? vehicleInfo,
    Location? driverLocation,
    int? estimatedArrivalMinutes,
    double? totalFare,
  }) {
    return Trip(
      id: id ?? this.id,
      booking: booking ?? this.booking,
      status: status ?? this.status,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      driverRating: driverRating ?? this.driverRating,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      driverLocation: driverLocation ?? this.driverLocation,
      estimatedArrivalMinutes: estimatedArrivalMinutes ?? this.estimatedArrivalMinutes,
      totalFare: totalFare ?? this.totalFare,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// State Notifiers
// ─────────────────────────────────────────────────────────────────────────────

/// Manages ride booking state
class RideBookingNotifier extends StateNotifier<RideBooking?> {
  RideBookingNotifier() : super(null);

  void setPickupLocation(Location location) {
    if (state == null) return;
    state = RideBooking(
      pickupLocation: location,
      destinationLocation: state!.destinationLocation,
      selectedRideOption: state!.selectedRideOption,
      bookingTime: state!.bookingTime,
    );
  }

  void setDestinationLocation(Location location) {
    if (state == null) return;
    state = RideBooking(
      pickupLocation: state!.pickupLocation,
      destinationLocation: location,
      selectedRideOption: state!.selectedRideOption,
      bookingTime: state!.bookingTime,
    );
  }

  void setRideOption(RideOption option) {
    if (state == null) return;
    state = RideBooking(
      pickupLocation: state!.pickupLocation,
      destinationLocation: state!.destinationLocation,
      selectedRideOption: option,
      bookingTime: state!.bookingTime,
    );
  }

  void initializeBooking(Location pickup, Location destination) {
    state = RideBooking(
      pickupLocation: pickup,
      destinationLocation: destination,
      selectedRideOption: const RideOption(
        id: 'standard',
        name: 'Standard',
        description: 'Affordable and reliable',
        estimatedFare: 5.99,
        estimatedMinutes: 5,
        vehicleType: 'sedan',
      ),
      bookingTime: DateTime.now(),
    );
  }

  void clearBooking() {
    state = null;
  }
}

/// Manages active trip state
class TripNotifier extends StateNotifier<Trip?> {
  TripNotifier() : super(null);

  void setTrip(Trip trip) {
    state = trip;
  }

  void updateTripStatus(TripStatus status) {
    if (state == null) return;
    state = state!.copyWith(status: status);
  }

  void updateDriverLocation(Location location) {
    if (state == null) return;
    state = state!.copyWith(driverLocation: location);
  }

  void updateEstimatedArrival(int minutes) {
    if (state == null) return;
    state = state!.copyWith(estimatedArrivalMinutes: minutes);
  }

  void assignDriver(String driverId, String driverName, double rating, String vehicleInfo) {
    if (state == null) return;
    state = state!.copyWith(
      driverId: driverId,
      driverName: driverName,
      driverRating: rating,
      vehicleInfo: vehicleInfo,
      status: TripStatus.driverAssigned,
    );
  }

  void completeTrip(double totalFare) {
    if (state == null) return;
    state = state!.copyWith(
      status: TripStatus.completed,
      totalFare: totalFare,
    );
  }

  void cancelTrip() {
    if (state == null) return;
    state = state!.copyWith(status: TripStatus.cancelled);
  }

  void clearTrip() {
    state = null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Ride booking state provider
final rideBookingProvider = StateNotifierProvider<RideBookingNotifier, RideBooking?>((ref) {
  return RideBookingNotifier();
});

/// Active trip state provider
final tripProvider = StateNotifierProvider<TripNotifier, Trip?>((ref) {
  return TripNotifier();
});

/// Estimated fare provider (mock implementation)
final estimatedFareProvider = FutureProvider.family<double, (Location, Location)>((ref, locations) async {
  // Mock implementation: calculate fare based on distance
  final pickup = locations.$1;
  final destination = locations.$2;

  // Simple distance calculation (in production, use real distance API)
  final distance = _calculateDistance(
    pickup.latitude,
    pickup.longitude,
    destination.latitude,
    destination.longitude,
  );

  // Mock fare calculation: $2.50 base + $1.50 per km
  return 2.50 + (distance * 1.50);
});

/// Available ride options provider (mock implementation)
final rideOptionsProvider = FutureProvider.family<List<RideOption>, (Location, Location)>((ref, locations) async {
  // Mock implementation: return standard ride options
  return [
    const RideOption(
      id: 'standard',
      name: 'Standard',
      description: 'Affordable and reliable',
      estimatedFare: 5.99,
      estimatedMinutes: 5,
      vehicleType: 'sedan',
    ),
    const RideOption(
      id: 'premium',
      name: 'Premium',
      description: 'Premium comfort',
      estimatedFare: 8.99,
      estimatedMinutes: 7,
      vehicleType: 'suv',
    ),
    const RideOption(
      id: 'xl',
      name: 'XL',
      description: 'For larger groups',
      estimatedFare: 11.99,
      estimatedMinutes: 8,
      vehicleType: 'van',
    ),
  ];
});

/// Trip history provider (mock implementation)
final tripHistoryProvider = FutureProvider<List<Trip>>((ref) async {
  // Mock implementation: return empty list
  return [];
});

// ─────────────────────────────────────────────────────────────────────────────
// Utilities
// ─────────────────────────────────────────────────────────────────────────────

/// Calculate distance between two coordinates (Haversine formula)
double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const earthRadiusKm = 6371.0;

  final dLat = _toRadians(lat2 - lat1);
  final dLon = _toRadians(lon2 - lon1);

  final a = (Math.sin(dLat / 2) * Math.sin(dLat / 2)) +
      (Math.cos(_toRadians(lat1)) *
          Math.cos(_toRadians(lat2)) *
          Math.sin(dLon / 2) *
          Math.sin(dLon / 2));

  final c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

  return earthRadiusKm * c;
}

double _toRadians(double degrees) {
  return degrees * (3.141592653589793 / 180.0);
}

// Simple Math class for trigonometric functions
class Math {
  static double sin(double x) => _sin(x);
  static double cos(double x) => _cos(x);
  static double sqrt(double x) => _sqrt(x);
  static double atan2(double y, double x) => _atan2(y, x);

  static double _sin(double x) {
    // Simplified sine approximation
    x = x % (2 * 3.141592653589793);
    return x - (x * x * x / 6) + (x * x * x * x * x / 120);
  }

  static double _cos(double x) {
    // Simplified cosine approximation
    x = x % (2 * 3.141592653589793);
    return 1 - (x * x / 2) + (x * x * x * x / 24);
  }

  static double _sqrt(double x) {
    if (x < 0) return 0;
    if (x == 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  static double _atan2(double y, double x) {
    // Simplified atan2 approximation
    return (y / x).abs() < 1 ? (y / x) : (3.141592653589793 / 2);
  }
}

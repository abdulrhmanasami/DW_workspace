/// In-Memory Ride Repository - Track B Ticket #242
/// Purpose: Development stub implementation of RideRepository
/// Created by: Track B - Ticket #242
/// Last updated: 2025-12-04
///
/// Pure Dart implementation for development/testing.
/// No Flutter, HTTP, or external SDK dependencies.
///
/// Uses RideFsm for all status transitions and validation.
/// Stores data in memory with simple ID generation.

import 'package:meta/meta.dart';

import 'place_models.dart';
import 'ride_exceptions.dart';
import 'ride_fsm.dart';
import 'ride_models.dart';
import 'ride_repository.dart';
import 'ride_status.dart';

/// In-memory implementation of RideRepository for development and testing.
///
/// This implementation:
/// - Stores ride requests in a simple Map<String, RideRequest>
/// - Generates IDs using timestamp-based counters
/// - Uses RideFsm for all status transitions
/// - Provides realistic delays for async operations
/// - Has no external dependencies (pure Dart)
///
/// Note: This is a development stub - does not persist data or
/// communicate with real backend services.
class InMemoryRideRepository implements RideRepository {
  /// Internal storage for ride requests.
  final Map<String, RideRequest> _storage = {};

  /// Simple ID generator using microseconds since epoch.
  String _generateId() => DateTime.now().microsecondsSinceEpoch.toString();

  @override
  RideRequest createDraft({MobilityPlace? initialPickup}) {
    final id = _generateId();
    final request = RideRequest(
      id: id,
      status: RideStatus.draft,
      pickup: initialPickup,
      destination: null,
      createdAt: DateTime.now().toUtc(),
    );

    _storage[id] = request;
    return request;
  }

  @override
  RideRequest updateLocations({
    required RideRequest request,
    MobilityPlace? pickup,
    MobilityPlace? destination,
  }) {
    final updatedRequest = RideRequest(
      id: request.id,
      status: request.status,
      pickup: pickup,
      destination: destination,
      createdAt: request.createdAt,
      updatedAt: DateTime.now().toUtc(),
      estimatedDurationSeconds: request.estimatedDurationSeconds,
      estimatedPrice: request.estimatedPrice,
      currencyCode: request.currencyCode,
    );

    // Simple pricing logic: if both locations are set, populate pricing
    final hasValidLocations = updatedRequest.hasValidLocations;
    final updatedWithPricing = hasValidLocations
        ? RideRequest(
            id: updatedRequest.id,
            status: updatedRequest.status,
            pickup: updatedRequest.pickup,
            destination: updatedRequest.destination,
            createdAt: updatedRequest.createdAt,
            updatedAt: updatedRequest.updatedAt,
            estimatedDurationSeconds: 600, // 10 minutes (fixed for demo)
            estimatedPrice: 1800, // 18.00 SAR (fixed for demo)
            currencyCode: 'SAR',
          )
        : updatedRequest;

    _storage[updatedRequest.id!] = updatedWithPricing;
    return updatedWithPricing;
  }

  @override
  Future<RideRequest> requestQuote(RideRequest draft) async {
    if (draft.status != RideStatus.draft) {
      throw ArgumentError('Can only request quote for draft requests');
    }

    if (!draft.hasValidLocations) {
      throw ArgumentError('Both pickup and destination must be set to request quote');
    }

    // Transition to quoting state
    final quotingRequest = RideFsm.transition(draft, RideStatus.quoting);
    _storage[quotingRequest.id!] = quotingRequest;

    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 300));

    // Transition to quote ready (assume pricing was already calculated in updateLocations)
    final quoteReadyRequest = RideFsm.transition(quotingRequest, RideStatus.quoteReady);
    _storage[quoteReadyRequest.id!] = quoteReadyRequest;

    return quoteReadyRequest;
  }

  @override
  Future<RideRequest> confirmRide(RideRequest quoted) async {
    if (quoted.status != RideStatus.quoteReady) {
      throw ArgumentError('Can only confirm rides with ready quotes');
    }

    // Transition to requesting state
    final requestingRequest = RideFsm.transition(quoted, RideStatus.requesting);
    _storage[requestingRequest.id!] = requestingRequest;

    // Simulate brief processing delay
    await Future<void>.delayed(const Duration(milliseconds: 200));

    // Transition to finding driver (this is a stub - no real driver matching)
    // In real implementation, this would wait for backend/driver matching
    final findingDriverRequest = RideFsm.transition(requestingRequest, RideStatus.findingDriver);
    _storage[findingDriverRequest.id!] = findingDriverRequest;

    return findingDriverRequest;
  }

  @override
  RideRequest applyStatusUpdate({
    required RideRequest current,
    required RideStatus newStatus,
  }) {
    final updatedRequest = RideFsm.transition(current, newStatus);
    _storage[updatedRequest.id!] = updatedRequest;
    return updatedRequest;
  }

  @override
  RideRequest cancelRide(RideRequest request) {
    if (!request.status.isCancellable) {
      throw InvalidRideTransitionException(request.status, RideStatus.cancelled);
    }

    final cancelledRequest = RideFsm.transition(request, RideStatus.cancelled);
    _storage[cancelledRequest.id!] = cancelledRequest;
    return cancelledRequest;
  }

  @override
  Future<RideRequest?> getRideStatus(String requestId) async {
    // Simulate brief network delay
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return _storage[requestId];
  }

  /// Development helper: Get all stored requests (for testing/debugging)
  @visibleForTesting
  Map<String, RideRequest> get allRequests => Map.unmodifiable(_storage);

  /// Development helper: Clear all stored requests (for testing)
  @visibleForTesting
  void clear() {
    _storage.clear();
  }
}

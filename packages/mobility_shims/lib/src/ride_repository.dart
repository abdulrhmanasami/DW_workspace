/// Ride Repository Interface - Track B Ticket #241
/// Purpose: Domain interface for ride booking operations
/// Created by: Track B - Ticket #241
/// Last updated: 2025-12-04
///
/// Defines the contract for ride booking operations.
/// This is a pure domain interface - no implementation details.
///
/// Implementations should handle:
/// - Network calls to pricing services
/// - Backend API communication
/// - Local caching and persistence
/// - Error handling and recovery

import 'place_models.dart';
import 'ride_models.dart';
import 'ride_status.dart';

/// Abstract interface for ride booking operations.
///
/// This interface defines the core operations needed for the ride booking
/// lifecycle. Implementations are responsible for coordinating with
/// pricing services, backend APIs, and other external systems.
///
/// All operations are asynchronous to account for network calls.
/// Implementations should handle errors appropriately and return
/// domain-appropriate exceptions.
abstract class RideRepository {
  /// Creates a new draft ride request.
  ///
  /// This initializes a ride request in the draft state, optionally
  /// with a pre-selected pickup location (e.g., current location).
  ///
  /// Parameters:
  /// - [initialPickup]: Optional initial pickup location
  ///
  /// Returns a new RideRequest in draft status.
  RideRequest createDraft({
    MobilityPlace? initialPickup,
  });

  /// Updates the locations for an existing ride request.
  ///
  /// Allows setting or changing pickup and destination locations.
  /// The request must be in a modifiable state (typically draft).
  ///
  /// Parameters:
  /// - [request]: The ride request to update
  /// - [pickup]: New pickup location (null to clear)
  /// - [destination]: New destination location (null to clear)
  ///
  /// Returns the updated RideRequest.
  /// Throws [StateError] if the request is not in a modifiable state.
  RideRequest updateLocations({
    required RideRequest request,
    MobilityPlace? pickup,
    MobilityPlace? destination,
  });

  /// Requests a quote for the specified ride request.
  ///
  /// Transitions the request from draft to quoting, then attempts to
  /// get pricing and availability information from the pricing service.
  ///
  /// This operation may take time as it involves network calls.
  ///
  /// Parameters:
  /// - [draft]: The draft request to quote (must be in draft status)
  ///
  /// Returns a Future that completes with the updated RideRequest
  /// in quoteReady status when successful.
  ///
  /// Throws exceptions for:
  /// - Invalid request state
  /// - Network failures
  /// - Pricing service errors
  /// - No available vehicles
  Future<RideRequest> requestQuote(RideRequest draft);

  /// Confirms and submits a ride request.
  ///
  /// Transitions from quoteReady to requesting, then submits the
  /// booking request to the dispatch system.
  ///
  /// Parameters:
  /// - [quoted]: The quoted request to confirm (must be in quoteReady status)
  ///
  /// Returns a Future that completes with the updated RideRequest
  /// in findingDriver status when the booking is accepted.
  ///
  /// Throws exceptions for:
  /// - Invalid request state
  /// - Booking rejection
  /// - Payment issues
  /// - System overload
  Future<RideRequest> confirmRide(RideRequest quoted);

  /// Applies a status update to an existing ride request.
  ///
  /// This method is typically called by backend event handlers
  /// or WebSocket listeners when the ride status changes externally.
  ///
  /// The method validates that the transition is allowed before applying it.
  ///
  /// Parameters:
  /// - [current]: The current ride request state
  /// - [newStatus]: The new status to transition to
  ///
  /// Returns the updated RideRequest with the new status and updated timestamp.
  ///
  /// Throws [StateError] if the transition is not allowed.
  RideRequest applyStatusUpdate({
    required RideRequest current,
    required RideStatus newStatus,
  });

  /// Cancels an existing ride request.
  ///
  /// Transitions the request to cancelled status if cancellation is allowed.
  /// Only works for requests that haven't started the trip yet.
  ///
  /// Parameters:
  /// - [request]: The request to cancel
  ///
  /// Returns the updated RideRequest in cancelled status.
  ///
  /// Throws [StateError] if cancellation is not allowed for this request.
  RideRequest cancelRide(RideRequest request);

  /// Gets the current status of a ride request by ID.
  ///
  /// This is useful for checking status when the app resumes
  /// or when handling push notifications.
  ///
  /// Parameters:
  /// - [requestId]: The ID of the request to check
  ///
  /// Returns the current RideRequest state, or null if not found.
  ///
  /// Note: This method may involve network calls to get the latest status.
  Future<RideRequest?> getRideStatus(String requestId);
}

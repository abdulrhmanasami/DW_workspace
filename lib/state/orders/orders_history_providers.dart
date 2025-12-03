import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:parcels_shims/parcels_shims.dart';
import '../parcels/parcel_shipments_providers.dart';
import '../mobility/ride_trip_session.dart';

/// Service type for unified orders history.
enum OrderHistoryServiceType {
  ride,
  parcel,
  food,
}

/// Base sealed type for orders history items.
///
/// IMPORTANT:
/// - لا نكرر موديلات الدومين.
/// - كل variant يمسك موديل الدومين الأصلي مباشرة.
@immutable
sealed class OrderHistoryItem {
  const OrderHistoryItem();

  OrderHistoryServiceType get serviceType;

  /// Used for sorting (newest first).
  DateTime get createdAt;
}

/// Parcel-based order history item.
@immutable
final class ParcelOrderHistoryItem extends OrderHistoryItem {
  const ParcelOrderHistoryItem(this.shipment);

  final ParcelShipment shipment;

  @override
  OrderHistoryServiceType get serviceType => OrderHistoryServiceType.parcel;

  @override
  DateTime get createdAt => shipment.createdAt;
}

/// Ride-based order history item.
///
/// Wraps a ride trip history entry into the unified OrderHistoryItem model.
@immutable
final class RideOrderHistoryItem extends OrderHistoryItem {
  const RideOrderHistoryItem(this.entry);

  final RideHistoryEntry entry;

  @override
  OrderHistoryServiceType get serviceType => OrderHistoryServiceType.ride;

  @override
  DateTime get createdAt => entry.completedAt;
}

// TODO (Track C/Food): add FoodOrderHistoryItem when food orders are implemented.

/// Unified orders history view.
///
/// Track C - Ticket #153: Hardened provider that preserves AsyncValue semantics.
/// Track B - Ticket #157: Integrated ride history from ride_trip_session.dart.
///
final ordersHistoryProvider =
    Provider.autoDispose<AsyncValue<List<OrderHistoryItem>>>((ref) {
  // Parcels source - maintains AsyncValue state
  final parcelShipmentsAsync = ref.watch(parcelShipmentsStreamProvider);

  // Ride history source - from ride trip session (synchronous)
  final rideSession = ref.watch(rideTripSessionProvider);

  return parcelShipmentsAsync.whenData((shipments) {
    final parcelItems = shipments
        .map<OrderHistoryItem>((s) => ParcelOrderHistoryItem(s))
        .toList();

    // Add ride history items
    final rideItems = rideSession.historyTrips
        .map<OrderHistoryItem>((entry) => RideOrderHistoryItem(entry))
        .toList();

    // Combine and sort by createdAt desc (newest first)
    final allItems = <OrderHistoryItem>[...parcelItems, ...rideItems]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return List<OrderHistoryItem>.unmodifiable(allItems);
  });
});

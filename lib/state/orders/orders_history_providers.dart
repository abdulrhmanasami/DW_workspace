import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:parcels_shims/parcels_shims.dart';
import '../parcels/parcel_shipments_providers.dart';

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

// TODO (Track B/D): add RideOrderHistoryItem when ride history repository exists.
// TODO (Track C/Food): add FoodOrderHistoryItem when food orders are implemented.

/// Unified orders history view.
///
/// Track C - Ticket #153: Hardened provider that preserves AsyncValue semantics.
/// Currently depends on parcels only, with structure prepared for rides/food integration.
/// 
/// This provider maintains the loading/error/data states from underlying service providers
/// instead of converting them to empty lists, allowing proper UI state handling.
final ordersHistoryProvider =
    Provider.autoDispose<AsyncValue<List<OrderHistoryItem>>>((ref) {
  // Parcels source - maintains AsyncValue state
  final parcelShipmentsAsync = ref.watch(parcelShipmentsStreamProvider);

  // TODO (future): Merge with rideHistoryProvider and foodOrdersProvider when available.
  // Will need to combine multiple AsyncValues properly.
  
  return parcelShipmentsAsync.whenData((shipments) {
    final items = shipments
        .map<OrderHistoryItem>((s) => ParcelOrderHistoryItem(s))
        .toList()
      // Sort by createdAt desc (newest first)
      ..sort(
        (a, b) => b.createdAt.compareTo(a.createdAt),
      );
    return List<OrderHistoryItem>.unmodifiable(items);
  });
});

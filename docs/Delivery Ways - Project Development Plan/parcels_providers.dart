import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Component: Parcels State Providers
/// Created by: Track C - Parcels & Food Implementation
/// Purpose: State management for parcel booking and tracking
/// Last updated: 2025-11-27

// ─────────────────────────────────────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────────────────────────────────────

/// Represents a location (pickup or delivery)
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

/// Parcel size enum
enum ParcelSize {
  small,
  medium,
  large,
}

/// Parcel status enum
enum ParcelStatus {
  pending,
  pickedUp,
  inTransit,
  delivered,
  cancelled,
}

/// Represents a parcel
class Parcel {
  final String id;
  final String trackingNumber;
  final Location pickupLocation;
  final Location deliveryLocation;
  final ParcelSize size;
  final double weight;
  final String description;
  final ParcelStatus status;
  final DateTime createdAt;
  final DateTime? estimatedDelivery;
  final double cost;
  final String? specialInstructions;

  const Parcel({
    required this.id,
    required this.trackingNumber,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.size,
    required this.weight,
    required this.description,
    required this.status,
    required this.createdAt,
    this.estimatedDelivery,
    required this.cost,
    this.specialInstructions,
  });

  Parcel copyWith({
    String? id,
    String? trackingNumber,
    Location? pickupLocation,
    Location? deliveryLocation,
    ParcelSize? size,
    double? weight,
    String? description,
    ParcelStatus? status,
    DateTime? createdAt,
    DateTime? estimatedDelivery,
    double? cost,
    String? specialInstructions,
  }) {
    return Parcel(
      id: id ?? this.id,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      size: size ?? this.size,
      weight: weight ?? this.weight,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      cost: cost ?? this.cost,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// State Notifiers
// ─────────────────────────────────────────────────────────────────────────────

/// Manages parcel creation state
class CreateParcelNotifier extends StateNotifier<Parcel?> {
  CreateParcelNotifier() : super(null);

  void initializeParcel(Location pickup, Location delivery) {
    state = Parcel(
      id: 'parcel_${DateTime.now().millisecondsSinceEpoch}',
      trackingNumber: 'PKG${DateTime.now().millisecondsSinceEpoch}',
      pickupLocation: pickup,
      deliveryLocation: delivery,
      size: ParcelSize.medium,
      weight: 0,
      description: '',
      status: ParcelStatus.pending,
      createdAt: DateTime.now(),
      estimatedDelivery: DateTime.now().add(const Duration(days: 1)),
      cost: 5.99,
    );
  }

  void updateSize(ParcelSize size) {
    if (state == null) return;
    state = state!.copyWith(size: size);
  }

  void updateWeight(double weight) {
    if (state == null) return;
    state = state!.copyWith(weight: weight);
  }

  void updateDescription(String description) {
    if (state == null) return;
    state = state!.copyWith(description: description);
  }

  void updateSpecialInstructions(String instructions) {
    if (state == null) return;
    state = state!.copyWith(specialInstructions: instructions);
  }

  void clearParcel() {
    state = null;
  }
}

/// Manages parcels list state
class ParcelsListNotifier extends StateNotifier<List<Parcel>> {
  ParcelsListNotifier() : super(_mockParcels);

  void addParcel(Parcel parcel) {
    state = [parcel, ...state];
  }

  void updateParcel(Parcel parcel) {
    state = state.map((p) => p.id == parcel.id ? parcel : p).toList();
  }

  void removeParcel(String id) {
    state = state.where((p) => p.id != id).toList();
  }

  void updateParcelStatus(String id, ParcelStatus status) {
    final parcel = state.firstWhere((p) => p.id == id);
    updateParcel(parcel.copyWith(status: status));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Create parcel state provider
final createParcelProvider = StateNotifierProvider<CreateParcelNotifier, Parcel?>((ref) {
  return CreateParcelNotifier();
});

/// Parcels list provider
final parcelsListProvider = StateNotifierProvider<ParcelsListNotifier, List<Parcel>>((ref) {
  return ParcelsListNotifier();
});

/// Filtered parcels provider (by status)
final filteredParcelsProvider = Provider.family<List<Parcel>, ParcelStatus?>((ref, status) {
  final parcels = ref.watch(parcelsListProvider);
  if (status == null) return parcels;
  return parcels.where((p) => p.status == status).toList();
});

/// Parcel detail provider
final parcelDetailProvider = Provider.family<Parcel?, String>((ref, id) {
  final parcels = ref.watch(parcelsListProvider);
  try {
    return parcels.firstWhere((p) => p.id == id);
  } catch (e) {
    return null;
  }
});

/// Parcel cost estimation provider
final parcelCostProvider = FutureProvider.family<double, (ParcelSize, double)>((ref, params) async {
  final size = params.$1;
  final weight = params.$2;

  // Mock implementation: calculate cost based on size and weight
  double baseCost = 3.00;
  double sizeCost = 0;
  double weightCost = 0;

  switch (size) {
    case ParcelSize.small:
      sizeCost = 1.00;
      break;
    case ParcelSize.medium:
      sizeCost = 2.00;
      break;
    case ParcelSize.large:
      sizeCost = 3.50;
      break;
  }

  // Weight cost: $0.50 per kg
  weightCost = weight * 0.50;

  return baseCost + sizeCost + weightCost;
});

// ─────────────────────────────────────────────────────────────────────────────
// Mock Data
// ─────────────────────────────────────────────────────────────────────────────

final _mockParcels = [
  Parcel(
    id: 'parcel_1',
    trackingNumber: 'PKG20251127001',
    pickupLocation: const Location(
      address: 'Downtown Office',
      latitude: 37.7749,
      longitude: -122.4194,
    ),
    deliveryLocation: const Location(
      address: 'Residential Area',
      latitude: 37.7849,
      longitude: -122.4094,
    ),
    size: ParcelSize.medium,
    weight: 2.5,
    description: 'Important documents',
    status: ParcelStatus.delivered,
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    estimatedDelivery: DateTime.now().subtract(const Duration(days: 1)),
    cost: 6.50,
  ),
  Parcel(
    id: 'parcel_2',
    trackingNumber: 'PKG20251127002',
    pickupLocation: const Location(
      address: 'Warehouse A',
      latitude: 37.7649,
      longitude: -122.4294,
    ),
    deliveryLocation: const Location(
      address: 'Customer Address',
      latitude: 37.7949,
      longitude: -122.3994,
    ),
    size: ParcelSize.large,
    weight: 5.0,
    description: 'Electronic equipment',
    status: ParcelStatus.inTransit,
    createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    estimatedDelivery: DateTime.now().add(const Duration(hours: 6)),
    cost: 8.99,
  ),
  Parcel(
    id: 'parcel_3',
    trackingNumber: 'PKG20251127003',
    pickupLocation: const Location(
      address: 'My Location',
      latitude: 37.7749,
      longitude: -122.4194,
    ),
    deliveryLocation: const Location(
      address: 'Friend\'s Place',
      latitude: 37.7849,
      longitude: -122.4294,
    ),
    size: ParcelSize.small,
    weight: 0.5,
    description: 'Gift package',
    status: ParcelStatus.pending,
    createdAt: DateTime.now(),
    estimatedDelivery: DateTime.now().add(const Duration(days: 1)),
    cost: 4.50,
  ),
];

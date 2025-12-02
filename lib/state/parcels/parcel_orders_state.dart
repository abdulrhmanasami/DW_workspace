/// Parcel Orders State + Controller
/// Created by: Track C - Ticket #44
/// Updated by: Track C - Ticket #49 (ParcelsRepository Port integration)
/// Updated by: Track C - Ticket #81 (cancelParcel method)
/// Updated by: Track B - Ticket #127 (Added isLoading for Skeleton Loader support)
/// Purpose: Manage in-memory session state for parcel shipments
/// Last updated: 2025-12-01

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parcels_shims/parcels_shims.dart';

import 'parcel_draft_state.dart';
import 'parcels_repository_provider.dart';

/// Session state for parcel orders.
///
/// Holds both the currently active parcel and a list of all parcels
/// created during the current session.
@immutable
class ParcelOrdersState {
  const ParcelOrdersState({
    this.activeParcel,
    this.parcels = const [],
    this.isLoading = false,
  });

  /// Currently active parcel (e.g. last created).
  final Parcel? activeParcel;

  /// All parcels created in this session.
  final List<Parcel> parcels;

  /// Track B - Ticket #127: Loading state for skeleton display.
  final bool isLoading;

  ParcelOrdersState copyWith({
    Parcel? activeParcel,
    List<Parcel>? parcels,
    bool? isLoading,
    bool clearActive = false,
  }) {
    return ParcelOrdersState(
      activeParcel: clearActive ? null : (activeParcel ?? this.activeParcel),
      parcels: parcels ?? this.parcels,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ParcelOrdersState &&
        other.activeParcel == activeParcel &&
        listEquals(other.parcels, parcels) &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode => Object.hash(activeParcel, parcels, isLoading);

  @override
  String toString() => 'ParcelOrdersState('
      'activeParcel: $activeParcel, parcels: ${parcels.length}, isLoading: $isLoading)';
}

/// Controller for managing parcel orders session state.
///
/// Ticket #44: All operations are in-memory only (no backend integration).
/// Ticket #49: Now uses ParcelsRepository Port for shipment creation.
class ParcelOrdersController extends StateNotifier<ParcelOrdersState> {
  ParcelOrdersController({
    required ParcelsRepository repository,
  })  : _repository = repository,
        super(const ParcelOrdersState());

  final ParcelsRepository _repository;

  /// Create a new Parcel from draft + quote + selected option and store it.
  ///
  /// Track C - Ticket #50: Now includes price from selected option.
  ///
  /// Returns the created [Parcel] for testing purposes.
  Parcel createParcelFromDraft({
    required ParcelDraftUiState draft,
    required ParcelQuote quote,
    required ParcelQuoteOption selectedOption,
  }) {
    // 1) Generate unique ID
    final parcelId = 'parcel-${DateTime.now().microsecondsSinceEpoch}';

    // 2) Convert weight text to numeric
    final rawWeight = draft.weightText.trim().replaceAll(',', '.');
    final weightKg = double.tryParse(rawWeight) ?? 1.0;

    // 3) Build domain models from draft
    final pickupAddress = ParcelAddress(label: draft.pickupAddress);
    final dropoffAddress = ParcelAddress(label: draft.dropoffAddress);
    final details = ParcelDetails(
      size: draft.size ?? ParcelSize.medium,
      weightKg: weightKg,
      description: draft.contentsDescription.isNotEmpty
          ? draft.contentsDescription
          : null,
    );

    // 4) Track C - Ticket #50: Build price from selected option
    final price = ParcelPrice(
      totalAmountCents: selectedOption.totalAmountCents,
      currencyCode: selectedOption.currencyCode,
    );

    // 5) Create Parcel with initial status and price
    final parcel = Parcel(
      id: parcelId,
      createdAt: DateTime.now(),
      pickupAddress: pickupAddress,
      dropoffAddress: dropoffAddress,
      details: details,
      status: ParcelStatus.scheduled,
      price: price,
    );

    // 6) Update state: add to list + set as active
    state = ParcelOrdersState(
      activeParcel: parcel,
      parcels: [...state.parcels, parcel],
    );

    return parcel;
  }

  /// Clear active parcel (optional for future screens).
  void clearActiveParcel() {
    state = state.copyWith(clearActive: true);
  }

  /// Cancel a parcel by id (local state update only).
  ///
  /// Track C - Ticket #81: Updates parcel status to cancelled in session state.
  /// This is a client-side only operation; backend integration would be in a future ticket.
  void cancelParcel({required String parcelId}) {
    final updatedParcels = state.parcels.map((parcel) {
      if (parcel.id == parcelId) {
        return parcel.copyWith(status: ParcelStatus.cancelled);
      }
      return parcel;
    }).toList();

    // Update activeParcel if it's the one being cancelled
    final updatedActive = state.activeParcel?.id == parcelId
        ? state.activeParcel?.copyWith(status: ParcelStatus.cancelled)
        : state.activeParcel;

    state = ParcelOrdersState(
      activeParcel: updatedActive,
      parcels: updatedParcels,
    );
  }

  /// Reset all parcels (session reset - used in tests).
  void reset() {
    state = const ParcelOrdersState();
  }

  /// Create a new shipment directly from the Create Shipment form.
  /// Track C - Ticket #46: Create Shipment Screen integration.
  /// Track C - Ticket #49: Now delegates to ParcelsRepository.
  ///
  /// Returns the created [Parcel] for testing purposes.
  Future<Parcel> createShipmentFromForm({
    required String senderName,
    required String senderPhone,
    required String senderAddress,
    required String receiverName,
    required String receiverPhone,
    required String receiverAddress,
    required String weightText,
    required ParcelSize size,
    String? notes,
    required ParcelServiceType serviceType,
  }) async {
    // Build request DTO
    final request = ParcelCreateRequest(
      senderName: senderName,
      senderPhone: senderPhone,
      senderAddress: senderAddress,
      receiverName: receiverName,
      receiverPhone: receiverPhone,
      receiverAddress: receiverAddress,
      weightText: weightText,
      size: size,
      notes: notes,
      serviceType: serviceType,
    );

    // Delegate to repository
    final parcel = await _repository.createShipment(request);

    // Update state: add to list + set as active
    state = ParcelOrdersState(
      activeParcel: parcel,
      parcels: [parcel, ...state.parcels],
    );

    return parcel;
  }
}

/// Provider for ParcelOrdersController.
/// Track C - Ticket #49: Now injects ParcelsRepository from provider.
final parcelOrdersProvider =
    StateNotifierProvider<ParcelOrdersController, ParcelOrdersState>((ref) {
  final repository = ref.watch(parcelsRepositoryProvider);
  return ParcelOrdersController(repository: repository);
});


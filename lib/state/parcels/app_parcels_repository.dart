/// App-side Adapter implementing ParcelsRepository.
/// Created by: Track C - Ticket #49
/// Updated by: Track C - Ticket #50 (Parcels Pricing Integration)
/// Purpose: In-memory implementation of ParcelsRepository Port.
/// Last updated: 2025-11-28

import 'package:parcels_shims/parcels_shims.dart';

/// Track C - Adapter: App-side implementation of ParcelsRepository.
///
/// Currently uses in-memory storage for parcels. This can be swapped out
/// for a backend implementation in the future without changing the UI/state layer.
///
/// Track C - Ticket #50: Now integrates with ParcelPricingService for pricing.
class AppParcelsRepository implements ParcelsRepository {
  AppParcelsRepository({
    List<Parcel>? initialParcels,
    ParcelPricingService? pricingService,
  })  : _parcels = List<Parcel>.from(initialParcels ?? const []),
        _pricingService = pricingService ?? const MockParcelPricingService();

  final List<Parcel> _parcels;
  final ParcelPricingService _pricingService;

  @override
  Future<List<Parcel>> listParcels() async {
    // Return unmodifiable copy to prevent external mutation
    return List<Parcel>.unmodifiable(_parcels);
  }

  @override
  Future<Parcel?> getParcelById(String id) async {
    try {
      return _parcels.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Parcel> createShipment(ParcelCreateRequest request) async {
    // 1) Generate unique ID
    final parcelId = 'parcel-${DateTime.now().microsecondsSinceEpoch}';

    // 2) Parse weight
    final rawWeight = request.weightText.trim().replaceAll(',', '.');
    final weightKg = double.tryParse(rawWeight) ?? 1.0;

    // 3) Build domain models
    // Sender address becomes pickup, receiver address becomes dropoff
    final pickupAddress = ParcelAddress(
      label: request.senderAddress,
      streetLine1: request.senderAddress,
    );
    final dropoffAddress = ParcelAddress(
      label: request.receiverAddress,
      streetLine1: request.receiverAddress,
    );
    final details = ParcelDetails(
      size: request.size,
      weightKg: weightKg,
      description: request.notes,
    );

    // 4) Track C - Ticket #50: Calculate price using pricing service
    ParcelPrice? price;
    try {
      final quote = await _pricingService.quoteParcel(
        pickup: pickupAddress,
        dropoff: dropoffAddress,
        details: details,
        serviceType: request.serviceType,
      );

      // Select the option matching the requested service type
      final selectedOption = quote.options.firstWhere(
        (opt) => opt.id == request.serviceType.name,
        orElse: () => quote.options.first,
      );

      price = ParcelPrice(
        totalAmountCents: selectedOption.totalAmountCents,
        currencyCode: selectedOption.currencyCode,
      );
    } on ParcelPricingException {
      // If pricing fails, proceed without price (null)
      price = null;
    }

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

    // 6) Add to storage (newest first)
    _parcels.insert(0, parcel);

    return parcel;
  }
}


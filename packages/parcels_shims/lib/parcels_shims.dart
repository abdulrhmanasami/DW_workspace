/// Domain models and shims for Parcels vertical in Delivery Ways.
///
/// This library provides:
/// - Core domain models for parcel shipments
/// - Contact and shipment models with sender/receiver details
/// - FSM for parcel lifecycle management
/// - Pricing service abstractions and mock implementations
/// - ParcelsRepository Port for Ports/Adapters pattern (Track C - Ticket #49)
/// - Enhanced ParcelShipmentsRepository with In-Memory implementation (Track C - Ticket #148)
library parcels_shims;

export 'src/parcel_models.dart';
export 'src/parcel_contact.dart';
export 'src/parcel_shipment.dart';
export 'src/parcel_shipments_repository.dart';
export 'src/parcel_fsm.dart';
export 'src/parcel_pricing_service.dart';
export 'src/parcels_repository.dart';


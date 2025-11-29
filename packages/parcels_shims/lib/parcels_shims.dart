/// Domain models and shims for Parcels vertical in Delivery Ways.
///
/// This library provides:
/// - Core domain models for parcel shipments
/// - FSM for parcel lifecycle management
/// - Pricing service abstractions and mock implementations
/// - ParcelsRepository Port for Ports/Adapters pattern (Track C - Ticket #49)
library parcels_shims;

export 'src/parcel_models.dart';
export 'src/parcel_fsm.dart';
export 'src/parcel_pricing_service.dart';
export 'src/parcels_repository.dart';


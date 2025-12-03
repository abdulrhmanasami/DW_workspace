/// Ride Pricing Providers
/// Ticket #210 – Track B: Mock Ride Pricing Service + Domain Interface
/// Purpose: Riverpod providers for ride pricing service

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pricing_shims/pricing_shims.dart';
import 'package:pricing_stub_impl/pricing_stub_impl.dart';

/// Provider for the ride pricing service.
///
/// Uses the mock implementation by default. Can be overridden
/// with a real backend implementation later.
final ridePricingServiceProvider = Provider<RidePricingService>((ref) {
  return const MockRidePricingService();
});

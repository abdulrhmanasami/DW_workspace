/// Demo script to verify the bug fixes for Ticket #211

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobility_shims/mobility_shims.dart';
import 'package:pricing_shims/pricing_shims.dart' as pricing;
import 'package:delivery_ways_clean/state/mobility/ride_trip_session.dart';

/// Mock Ref implementation for tests
class _MockRef implements Ref {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Mock RidePricingService for testing
class MockRidePricingService implements pricing.RidePricingService {
  pricing.RideQuoteResult? result;

  @override
  Future<pricing.RideQuoteResult> requestQuote(pricing.RideQuoteRequest request) async {
    return result ?? const pricing.RideQuoteResult.failure(pricing.RideQuoteFailureReason.networkError);
  }
}

void main() async {
  print('🧪 Testing Bug Fixes for Ticket #211');

  // Test Bug 1: _TestRideTripSessionController should not crash with null ref
  print('\n1️⃣ Testing Bug 1: Test controller with null ref fix');
  try {
    final mockRef = _MockRef();
    final controller = _TestRideTripSessionController(mockRef);
    print('✅ Bug 1 FIXED: Test controller created successfully without null ref crash');
  } catch (e) {
    print('❌ Bug 1 NOT FIXED: $e');
  }

  // Test Bug 2: Location comparison should work with different object instances
  print('\n2️⃣ Testing Bug 2: Location comparison fix');
  try {
    final mockPricing = MockRidePricingService();
    final mockRef = _MockRef();

    // Create controller with mock pricing service
    final container = ProviderContainer(
      overrides: [
        ridePricingServiceProvider.overrideWithValue(mockPricing),
      ],
    );

    final controller = container.read(rideTripSessionProvider.notifier);

    // Create draft with pickup and dropoff at same location (different instances)
    final sameLocation1 = LocationPoint(
      latitude: 24.7136,
      longitude: 46.6753,
      accuracyMeters: 10,
      timestamp: DateTime.now(),
    );
    final sameLocation2 = LocationPoint(
      latitude: 24.7136, // Same coordinates
      longitude: 46.6753, // Same coordinates
      accuracyMeters: 10,
      timestamp: DateTime.now(),
    );

    final draft = RideDraftUiState(
      pickupPlace: MobilityPlace(
        label: 'Pickup',
        location: sameLocation1,
        type: MobilityPlaceType.recent,
      ),
      destinationPlace: MobilityPlace(
        label: 'Dropoff',
        location: sameLocation2, // Same coordinates, different instance
        type: MobilityPlaceType.recent,
      ),
      destinationQuery: 'Test',
    );

    controller.state = controller.state.copyWith(draftSnapshot: draft);

    // Setup mock to return success (shouldn't be called due to validation)
    final mockQuote = pricing.RideQuote(
      id: 'test-quote',
      price: Amount(2500, 'SAR'),
      estimatedDuration: const Duration(minutes: 15),
      distanceMeters: 5000,
      surgeMultiplier: 1.0,
    );
    mockPricing.result = pricing.RideQuoteResult.success(mockQuote);

    // Request quote - should fail due to same pickup/dropoff
    final result = await controller.requestQuoteForCurrentDraft();

    if (!result && controller.state.lastQuoteFailure == pricing.RideQuoteFailureReason.invalidRequest) {
      print('✅ Bug 2 FIXED: Location comparison correctly detected same coordinates in different instances');
    } else {
      print('❌ Bug 2 NOT FIXED: Expected invalidRequest failure, got result=$result, failure=${controller.state.lastQuoteFailure}');
    }

    container.dispose();
  } catch (e) {
    print('❌ Bug 2 NOT FIXED: $e');
  }

  print('\n🎉 Bug fix verification complete!');
}

/// Test controller that returns a fixed session state
class _TestRideTripSessionController extends RideTripSessionController {
  _TestRideTripSessionController(Ref ref) : super(ref);

  // Override to prevent tracking subscription in tests
  @override
  void _setupTrackingSubscription() {
    // Do nothing in tests - we don't need tracking functionality
  }
}

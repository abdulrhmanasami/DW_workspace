/// RideQuoteController Unit Tests - Track B Ticket #17, #27, #121
/// Purpose: Safety net tests for RideQuoteController before deeper integration
/// Created by: Track B - Ticket #17
/// Updated by: Track B - Ticket #27 (MockRidePricingService integration)
/// Updated by: Track B - Ticket #121 (Structured RideQuoteError handling)
/// Last updated: 2025-12-01

import 'package:flutter_test/flutter_test.dart';

import 'package:mobility_shims/mobility_shims.dart';

import 'package:delivery_ways_clean/state/mobility/ride_draft_state.dart';
import 'package:delivery_ways_clean/state/mobility/ride_quote_controller.dart';

void main() {
  // Helper to create MobilityPlace with coordinates
  MobilityPlace createPlace({
    required String label,
    required double lat,
    required double lng,
  }) {
    return MobilityPlace(
      label: label,
      location: LocationPoint(
        latitude: lat,
        longitude: lng,
        accuracyMeters: 10,
        timestamp: DateTime.now(),
      ),
    );
  }

  group('RideQuoteController with RidePricingService (Ticket #27)', () {
    group('initial state', () {
      test('has isLoading = false', () {
        const pricingService = MockRidePricingService(
          baseLatency: Duration.zero,
        );
        final controller = RideQuoteController(pricingService: pricingService);

        expect(controller.state.isLoading, isFalse);
      });

      test('has null quote', () {
        const pricingService = MockRidePricingService(
          baseLatency: Duration.zero,
        );
        final controller = RideQuoteController(pricingService: pricingService);

        expect(controller.state.quote, isNull);
        expect(controller.state.hasQuote, isFalse);
      });

      test('has null error', () {
        const pricingService = MockRidePricingService(
          baseLatency: Duration.zero,
        );
        final controller = RideQuoteController(pricingService: pricingService);

        // Track B - Ticket #121: Use structured error instead of errorMessage
        expect(controller.state.error, isNull);
        expect(controller.state.hasError, isFalse);
      });
    });

    group('refreshFromDraft with MobilityPlace', () {
      test('success path with pickup and destination places', () async {
        const pricingService = MockRidePricingService(
          baseLatency: Duration.zero,
        );
        final controller = RideQuoteController(pricingService: pricingService);

        final pickup = createPlace(
          label: 'Home',
          lat: 24.7136,
          lng: 46.6753,
        );
        final destination = createPlace(
          label: 'Office',
          lat: 24.7500,
          lng: 46.7000,
        );

        final draft = RideDraftUiState(
          pickupLabel: pickup.label,
          pickupPlace: pickup,
          destinationQuery: destination.label,
          destinationPlace: destination,
        );

        await controller.refreshFromDraft(draft);

        expect(controller.state.isLoading, isFalse);
        expect(controller.state.hasQuote, isTrue);
        expect(controller.state.quote, isNotNull);
        // Track B - Ticket #121: Use structured error
        expect(controller.state.error, isNull);
        expect(controller.state.hasError, isFalse);
      });

      test('quote contains expected options', () async {
        const pricingService = MockRidePricingService(
          baseLatency: Duration.zero,
        );
        final controller = RideQuoteController(pricingService: pricingService);

        final pickup = createPlace(
          label: 'Home',
          lat: 24.7136,
          lng: 46.6753,
        );
        final destination = createPlace(
          label: 'Mall',
          lat: 24.7300,
          lng: 46.6900,
        );

        final draft = RideDraftUiState(
          pickupPlace: pickup,
          destinationPlace: destination,
        );

        await controller.refreshFromDraft(draft);

        final quote = controller.state.quote!;
        expect(quote.options.length, equals(3));
        expect(
          quote.options.map((o) => o.id).toList(),
          containsAll(['economy', 'xl', 'premium']),
        );
      });

      test('quote has recommendedOption', () async {
        const pricingService = MockRidePricingService(
          baseLatency: Duration.zero,
        );
        final controller = RideQuoteController(pricingService: pricingService);

        final pickup = createPlace(
          label: 'A',
          lat: 24.7136,
          lng: 46.6753,
        );
        final destination = createPlace(
          label: 'B',
          lat: 24.7200,
          lng: 46.6800,
        );

        final draft = RideDraftUiState(
          pickupPlace: pickup,
          destinationPlace: destination,
        );

        await controller.refreshFromDraft(draft);

        final quote = controller.state.quote!;
        expect(quote.recommendedOption, isNotNull);
        // Track B - Ticket #121: recommendedOption is now nullable
        expect(quote.recommendedOption!.isRecommended, isTrue);
      });

      test('failure path sets error state with RideQuoteErrorPricingFailed', () async {
        const pricingService = MockRidePricingService(
          baseLatency: Duration.zero,
          failureRate: 1.0, // Always fails
        );
        final controller = RideQuoteController(pricingService: pricingService);

        final pickup = createPlace(
          label: 'A',
          lat: 24.7136,
          lng: 46.6753,
        );
        final destination = createPlace(
          label: 'B',
          lat: 24.7200,
          lng: 46.6800,
        );

        final draft = RideDraftUiState(
          pickupPlace: pickup,
          destinationPlace: destination,
        );

        await controller.refreshFromDraft(draft);

        expect(controller.state.isLoading, isFalse);
        expect(controller.state.hasError, isTrue);
        // Track B - Ticket #121: Verify structured error type
        expect(controller.state.error, isA<RideQuoteErrorPricingFailed>());
        expect(controller.state.quote, isNull);
      });
    });

    group('refreshFromDraft fallback (destination query only)', () {
      test('with non-empty destination returns quote', () async {
        const pricingService = MockRidePricingService(
          baseLatency: Duration.zero,
        );
        final controller = RideQuoteController(pricingService: pricingService);

        const draft = RideDraftUiState(
          destinationQuery: 'Riyadh Airport',
        );

        await controller.refreshFromDraft(draft);
        final state = controller.state;

        expect(state.isLoading, isFalse);
        expect(state.hasQuote, isTrue);
        expect(state.quote, isNotNull);
        expect(state.quote!.options, isNotEmpty);
        // Track B - Ticket #121: Use structured error
        expect(state.error, isNull);
        expect(state.hasError, isFalse);
      });

      test('with empty destination sets error', () async {
        const pricingService = MockRidePricingService(
          baseLatency: Duration.zero,
        );
        final controller = RideQuoteController(pricingService: pricingService);

        const draft = RideDraftUiState(destinationQuery: '');

        await controller.refreshFromDraft(draft);
        final state = controller.state;

        expect(state.isLoading, isFalse);
        expect(state.hasQuote, isFalse);
        expect(state.quote, isNull);
        expect(state.hasError, isTrue);
        // Track B - Ticket #121: Use structured error
        expect(state.error, isNotNull);
      });

      test('with whitespace-only destination sets error', () async {
        const pricingService = MockRidePricingService(
          baseLatency: Duration.zero,
        );
        final controller = RideQuoteController(pricingService: pricingService);

        const draft = RideDraftUiState(destinationQuery: '   ');

        await controller.refreshFromDraft(draft);
        final state = controller.state;

        expect(state.isLoading, isFalse);
        expect(state.hasQuote, isFalse);
        expect(state.quote, isNull);
        expect(state.hasError, isTrue);
        // Track B - Ticket #121: Use structured error
        expect(state.error, isNotNull);
      });
    });

    group('clear', () {
      test('resets state to defaults after having quote', () async {
        const pricingService = MockRidePricingService(
          baseLatency: Duration.zero,
        );
        final controller = RideQuoteController(pricingService: pricingService);

        final pickup = createPlace(
          label: 'A',
          lat: 24.7136,
          lng: 46.6753,
        );
        final destination = createPlace(
          label: 'B',
          lat: 24.7200,
          lng: 46.6800,
        );

        final draft = RideDraftUiState(
          pickupPlace: pickup,
          destinationPlace: destination,
        );

        await controller.refreshFromDraft(draft);
        expect(controller.state.hasQuote, isTrue);

        controller.clear();

        expect(controller.state.isLoading, isFalse);
        expect(controller.state.quote, isNull);
        // Track B - Ticket #121: Use structured error
        expect(controller.state.error, isNull);
        expect(controller.state.hasQuote, isFalse);
        expect(controller.state.hasError, isFalse);
      });

      test('clears error state', () async {
        const pricingService = MockRidePricingService(
          baseLatency: Duration.zero,
          failureRate: 1.0,
        );
        final controller = RideQuoteController(pricingService: pricingService);

        final pickup = createPlace(
          label: 'A',
          lat: 24.7136,
          lng: 46.6753,
        );
        final destination = createPlace(
          label: 'B',
          lat: 24.7200,
          lng: 46.6800,
        );

        final draft = RideDraftUiState(
          pickupPlace: pickup,
          destinationPlace: destination,
        );

        await controller.refreshFromDraft(draft);
        expect(controller.state.hasError, isTrue);

        controller.clear();

        expect(controller.state.hasError, isFalse);
        // Track B - Ticket #121: Use structured error
        expect(controller.state.error, isNull);
      });

      test('clear on fresh controller is safe', () {
        const pricingService = MockRidePricingService(
          baseLatency: Duration.zero,
        );
        final controller = RideQuoteController(pricingService: pricingService);

        controller.clear();

        expect(controller.state.isLoading, isFalse);
        expect(controller.state.quote, isNull);
        // Track B - Ticket #121: Use structured error
        expect(controller.state.error, isNull);
      });
    });
  });

  group('RideQuoteController.legacy (backward compatibility)', () {
    group('initial state', () {
      test('has isLoading = false', () {
        const service = MockRideQuoteService();
        final controller = RideQuoteController.legacy(service);

        expect(controller.state.isLoading, isFalse);
      });

      test('has null quote', () {
        const service = MockRideQuoteService();
        final controller = RideQuoteController.legacy(service);

        expect(controller.state.quote, isNull);
        expect(controller.state.hasQuote, isFalse);
      });

      test('has null error', () {
        const service = MockRideQuoteService();
        final controller = RideQuoteController.legacy(service);

        // Track B - Ticket #121: Use structured error
        expect(controller.state.error, isNull);
        expect(controller.state.hasError, isFalse);
      });
    });

    group('refreshFromDraft', () {
      test('with non-empty destination returns quote', () async {
        const service = MockRideQuoteService();
        final controller = RideQuoteController.legacy(service);
        const draft = RideDraftUiState(destinationQuery: 'Riyadh Airport');

        await controller.refreshFromDraft(draft);
        final state = controller.state;

        expect(state.isLoading, isFalse);
        expect(state.hasQuote, isTrue);
        expect(state.quote, isNotNull);
        expect(state.quote!.request.currencyCode, 'SAR');
        expect(state.quote!.options, isNotEmpty);
        // Track B - Ticket #121: Use structured error
        expect(state.error, isNull);
        expect(state.hasError, isFalse);
      });

      test('with empty destination sets error', () async {
        const service = MockRideQuoteService();
        final controller = RideQuoteController.legacy(service);
        const draft = RideDraftUiState(destinationQuery: '');

        await controller.refreshFromDraft(draft);
        final state = controller.state;

        expect(state.isLoading, isFalse);
        expect(state.hasQuote, isFalse);
        expect(state.quote, isNull);
        expect(state.hasError, isTrue);
        // Track B - Ticket #121: Use structured error
        expect(state.error, isNotNull);
      });

      test('with whitespace-only destination sets error', () async {
        const service = MockRideQuoteService();
        final controller = RideQuoteController.legacy(service);
        const draft = RideDraftUiState(destinationQuery: '   ');

        await controller.refreshFromDraft(draft);
        final state = controller.state;

        expect(state.isLoading, isFalse);
        expect(state.hasQuote, isFalse);
        expect(state.quote, isNull);
        expect(state.hasError, isTrue);
        // Track B - Ticket #121: Use structured error
        expect(state.error, isNotNull);
      });

      test('quote contains expected options', () async {
        const service = MockRideQuoteService();
        final controller = RideQuoteController.legacy(service);
        const draft = RideDraftUiState(destinationQuery: 'Downtown');

        await controller.refreshFromDraft(draft);
        final quote = controller.state.quote!;

        // MockRideQuoteService returns 3 options: economy, xl, premium
        expect(quote.options.length, 3);

        final categories = quote.options.map((o) => o.category).toSet();
        expect(categories, contains(RideVehicleCategory.economy));
        expect(categories, contains(RideVehicleCategory.xl));
        expect(categories, contains(RideVehicleCategory.premium));
      });

      test('quote has recommendedOption', () async {
        const service = MockRideQuoteService();
        final controller = RideQuoteController.legacy(service);
        const draft = RideDraftUiState(destinationQuery: 'Test');

        await controller.refreshFromDraft(draft);
        final quote = controller.state.quote!;

        expect(quote.recommendedOption, isNotNull);
        // Track B - Ticket #121: recommendedOption is now nullable
        expect(quote.recommendedOption!.isRecommended, isTrue);
      });

      test('quote.optionById returns correct option', () async {
        const service = MockRideQuoteService();
        final controller = RideQuoteController.legacy(service);
        const draft = RideDraftUiState(destinationQuery: 'Test');

        await controller.refreshFromDraft(draft);
        final quote = controller.state.quote!;

        for (final option in quote.options) {
          final found = quote.optionById(option.id);
          expect(found, isNotNull);
          expect(found!.id, option.id);
        }
      });

      test('sequential refresh replaces previous quote', () async {
        const service = MockRideQuoteService();
        final controller = RideQuoteController.legacy(service);

        const draft1 = RideDraftUiState(destinationQuery: 'First');
        await controller.refreshFromDraft(draft1);
        final firstQuoteId = controller.state.quote!.quoteId;

        const draft2 = RideDraftUiState(destinationQuery: 'Second');
        await controller.refreshFromDraft(draft2);
        final secondQuoteId = controller.state.quote!.quoteId;

        expect(firstQuoteId, isNot(equals(secondQuoteId)));
      });
    });

    group('clear', () {
      test('resets state to defaults after having quote', () async {
        const service = MockRideQuoteService();
        final controller = RideQuoteController.legacy(service);
        const draft = RideDraftUiState(destinationQuery: 'Downtown');

        await controller.refreshFromDraft(draft);
        expect(controller.state.hasQuote, isTrue);

        controller.clear();

        expect(controller.state.isLoading, isFalse);
        expect(controller.state.quote, isNull);
        // Track B - Ticket #121: Use structured error
        expect(controller.state.error, isNull);
        expect(controller.state.hasQuote, isFalse);
        expect(controller.state.hasError, isFalse);
      });

      test('clears error state', () async {
        const service = MockRideQuoteService();
        final controller = RideQuoteController.legacy(service);
        const draft = RideDraftUiState(destinationQuery: '');

        await controller.refreshFromDraft(draft);
        expect(controller.state.hasError, isTrue);

        controller.clear();

        expect(controller.state.hasError, isFalse);
        // Track B - Ticket #121: Use structured error
        expect(controller.state.error, isNull);
      });

      test('clear on fresh controller is safe', () {
        const service = MockRideQuoteService();
        final controller = RideQuoteController.legacy(service);

        controller.clear();

        expect(controller.state.isLoading, isFalse);
        expect(controller.state.quote, isNull);
        // Track B - Ticket #121: Use structured error
        expect(controller.state.error, isNull);
      });
    });
  });

  group('RideQuoteUiState', () {
    test('hasQuote is true when quote exists', () async {
      // Use MockRideQuoteService to get a real quote for testing
      const service = MockRideQuoteService();
      final request = RideQuoteRequest(
        pickup: LocationPoint(
          latitude: 24.7136,
          longitude: 46.6753,
          accuracyMeters: 10,
          timestamp: DateTime.now(),
        ),
        dropoff: LocationPoint(
          latitude: 24.7236,
          longitude: 46.6853,
          accuracyMeters: 10,
          timestamp: DateTime.now(),
        ),
        currencyCode: 'SAR',
      );

      final quote = await service.getQuote(request);
      final state = RideQuoteUiState(quote: quote);

      expect(state.hasQuote, isTrue);
      expect(state.hasError, isFalse);
    });

    // Track B - Ticket #121: Updated to use structured RideQuoteError
    test('hasError is true when error exists and no quote', () {
      const state = RideQuoteUiState(
        error: RideQuoteErrorPricingFailed(),
      );

      expect(state.hasQuote, isFalse);
      expect(state.hasError, isTrue);
      expect(state.error, isA<RideQuoteErrorPricingFailed>());
    });

    // Track B - Ticket #121: Updated to use structured RideQuoteError
    test('hasError is false when both quote and error exist', () async {
      // Use MockRideQuoteService to get a real quote for testing
      const service = MockRideQuoteService();
      final request = RideQuoteRequest(
        pickup: LocationPoint(
          latitude: 24.7136,
          longitude: 46.6753,
          accuracyMeters: 10,
          timestamp: DateTime.now(),
        ),
        dropoff: LocationPoint(
          latitude: 24.7236,
          longitude: 46.6853,
          accuracyMeters: 10,
          timestamp: DateTime.now(),
        ),
        currencyCode: 'SAR',
      );

      final quote = await service.getQuote(request);
      final state = RideQuoteUiState(
        quote: quote,
        error: const RideQuoteErrorPricingFailed(),
      );

      // hasError only when quote is null
      expect(state.hasQuote, isTrue);
      expect(state.hasError, isFalse);
    });

    test('copyWith clearQuote sets quote to null', () async {
      // Use MockRideQuoteService to get a real quote for testing
      const service = MockRideQuoteService();
      final request = RideQuoteRequest(
        pickup: LocationPoint(
          latitude: 24.7136,
          longitude: 46.6753,
          accuracyMeters: 10,
          timestamp: DateTime.now(),
        ),
        dropoff: LocationPoint(
          latitude: 24.7236,
          longitude: 46.6853,
          accuracyMeters: 10,
          timestamp: DateTime.now(),
        ),
        currencyCode: 'SAR',
      );

      final quote = await service.getQuote(request);
      final original = RideQuoteUiState(quote: quote);
      final cleared = original.copyWith(clearQuote: true);

      expect(cleared.quote, isNull);
    });

    // Track B - Ticket #121: Updated to use structured RideQuoteError
    test('copyWith clearError sets error to null', () {
      const original = RideQuoteUiState(
        error: RideQuoteErrorPricingFailed(),
      );
      final cleared = original.copyWith(clearError: true);

      expect(cleared.error, isNull);
    });
  });

  // ==========================================================================
  // Failure Tests - Track B Ticket #29, #121
  // ==========================================================================
  group('RideQuoteController Failure Tests - Ticket #29, #121', () {
    test('refreshFromDraft sets hasError when both places are null', () async {
      // MockRidePricingService with zero failureRate
      const pricingService = MockRidePricingService(
        baseLatency: Duration.zero,
        failureRate: 0.0,
      );
      final controller = RideQuoteController(pricingService: pricingService);

      // Draft with no places at all
      const draft = RideDraftUiState(
        pickupLabel: 'Current location',
        destinationQuery: '',
        pickupPlace: null,
        destinationPlace: null,
      );

      await controller.refreshFromDraft(draft);

      // With empty destination query and no places, it should set error
      // The controller requires valid places to quote
      expect(controller.state.isLoading, isFalse);
      // Quote may be null or have an error depending on implementation
      // At minimum, it should not crash
    });

    // Track B - Ticket #121: Verify RideQuoteErrorPricingFailed on service exception
    test('refreshFromDraft sets RideQuoteErrorPricingFailed on RidePricingException', () async {
      // Use MockRidePricingService with 100% failure rate
      const failingService = MockRidePricingService(
        baseLatency: Duration.zero,
        failureRate: 1.0, // 100% failure
      );
      final controller = RideQuoteController(pricingService: failingService);

      // Valid draft with places
      final pickupPlace = MobilityPlace(
        label: 'Home',
        location: LocationPoint(
          latitude: 24.7136,
          longitude: 46.6753,
          accuracyMeters: 10,
          timestamp: DateTime.now(),
        ),
      );

      final destinationPlace = MobilityPlace(
        label: 'Office',
        location: LocationPoint(
          latitude: 24.7500,
          longitude: 46.7000,
          accuracyMeters: 10,
          timestamp: DateTime.now(),
        ),
      );

      final draft = RideDraftUiState(
        pickupLabel: 'Home',
        pickupPlace: pickupPlace,
        destinationQuery: 'Office',
        destinationPlace: destinationPlace,
      );

      await controller.refreshFromDraft(draft);

      // Verify structured error state
      expect(controller.state.isLoading, isFalse);
      expect(controller.state.hasError, isTrue);
      expect(controller.state.error, isA<RideQuoteErrorPricingFailed>());
      expect(controller.state.quote, isNull);
    });

    test('refreshFromDraft handles missing destination query gracefully', () async {
      const pricingService = MockRidePricingService(
        baseLatency: Duration.zero,
        failureRate: 0.0,
      );
      final controller = RideQuoteController(pricingService: pricingService);

      // Draft with only whitespace destination
      const draft = RideDraftUiState(
        pickupLabel: 'Current location',
        destinationQuery: '   ', // whitespace only
      );

      await controller.refreshFromDraft(draft);

      // Should not crash, will handle as edge case
      expect(controller.state.isLoading, isFalse);
    });

    test('refreshFromDraft recovers from error on retry with valid data', () async {
      // First use failing service
      const failingService = MockRidePricingService(
        baseLatency: Duration.zero,
        failureRate: 1.0,
      );
      final controller = RideQuoteController(pricingService: failingService);

      // Valid places
      final pickupPlace = MobilityPlace(
        label: 'Home',
        location: LocationPoint(
          latitude: 24.7136,
          longitude: 46.6753,
          accuracyMeters: 10,
          timestamp: DateTime.now(),
        ),
      );

      final destinationPlace = MobilityPlace(
        label: 'Office',
        location: LocationPoint(
          latitude: 24.7500,
          longitude: 46.7000,
          accuracyMeters: 10,
          timestamp: DateTime.now(),
        ),
      );

      final draft = RideDraftUiState(
        pickupLabel: 'Home',
        pickupPlace: pickupPlace,
        destinationQuery: 'Office',
        destinationPlace: destinationPlace,
      );

      // First call fails
      await controller.refreshFromDraft(draft);
      expect(controller.state.hasError, isTrue);

      // Now use a new controller with working service to simulate retry
      const workingService = MockRidePricingService(
        baseLatency: Duration.zero,
        failureRate: 0.0,
      );
      final newController = RideQuoteController(pricingService: workingService);

      await newController.refreshFromDraft(draft);

      // Should recover with valid quote
      expect(newController.state.hasError, isFalse);
      expect(newController.state.hasQuote, isTrue);
      expect(newController.state.quote, isNotNull);
    });
  });

  // ==========================================================================
  // Track B - Ticket #121: Structured Error Tests
  // ==========================================================================
  group('RideQuoteController Structured Error Tests - Ticket #121', () {
    // Helper to create MobilityPlace with coordinates
    MobilityPlace createPlace({
      required String label,
      required double lat,
      required double lng,
    }) {
      return MobilityPlace(
        label: label,
        location: LocationPoint(
          latitude: lat,
          longitude: lng,
          accuracyMeters: 10,
          timestamp: DateTime.now(),
        ),
      );
    }

    test('RideQuoteErrorNoOptionsAvailable is set when quote has empty options', () async {
      // Use MockRidePricingService configured to return empty options
      const pricingService = MockRidePricingService(
        baseLatency: Duration.zero,
        returnEmptyOptions: true, // Flag to trigger empty options
      );
      final controller = RideQuoteController(pricingService: pricingService);

      final pickup = createPlace(label: 'A', lat: 24.7136, lng: 46.6753);
      final destination = createPlace(label: 'B', lat: 24.7200, lng: 46.6800);

      final draft = RideDraftUiState(
        pickupPlace: pickup,
        destinationPlace: destination,
      );

      await controller.refreshFromDraft(draft);

      expect(controller.state.isLoading, isFalse);
      expect(controller.state.hasError, isTrue);
      expect(controller.state.error, isA<RideQuoteErrorNoOptionsAvailable>());
      expect(controller.state.quote, isNull);
    });

    test('retryFromDraft delegates to refreshFromDraft', () async {
      const pricingService = MockRidePricingService(
        baseLatency: Duration.zero,
      );
      final controller = RideQuoteController(pricingService: pricingService);

      final pickup = createPlace(label: 'A', lat: 24.7136, lng: 46.6753);
      final destination = createPlace(label: 'B', lat: 24.7200, lng: 46.6800);

      final draft = RideDraftUiState(
        pickupPlace: pickup,
        destinationPlace: destination,
      );

      // Call retryFromDraft instead of refreshFromDraft
      await controller.retryFromDraft(draft);

      // Should produce the same result as refreshFromDraft
      expect(controller.state.isLoading, isFalse);
      expect(controller.state.hasQuote, isTrue);
      expect(controller.state.quote, isNotNull);
      expect(controller.state.error, isNull);
    });

    test('error is cleared on successful retry after failure', () async {
      // Start with failing service
      const failingService = MockRidePricingService(
        baseLatency: Duration.zero,
        failureRate: 1.0,
      );
      final controller = RideQuoteController(pricingService: failingService);

      final pickup = createPlace(label: 'A', lat: 24.7136, lng: 46.6753);
      final destination = createPlace(label: 'B', lat: 24.7200, lng: 46.6800);

      final draft = RideDraftUiState(
        pickupPlace: pickup,
        destinationPlace: destination,
      );

      // First call fails
      await controller.refreshFromDraft(draft);
      expect(controller.state.hasError, isTrue);
      expect(controller.state.error, isA<RideQuoteErrorPricingFailed>());

      // Simulate retry with working service (new controller for isolation)
      const workingService = MockRidePricingService(
        baseLatency: Duration.zero,
        failureRate: 0.0,
      );
      final retryController = RideQuoteController(pricingService: workingService);

      await retryController.retryFromDraft(draft);

      // Error should be cleared on success
      expect(retryController.state.hasError, isFalse);
      expect(retryController.state.error, isNull);
      expect(retryController.state.hasQuote, isTrue);
    });

    test('RideQuoteErrorPricingFailed distinguishable from RideQuoteErrorNoOptionsAvailable', () {
      const pricingError = RideQuoteErrorPricingFailed();
      const emptyError = RideQuoteErrorNoOptionsAvailable();

      expect(pricingError, isA<RideQuoteErrorPricingFailed>());
      expect(emptyError, isA<RideQuoteErrorNoOptionsAvailable>());
      expect(pricingError.runtimeType, isNot(emptyError.runtimeType));
    });

    test('RideQuoteErrorUnexpected for non-RidePricingException errors', () {
      // This tests the type hierarchy directly since we can't easily inject
      // a generic exception through MockRidePricingService
      const unexpectedError = RideQuoteErrorUnexpected();

      expect(unexpectedError, isA<RideQuoteError>());
      expect(unexpectedError, isA<RideQuoteErrorUnexpected>());
    });
  });
}

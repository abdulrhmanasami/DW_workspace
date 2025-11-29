/// ParcelQuoteState Unit Tests - Track C Ticket #43
/// Purpose: Safety net tests for ParcelQuoteUiState and ParcelQuoteController
/// Created by: Track C - Ticket #43
/// Last updated: 2025-11-28

import 'package:flutter_test/flutter_test.dart';
import 'package:parcels_shims/parcels_shims.dart';

import 'package:delivery_ways_clean/state/parcels/parcel_draft_state.dart';
import 'package:delivery_ways_clean/state/parcels/parcel_quote_state.dart';

void main() {
  group('ParcelQuoteUiState', () {
    test('default state has isLoading false', () {
      const state = ParcelQuoteUiState();

      expect(state.isLoading, false);
    });

    test('default state has quote null', () {
      const state = ParcelQuoteUiState();

      expect(state.quote, isNull);
    });

    test('default state has errorMessage null', () {
      const state = ParcelQuoteUiState();

      expect(state.errorMessage, isNull);
    });

    test('default state has hasQuote false', () {
      const state = ParcelQuoteUiState();

      expect(state.hasQuote, false);
    });

    test('default state has hasError false', () {
      const state = ParcelQuoteUiState();

      expect(state.hasError, false);
    });

    test('hasQuote returns true when quote is set', () {
      final quote = ParcelQuote(
        quoteId: 'test-quote',
        options: const [
          ParcelQuoteOption(
            id: 'standard',
            label: 'Standard',
            estimatedMinutes: 60,
            totalAmountCents: 1500,
            currencyCode: 'SAR',
          ),
        ],
      );

      final state = ParcelQuoteUiState(quote: quote);

      expect(state.hasQuote, true);
    });

    test('hasError returns true when errorMessage is non-empty', () {
      const state = ParcelQuoteUiState(errorMessage: 'Some error');

      expect(state.hasError, true);
    });

    test('hasError returns false when errorMessage is empty', () {
      const state = ParcelQuoteUiState(errorMessage: '');

      expect(state.hasError, false);
    });

    group('copyWith', () {
      test('updates isLoading correctly', () {
        const state = ParcelQuoteUiState();

        final updated = state.copyWith(isLoading: true);

        expect(updated.isLoading, true);
        expect(updated.quote, isNull);
        expect(updated.errorMessage, isNull);
      });

      test('updates quote correctly', () {
        const state = ParcelQuoteUiState();
        final quote = ParcelQuote(
          quoteId: 'test-quote',
          options: const [
            ParcelQuoteOption(
              id: 'standard',
              label: 'Standard',
              estimatedMinutes: 60,
              totalAmountCents: 1500,
              currencyCode: 'SAR',
            ),
          ],
        );

        final updated = state.copyWith(quote: quote);

        expect(updated.quote, isNotNull);
        expect(updated.quote!.quoteId, 'test-quote');
      });

      test('updates errorMessage correctly', () {
        const state = ParcelQuoteUiState();

        final updated = state.copyWith(errorMessage: 'Test error');

        expect(updated.errorMessage, 'Test error');
      });

      test('clearError sets errorMessage to null', () {
        const state = ParcelQuoteUiState(errorMessage: 'Some error');

        final updated = state.copyWith(clearError: true);

        expect(updated.errorMessage, isNull);
      });

      test('clearQuote sets quote to null', () {
        final quote = ParcelQuote(
          quoteId: 'test-quote',
          options: const [
            ParcelQuoteOption(
              id: 'standard',
              label: 'Standard',
              estimatedMinutes: 60,
              totalAmountCents: 1500,
              currencyCode: 'SAR',
            ),
          ],
        );
        final state = ParcelQuoteUiState(quote: quote);

        final updated = state.copyWith(clearQuote: true);

        expect(updated.quote, isNull);
      });

      test('preserves unchanged fields', () {
        final quote = ParcelQuote(
          quoteId: 'test-quote',
          options: const [
            ParcelQuoteOption(
              id: 'standard',
              label: 'Standard',
              estimatedMinutes: 60,
              totalAmountCents: 1500,
              currencyCode: 'SAR',
            ),
          ],
        );
        final state = ParcelQuoteUiState(
          isLoading: true,
          quote: quote,
          errorMessage: 'Some error',
        );

        final updated = state.copyWith(isLoading: false);

        expect(updated.isLoading, false);
        expect(updated.quote, quote);
        expect(updated.errorMessage, 'Some error');
      });
    });

    group('equality', () {
      test('two states with same values are equal', () {
        const state1 = ParcelQuoteUiState(isLoading: true);
        const state2 = ParcelQuoteUiState(isLoading: true);

        expect(state1, equals(state2));
      });

      test('two states with different values are not equal', () {
        const state1 = ParcelQuoteUiState(isLoading: true);
        const state2 = ParcelQuoteUiState(isLoading: false);

        expect(state1, isNot(equals(state2)));
      });

      test('hashCode is consistent for equal states', () {
        const state1 = ParcelQuoteUiState(isLoading: true);
        const state2 = ParcelQuoteUiState(isLoading: true);

        expect(state1.hashCode, equals(state2.hashCode));
      });
    });

    test('toString contains state info', () {
      const state = ParcelQuoteUiState(isLoading: true);

      final result = state.toString();

      expect(result, contains('isLoading: true'));
      expect(result, contains('hasQuote: false'));
      expect(result, contains('hasError: false'));
    });
  });

  group('ParcelQuoteController', () {
    late ParcelQuoteController controller;
    late MockParcelPricingService mockService;

    setUp(() {
      mockService = const MockParcelPricingService(
        baseLatency: Duration.zero,
        failureRate: 0.0,
      );
      controller = ParcelQuoteController(pricingService: mockService);
    });

    test('initial state is empty', () {
      expect(controller.state.isLoading, false);
      expect(controller.state.quote, isNull);
      expect(controller.state.errorMessage, isNull);
    });

    group('refreshFromDraft', () {
      test('success path - returns quote with options', () async {
        final draft = ParcelDraftUiState(
          pickupAddress: '123 Main Street',
          dropoffAddress: '456 Oak Avenue',
          size: ParcelSize.medium,
          weightText: '2.5',
          contentsDescription: 'Electronics',
          isFragile: true,
        );

        await controller.refreshFromDraft(draft);

        expect(controller.state.isLoading, false);
        expect(controller.state.hasQuote, true);
        expect(controller.state.hasError, false);
        expect(controller.state.quote!.options.length, greaterThan(0));
      });

      test('missing size returns error', () async {
        const draft = ParcelDraftUiState(
          pickupAddress: '123 Main Street',
          dropoffAddress: '456 Oak Avenue',
          weightText: '2.5',
          contentsDescription: 'Electronics',
        );

        await controller.refreshFromDraft(draft);

        expect(controller.state.isLoading, false);
        expect(controller.state.hasQuote, false);
        expect(controller.state.hasError, true);
      });

      test('missing weight returns error', () async {
        final draft = ParcelDraftUiState(
          pickupAddress: '123 Main Street',
          dropoffAddress: '456 Oak Avenue',
          size: ParcelSize.medium,
          weightText: '',
          contentsDescription: 'Electronics',
        );

        await controller.refreshFromDraft(draft);

        expect(controller.state.isLoading, false);
        expect(controller.state.hasQuote, false);
        expect(controller.state.hasError, true);
      });

      test('missing pickup address returns error', () async {
        final draft = ParcelDraftUiState(
          pickupAddress: '',
          dropoffAddress: '456 Oak Avenue',
          size: ParcelSize.medium,
          weightText: '2.5',
          contentsDescription: 'Electronics',
        );

        await controller.refreshFromDraft(draft);

        expect(controller.state.isLoading, false);
        expect(controller.state.hasQuote, false);
        expect(controller.state.hasError, true);
      });

      test('missing dropoff address returns error', () async {
        final draft = ParcelDraftUiState(
          pickupAddress: '123 Main Street',
          dropoffAddress: '',
          size: ParcelSize.medium,
          weightText: '2.5',
          contentsDescription: 'Electronics',
        );

        await controller.refreshFromDraft(draft);

        expect(controller.state.isLoading, false);
        expect(controller.state.hasQuote, false);
        expect(controller.state.hasError, true);
      });

      test('pricing failure returns error', () async {
        // Use a mock service with 100% failure rate
        final failingService = const MockParcelPricingService(
          baseLatency: Duration.zero,
          failureRate: 1.0,
        );
        final failingController = ParcelQuoteController(
          pricingService: failingService,
        );

        final draft = ParcelDraftUiState(
          pickupAddress: '123 Main Street',
          dropoffAddress: '456 Oak Avenue',
          size: ParcelSize.medium,
          weightText: '2.5',
          contentsDescription: 'Electronics',
        );

        await failingController.refreshFromDraft(draft);

        expect(failingController.state.isLoading, false);
        expect(failingController.state.hasQuote, false);
        expect(failingController.state.hasError, true);
      });

      test('handles weight with comma as decimal separator', () async {
        final draft = ParcelDraftUiState(
          pickupAddress: '123 Main Street',
          dropoffAddress: '456 Oak Avenue',
          size: ParcelSize.medium,
          weightText: '2,5', // comma instead of dot
          contentsDescription: 'Electronics',
        );

        await controller.refreshFromDraft(draft);

        expect(controller.state.isLoading, false);
        expect(controller.state.hasQuote, true);
        expect(controller.state.hasError, false);
      });

      test('handles invalid weight gracefully (defaults to 1.0)', () async {
        final draft = ParcelDraftUiState(
          pickupAddress: '123 Main Street',
          dropoffAddress: '456 Oak Avenue',
          size: ParcelSize.medium,
          weightText: 'invalid',
          contentsDescription: 'Electronics',
        );

        await controller.refreshFromDraft(draft);

        // Even with invalid weight, it should still succeed (defaults to 1.0)
        expect(controller.state.isLoading, false);
        expect(controller.state.hasQuote, true);
        expect(controller.state.hasError, false);
      });
    });

    group('clearError', () {
      test('clears error message', () async {
        // First cause an error
        const draft = ParcelDraftUiState(
          pickupAddress: '',
          dropoffAddress: '',
        );
        await controller.refreshFromDraft(draft);
        expect(controller.state.hasError, true);

        // Then clear it
        controller.clearError();

        expect(controller.state.hasError, false);
        expect(controller.state.errorMessage, isNull);
      });
    });

    group('reset', () {
      test('resets state to initial values', () async {
        // First load some data
        final draft = ParcelDraftUiState(
          pickupAddress: '123 Main Street',
          dropoffAddress: '456 Oak Avenue',
          size: ParcelSize.medium,
          weightText: '2.5',
          contentsDescription: 'Electronics',
        );
        await controller.refreshFromDraft(draft);
        expect(controller.state.hasQuote, true);

        // Then reset
        controller.reset();

        expect(controller.state.isLoading, false);
        expect(controller.state.quote, isNull);
        expect(controller.state.errorMessage, isNull);
      });
    });
  });
}


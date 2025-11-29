/// ParcelOrdersState Unit Tests - Track C Ticket #44
/// Purpose: Safety net tests for ParcelOrdersState and ParcelOrdersController
/// Created by: Track C - Ticket #44
/// Updated by: Track C - Ticket #49 (ParcelsRepository Port integration)
/// Last updated: 2025-11-28

import 'package:flutter_test/flutter_test.dart';
import 'package:parcels_shims/parcels_shims.dart';

import 'package:delivery_ways_clean/state/parcels/app_parcels_repository.dart';
import 'package:delivery_ways_clean/state/parcels/parcel_draft_state.dart';
import 'package:delivery_ways_clean/state/parcels/parcel_orders_state.dart';

void main() {
  group('ParcelOrdersState', () {
    test('default state has null activeParcel', () {
      const state = ParcelOrdersState();

      expect(state.activeParcel, isNull);
    });

    test('default state has empty parcels list', () {
      const state = ParcelOrdersState();

      expect(state.parcels, isEmpty);
    });

    group('copyWith', () {
      test('updates activeParcel correctly', () {
        const state = ParcelOrdersState();
        final parcel = _createTestParcel('test-1');

        final updated = state.copyWith(activeParcel: parcel);

        expect(updated.activeParcel, isNotNull);
        expect(updated.activeParcel!.id, 'test-1');
      });

      test('updates parcels list correctly', () {
        const state = ParcelOrdersState();
        final parcel1 = _createTestParcel('test-1');
        final parcel2 = _createTestParcel('test-2');

        final updated = state.copyWith(parcels: [parcel1, parcel2]);

        expect(updated.parcels.length, 2);
        expect(updated.parcels[0].id, 'test-1');
        expect(updated.parcels[1].id, 'test-2');
      });

      test('clearActive sets activeParcel to null', () {
        final parcel = _createTestParcel('test-1');
        final state = ParcelOrdersState(activeParcel: parcel);

        final updated = state.copyWith(clearActive: true);

        expect(updated.activeParcel, isNull);
      });

      test('clearActive preserves parcels list', () {
        final parcel = _createTestParcel('test-1');
        final state = ParcelOrdersState(
          activeParcel: parcel,
          parcels: [parcel],
        );

        final updated = state.copyWith(clearActive: true);

        expect(updated.activeParcel, isNull);
        expect(updated.parcels.length, 1);
      });

      test('preserves unchanged fields', () {
        final parcel = _createTestParcel('test-1');
        final state = ParcelOrdersState(
          activeParcel: parcel,
          parcels: [parcel],
        );

        final updated = state.copyWith();

        expect(updated.activeParcel, parcel);
        expect(updated.parcels.length, 1);
      });
    });

    group('equality', () {
      test('two states with same values are equal', () {
        final parcel = _createTestParcel('test-1');
        final state1 = ParcelOrdersState(
          activeParcel: parcel,
          parcels: [parcel],
        );
        final state2 = ParcelOrdersState(
          activeParcel: parcel,
          parcels: [parcel],
        );

        expect(state1, equals(state2));
      });

      test('two states with different values are not equal', () {
        final parcel1 = _createTestParcel('test-1');
        final parcel2 = _createTestParcel('test-2');
        final state1 = ParcelOrdersState(activeParcel: parcel1);
        final state2 = ParcelOrdersState(activeParcel: parcel2);

        expect(state1, isNot(equals(state2)));
      });

      test('hashCode is consistent for equal states', () {
        const state1 = ParcelOrdersState();
        const state2 = ParcelOrdersState();

        expect(state1.hashCode, equals(state2.hashCode));
      });
    });

    test('toString contains state info', () {
      final parcel = _createTestParcel('test-1');
      final state = ParcelOrdersState(
        activeParcel: parcel,
        parcels: [parcel],
      );

      final result = state.toString();

      expect(result, contains('activeParcel:'));
      expect(result, contains('parcels: 1'));
    });
  });

  group('ParcelOrdersController', () {
    late ParcelOrdersController controller;
    late AppParcelsRepository repository;

    setUp(() {
      // Track C - Ticket #49: Now requires ParcelsRepository
      repository = AppParcelsRepository();
      controller = ParcelOrdersController(repository: repository);
    });

    test('initial state is empty', () {
      expect(controller.state.activeParcel, isNull);
      expect(controller.state.parcels, isEmpty);
    });

    group('createParcelFromDraft', () {
      test('creates parcel with correct properties from draft', () {
        final draft = ParcelDraftUiState(
          pickupAddress: '123 Main Street',
          dropoffAddress: '456 Oak Avenue',
          size: ParcelSize.medium,
          weightText: '2.5',
          contentsDescription: 'Electronics',
          isFragile: true,
          selectedQuoteOptionId: 'standard',
        );
        final quote = _createTestQuote();
        final selectedOption = quote.options.first;

        final parcel = controller.createParcelFromDraft(
          draft: draft,
          quote: quote,
          selectedOption: selectedOption,
        );

        expect(parcel.pickupAddress.label, '123 Main Street');
        expect(parcel.dropoffAddress.label, '456 Oak Avenue');
        expect(parcel.details.size, ParcelSize.medium);
        expect(parcel.details.weightKg, 2.5);
        expect(parcel.details.description, 'Electronics');
        expect(parcel.status, ParcelStatus.scheduled);
      });

      test('adds parcel to state.parcels list', () {
        final draft = _createCompleteDraft();
        final quote = _createTestQuote();
        final selectedOption = quote.options.first;

        controller.createParcelFromDraft(
          draft: draft,
          quote: quote,
          selectedOption: selectedOption,
        );

        expect(controller.state.parcels.length, 1);
      });

      test('sets created parcel as activeParcel', () {
        final draft = _createCompleteDraft();
        final quote = _createTestQuote();
        final selectedOption = quote.options.first;

        final parcel = controller.createParcelFromDraft(
          draft: draft,
          quote: quote,
          selectedOption: selectedOption,
        );

        expect(controller.state.activeParcel, parcel);
      });

      test('returns the created parcel', () {
        final draft = _createCompleteDraft();
        final quote = _createTestQuote();
        final selectedOption = quote.options.first;

        final parcel = controller.createParcelFromDraft(
          draft: draft,
          quote: quote,
          selectedOption: selectedOption,
        );

        expect(parcel, isNotNull);
        expect(parcel.id, isNotEmpty);
      });

      test('generates unique parcel IDs', () {
        final draft = _createCompleteDraft();
        final quote = _createTestQuote();
        final selectedOption = quote.options.first;

        final parcel1 = controller.createParcelFromDraft(
          draft: draft,
          quote: quote,
          selectedOption: selectedOption,
        );
        final parcel2 = controller.createParcelFromDraft(
          draft: draft,
          quote: quote,
          selectedOption: selectedOption,
        );

        expect(parcel1.id, isNot(equals(parcel2.id)));
      });

      test('handles weight with comma as decimal separator', () {
        final draft = ParcelDraftUiState(
          pickupAddress: '123 Main Street',
          dropoffAddress: '456 Oak Avenue',
          size: ParcelSize.medium,
          weightText: '2,5', // comma instead of dot
          contentsDescription: 'Electronics',
        );
        final quote = _createTestQuote();
        final selectedOption = quote.options.first;

        final parcel = controller.createParcelFromDraft(
          draft: draft,
          quote: quote,
          selectedOption: selectedOption,
        );

        expect(parcel.details.weightKg, 2.5);
      });

      test('defaults to 1.0 kg for invalid weight', () {
        final draft = ParcelDraftUiState(
          pickupAddress: '123 Main Street',
          dropoffAddress: '456 Oak Avenue',
          size: ParcelSize.medium,
          weightText: 'invalid',
          contentsDescription: 'Electronics',
        );
        final quote = _createTestQuote();
        final selectedOption = quote.options.first;

        final parcel = controller.createParcelFromDraft(
          draft: draft,
          quote: quote,
          selectedOption: selectedOption,
        );

        expect(parcel.details.weightKg, 1.0);
      });

      test('defaults to medium size when draft.size is null', () {
        const draft = ParcelDraftUiState(
          pickupAddress: '123 Main Street',
          dropoffAddress: '456 Oak Avenue',
          size: null,
          weightText: '2.5',
          contentsDescription: 'Electronics',
        );
        final quote = _createTestQuote();
        final selectedOption = quote.options.first;

        final parcel = controller.createParcelFromDraft(
          draft: draft,
          quote: quote,
          selectedOption: selectedOption,
        );

        expect(parcel.details.size, ParcelSize.medium);
      });

      test('sets description to null when empty', () {
        const draft = ParcelDraftUiState(
          pickupAddress: '123 Main Street',
          dropoffAddress: '456 Oak Avenue',
          size: ParcelSize.medium,
          weightText: '2.5',
          contentsDescription: '',
        );
        final quote = _createTestQuote();
        final selectedOption = quote.options.first;

        final parcel = controller.createParcelFromDraft(
          draft: draft,
          quote: quote,
          selectedOption: selectedOption,
        );

        expect(parcel.details.description, isNull);
      });

      test('accumulates multiple parcels in list', () {
        final draft = _createCompleteDraft();
        final quote = _createTestQuote();
        final selectedOption = quote.options.first;

        controller.createParcelFromDraft(
          draft: draft,
          quote: quote,
          selectedOption: selectedOption,
        );
        controller.createParcelFromDraft(
          draft: draft,
          quote: quote,
          selectedOption: selectedOption,
        );
        controller.createParcelFromDraft(
          draft: draft,
          quote: quote,
          selectedOption: selectedOption,
        );

        expect(controller.state.parcels.length, 3);
      });
    });

    group('clearActiveParcel', () {
      test('sets activeParcel to null', () {
        final draft = _createCompleteDraft();
        final quote = _createTestQuote();
        final selectedOption = quote.options.first;

        controller.createParcelFromDraft(
          draft: draft,
          quote: quote,
          selectedOption: selectedOption,
        );
        expect(controller.state.activeParcel, isNotNull);

        controller.clearActiveParcel();

        expect(controller.state.activeParcel, isNull);
      });

      test('preserves parcels list', () {
        final draft = _createCompleteDraft();
        final quote = _createTestQuote();
        final selectedOption = quote.options.first;

        controller.createParcelFromDraft(
          draft: draft,
          quote: quote,
          selectedOption: selectedOption,
        );
        expect(controller.state.parcels.length, 1);

        controller.clearActiveParcel();

        expect(controller.state.parcels.length, 1);
      });
    });

    group('reset', () {
      test('clears activeParcel', () {
        final draft = _createCompleteDraft();
        final quote = _createTestQuote();
        final selectedOption = quote.options.first;

        controller.createParcelFromDraft(
          draft: draft,
          quote: quote,
          selectedOption: selectedOption,
        );
        expect(controller.state.activeParcel, isNotNull);

        controller.reset();

        expect(controller.state.activeParcel, isNull);
      });

      test('clears parcels list', () {
        final draft = _createCompleteDraft();
        final quote = _createTestQuote();
        final selectedOption = quote.options.first;

        controller.createParcelFromDraft(
          draft: draft,
          quote: quote,
          selectedOption: selectedOption,
        );
        expect(controller.state.parcels.length, 1);

        controller.reset();

        expect(controller.state.parcels, isEmpty);
      });

      test('returns state to initial values', () {
        final draft = _createCompleteDraft();
        final quote = _createTestQuote();
        final selectedOption = quote.options.first;

        controller.createParcelFromDraft(
          draft: draft,
          quote: quote,
          selectedOption: selectedOption,
        );

        controller.reset();

        expect(controller.state, equals(const ParcelOrdersState()));
      });
    });
  });
}

/// Helper to create a test Parcel.
Parcel _createTestParcel(String id) {
  return Parcel(
    id: id,
    createdAt: DateTime.now(),
    pickupAddress: const ParcelAddress(label: 'Test Pickup'),
    dropoffAddress: const ParcelAddress(label: 'Test Dropoff'),
    details: const ParcelDetails(
      size: ParcelSize.medium,
      weightKg: 2.5,
      description: 'Test contents',
    ),
    status: ParcelStatus.scheduled,
  );
}

/// Helper to create a complete draft for testing.
ParcelDraftUiState _createCompleteDraft() {
  return ParcelDraftUiState(
    pickupAddress: '123 Main Street',
    dropoffAddress: '456 Oak Avenue',
    size: ParcelSize.medium,
    weightText: '2.5',
    contentsDescription: 'Electronics',
    isFragile: true,
    selectedQuoteOptionId: 'standard',
  );
}

/// Helper to create a test ParcelQuote.
ParcelQuote _createTestQuote() {
  return ParcelQuote(
    quoteId: 'test-quote-123',
    options: const [
      ParcelQuoteOption(
        id: 'standard',
        label: 'Standard',
        estimatedMinutes: 60,
        totalAmountCents: 1500,
        currencyCode: 'SAR',
      ),
      ParcelQuoteOption(
        id: 'express',
        label: 'Express',
        estimatedMinutes: 30,
        totalAmountCents: 2250,
        currencyCode: 'SAR',
      ),
    ],
  );
}


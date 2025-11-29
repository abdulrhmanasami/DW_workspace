/// ParcelDraftState Unit Tests - Track C Ticket #41 + #42 + #43
/// Purpose: Safety net tests for ParcelDraftUiState and ParcelDraftController
/// Created by: Track C - Ticket #41
/// Last updated: 2025-11-28 (Ticket #43 - Added tests for selectedQuoteOptionId)

import 'package:flutter_test/flutter_test.dart';
import 'package:parcels_shims/parcels_shims.dart' show ParcelSize;

import 'package:delivery_ways_clean/state/parcels/parcel_draft_state.dart';

void main() {
  group('ParcelDraftUiState', () {
    test('default state has empty pickupAddress', () {
      const state = ParcelDraftUiState();

      expect(state.pickupAddress, '');
    });

    test('default state has empty dropoffAddress', () {
      const state = ParcelDraftUiState();

      expect(state.dropoffAddress, '');
    });

    test('default state has null size', () {
      const state = ParcelDraftUiState();

      expect(state.size, isNull);
    });

    test('default state has empty weightText', () {
      const state = ParcelDraftUiState();

      expect(state.weightText, '');
    });

    test('default state has empty contentsDescription', () {
      const state = ParcelDraftUiState();

      expect(state.contentsDescription, '');
    });

    test('default state has isFragile false', () {
      const state = ParcelDraftUiState();

      expect(state.isFragile, false);
    });

    test('default state has null selectedQuoteOptionId', () {
      const state = ParcelDraftUiState();

      expect(state.selectedQuoteOptionId, isNull);
    });

    test('copyWith updates pickupAddress correctly', () {
      const state = ParcelDraftUiState();

      final updated = state.copyWith(pickupAddress: '123 Main Street');

      expect(updated.pickupAddress, '123 Main Street');
      expect(updated.dropoffAddress, '');
    });

    test('copyWith updates dropoffAddress correctly', () {
      const state = ParcelDraftUiState();

      final updated = state.copyWith(dropoffAddress: '456 Oak Avenue');

      expect(updated.pickupAddress, '');
      expect(updated.dropoffAddress, '456 Oak Avenue');
    });

    test('copyWith updates both fields correctly', () {
      const state = ParcelDraftUiState();

      final updated = state.copyWith(
        pickupAddress: 'Pickup Location',
        dropoffAddress: 'Delivery Location',
      );

      expect(updated.pickupAddress, 'Pickup Location');
      expect(updated.dropoffAddress, 'Delivery Location');
    });

    test('copyWith preserves unchanged fields', () {
      const state = ParcelDraftUiState(
        pickupAddress: 'Original Pickup',
        dropoffAddress: 'Original Dropoff',
      );

      final updated = state.copyWith(pickupAddress: 'New Pickup');

      expect(updated.pickupAddress, 'New Pickup');
      expect(updated.dropoffAddress, 'Original Dropoff');
    });

    test('copyWith updates size correctly', () {
      const state = ParcelDraftUiState();

      final updated = state.copyWith(size: ParcelSize.medium);

      expect(updated.size, ParcelSize.medium);
    });

    test('copyWith with clearSize sets size to null', () {
      final state = ParcelDraftUiState(size: ParcelSize.large);

      final updated = state.copyWith(clearSize: true);

      expect(updated.size, isNull);
    });

    test('copyWith updates weightText correctly', () {
      const state = ParcelDraftUiState();

      final updated = state.copyWith(weightText: '2.5');

      expect(updated.weightText, '2.5');
    });

    test('copyWith updates contentsDescription correctly', () {
      const state = ParcelDraftUiState();

      final updated = state.copyWith(contentsDescription: 'Electronics');

      expect(updated.contentsDescription, 'Electronics');
    });

    test('copyWith updates isFragile correctly', () {
      const state = ParcelDraftUiState();

      final updated = state.copyWith(isFragile: true);

      expect(updated.isFragile, true);
    });

    test('copyWith updates selectedQuoteOptionId correctly', () {
      const state = ParcelDraftUiState();

      final updated = state.copyWith(selectedQuoteOptionId: 'standard');

      expect(updated.selectedQuoteOptionId, 'standard');
    });

    test('copyWith with clearSelectedQuoteOptionId sets to null', () {
      final state = ParcelDraftUiState(selectedQuoteOptionId: 'express');

      final updated = state.copyWith(clearSelectedQuoteOptionId: true);

      expect(updated.selectedQuoteOptionId, isNull);
    });

    test('copyWith preserves all fields when updating one', () {
      final state = ParcelDraftUiState(
        pickupAddress: 'Pickup',
        dropoffAddress: 'Dropoff',
        size: ParcelSize.small,
        weightText: '1.0',
        contentsDescription: 'Books',
        isFragile: true,
        selectedQuoteOptionId: 'standard',
      );

      final updated = state.copyWith(weightText: '2.0');

      expect(updated.pickupAddress, 'Pickup');
      expect(updated.dropoffAddress, 'Dropoff');
      expect(updated.size, ParcelSize.small);
      expect(updated.weightText, '2.0');
      expect(updated.contentsDescription, 'Books');
      expect(updated.isFragile, true);
      expect(updated.selectedQuoteOptionId, 'standard');
    });

    group('equality', () {
      test('two states with same values are equal', () {
        const state1 = ParcelDraftUiState(
          pickupAddress: 'A',
          dropoffAddress: 'B',
        );
        const state2 = ParcelDraftUiState(
          pickupAddress: 'A',
          dropoffAddress: 'B',
        );

        expect(state1, equals(state2));
      });

      test('two states with different values are not equal', () {
        const state1 = ParcelDraftUiState(
          pickupAddress: 'A',
          dropoffAddress: 'B',
        );
        const state2 = ParcelDraftUiState(
          pickupAddress: 'C',
          dropoffAddress: 'D',
        );

        expect(state1, isNot(equals(state2)));
      });

      test('hashCode is consistent for equal states', () {
        const state1 = ParcelDraftUiState(
          pickupAddress: 'A',
          dropoffAddress: 'B',
        );
        const state2 = ParcelDraftUiState(
          pickupAddress: 'A',
          dropoffAddress: 'B',
        );

        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('two states with same new fields are equal', () {
        final state1 = ParcelDraftUiState(
          pickupAddress: 'A',
          dropoffAddress: 'B',
          size: ParcelSize.medium,
          weightText: '2.5',
          contentsDescription: 'Clothes',
          isFragile: false,
          selectedQuoteOptionId: 'standard',
        );
        final state2 = ParcelDraftUiState(
          pickupAddress: 'A',
          dropoffAddress: 'B',
          size: ParcelSize.medium,
          weightText: '2.5',
          contentsDescription: 'Clothes',
          isFragile: false,
          selectedQuoteOptionId: 'standard',
        );

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('two states with different selectedQuoteOptionId are not equal', () {
        final state1 = ParcelDraftUiState(
          pickupAddress: 'A',
          dropoffAddress: 'B',
          selectedQuoteOptionId: 'standard',
        );
        final state2 = ParcelDraftUiState(
          pickupAddress: 'A',
          dropoffAddress: 'B',
          selectedQuoteOptionId: 'express',
        );

        expect(state1, isNot(equals(state2)));
      });

      test('two states with different new fields are not equal', () {
        final state1 = ParcelDraftUiState(
          pickupAddress: 'A',
          dropoffAddress: 'B',
          size: ParcelSize.small,
        );
        final state2 = ParcelDraftUiState(
          pickupAddress: 'A',
          dropoffAddress: 'B',
          size: ParcelSize.large,
        );

        expect(state1, isNot(equals(state2)));
      });
    });

    test('toString contains field values', () {
      const state = ParcelDraftUiState(
        pickupAddress: 'Pickup',
        dropoffAddress: 'Dropoff',
      );

      final result = state.toString();

      expect(result, contains('pickupAddress: Pickup'));
      expect(result, contains('dropoffAddress: Dropoff'));
    });

    test('toString contains new field values', () {
      final state = ParcelDraftUiState(
        pickupAddress: 'Pickup',
        dropoffAddress: 'Dropoff',
        size: ParcelSize.medium,
        weightText: '3.0',
        contentsDescription: 'Electronics',
        isFragile: true,
        selectedQuoteOptionId: 'express',
      );

      final result = state.toString();

      expect(result, contains('size: ParcelSize.medium'));
      expect(result, contains('weightText: 3.0'));
      expect(result, contains('contentsDescription: Electronics'));
      expect(result, contains('isFragile: true'));
      expect(result, contains('selectedQuoteOptionId: express'));
    });
  });

  group('ParcelDraftController', () {
    test('initial state has empty pickup address', () {
      final controller = ParcelDraftController();

      expect(controller.state.pickupAddress, '');
    });

    test('initial state has empty dropoff address', () {
      final controller = ParcelDraftController();

      expect(controller.state.dropoffAddress, '');
    });

    test('initial state has null size', () {
      final controller = ParcelDraftController();

      expect(controller.state.size, isNull);
    });

    test('initial state has empty weightText', () {
      final controller = ParcelDraftController();

      expect(controller.state.weightText, '');
    });

    test('initial state has empty contentsDescription', () {
      final controller = ParcelDraftController();

      expect(controller.state.contentsDescription, '');
    });

    test('initial state has isFragile false', () {
      final controller = ParcelDraftController();

      expect(controller.state.isFragile, false);
    });

    test('initial state has null selectedQuoteOptionId', () {
      final controller = ParcelDraftController();

      expect(controller.state.selectedQuoteOptionId, isNull);
    });

    group('updatePickupAddress', () {
      test('updates pickup address', () {
        final controller = ParcelDraftController();

        controller.updatePickupAddress('123 Main Street');

        expect(controller.state.pickupAddress, '123 Main Street');
        expect(controller.state.dropoffAddress, '');
      });

      test('can update pickup address multiple times', () {
        final controller = ParcelDraftController();

        controller.updatePickupAddress('First');
        expect(controller.state.pickupAddress, 'First');

        controller.updatePickupAddress('Second');
        expect(controller.state.pickupAddress, 'Second');
      });
    });

    group('updateDropoffAddress', () {
      test('updates dropoff address', () {
        final controller = ParcelDraftController();

        controller.updateDropoffAddress('456 Oak Avenue');

        expect(controller.state.pickupAddress, '');
        expect(controller.state.dropoffAddress, '456 Oak Avenue');
      });

      test('can update dropoff address multiple times', () {
        final controller = ParcelDraftController();

        controller.updateDropoffAddress('First');
        expect(controller.state.dropoffAddress, 'First');

        controller.updateDropoffAddress('Second');
        expect(controller.state.dropoffAddress, 'Second');
      });
    });

    group('updateSize', () {
      test('updates size', () {
        final controller = ParcelDraftController();

        controller.updateSize(ParcelSize.small);

        expect(controller.state.size, ParcelSize.small);
      });

      test('can update size multiple times', () {
        final controller = ParcelDraftController();

        controller.updateSize(ParcelSize.small);
        expect(controller.state.size, ParcelSize.small);

        controller.updateSize(ParcelSize.large);
        expect(controller.state.size, ParcelSize.large);
      });
    });

    group('clearSize', () {
      test('clears size to null', () {
        final controller = ParcelDraftController();
        controller.updateSize(ParcelSize.medium);

        controller.clearSize();

        expect(controller.state.size, isNull);
      });

      test('clearSize on fresh controller does not throw', () {
        final controller = ParcelDraftController();

        expect(() => controller.clearSize(), returnsNormally);
        expect(controller.state.size, isNull);
      });
    });

    group('updateWeightText', () {
      test('updates weightText', () {
        final controller = ParcelDraftController();

        controller.updateWeightText('2.5');

        expect(controller.state.weightText, '2.5');
      });

      test('can update weightText multiple times', () {
        final controller = ParcelDraftController();

        controller.updateWeightText('1.0');
        expect(controller.state.weightText, '1.0');

        controller.updateWeightText('3.5');
        expect(controller.state.weightText, '3.5');
      });
    });

    group('updateContentsDescription', () {
      test('updates contentsDescription', () {
        final controller = ParcelDraftController();

        controller.updateContentsDescription('Electronics');

        expect(controller.state.contentsDescription, 'Electronics');
      });

      test('can update contentsDescription multiple times', () {
        final controller = ParcelDraftController();

        controller.updateContentsDescription('Books');
        expect(controller.state.contentsDescription, 'Books');

        controller.updateContentsDescription('Clothes');
        expect(controller.state.contentsDescription, 'Clothes');
      });
    });

    group('toggleFragile', () {
      test('toggles isFragile from false to true', () {
        final controller = ParcelDraftController();

        controller.toggleFragile();

        expect(controller.state.isFragile, true);
      });

      test('toggles isFragile from true to false', () {
        final controller = ParcelDraftController();
        controller.toggleFragile(); // now true

        controller.toggleFragile(); // now false

        expect(controller.state.isFragile, false);
      });

      test('can toggle multiple times', () {
        final controller = ParcelDraftController();

        controller.toggleFragile();
        expect(controller.state.isFragile, true);

        controller.toggleFragile();
        expect(controller.state.isFragile, false);

        controller.toggleFragile();
        expect(controller.state.isFragile, true);
      });
    });

    group('updateSelectedQuoteOptionId', () {
      test('updates selectedQuoteOptionId', () {
        final controller = ParcelDraftController();

        controller.updateSelectedQuoteOptionId('standard');

        expect(controller.state.selectedQuoteOptionId, 'standard');
      });

      test('can update selectedQuoteOptionId multiple times', () {
        final controller = ParcelDraftController();

        controller.updateSelectedQuoteOptionId('standard');
        expect(controller.state.selectedQuoteOptionId, 'standard');

        controller.updateSelectedQuoteOptionId('express');
        expect(controller.state.selectedQuoteOptionId, 'express');
      });

      test('passing null clears selectedQuoteOptionId', () {
        final controller = ParcelDraftController();
        controller.updateSelectedQuoteOptionId('standard');

        controller.updateSelectedQuoteOptionId(null);

        expect(controller.state.selectedQuoteOptionId, isNull);
      });
    });

    group('reset', () {
      test('resets state to default values', () {
        final controller = ParcelDraftController();

        controller.updatePickupAddress('Some Pickup');
        controller.updateDropoffAddress('Some Dropoff');

        controller.reset();

        expect(controller.state.pickupAddress, '');
        expect(controller.state.dropoffAddress, '');
      });

      test('reset clears all new fields', () {
        final controller = ParcelDraftController();

        controller.updatePickupAddress('Pickup');
        controller.updateDropoffAddress('Dropoff');
        controller.updateSize(ParcelSize.large);
        controller.updateWeightText('5.0');
        controller.updateContentsDescription('Furniture');
        controller.toggleFragile(); // set to true
        controller.updateSelectedQuoteOptionId('express');

        controller.reset();

        expect(controller.state.pickupAddress, '');
        expect(controller.state.dropoffAddress, '');
        expect(controller.state.size, isNull);
        expect(controller.state.weightText, '');
        expect(controller.state.contentsDescription, '');
        expect(controller.state.isFragile, false);
        expect(controller.state.selectedQuoteOptionId, isNull);
      });

      test('reset on fresh controller does not throw', () {
        final controller = ParcelDraftController();

        expect(() => controller.reset(), returnsNormally);
        expect(controller.state.pickupAddress, '');
        expect(controller.state.dropoffAddress, '');
      });
    });

    test('updates preserve other field values', () {
      final controller = ParcelDraftController();

      controller.updatePickupAddress('Pickup');
      controller.updateDropoffAddress('Dropoff');
      controller.updateSize(ParcelSize.small);
      controller.updateWeightText('1.5');
      controller.updateContentsDescription('Documents');
      controller.toggleFragile();
      controller.updateSelectedQuoteOptionId('standard');

      expect(controller.state.pickupAddress, 'Pickup');
      expect(controller.state.dropoffAddress, 'Dropoff');
      expect(controller.state.size, ParcelSize.small);
      expect(controller.state.weightText, '1.5');
      expect(controller.state.contentsDescription, 'Documents');
      expect(controller.state.isFragile, true);
      expect(controller.state.selectedQuoteOptionId, 'standard');
    });
  });
}

/// RideDraftController Unit Tests - Track B Ticket #17
/// Purpose: Safety net tests for RideDraftController before deeper integration
/// Created by: Track B - Ticket #17
/// Last updated: 2025-11-28

import 'package:flutter_test/flutter_test.dart';

import 'package:delivery_ways_clean/state/mobility/ride_draft_state.dart';

void main() {
  group('RideDraftController', () {
    group('initial state', () {
      test('has default pickup label "Current location"', () {
        final controller = RideDraftController();

        expect(controller.state.pickupLabel, 'Current location');
      });

      test('has empty destination query', () {
        final controller = RideDraftController();

        expect(controller.state.destinationQuery, '');
      });

      test('has null selectedOptionId', () {
        final controller = RideDraftController();

        expect(controller.state.selectedOptionId, isNull);
      });
    });

    group('updateDestination', () {
      test('updates destination query only', () {
        final controller = RideDraftController();

        controller.updateDestination('Riyadh Airport');

        expect(controller.state.destinationQuery, 'Riyadh Airport');
        expect(controller.state.pickupLabel, 'Current location');
        expect(controller.state.selectedOptionId, isNull);
      });

      test('can update destination multiple times', () {
        final controller = RideDraftController();

        controller.updateDestination('First destination');
        expect(controller.state.destinationQuery, 'First destination');

        controller.updateDestination('Second destination');
        expect(controller.state.destinationQuery, 'Second destination');
      });
    });

    group('updateSelectedOption', () {
      test('selects option by id', () {
        final controller = RideDraftController();

        controller.updateSelectedOption('economy');

        expect(controller.state.selectedOptionId, 'economy');
        expect(controller.state.pickupLabel, 'Current location');
        expect(controller.state.destinationQuery, '');
      });

      test('can change selected option', () {
        final controller = RideDraftController();

        controller.updateSelectedOption('economy');
        expect(controller.state.selectedOptionId, 'economy');

        controller.updateSelectedOption('xl');
        expect(controller.state.selectedOptionId, 'xl');

        controller.updateSelectedOption('premium');
        expect(controller.state.selectedOptionId, 'premium');
      });
    });

    group('updatePickupLabel', () {
      test('updates pickup label', () {
        final controller = RideDraftController();

        controller.updatePickupLabel('My Home');

        expect(controller.state.pickupLabel, 'My Home');
      });
    });

    group('clear', () {
      test('resets state to defaults after modifications', () {
        final controller = RideDraftController()
          ..updateDestination('Some destination')
          ..updateSelectedOption('xl')
          ..updatePickupLabel('Custom pickup');

        // Verify state changed
        expect(controller.state.destinationQuery, 'Some destination');
        expect(controller.state.selectedOptionId, 'xl');
        expect(controller.state.pickupLabel, 'Custom pickup');

        // Clear
        controller.clear();

        // Verify reset
        expect(controller.state.destinationQuery, '');
        expect(controller.state.selectedOptionId, isNull);
        expect(controller.state.pickupLabel, 'Current location');
      });

      test('clear on fresh controller keeps defaults', () {
        final controller = RideDraftController();

        controller.clear();

        expect(controller.state.destinationQuery, '');
        expect(controller.state.selectedOptionId, isNull);
        expect(controller.state.pickupLabel, 'Current location');
      });
    });
  });

  group('RideDraftUiState', () {
    test('equality works correctly', () {
      const state1 = RideDraftUiState(
        pickupLabel: 'A',
        destinationQuery: 'B',
        selectedOptionId: 'C',
      );

      const state2 = RideDraftUiState(
        pickupLabel: 'A',
        destinationQuery: 'B',
        selectedOptionId: 'C',
      );

      expect(state1, equals(state2));
    });

    test('copyWith preserves unchanged fields', () {
      const original = RideDraftUiState(
        pickupLabel: 'Original',
        destinationQuery: 'Dest',
        selectedOptionId: 'opt',
      );

      final updated = original.copyWith(destinationQuery: 'New Dest');

      expect(updated.pickupLabel, 'Original');
      expect(updated.destinationQuery, 'New Dest');
      expect(updated.selectedOptionId, 'opt');
    });
  });
}


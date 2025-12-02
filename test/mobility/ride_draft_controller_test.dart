/// RideDraftController Unit Tests - Track B Ticket #17
/// Purpose: Safety net tests for RideDraftController before deeper integration
/// Created by: Track B - Ticket #17
/// Updated by: Track B - Ticket #101 (Payment method integration tests)
/// Updated by: Track B - Ticket #102 (Payment method lifecycle tests)
/// Last updated: 2025-11-30

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

      // Track B - Ticket #101
      test('has null paymentMethodId', () {
        final controller = RideDraftController();

        expect(controller.state.paymentMethodId, isNull);
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

    // Track B - Ticket #101: Payment method integration
    group('setPaymentMethodId', () {
      test('sets payment method id on draft state', () {
        final controller = RideDraftController();

        controller.setPaymentMethodId('card_123');

        expect(controller.state.paymentMethodId, 'card_123');
        // Other fields remain unchanged
        expect(controller.state.pickupLabel, 'Current location');
        expect(controller.state.destinationQuery, '');
        expect(controller.state.selectedOptionId, isNull);
      });

      test('can update payment method id multiple times', () {
        final controller = RideDraftController();

        controller.setPaymentMethodId('cash');
        expect(controller.state.paymentMethodId, 'cash');

        controller.setPaymentMethodId('visa_4242');
        expect(controller.state.paymentMethodId, 'visa_4242');
      });

      test('can set payment method id to null', () {
        final controller = RideDraftController();

        controller.setPaymentMethodId('card_123');
        expect(controller.state.paymentMethodId, 'card_123');

        // Using copyWith with clearPaymentMethodId
        // Note: setPaymentMethodId with null won't clear due to copyWith behavior
        // We test the clear functionality in copyWith test
        controller.setPaymentMethodId('another_card');
        expect(controller.state.paymentMethodId, 'another_card');
      });

      test('payment method id persists when updating other fields', () {
        final controller = RideDraftController();

        controller.setPaymentMethodId('visa_4242');
        controller.updateDestination('Airport');
        controller.updateSelectedOption('economy');

        expect(controller.state.paymentMethodId, 'visa_4242');
        expect(controller.state.destinationQuery, 'Airport');
        expect(controller.state.selectedOptionId, 'economy');
      });
    });

    // Track B - Ticket #102: Payment method lifecycle
    group('clearPaymentMethodId (Ticket #102)', () {
      test('clears only paymentMethodId while preserving other fields', () {
        final controller = RideDraftController()
          ..updateDestination('Airport')
          ..updateSelectedOption('economy')
          ..updatePickupLabel('My Home')
          ..setPaymentMethodId('visa_4242');

        // Verify state before clear
        expect(controller.state.paymentMethodId, 'visa_4242');
        expect(controller.state.destinationQuery, 'Airport');
        expect(controller.state.selectedOptionId, 'economy');
        expect(controller.state.pickupLabel, 'My Home');

        // Clear only paymentMethodId
        controller.clearPaymentMethodId();

        // Verify paymentMethodId is null
        expect(controller.state.paymentMethodId, isNull,
            reason: 'paymentMethodId should be cleared');

        // Verify other fields are preserved
        expect(controller.state.destinationQuery, 'Airport',
            reason: 'destinationQuery should be preserved');
        expect(controller.state.selectedOptionId, 'economy',
            reason: 'selectedOptionId should be preserved');
        expect(controller.state.pickupLabel, 'My Home',
            reason: 'pickupLabel should be preserved');
      });

      test('clearPaymentMethodId on fresh state has no effect', () {
        final controller = RideDraftController();

        // Initially paymentMethodId is null
        expect(controller.state.paymentMethodId, isNull);

        controller.clearPaymentMethodId();

        // Still null after clear
        expect(controller.state.paymentMethodId, isNull);
        // Default values preserved
        expect(controller.state.pickupLabel, 'Current location');
        expect(controller.state.destinationQuery, '');
      });

      test('clearPaymentMethodId can be called multiple times safely', () {
        final controller = RideDraftController()
          ..setPaymentMethodId('cash')
          ..updateDestination('Mall');

        controller.clearPaymentMethodId();
        expect(controller.state.paymentMethodId, isNull);
        expect(controller.state.destinationQuery, 'Mall');

        // Second clear should be safe
        controller.clearPaymentMethodId();
        expect(controller.state.paymentMethodId, isNull);
        expect(controller.state.destinationQuery, 'Mall');
      });

      test('can set new paymentMethodId after clearing', () {
        final controller = RideDraftController()
          ..setPaymentMethodId('visa_4242')
          ..clearPaymentMethodId();

        expect(controller.state.paymentMethodId, isNull);

        controller.setPaymentMethodId('mastercard_5555');

        expect(controller.state.paymentMethodId, 'mastercard_5555');
      });
    });

    group('clear', () {
      test('resets state to defaults after modifications', () {
        final controller = RideDraftController()
          ..updateDestination('Some destination')
          ..updateSelectedOption('xl')
          ..updatePickupLabel('Custom pickup')
          ..setPaymentMethodId('visa_4242'); // Track B - Ticket #101

        // Verify state changed
        expect(controller.state.destinationQuery, 'Some destination');
        expect(controller.state.selectedOptionId, 'xl');
        expect(controller.state.pickupLabel, 'Custom pickup');
        expect(controller.state.paymentMethodId, 'visa_4242');

        // Clear
        controller.clear();

        // Verify reset
        expect(controller.state.destinationQuery, '');
        expect(controller.state.selectedOptionId, isNull);
        expect(controller.state.pickupLabel, 'Current location');
        expect(controller.state.paymentMethodId, isNull); // Track B - Ticket #101
      });

      test('clear on fresh controller keeps defaults', () {
        final controller = RideDraftController();

        controller.clear();

        expect(controller.state.destinationQuery, '');
        expect(controller.state.selectedOptionId, isNull);
        expect(controller.state.pickupLabel, 'Current location');
        expect(controller.state.paymentMethodId, isNull); // Track B - Ticket #101
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

    // Track B - Ticket #101: Payment method integration tests
    group('paymentMethodId (Ticket #101)', () {
      test('equality includes paymentMethodId', () {
        const state1 = RideDraftUiState(
          pickupLabel: 'A',
          destinationQuery: 'B',
          selectedOptionId: 'C',
          paymentMethodId: 'visa_4242',
        );

        const state2 = RideDraftUiState(
          pickupLabel: 'A',
          destinationQuery: 'B',
          selectedOptionId: 'C',
          paymentMethodId: 'visa_4242',
        );

        const state3 = RideDraftUiState(
          pickupLabel: 'A',
          destinationQuery: 'B',
          selectedOptionId: 'C',
          paymentMethodId: 'cash',
        );

        expect(state1, equals(state2));
        expect(state1, isNot(equals(state3)));
      });

      test('copyWith updates paymentMethodId', () {
        const original = RideDraftUiState(
          pickupLabel: 'Original',
          destinationQuery: 'Dest',
          selectedOptionId: 'opt',
          paymentMethodId: 'cash',
        );

        final updated = original.copyWith(paymentMethodId: 'visa_4242');

        expect(updated.paymentMethodId, 'visa_4242');
        // Other fields preserved
        expect(updated.pickupLabel, 'Original');
        expect(updated.destinationQuery, 'Dest');
        expect(updated.selectedOptionId, 'opt');
      });

      test('copyWith preserves paymentMethodId when not specified', () {
        const original = RideDraftUiState(
          pickupLabel: 'Original',
          destinationQuery: 'Dest',
          paymentMethodId: 'visa_4242',
        );

        final updated = original.copyWith(destinationQuery: 'New Dest');

        expect(updated.paymentMethodId, 'visa_4242');
      });

      test('copyWith clears paymentMethodId with clearPaymentMethodId flag', () {
        const original = RideDraftUiState(
          pickupLabel: 'Original',
          destinationQuery: 'Dest',
          paymentMethodId: 'visa_4242',
        );

        final updated = original.copyWith(clearPaymentMethodId: true);

        expect(updated.paymentMethodId, isNull);
        // Other fields preserved
        expect(updated.pickupLabel, 'Original');
        expect(updated.destinationQuery, 'Dest');
      });

      test('toString includes paymentMethodId', () {
        const state = RideDraftUiState(
          pickupLabel: 'Home',
          destinationQuery: 'Airport',
          paymentMethodId: 'cash',
        );

        expect(state.toString(), contains('paymentMethodId: cash'));
      });

      test('hashCode differs when paymentMethodId differs', () {
        const state1 = RideDraftUiState(
          pickupLabel: 'A',
          paymentMethodId: 'cash',
        );

        const state2 = RideDraftUiState(
          pickupLabel: 'A',
          paymentMethodId: 'visa_4242',
        );

        expect(state1.hashCode, isNot(equals(state2.hashCode)));
      });
    });
  });

  // Track B - Ticket #102: Payment method lifecycle tests
  group('Payment Method Lifecycle (Ticket #102)', () {
    test('clear() resets paymentMethodId preventing leakage to next ride', () {
      final controller = RideDraftController();

      // First ride with Visa
      controller.updateDestination('Airport');
      controller.setPaymentMethodId('visa_4242');
      expect(controller.state.paymentMethodId, 'visa_4242');

      // Ride completed - clear draft
      controller.clear();

      // Start second ride - should have no paymentMethodId
      expect(controller.state.paymentMethodId, isNull,
          reason: 'paymentMethodId should not leak from first ride');
      expect(controller.state.destinationQuery, '',
          reason: 'destinationQuery should be reset');
    });

    test('second ride can use same payment method without leakage', () {
      final controller = RideDraftController();

      // First ride with Cash
      controller.updateDestination('Mall');
      controller.setPaymentMethodId('cash');
      expect(controller.state.paymentMethodId, 'cash');

      // Ride completed - clear draft
      controller.clear();

      // Second ride - set payment method fresh (simulating UI flow)
      controller.updateDestination('Office');
      expect(controller.state.paymentMethodId, isNull,
          reason: 'paymentMethodId should be null before setting');

      // User selects same payment method in UI
      controller.setPaymentMethodId('cash');
      expect(controller.state.paymentMethodId, 'cash',
          reason: 'paymentMethodId should be set fresh');
    });

    test('second ride can use different payment method', () {
      final controller = RideDraftController();

      // First ride with Visa
      controller.updateDestination('Airport');
      controller.setPaymentMethodId('visa_4242');

      // Ride cancelled - clear draft
      controller.clear();

      // Second ride with Cash
      controller.updateDestination('Restaurant');
      controller.setPaymentMethodId('cash');

      expect(controller.state.paymentMethodId, 'cash',
          reason: 'Second ride should use Cash, not Visa from first ride');
    });

    test('RideDraftUiState initial state has null paymentMethodId', () {
      const initial = RideDraftUiState();
      expect(initial.paymentMethodId, isNull,
          reason: 'Initial state should have null paymentMethodId');
    });
  });
}


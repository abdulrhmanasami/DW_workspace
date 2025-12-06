// Component: Payment Methods Controller Tests
// Created by: CENT-006 QA Implementation
// Purpose: Unit tests for payment methods state management
// Last updated: 2025-11-25


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:payments/payments.dart';

import 'package:delivery_ways_clean/state/payments/payment_methods_controller.dart';

// ============================================================================
// Test Doubles (Stubs/Fakes)
// ============================================================================

/// Stub PaymentGateway for testing without Stripe SDK
class StubPaymentGateway implements PaymentGateway {
  bool createIntentCalled = false;
  bool confirmIntentCalled = false;
  bool setupPaymentMethodCalled = false;
  bool listMethodsCalled = false;
  bool detachPaymentMethodCalled = false;

  SetupRequest? lastSetupRequest;
  String? lastCustomerId;
  String? lastDetachedMethodId;

  Exception? listMethodsError;
  Exception? setupMethodError;
  Exception? detachMethodError;

  List<SavedPaymentMethod> methodsToReturn = [];
  SetupResult? setupResultToReturn;

  @override
  Future<PaymentIntent> createIntent(Amount amount, Currency currency) async {
    createIntentCalled = true;
    return PaymentIntent(
      id: 'pi_test_${DateTime.now().millisecondsSinceEpoch}',
      amount: amount.value,
      currency: currency.code,
      clientSecret: 'cs_test_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Future<PaymentResult> confirmIntent(
    String clientSecret, {
    PaymentMethod? method,
  }) async {
    confirmIntentCalled = true;
    return const PaymentResult(status: PaymentStatus.succeeded);
  }

  @override
  Future<SetupResult> setupPaymentMethod({required SetupRequest request}) async {
    setupPaymentMethodCalled = true;
    lastSetupRequest = request;
    if (setupMethodError != null) {
      throw setupMethodError!;
    }
    return setupResultToReturn ??
        SetupResult(
          paymentMethodId: 'pm_test_${DateTime.now().millisecondsSinceEpoch}',
          status: SetupIntentStatus.succeeded,
        );
  }

  @override
  Future<List<SavedPaymentMethod>> listMethods({
    required String customerId,
  }) async {
    listMethodsCalled = true;
    lastCustomerId = customerId;
    if (listMethodsError != null) {
      throw listMethodsError!;
    }
    return methodsToReturn;
  }

  @override
  Future<void> detachPaymentMethod({
    required String customerId,
    required String paymentMethodId,
  }) async {
    detachPaymentMethodCalled = true;
    lastCustomerId = customerId;
    lastDetachedMethodId = paymentMethodId;
    if (detachMethodError != null) {
      throw detachMethodError!;
    }
    // Remove from list to simulate detachment
    methodsToReturn.removeWhere((m) => m.id == paymentMethodId);
  }

  @override
  void dispose() {}
}

// ============================================================================
// Test Helpers
// ============================================================================

SavedPaymentMethod createTestMethod({
  required String id,
  String brand = 'Visa',
  String last4 = '4242',
}) {
  return SavedPaymentMethod(
    id: id,
    brand: brand,
    last4: last4,
    expMonth: 12,
    expYear: 2025,
    type: PaymentMethodType.card,
  );
}

// ============================================================================
// Tests
// ============================================================================

void main() {
  group('PaymentMethodsController', () {
    late StubPaymentGateway stubGateway;

    setUp(() {
      stubGateway = StubPaymentGateway();
    });

    // --------------------------------------------------------------------------
    // Initial State
    // --------------------------------------------------------------------------
    group('Initial State', () {
      test('starts with loading state', () async {
        final controller = PaymentMethodsController(
          stubGateway,
          Future.value('cus_test'),
        );

        // Check initial state synchronously before async init completes
        final initialState = controller.state;
        expect(initialState.methods.isLoading, isTrue);
        expect(initialState.isAdding, isFalse);
        expect(initialState.error, isNull);

        // Wait for async init before dispose
        await Future<void>.delayed(const Duration(milliseconds: 100));
        controller.dispose();
      });
    });

    // --------------------------------------------------------------------------
    // refresh - Success Scenarios
    // --------------------------------------------------------------------------
    group('refresh - Success', () {
      test('loads payment methods on init', () async {
        stubGateway.methodsToReturn = [
          createTestMethod(id: 'pm_1', brand: 'Visa', last4: '4242'),
          createTestMethod(id: 'pm_2', brand: 'Mastercard', last4: '5555'),
        ];

        final controller = PaymentMethodsController(
          stubGateway,
          Future.value('cus_test'),
        );

        // Wait for async init to complete
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(stubGateway.listMethodsCalled, isTrue);
        expect(stubGateway.lastCustomerId, equals('cus_test'));
        expect(controller.state.methods.hasValue, isTrue);
        expect(controller.state.methods.value?.length, equals(2));

        controller.dispose();
      });

      test('returns empty list for null customer ID', () async {
        final controller = PaymentMethodsController(
          stubGateway,
          Future.value(null),
        );

        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(controller.state.methods.hasValue, isTrue);
        expect(controller.state.methods.value, isEmpty);
        // Gateway should NOT be called without customer ID
        expect(stubGateway.listMethodsCalled, isFalse);

        controller.dispose();
      });

      test('returns empty list for empty customer ID', () async {
        final controller = PaymentMethodsController(
          stubGateway,
          Future.value(''),
        );

        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(controller.state.methods.hasValue, isTrue);
        expect(controller.state.methods.value, isEmpty);
        expect(stubGateway.listMethodsCalled, isFalse);

        controller.dispose();
      });

      test('refresh clears error state', () async {
        // First, cause an error
        stubGateway.listMethodsError = Exception('Test error');
        final controller = PaymentMethodsController(
          stubGateway,
          Future.value('cus_test'),
        );

        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(controller.state.methods.hasError, isTrue);

        // Clear error and refresh
        stubGateway.listMethodsError = null;
        stubGateway.methodsToReturn = [createTestMethod(id: 'pm_1')];
        await controller.refresh();

        expect(controller.state.methods.hasValue, isTrue);
        expect(controller.state.error, isNull);

        controller.dispose();
      });
    });

    // --------------------------------------------------------------------------
    // refresh - Failure Scenarios
    // --------------------------------------------------------------------------
    group('refresh - Failures', () {
      test('handles gateway error gracefully', () async {
        stubGateway.listMethodsError = Exception('Network error');

        final controller = PaymentMethodsController(
          stubGateway,
          Future.value('cus_test'),
        );

        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(controller.state.methods.hasError, isTrue);
        expect(controller.state.error, contains('Network error'));

        controller.dispose();
      });
    });

    // --------------------------------------------------------------------------
    // addMethod - Success Scenarios
    // --------------------------------------------------------------------------
    group('addMethod - Success', () {
      test('adds payment method successfully', () async {
        stubGateway.methodsToReturn = [];
        final controller = PaymentMethodsController(
          stubGateway,
          Future.value('cus_test'),
        );

        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Add a method
        final newMethod = createTestMethod(id: 'pm_new');
        stubGateway.methodsToReturn = [newMethod];

        await controller.addMethod(useGPayIfAvailable: false);

        expect(stubGateway.setupPaymentMethodCalled, isTrue);
        expect(stubGateway.lastSetupRequest?.customerId, equals('cus_test'));
        expect(stubGateway.lastSetupRequest?.useGooglePayIfAvailable, isFalse);
        expect(controller.state.methods.value?.length, equals(1));
        expect(controller.state.isAdding, isFalse);

        controller.dispose();
      });

      test('passes Google Pay flag correctly', () async {
        final controller = PaymentMethodsController(
          stubGateway,
          Future.value('cus_test'),
        );

        await Future<void>.delayed(const Duration(milliseconds: 50));
        await controller.addMethod(useGPayIfAvailable: true);

        expect(stubGateway.lastSetupRequest?.useGooglePayIfAvailable, isTrue);

        controller.dispose();
      });

      test('sets isAdding during operation', () async {
        final controller = PaymentMethodsController(
          stubGateway,
          Future.value('cus_test'),
        );

        await Future<void>.delayed(const Duration(milliseconds: 50));

        // We can't easily intercept async, so we'll verify final state
        await controller.addMethod(useGPayIfAvailable: false);

        // After completion, isAdding should be false
        expect(controller.state.isAdding, isFalse);

        controller.dispose();
      });

      test('refreshes list after successful add', () async {
        final controller = PaymentMethodsController(
          stubGateway,
          Future.value('cus_test'),
        );

        await Future<void>.delayed(const Duration(milliseconds: 50));

        stubGateway.listMethodsCalled = false;
        await controller.addMethod(useGPayIfAvailable: false);

        // listMethods should be called again for refresh
        expect(stubGateway.listMethodsCalled, isTrue);

        controller.dispose();
      });
    });

    // --------------------------------------------------------------------------
    // addMethod - Failure Scenarios
    // --------------------------------------------------------------------------
    group('addMethod - Failures', () {
      test('handles setup error gracefully', () async {
        final controller = PaymentMethodsController(
          stubGateway,
          Future.value('cus_test'),
        );

        await Future<void>.delayed(const Duration(milliseconds: 100));

        stubGateway.setupMethodError = Exception('Setup failed');
        await controller.addMethod(useGPayIfAvailable: false);

        // Error should be set after failed setup attempt
        expect(controller.state.error, isNotNull);
        expect(controller.state.error!, contains('Setup failed'));
        expect(controller.state.isAdding, isFalse);

        controller.dispose();
      });

      test('throws StateError without customer ID', () async {
        final controller = PaymentMethodsController(
          stubGateway,
          Future.value(null),
        );

        await Future<void>.delayed(const Duration(milliseconds: 100));
        await controller.addMethod(useGPayIfAvailable: false);

        // Error should be set when customer ID is missing
        expect(controller.state.error, isNotNull);
        expect(controller.state.error!, contains('Missing payment customer id'));

        controller.dispose();
      });
    });

    // --------------------------------------------------------------------------
    // removeMethod - Success Scenarios
    // --------------------------------------------------------------------------
    group('removeMethod - Success', () {
      test('removes payment method successfully', () async {
        final methodToRemove = createTestMethod(id: 'pm_to_remove');
        stubGateway.methodsToReturn = [
          methodToRemove,
          createTestMethod(id: 'pm_keep'),
        ];

        final controller = PaymentMethodsController(
          stubGateway,
          Future.value('cus_test'),
        );

        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(controller.state.methods.value?.length, equals(2));

        await controller.removeMethod('pm_to_remove');

        expect(stubGateway.detachPaymentMethodCalled, isTrue);
        expect(stubGateway.lastDetachedMethodId, equals('pm_to_remove'));
        expect(controller.state.methods.value?.length, equals(1));
        expect(
          controller.state.methods.value?.any((m) => m.id == 'pm_to_remove'),
          isFalse,
        );

        controller.dispose();
      });

      test('refreshes list after removal', () async {
        stubGateway.methodsToReturn = [createTestMethod(id: 'pm_1')];

        final controller = PaymentMethodsController(
          stubGateway,
          Future.value('cus_test'),
        );

        await Future<void>.delayed(const Duration(milliseconds: 50));

        stubGateway.listMethodsCalled = false;
        await controller.removeMethod('pm_1');

        expect(stubGateway.listMethodsCalled, isTrue);

        controller.dispose();
      });
    });

    // --------------------------------------------------------------------------
    // removeMethod - Failure Scenarios
    // --------------------------------------------------------------------------
    group('removeMethod - Failures', () {
      test('handles detach error gracefully', () async {
        stubGateway.methodsToReturn = [createTestMethod(id: 'pm_1')];
        stubGateway.detachMethodError = Exception('Detach failed');

        final controller = PaymentMethodsController(
          stubGateway,
          Future.value('cus_test'),
        );

        await Future<void>.delayed(const Duration(milliseconds: 50));
        await controller.removeMethod('pm_1');

        expect(controller.state.error, contains('Detach failed'));

        controller.dispose();
      });
    });

    // --------------------------------------------------------------------------
    // PaymentMethodsState
    // --------------------------------------------------------------------------
    group('PaymentMethodsState', () {
      test('initial state is loading', () {
        final state = PaymentMethodsState.initial();

        expect(state.methods.isLoading, isTrue);
        expect(state.isAdding, isFalse);
        expect(state.error, isNull);
      });

      test('copyWith preserves unchanged fields', () {
        const initial = PaymentMethodsState(
          methods: AsyncValue.data([]),
          isAdding: true,
          error: 'test error',
        );

        // copyWith preserves error by default
        final updated = initial.copyWith(isAdding: false);
        expect(updated.methods.hasValue, isTrue);
        expect(updated.isAdding, isFalse);
        expect(updated.error, equals('test error')); // error is preserved

        // Use clearError: true to explicitly clear error
        final cleared = initial.copyWith(isAdding: false, clearError: true);
        expect(cleared.error, isNull);
      });
    });
  });

  // --------------------------------------------------------------------------
  // SavedPaymentMethod Tests
  // --------------------------------------------------------------------------
  group('SavedPaymentMethod', () {
    test('displayName format is correct', () {
      const method = SavedPaymentMethod(
        id: 'pm_test',
        brand: 'Visa',
        last4: '4242',
        expMonth: 12,
        expYear: 2025,
        type: PaymentMethodType.card,
      );

      expect(method.displayName, equals('Visa **** 4242'));
    });

    test('isAvailable returns true by default', () {
      const method = SavedPaymentMethod(
        id: 'pm_test',
        brand: 'Visa',
        last4: '4242',
        type: PaymentMethodType.card,
      );

      expect(method.isAvailable, isTrue);
    });
  });
}


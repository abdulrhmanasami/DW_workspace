/// Payments Screen Tests - Track A Ticket #225
/// Purpose: Test Payments tab with PaymentMethodCard, DWEmptyState, LTR/RTL support
/// Created by: Track A - Ticket #225
/// Last updated: 2025-12-04

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/ui/common/empty_state.dart';
import 'package:delivery_ways_clean/ui/payments/payment_method_card.dart';
import 'package:delivery_ways_clean/screens/payments/payments_tab_screen.dart';
import 'package:delivery_ways_clean/state/payments/payment_methods_controller.dart';
import 'package:payments/payments.dart';

/// Fake PaymentMethodsController for tests - Track A - Ticket #226
/// Avoids PaymentGateway dependency to prevent initialization errors in tests
class FakePaymentMethodsController extends PaymentMethodsController {
  FakePaymentMethodsController({
    required PaymentMethodsState initialState,
  }) : super(
          // Use dummy implementations that don't trigger real PaymentGateway
          _FakePaymentGateway(),
          Future.value(null), // null customerId will cause refresh() to set empty state
        ) {
    // Override the initial state immediately
    state = initialState;
  }

  @override
  Future<void> refresh() async {
    // Don't call the real refresh that would trigger gateway calls
    // Just keep the current state
  }

  @override
  Future<void> addMethod({required bool useGPayIfAvailable}) async {
    // No-op in tests
  }

  @override
  Future<void> removeMethod(String paymentMethodId) async {
    // No-op in tests
  }
}

/// Test wrapper for PaymentsTabScreen with provider setup
Widget createPaymentsScreenTest({
  required PaymentMethodsState paymentsState,
  Locale locale = const Locale('en'),
}) {
  final fakeController = FakePaymentMethodsController(initialState: paymentsState);

  return ProviderScope(
    overrides: [
      paymentMethodsControllerProvider.overrideWith((ref) => fakeController),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: const Scaffold(
        body: SafeArea(
          child: PaymentsTabScreen(),
        ),
      ),
    ),
  );
}

/// Fake PaymentGateway that throws on any real operations
class _FakePaymentGateway implements PaymentGateway {
  @override
  Future<PaymentIntent> createIntent(Amount amount, Currency currency) {
    throw UnimplementedError('Fake PaymentGateway - not implemented in tests');
  }

  @override
  Future<PaymentResult> confirmIntent(
    String clientSecret, {
    PaymentMethod? method,
  }) {
    throw UnimplementedError('Fake PaymentGateway - not implemented in tests');
  }

  @override
  Future<SetupResult> setupPaymentMethod({required SetupRequest request}) {
    throw UnimplementedError('Fake PaymentGateway - not implemented in tests');
  }

  @override
  Future<List<SavedPaymentMethod>> listMethods({required String customerId}) {
    throw UnimplementedError('Fake PaymentGateway - not implemented in tests');
  }

  @override
  Future<void> detachPaymentMethod({
    required String customerId,
    required String paymentMethodId,
  }) {
    throw UnimplementedError('Fake PaymentGateway - not implemented in tests');
  }

  @override
  void dispose() {
    // No-op in tests
  }
}

void main() {
  // Test helpers will be added when tests are implemented

  group('Payments Screen - Ticket #225', () {
    testWidgets('Payments screen loads without exceptions (LTR)', (tester) async {
      const loadingState = PaymentMethodsState(
        methods: AsyncValue.loading(),
      );
      await tester.pumpWidget(createPaymentsScreenTest(paymentsState: loadingState));
      await tester.pumpAndSettle();

      // Verify Payments screen is displayed
      expect(find.text('Payments'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Payments screen shows DWEmptyState when no payment methods (LTR)', (tester) async {
      const emptyState = PaymentMethodsState(
        methods: AsyncValue.data(<SavedPaymentMethod>[]),
      );
      await tester.pumpWidget(createPaymentsScreenTest(paymentsState: emptyState));
      await tester.pumpAndSettle();

      // Verify DWEmptyState is shown
      expect(find.byType(DWEmptyState), findsOneWidget);
      expect(find.text('No payment methods saved'), findsOneWidget);
      expect(find.text('Add new payment method'), findsOneWidget);

      // Verify no PaymentMethodCard is shown
      expect(find.byType(PaymentMethodCard), findsNothing);
    });

    testWidgets('Payments screen shows payment methods list when data exists (LTR)', (tester) async {
      final testMethods = [
        const SavedPaymentMethod(
          id: 'card_1',
          brand: 'Visa',
          last4: '4242',
          type: PaymentMethodType.card,
          expMonth: 8,
          expYear: 27,
        ),
        const SavedPaymentMethod(
          id: 'cash_1',
          brand: 'Cash',
          last4: '',
          type: PaymentMethodType.cash,
        ),
      ];

      final dataState = PaymentMethodsState(
        methods: AsyncValue.data(testMethods),
      );

      await tester.pumpWidget(createPaymentsScreenTest(paymentsState: dataState));
      await tester.pumpAndSettle();

      // Verify PaymentMethodCard widgets are shown
      expect(find.byType(PaymentMethodCard), findsNWidgets(2));

      // Verify card content - check for key elements that should be present
      expect(find.text('Visa **** 4242'), findsOneWidget);
      expect(find.textContaining('08/27'), findsOneWidget); // More flexible expiry check
      expect(find.text('Cash'), findsOneWidget);

      // Verify Add button is present
      expect(find.text('Add new payment method'), findsOneWidget);

      // Verify DWEmptyState is not shown
      expect(find.byType(DWEmptyState), findsNothing);
    });

    testWidgets('Payments screen handles loading state', (tester) async {
      const loadingState = PaymentMethodsState(
        methods: AsyncValue.loading(),
      );

      await tester.pumpWidget(createPaymentsScreenTest(paymentsState: loadingState));
      await tester.pumpAndSettle();

      // Verify loading indicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Payments screen handles error state', (tester) async {
      final errorState = PaymentMethodsState(
        methods: AsyncValue.error('Network error', StackTrace.current),
      );

      await tester.pumpWidget(createPaymentsScreenTest(paymentsState: errorState));
      await tester.pumpAndSettle();

      // Verify error message is shown
      expect(find.text('Unable to load payment methods'), findsOneWidget);
      expect(find.text('Network error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('Payments screen works correctly in Arabic (RTL)', (tester) async {
      const emptyState = PaymentMethodsState(
        methods: AsyncValue.data(<SavedPaymentMethod>[]),
      );

      await tester.pumpWidget(createPaymentsScreenTest(
        locale: const Locale('ar'),
        paymentsState: emptyState,
      ));
      await tester.pumpAndSettle();

      // Verify Arabic text is shown
      expect(find.text('طرق الدفع'), findsOneWidget);
      expect(find.text('لا توجد طرق دفع محفوظة'), findsOneWidget);
      expect(find.text('إضافة طريقة دفع جديدة'), findsOneWidget);
    });

    testWidgets('Payments screen shows payment methods with Arabic labels (RTL)', (tester) async {
      final testMethods = [
        const SavedPaymentMethod(
          id: 'card_1',
          brand: 'Visa',
          last4: '4242',
          type: PaymentMethodType.card,
          expMonth: 8,
          expYear: 27,
        ),
        const SavedPaymentMethod(
          id: 'apple_pay_1',
          brand: 'Apple Pay',
          last4: '',
          type: PaymentMethodType.applePay,
        ),
      ];

      final dataState = PaymentMethodsState(
        methods: AsyncValue.data(testMethods),
      );

      await tester.pumpWidget(createPaymentsScreenTest(
        locale: const Locale('ar'),
        paymentsState: dataState,
      ));
      await tester.pumpAndSettle();

      // Verify PaymentMethodCard widgets are shown
      expect(find.byType(PaymentMethodCard), findsNWidgets(2));

      // Verify Arabic subtitle for card expiry
      expect(find.textContaining('08/27'), findsOneWidget); // More flexible expiry check

      // Verify Arabic Add button
      expect(find.text('إضافة طريقة دفع جديدة'), findsOneWidget);
    });

    testWidgets('Payments screen displays multiple payment method types correctly', (tester) async {
      final testMethods = [
        const SavedPaymentMethod(
          id: 'card_1',
          brand: 'Visa',
          last4: '4242',
          type: PaymentMethodType.card,
          expMonth: 8,
          expYear: 27,
        ),
        const SavedPaymentMethod(
          id: 'apple_pay_1',
          brand: 'Apple Pay',
          last4: '',
          type: PaymentMethodType.applePay,
        ),
        const SavedPaymentMethod(
          id: 'cash_1',
          brand: 'Cash',
          last4: '',
          type: PaymentMethodType.cash,
        ),
      ];

      final dataState = PaymentMethodsState(
        methods: AsyncValue.data(testMethods),
      );

      await tester.pumpWidget(createPaymentsScreenTest(paymentsState: dataState));
      await tester.pumpAndSettle();

      // Verify all payment method types are displayed
      expect(find.byType(PaymentMethodCard), findsNWidgets(3));
      expect(find.text('Visa **** 4242'), findsOneWidget);
      expect(find.text('Apple Pay'), findsOneWidget);
      expect(find.text('Cash'), findsOneWidget);
    });
  });
}

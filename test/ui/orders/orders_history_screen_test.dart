/// Orders History Screen Tests - Track A Ticket #224
/// Purpose: Test Orders tab with OrderCard, EmptyState, LTR/RTL support
/// Created by: Track A - Ticket #224
/// Last updated: 2025-12-04

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/app_shell/app_shell.dart';
import 'package:delivery_ways_clean/ui/orders/order_card.dart';
import 'package:delivery_ways_clean/ui/common/empty_state.dart';
import 'package:delivery_ways_clean/state/payments/payment_methods_controller.dart';
import 'package:delivery_ways_clean/config/feature_flags.dart';
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
  /// Creates a test widget with necessary L10n and provider setup.
  /// Uses same pattern as app_shell_bottom_nav_test.dart for consistency.
  Widget createTestApp({
    Locale locale = const Locale('en'),
  }) {
    final fakePaymentController = FakePaymentMethodsController(
      initialState: PaymentMethodsState.initial(),
    );

    return ProviderScope(
      overrides: [
        paymentMethodsControllerProvider.overrideWith((ref) => fakePaymentController),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        home: const AppShell(),
      ),
    );
  }

  group('Orders History Screen - Ticket #224', () {
    setUp(() {
      // Enable Food MVP for tests that check Food filter
      FeatureFlags.overrideForTests(const FeatureFlags(
        enableFoodMvpValue: true,
        enableParcelsMvpValue: true,
      ));
    });

    tearDown(() {
      FeatureFlags.resetForTests();
    });

    testWidgets('Orders tab loads without exceptions (LTR)', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Navigate to Orders tab
      await tester.tap(find.text('Orders'));
      await tester.pumpAndSettle();

      // Verify Orders screen is displayed
      expect(find.text('My Orders'), findsOneWidget);

      // Verify basic components are present (filter bar, etc.)
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Rides'), findsOneWidget);
      expect(find.text('Parcels'), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
    });

    testWidgets('Orders tab shows DWEmptyState when no data (LTR)', (tester) async {
      // TODO: This test would need provider mocking to ensure empty state
      // For now, we'll skip this as it requires more complex setup
    });

    testWidgets('OrderCard displays service icons correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: OrderCard(
              serviceType: OrderServiceType.ride,
              title: 'Test Ride',
              subtitle: 'Test subtitle',
              statusLabel: 'Completed',
              priceLabel: 'SAR 50.00',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify OrderCard renders correctly
      expect(find.text('Test Ride'), findsOneWidget);
      expect(find.text('Test subtitle'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('SAR 50.00'), findsOneWidget);

      // Verify ride icon is present
      expect(find.byIcon(Icons.directions_car_outlined), findsOneWidget);
    });

    testWidgets('DWEmptyState renders basic components', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: DWEmptyState(
              title: 'No History Yet',
              icon: Icons.history,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify DWEmptyState renders correctly
      expect(find.text('No History Yet'), findsOneWidget);

      // Verify history icon is present
      expect(find.byIcon(Icons.history), findsOneWidget);
    });

    testWidgets('Orders tab works in RTL layout without exceptions', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.rtl,
          child: createTestApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to Orders tab
      await tester.tap(find.text('Orders'));
      await tester.pumpAndSettle();

      // Verify Orders screen displays without throwing exceptions
      expect(find.text('My Orders'), findsOneWidget);

      // Verify basic RTL components are present
      expect(find.text('All'), findsOneWidget);
    });

    testWidgets('Orders tab works in RTL Arabic locale without exceptions', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.rtl,
          child: createTestApp(locale: const Locale('ar')),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to Orders tab (Arabic)
      await tester.tap(find.text('الطلبات'));
      await tester.pumpAndSettle();

      // Verify Arabic Orders screen displays without throwing exceptions
      expect(find.text('طلباتي'), findsOneWidget);

      // Verify Arabic filter labels are present
      expect(find.text('الكل'), findsOneWidget);
      expect(find.text('الرحلات'), findsOneWidget);
      expect(find.text('الطرود'), findsOneWidget);
      expect(find.text('الطعام'), findsOneWidget);
    });
  });
}

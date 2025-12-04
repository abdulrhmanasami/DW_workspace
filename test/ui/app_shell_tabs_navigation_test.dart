/// AppShell Tabs Navigation Integration Tests - Track A Ticket #231
/// Purpose: Integration tests for AppShell tab navigation in LTR/RTL with content verification
/// Created by: Track A - Ticket #231
/// Last updated: 2025-12-04

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/app_shell/app_shell.dart';
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
  /// Creates a test widget with necessary L10n, provider setup, and FeatureFlags.
  /// Uses same pattern as orders_history_screen_test.dart for consistency.
  Widget createTestApp({
    Locale locale = const Locale('en'),
    TextDirection textDirection = TextDirection.ltr,
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
        home: Directionality(
          textDirection: textDirection,
          child: const AppShell(),
        ),
      ),
    );
  }

  group('AppShell Tabs Navigation Integration Tests - Ticket #231', () {
    setUp(() {
      // Enable Food MVP for tests that check Food filter in Orders tab
      FeatureFlags.overrideForTests(const FeatureFlags(
        enableFoodMvpValue: true,
        enableParcelsMvpValue: true,
      ));
    });

    tearDown(() {
      FeatureFlags.resetForTests();
    });

    group('LTR English Locale Navigation', () {
      testWidgets('Home tab is default active and shows expected content', (tester) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Verify Home tab is active by default (selectedIndex = 0)
        final navigationBar = find.byType(NavigationBar);
        expect(navigationBar, findsOneWidget);

        // Verify Home content is visible - "Services" text from HomeTabScreen
        expect(find.text('Services'), findsOneWidget);

        // Verify all bottom nav tabs are present
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Orders'), findsOneWidget);
        expect(find.text('Payments'), findsOneWidget);
        expect(find.text('Profile'), findsOneWidget);
      });

      testWidgets('navigates to Orders tab and shows OrdersHistoryScreen content', (tester) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Navigate to Orders tab
        await tester.tap(find.text('Orders'));
        await tester.pump();

        // Verify OrdersHistoryScreen AppBar title
        expect(find.text('My Orders'), findsOneWidget);
      });

      testWidgets('navigates to Payments tab and shows PaymentsTabScreen content', (tester) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Navigate to Payments tab
        await tester.tap(find.text('Payments'));
        await tester.pump();

        // Verify PaymentsTabScreen AppBar title
        expect(find.text('Payments'), findsAtLeastNWidgets(2)); // Title + nav label
      });

      testWidgets('navigates to Profile tab and shows ProfileTabScreen content', (tester) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Navigate to Profile tab
        await tester.tap(find.text('Profile'));
        await tester.pump();

        // Verify ProfileTabScreen AppBar title
        expect(find.widgetWithText(AppBar, 'Profile'), findsOneWidget);

        // Verify profile sections are present (at least Settings and Personal info)
        expect(find.text('Settings'), findsAtLeastNWidgets(1));
        expect(find.text('Personal info'), findsAtLeastNWidgets(1));
      });

      testWidgets('tab switching preserves navigation and content', (tester) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Start on Home
        expect(find.text('Services'), findsOneWidget);

        // Switch to Orders
        await tester.tap(find.text('Orders'));
        await tester.pump();
        expect(find.text('My Orders'), findsOneWidget);

        // Switch back to Home
        await tester.tap(find.text('Home'));
        await tester.pump();
        expect(find.text('Services'), findsOneWidget);

        // Verify no exceptions occurred during navigation
        expect(find.byType(AppShell), findsOneWidget);
      });
    });

    group('RTL Arabic Locale Navigation', () {
      testWidgets('Home tab shows Arabic content in RTL layout', (tester) async {
        await tester.pumpWidget(createTestApp(
          locale: const Locale('ar'),
          textDirection: TextDirection.rtl,
        ));
        await tester.pumpAndSettle();

        // Verify Arabic bottom nav labels
        expect(find.text('الرئيسية'), findsOneWidget);
        expect(find.text('الطلبات'), findsOneWidget);
        expect(find.text('المدفوعات'), findsOneWidget);
        expect(find.text('الحساب'), findsOneWidget);

        // Verify Home content is still visible
        expect(find.text('Services'), findsOneWidget);
      });

      testWidgets('navigates to Orders tab in Arabic RTL and shows Arabic content', (tester) async {
        await tester.pumpWidget(createTestApp(
          locale: const Locale('ar'),
          textDirection: TextDirection.rtl,
        ));
        await tester.pumpAndSettle();

        // Navigate to Orders tab (Arabic)
        await tester.tap(find.text('الطلبات'));
        await tester.pump();

        // Verify Arabic OrdersHistoryScreen AppBar title
        expect(find.text('طلباتي'), findsOneWidget);
      });

      testWidgets('navigates to Payments tab in Arabic RTL and shows Arabic content', (tester) async {
        await tester.pumpWidget(createTestApp(
          locale: const Locale('ar'),
          textDirection: TextDirection.rtl,
        ));
        await tester.pumpAndSettle();

        // Navigate to Payments tab (Arabic)
        await tester.tap(find.text('المدفوعات'));
        await tester.pump();

        // Verify Arabic PaymentsTabScreen title
        expect(find.text('طرق الدفع'), findsOneWidget);
      });

      testWidgets('navigates to Profile tab in Arabic RTL and shows Arabic content', (tester) async {
        await tester.pumpWidget(createTestApp(
          locale: const Locale('ar'),
          textDirection: TextDirection.rtl,
        ));
        await tester.pumpAndSettle();

        // Navigate to Profile tab (Arabic)
        await tester.tap(find.text('الحساب'));
        await tester.pump();

        // Verify Arabic Profile title
        expect(find.text('الملف الشخصي'), findsOneWidget);
      });

      testWidgets('RTL Arabic tab switching works without exceptions', (tester) async {
        await tester.pumpWidget(createTestApp(
          locale: const Locale('ar'),
          textDirection: TextDirection.rtl,
        ));
        await tester.pumpAndSettle();

        // Verify starting on Home
        expect(find.text('Services'), findsOneWidget);

        // Switch to Orders (Arabic)
        await tester.tap(find.text('الطلبات'));
        await tester.pump();
        expect(find.text('طلباتي'), findsOneWidget);

        // Switch back to Home (Arabic)
        await tester.tap(find.text('الرئيسية'));
        await tester.pump();
        expect(find.text('Services'), findsOneWidget);

        // Verify no exceptions occurred during RTL navigation
        expect(find.byType(AppShell), findsOneWidget);
      });
    });

    group('PaymentGateway Integration Prevention', () {
      testWidgets('AppShell tabs navigation does not trigger PaymentGateway initialization', (tester) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Navigate through tabs without triggering PaymentGateway
        await tester.tap(find.text('Orders'));
        await tester.pump();

        await tester.tap(find.text('Home'));
        await tester.pump();

        // If we reach here without "Bad state: PaymentGateway not initialized" errors, test passes
        expect(find.byType(AppShell), findsOneWidget);
      });
    });
  });
}

/// Parcel Create Shipment Screen Widget Tests - Track C Ticket #46
/// Purpose: Test ParcelCreateShipmentScreen UI components and behavior
/// Created by: Track C - Ticket #46
/// Updated by: Track C - Ticket #49 (ParcelsRepository Port integration)
/// Last updated: 2025-11-28

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/screens/parcels/parcel_create_shipment_screen.dart';
import 'package:delivery_ways_clean/state/parcels/app_parcels_repository.dart';
import 'package:delivery_ways_clean/state/parcels/parcel_orders_state.dart';
import 'package:parcels_shims/parcels_shims.dart';
import '../support/design_system_harness.dart';

void main() {
  setUpAll(() {
    ensureDesignSystemStubsForTests();
  });

  // =========================================================================
  // Helper Functions
  // =========================================================================

  Widget createTestWidget({
    Locale locale = const Locale('en'),
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('ar'),
          Locale('de'),
        ],
        home: const ParcelCreateShipmentScreen(),
      ),
    );
  }

  // =========================================================================
  // Section 1: Field Display Tests
  // =========================================================================

  group('Ticket #46 - Field Display Tests', () {
    testWidgets('displays screen title "New Shipment"',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for title
      expect(find.text('New Shipment'), findsOneWidget);
    });

    testWidgets('displays all section headers', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check section headers
      expect(find.text('Sender'), findsOneWidget);
      expect(find.text('Receiver'), findsOneWidget);
      expect(find.text('Parcel details'), findsOneWidget);
      expect(find.text('Service type'), findsOneWidget);
    });

    testWidgets('displays sender fields', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check sender field labels
      expect(find.text('Sender name'), findsOneWidget);
      expect(find.text('Sender phone'), findsOneWidget);
      expect(find.text('Sender address'), findsOneWidget);
    });

    testWidgets('displays receiver fields', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check receiver field labels
      expect(find.text('Receiver name'), findsOneWidget);
      expect(find.text('Receiver phone'), findsOneWidget);
      expect(find.text('Receiver address'), findsOneWidget);
    });

    testWidgets('displays parcel details fields', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check parcel details field labels
      expect(find.text('Weight (kg)'), findsOneWidget);
      expect(find.text('Size'), findsOneWidget);
      expect(find.text('Notes (optional)'), findsOneWidget);
    });

    testWidgets('displays service type options', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check service type options
      expect(find.text('Express'), findsOneWidget);
      expect(find.text('Standard'), findsOneWidget);
    });

    testWidgets('displays CTA button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check CTA button
      expect(find.text('Get estimate'), findsOneWidget);
    });

    testWidgets('displays size selector with all options',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check size selector buttons
      expect(find.byType(SegmentedButton<ParcelSize>), findsOneWidget);
      expect(find.text('S'), findsOneWidget);
      expect(find.text('M'), findsOneWidget);
      expect(find.text('L'), findsOneWidget);
      expect(find.text('XL'), findsOneWidget);
    });
  });

  // =========================================================================
  // Section 2: Validation Tests
  // =========================================================================

  group('Ticket #46 - Validation Tests', () {
    testWidgets('shows validation errors when required fields are empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap CTA button without filling any fields
      final ctaButton = find.text('Get estimate');
      await tester.ensureVisible(ctaButton);
      await tester.tap(ctaButton);
      await tester.pumpAndSettle();

      // Should show validation errors for all required fields
      expect(
        find.text('This field is required'),
        findsAtLeastNWidgets(1),
      );
    });

    testWidgets('shows phone validation error for short phone numbers',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and fill sender phone with short number
      final senderPhoneFinder = find.ancestor(
        of: find.text('Sender phone'),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(senderPhoneFinder, '123');

      // Tap CTA to trigger validation
      final ctaButton = find.text('Get estimate');
      await tester.ensureVisible(ctaButton);
      await tester.tap(ctaButton);
      await tester.pumpAndSettle();

      // Should show phone validation error
      expect(
        find.text('Please enter a valid phone number'),
        findsAtLeastNWidgets(1),
      );
    });

    testWidgets('shows number validation error for invalid weight',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and fill weight with invalid value
      final weightFieldFinder = find.ancestor(
        of: find.text('Weight (kg)'),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(weightFieldFinder, 'abc');

      // Tap CTA to trigger validation
      final ctaButton = find.text('Get estimate');
      await tester.ensureVisible(ctaButton);
      await tester.tap(ctaButton);
      await tester.pumpAndSettle();

      // Should show number validation error
      expect(
        find.text('Please enter a valid number'),
        findsOneWidget,
      );
    });

    testWidgets('accepts valid weight with comma as decimal separator',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Fill all required fields
      await _fillAllRequiredFields(tester);

      // Enter weight with comma
      final weightFieldFinder = find.ancestor(
        of: find.text('Weight (kg)'),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(weightFieldFinder, '2,5');

      // Tap CTA - should not show weight error
      final ctaButton = find.text('Get estimate');
      await tester.ensureVisible(ctaButton);
      await tester.tap(ctaButton);
      await tester.pumpAndSettle();

      // Should not show invalid number error for weight
      expect(find.text('Please enter a valid number'), findsNothing);
    });
  });

  // =========================================================================
  // Section 3: Interaction Tests
  // =========================================================================

  group('Ticket #46 - Interaction Tests', () {
    testWidgets('displays service type options',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Both service type options should be displayed
      expect(find.text('Express'), findsOneWidget);
      expect(find.text('Standard'), findsOneWidget);

      // ChoiceChip widgets should exist
      expect(find.byType(ChoiceChip), findsNWidgets(2));
    });

    testWidgets('displays size selector', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find SegmentedButton
      expect(find.byType(SegmentedButton<ParcelSize>), findsOneWidget);

      // Check all size options are displayed
      expect(find.text('S'), findsOneWidget);
      expect(find.text('M'), findsOneWidget);
      expect(find.text('L'), findsOneWidget);
      expect(find.text('XL'), findsOneWidget);
    });
  });

  // =========================================================================
  // Section 4: Happy Path + Provider Integration Tests
  // =========================================================================

  group('Ticket #46 - Happy Path + Provider Tests', () {
    testWidgets('submitting valid form pops navigation',
        (WidgetTester tester) async {
      var navigatedBack = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const ParcelCreateShipmentScreen(),
                        ),
                      );
                      navigatedBack = true;
                    },
                    child: const Text('Open Create'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open the screen
      await tester.tap(find.text('Open Create'));
      await tester.pumpAndSettle();

      // Fill fields and submit
      await _fillAllRequiredFields(tester);

      final ctaButton = find.text('Get estimate');
      await tester.ensureVisible(ctaButton);
      await tester.tap(ctaButton);
      await tester.pumpAndSettle();

      // Should have navigated back
      expect(navigatedBack, isTrue);
    });

    testWidgets('new shipment appears in parcelOrdersProvider state',
        (WidgetTester tester) async {
      // Use the real controller to verify state update
      // Track C - Ticket #49: Now requires repository
      final repository = AppParcelsRepository();
      final controller = ParcelOrdersController(repository: repository);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            parcelOrdersProvider.overrideWith((ref) => controller),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en')],
            home: ParcelCreateShipmentScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially no parcels
      expect(controller.state.parcels.length, 0);

      // Fill all fields and submit
      await _fillAllRequiredFields(tester);

      final ctaButton = find.text('Get estimate');
      await tester.ensureVisible(ctaButton);
      await tester.tap(ctaButton);
      await tester.pumpAndSettle();

      // Should have one parcel now
      expect(controller.state.parcels.length, 1);

      // Verify parcel properties
      final createdParcel = controller.state.parcels.first;
      expect(createdParcel.pickupAddress.label, '123 Sender St');
      expect(createdParcel.dropoffAddress.label, '456 Receiver St');
      expect(createdParcel.status, ParcelStatus.scheduled);
    });
  });

  // =========================================================================
  // Section 5: Localization Tests
  // =========================================================================

  group('Ticket #46 - Localization Tests', () {
    testWidgets('displays Arabic translations when locale is ar',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      // Check Arabic title
      expect(find.text('شحنة جديدة'), findsOneWidget);

      // Check Arabic section headers
      expect(find.text('المرسل'), findsOneWidget);
      expect(find.text('المستلم'), findsOneWidget);
      expect(find.text('تفاصيل الشحنة'), findsOneWidget);
      expect(find.text('نوع الخدمة'), findsOneWidget);

      // Check Arabic service types
      expect(find.text('سريع'), findsOneWidget);
      expect(find.text('عادي'), findsOneWidget);

      // Check Arabic CTA
      expect(find.text('احصل على التقدير'), findsOneWidget);
    });

    testWidgets('displays German translations when locale is de',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('de')));
      await tester.pumpAndSettle();

      // Check German title
      expect(find.text('Neue Sendung'), findsOneWidget);

      // Check German section headers
      expect(find.text('Absender'), findsOneWidget);
      expect(find.text('Empfänger'), findsOneWidget);
      expect(find.text('Sendungsdetails'), findsOneWidget);
      expect(find.text('Serviceart'), findsOneWidget);

      // Check German CTA
      expect(find.text('Kostenvoranschlag'), findsOneWidget);
    });

    testWidgets('displays Arabic validation errors when locale is ar',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      // Tap CTA without filling fields
      final ctaButton = find.text('احصل على التقدير');
      await tester.ensureVisible(ctaButton);
      await tester.tap(ctaButton);
      await tester.pumpAndSettle();

      // Should show Arabic validation errors
      expect(find.text('هذا الحقل مطلوب'), findsAtLeastNWidgets(1));
    });
  });
}

// =============================================================================
// Test Helpers
// =============================================================================

/// Fill all required fields with valid test data.
Future<void> _fillAllRequiredFields(WidgetTester tester) async {
  // Sender fields
  final senderNameField = find.ancestor(
    of: find.text('Sender name'),
    matching: find.byType(TextFormField),
  );
  await tester.enterText(senderNameField, 'John Doe');

  final senderPhoneField = find.ancestor(
    of: find.text('Sender phone'),
    matching: find.byType(TextFormField),
  );
  await tester.enterText(senderPhoneField, '+1234567890');

  final senderAddressField = find.ancestor(
    of: find.text('Sender address'),
    matching: find.byType(TextFormField),
  );
  await tester.enterText(senderAddressField, '123 Sender St');

  // Receiver fields
  final receiverNameField = find.ancestor(
    of: find.text('Receiver name'),
    matching: find.byType(TextFormField),
  );
  await tester.enterText(receiverNameField, 'Jane Smith');

  final receiverPhoneField = find.ancestor(
    of: find.text('Receiver phone'),
    matching: find.byType(TextFormField),
  );
  await tester.enterText(receiverPhoneField, '+0987654321');

  final receiverAddressField = find.ancestor(
    of: find.text('Receiver address'),
    matching: find.byType(TextFormField),
  );
  await tester.enterText(receiverAddressField, '456 Receiver St');

  // Weight
  final weightField = find.ancestor(
    of: find.text('Weight (kg)'),
    matching: find.byType(TextFormField),
  );
  await tester.enterText(weightField, '2.5');

  await tester.pumpAndSettle();
}


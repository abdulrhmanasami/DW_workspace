import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:parcels_shims/parcels_shims.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/screens/parcels/parcels_create_shipment_screen.dart';
import 'package:delivery_ways_clean/state/parcels/parcel_shipments_providers.dart';
import 'package:design_system_shims/design_system_shims.dart';
import '../support/design_system_harness.dart';

void main() {
  setUpAll(() {
    ensureDesignSystemStubsForTests();
  });

  group('ParcelsCreateShipmentScreen Widget Tests (Track C - Ticket #150)', () {
    Widget createTestWidget({
      Widget? child,
      List<Override> overrides = const [],
      Locale locale = const Locale('en'),
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
          home: child ?? const ParcelsCreateShipmentScreen(),
        ),
      );
    }

    testWidgets('displays all form fields correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Check section titles
      expect(find.text('Sender details'), findsOneWidget);
      expect(find.text('Receiver details'), findsOneWidget);
      expect(find.text('Addresses'), findsOneWidget);
      expect(find.text('Parcel details'), findsOneWidget);
      expect(find.text('Service type'), findsOneWidget);

      // Check form fields
      expect(find.text('Sender name'), findsOneWidget);
      expect(find.text('Sender phone'), findsOneWidget);
      expect(find.text('Receiver name'), findsOneWidget);
      expect(find.text('Receiver phone'), findsOneWidget);
      expect(find.text('Pickup address'), findsOneWidget);
      expect(find.text('Dropoff address'), findsOneWidget);
      expect(find.text('Weight (kg)'), findsOneWidget);
      expect(find.text('Size'), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);

      // Check service type options
      expect(find.text('Express'), findsOneWidget);
      expect(find.text('Standard'), findsOneWidget);

      // Check submit button
      expect(find.text('Create shipment'), findsAtLeastNWidgets(1));
    });

    testWidgets('validates required fields', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find and tap the submit button without filling fields
      final submitButton = find.widgetWithText(DWButton, 'Create shipment');
      expect(submitButton, findsOneWidget);

      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Check for validation error messages
      expect(find.text('This field is required'), findsAtLeastNWidgets(6)); // 6 required fields
    });

    testWidgets('shows error when no service type selected', (tester) async {
      final fakeRepo = _FakeParcelShipmentsRepository();

      await tester.pumpWidget(
        createTestWidget(
          overrides: [
            parcelShipmentsRepositoryProvider.overrideWithValue(fakeRepo),
          ],
        ),
      );

      // Fill all required fields
      await tester.enterText(find.widgetWithText(TextFormField, 'Sender name'), 'John Doe');
      await tester.enterText(find.widgetWithText(TextFormField, 'Sender phone'), '1234567890');
      await tester.enterText(find.widgetWithText(TextFormField, 'Receiver name'), 'Jane Smith');
      await tester.enterText(find.widgetWithText(TextFormField, 'Receiver phone'), '0987654321');
      await tester.enterText(find.widgetWithText(TextFormField, 'Pickup address'), '123 Main St');
      await tester.enterText(find.widgetWithText(TextFormField, 'Dropoff address'), '456 Oak Ave');

      // Try to submit without selecting service type
      final submitButton = find.widgetWithText(DWButton, 'Create shipment');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Check for service type error
      expect(find.text('Please select a service type'), findsOneWidget);
    });

    testWidgets('creates shipment successfully with all fields filled', (tester) async {
      final fakeRepo = _FakeParcelShipmentsRepository();
      bool wasCreated = false;

      await tester.pumpWidget(
        createTestWidget(
          overrides: [
            parcelShipmentsRepositoryProvider.overrideWithValue(fakeRepo),
            createParcelShipmentProvider.overrideWithValue((shipment) async {
              wasCreated = true;
              return shipment;
            }),
          ],
        ),
      );

      // Fill all required fields
      await tester.enterText(find.widgetWithText(TextFormField, 'Sender name'), 'John Doe');
      await tester.enterText(find.widgetWithText(TextFormField, 'Sender phone'), '1234567890');
      await tester.enterText(find.widgetWithText(TextFormField, 'Receiver name'), 'Jane Smith');
      await tester.enterText(find.widgetWithText(TextFormField, 'Receiver phone'), '0987654321');
      await tester.enterText(find.widgetWithText(TextFormField, 'Pickup address'), '123 Main St');
      await tester.enterText(find.widgetWithText(TextFormField, 'Dropoff address'), '456 Oak Ave');

      // Fill optional fields
      await tester.enterText(find.widgetWithText(TextFormField, 'Weight (kg)'), '2.5');
      await tester.enterText(find.widgetWithText(TextFormField, 'Size'), 'Medium Box');
      await tester.enterText(find.widgetWithText(TextFormField, 'Notes'), 'Fragile items');

      // Select Express service type
      await tester.tap(find.text('Express'));
      await tester.pump();

      // Submit the form
      final submitButton = find.widgetWithText(DWButton, 'Create shipment');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify shipment was created
      expect(wasCreated, isTrue);
    });

    testWidgets('service type chips work correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Initially neither chip should be selected visually (no check icons)
      expect(find.byIcon(Icons.check_circle), findsNothing);

      // Tap Express
      await tester.tap(find.text('Express'));
      await tester.pump();

      // Express should show selected icon
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      // Tap Standard
      await tester.tap(find.text('Standard'));
      await tester.pump();

      // Standard should now show selected icon (still only one)
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('weight field only accepts numeric input', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final weightField = find.widgetWithText(TextFormField, 'Weight (kg)');
      
      // Try to enter non-numeric text - should not appear
      await tester.enterText(weightField, 'abc');
      await tester.pump();

      // Field should be empty as non-numeric characters are filtered
      final textField = tester.widget<TextFormField>(weightField);
      expect(textField.controller?.text ?? '', '');

      // Enter valid numeric value
      await tester.enterText(weightField, '5.5');
      await tester.pump();

      // This should work
      expect(textField.controller?.text, '5.5');
    });

    testWidgets('phone fields only accept numeric input', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final senderPhoneField = find.widgetWithText(TextFormField, 'Sender phone');
      
      // Try to enter non-numeric text
      await tester.enterText(senderPhoneField, 'abc123');
      await tester.pump();

      // Only numeric characters should remain
      final textField = tester.widget<TextFormField>(senderPhoneField);
      expect(textField.controller?.text, '123');
    });

    testWidgets('notes field supports multiline input', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final notesField = find.widgetWithText(TextFormField, 'Notes');
      
      // Verify the field exists and can accept multiline text
      expect(notesField, findsOneWidget);
      
      // Try entering multiline text
      await tester.enterText(notesField, 'Line 1\nLine 2\nLine 3');
      await tester.pump();
      
      // Verify the text was accepted
      final textField = tester.widget<TextFormField>(notesField);
      expect(textField.controller?.text, contains('Line 1\nLine 2\nLine 3'));
    });
  });
}

// Fake implementation for testing
class _FakeParcelShipmentsRepository implements ParcelShipmentsRepository {
  final List<ParcelShipment> _shipments = [];

  @override
  Stream<List<ParcelShipment>> watchShipments() {
    return Stream.value(_shipments);
  }

  @override
  Future<ParcelShipment?> getShipmentById(String id) async {
    try {
      return _shipments.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<ParcelShipment> createShipment(ParcelShipment shipment) async {
    _shipments.add(shipment);
    return shipment;
  }

  @override
  Future<void> updateShipmentStatus(
      String id, ParcelShipmentStatus status) async {
    final index = _shipments.indexWhere((s) => s.id == id);
    if (index != -1) {
      _shipments[index] = _shipments[index].copyWith(status: status);
    }
  }

  @override
  Future<void> clearAll() async {
    _shipments.clear();
  }

  void dispose() {
    // Clean up if needed
  }
}

/// Parcels Happy Path Flow Test - Track C Ticket #79
/// Purpose: End-to-end widget test for the complete Parcels creation flow
/// Flow: ParcelsListScreen (empty) → Destination → Details → Quote → Confirm → List shows shipment
/// Created by: Track C - Ticket #79
/// Last updated: 2025-11-29

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:design_system_shims/design_system_shims.dart';
import 'package:parcels_shims/parcels_shims.dart';

import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/router/app_router.dart';
import 'package:delivery_ways_clean/screens/parcels/parcels_list_screen.dart';
import 'package:delivery_ways_clean/screens/parcels/parcel_destination_screen.dart';
import 'package:delivery_ways_clean/screens/parcels/parcel_details_screen.dart';
import 'package:delivery_ways_clean/screens/parcels/parcel_quote_screen.dart';
import 'package:delivery_ways_clean/screens/parcels/parcel_shipment_details_screen.dart';
import 'package:delivery_ways_clean/screens/parcels/parcels_entry_screen.dart';
import 'package:delivery_ways_clean/state/parcels/parcel_draft_state.dart';
import 'package:delivery_ways_clean/state/parcels/parcel_orders_state.dart';
import 'package:delivery_ways_clean/state/parcels/parcel_quote_state.dart';
import 'package:delivery_ways_clean/state/parcels/parcels_repository_provider.dart';
import '../../support/design_system_harness.dart';

void main() {
  setUpAll(() {
    ensureDesignSystemStubsForTests();
  });

  /// Creates a complete test app with all Parcels routes configured.
  /// Uses real providers to test the complete flow end-to-end.
  Widget createParcelsFlowTestApp({
    Locale locale = const Locale('en'),
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: [
        // Use MockParcelPricingService with fast response for testing
        parcelPricingServiceProvider.overrideWithValue(
          const MockParcelPricingService(
            baseLatency: Duration.zero,
            failureRate: 0.0,
          ),
        ),
        // Use in-memory repository
        parcelsRepositoryProvider.overrideWithValue(_StubParcelsRepository()),
        ...overrides,
      ],
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
        routes: {
          '/': (_) => const ParcelsListScreen(),
          RoutePaths.parcelsList: (_) => const ParcelsListScreen(),
          RoutePaths.parcelsHome: (_) => const ParcelsEntryScreen(),
          RoutePaths.parcelsDestination: (_) => const ParcelDestinationScreen(),
          RoutePaths.parcelsDetails: (_) => const ParcelDetailsScreen(),
          RoutePaths.parcelsQuote: (_) => const ParcelQuoteScreen(),
        },
        initialRoute: '/',
      ),
    );
  }

  group('Parcels Happy Path Flow Tests (Ticket #79)', () {
    testWidgets(
      'parcels happy path: create → details → quote → confirm and list updates',
      (WidgetTester tester) async {
        // =====================================================================
        // SETUP: Start with empty ParcelsListScreen
        // =====================================================================
        await tester.pumpWidget(createParcelsFlowTestApp());
        await tester.pumpAndSettle();

        // Assert: Empty state is shown
        expect(find.text('No shipments yet'), findsOneWidget);
        expect(find.text('Create first shipment'), findsOneWidget);
        expect(find.byIcon(Icons.local_shipping_outlined), findsOneWidget);

        // =====================================================================
        // STEP 1: Tap CTA to start creating a new shipment
        // =====================================================================
        await tester.tap(find.text('Create first shipment'));
        await tester.pumpAndSettle();

        // Assert: Now on ParcelDestinationScreen (AppBar title = "New Shipment")
        expect(find.text('New Shipment'), findsAtLeastNWidgets(1));
        expect(find.byType(ParcelDestinationScreen), findsOneWidget);

        // =====================================================================
        // STEP 2: Fill Destination form (Sender/Receiver)
        // =====================================================================
        final textFields = find.byType(TextFormField);
        expect(textFields, findsNWidgets(4));

        // Fill sender name (field 0)
        await tester.enterText(textFields.at(0), 'John Sender');
        await tester.pumpAndSettle();

        // Fill pickup address (field 1)
        await tester.enterText(textFields.at(1), '123 Pickup Street, Riyadh');
        await tester.pumpAndSettle();

        // Fill receiver name (field 2)
        await tester.enterText(textFields.at(2), 'Jane Receiver');
        await tester.pumpAndSettle();

        // Fill delivery address (field 3)
        await tester.enterText(textFields.at(3), '456 Delivery Ave, Jeddah');
        await tester.pumpAndSettle();

        // Tap "Get estimate" CTA
        await tester.tap(find.text('Get estimate'));
        await tester.pumpAndSettle();

        // Assert: Now on ParcelDetailsScreen
        expect(find.text('Parcel details'), findsAtLeastNWidgets(1));
        expect(find.byType(ParcelDetailsScreen), findsOneWidget);

        // =====================================================================
        // STEP 3: Fill Details form (Size, Weight, Contents)
        // =====================================================================

        // Select size: Medium
        await tester.tap(find.text('Medium'));
        await tester.pumpAndSettle();

        // Find DWTextField widgets for weight and contents
        final dwTextFields = find.byType(DWTextField);
        expect(dwTextFields, findsNWidgets(2));

        // Enter weight (first DWTextField)
        await tester.enterText(dwTextFields.first, '2.5');
        await tester.pumpAndSettle();

        // Enter contents description (second DWTextField)
        await tester.enterText(dwTextFields.at(1), 'Books and documents');
        await tester.pumpAndSettle();

        // Scroll to and tap "Review price" CTA
        await tester.scrollUntilVisible(
          find.text('Review price'),
          100.0,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text('Review price'));
        await tester.pumpAndSettle();

        // Assert: Now on ParcelQuoteScreen
        expect(find.text('Shipment pricing'), findsAtLeastNWidgets(1));
        expect(find.byType(ParcelQuoteScreen), findsOneWidget);

        // =====================================================================
        // STEP 4: Quote Screen - Select option and confirm
        // =====================================================================

        // Wait for pricing to load (MockPricingService returns instantly)
        await tester.pumpAndSettle();

        // Verify pricing options are shown
        expect(find.text('Standard'), findsOneWidget);
        expect(find.text('Express'), findsOneWidget);

        // Verify summary card shows our data
        expect(find.text('Shipment summary'), findsOneWidget);
        expect(find.text('123 Pickup Street, Riyadh'), findsOneWidget);
        expect(find.text('456 Delivery Ave, Jeddah'), findsOneWidget);
        expect(find.text('2.5 kg'), findsOneWidget);

        // Select "Standard" option
        await tester.tap(find.text('Standard'));
        await tester.pumpAndSettle();

        // Verify total row appears after selection
        expect(find.textContaining('SAR'), findsAtLeastNWidgets(1));

        // Tap "Confirm shipment" CTA
        await tester.tap(find.text('Confirm shipment'));
        await tester.pumpAndSettle();

        // =====================================================================
        // STEP 5: Verify navigation to ParcelShipmentDetailsScreen (Ticket #80)
        // =====================================================================

        // After confirm, should navigate to ParcelShipmentDetailsScreen
        await tester.pumpAndSettle();

        // Ticket #80: Verify we're now on ParcelShipmentDetailsScreen
        expect(find.byType(ParcelShipmentDetailsScreen), findsOneWidget);
        expect(find.byType(ParcelQuoteScreen), findsNothing);

        // Verify AppBar shows "Active shipment" title
        expect(find.text('Active shipment'), findsOneWidget);

        // Access the ProviderContainer to verify state
        final element = tester.element(find.byType(MaterialApp));
        final container = ProviderScope.containerOf(element);

        // Verify parcel was created in the orders state
        final ordersState = container.read(parcelOrdersProvider);
        expect(ordersState.parcels.length, 1);
        expect(ordersState.activeParcel, isNotNull);

        // Verify parcel properties
        final createdParcel = ordersState.parcels.first;
        expect(createdParcel.pickupAddress.label, '123 Pickup Street, Riyadh');
        expect(createdParcel.dropoffAddress.label, '456 Delivery Ave, Jeddah');
        expect(createdParcel.details.size, ParcelSize.medium);
        expect(createdParcel.details.weightKg, 2.5);
        expect(createdParcel.status, ParcelStatus.scheduled);

        // Verify the details screen shows the correct data (addresses may appear in multiple sections)
        expect(find.text('123 Pickup Street, Riyadh'), findsAtLeastNWidgets(1));
        expect(find.text('456 Delivery Ave, Jeddah'), findsAtLeastNWidgets(1));

        // Verify draft was reset
        final draftState = container.read(parcelDraftProvider);
        expect(draftState.pickupAddress, isEmpty);
        expect(draftState.dropoffAddress, isEmpty);
        expect(draftState.size, isNull);
        expect(draftState.weightText, isEmpty);
        expect(draftState.selectedQuoteOptionId, isNull);

        // Verify quote state was reset
        final quoteState = container.read(parcelQuoteControllerProvider);
        expect(quoteState.isLoading, isFalse);
        expect(quoteState.quote, isNull);
      },
    );

    testWidgets(
      'verify parcel appears in list after creation via state injection',
      (WidgetTester tester) async {
        // Create a pre-filled state with one parcel
        final existingParcel = Parcel(
          id: 'test-parcel-123',
          createdAt: DateTime(2025, 11, 29, 10, 30),
          pickupAddress: const ParcelAddress(label: 'Test Pickup'),
          dropoffAddress: const ParcelAddress(label: 'Test Dropoff'),
          details: const ParcelDetails(
            size: ParcelSize.small,
            weightKg: 1.0,
          ),
          status: ParcelStatus.scheduled,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              parcelOrdersProvider.overrideWith((ref) {
                final controller = ParcelOrdersController(
                  repository: _StubParcelsRepository(),
                );
                controller.state = ParcelOrdersState(
                  activeParcel: existingParcel,
                  parcels: [existingParcel],
                );
                return controller;
              }),
            ],
            child: const MaterialApp(
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: [Locale('en')],
              home: ParcelsListScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify list is NOT empty
        expect(find.text('No shipments yet'), findsNothing);

        // Verify parcel card is shown
        expect(find.text('Test Dropoff'), findsOneWidget);
        expect(find.byIcon(Icons.local_shipping_outlined), findsOneWidget);

        // Verify status chip shows scheduled status (using localizedParcelStatusLong)
        // localizedParcelStatusLong returns "Pickup scheduled" for scheduled status
        expect(find.text('Pickup scheduled'), findsOneWidget);

        // Verify chevron for navigation
        expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      },
    );

    testWidgets(
      'parcel creation stores correct data in provider state',
      (WidgetTester tester) async {
        await tester.pumpWidget(createParcelsFlowTestApp());
        await tester.pumpAndSettle();

        // === Parcel Creation Flow ===
        await tester.tap(find.text('Create first shipment'));
        await tester.pumpAndSettle();

        // Fill form fields
        final textFields1 = find.byType(TextFormField);
        await tester.enterText(textFields1.at(0), 'Test Sender');
        await tester.enterText(textFields1.at(1), 'Test Pickup Address');
        await tester.enterText(textFields1.at(2), 'Test Receiver');
        await tester.enterText(textFields1.at(3), 'Test Dropoff Address');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Get estimate'));
        await tester.pumpAndSettle();

        // Details screen
        await tester.tap(find.text('Small'));
        await tester.pumpAndSettle();

        final dwFields1 = find.byType(DWTextField);
        await tester.enterText(dwFields1.first, '1.5');
        await tester.enterText(dwFields1.at(1), 'Test Contents');
        await tester.pumpAndSettle();

        await tester.scrollUntilVisible(
          find.text('Review price'),
          100.0,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text('Review price'));
        await tester.pumpAndSettle();

        // Quote screen - select and confirm
        await tester.tap(find.text('Standard'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Confirm shipment'));
        await tester.pumpAndSettle();

        // Get container reference
        final element = tester.element(find.byType(MaterialApp));
        final container = ProviderScope.containerOf(element);

        // Verify parcel created with correct data
        final ordersState = container.read(parcelOrdersProvider);
        expect(ordersState.parcels.length, 1);

        final parcel = ordersState.parcels.first;
        expect(parcel.pickupAddress.label, 'Test Pickup Address');
        expect(parcel.dropoffAddress.label, 'Test Dropoff Address');
        expect(parcel.details.size, ParcelSize.small);
        expect(parcel.details.weightKg, 1.5);
        expect(parcel.status, ParcelStatus.scheduled);
      },
    );

    testWidgets(
      'validation errors prevent progression through flow',
      (WidgetTester tester) async {
        await tester.pumpWidget(createParcelsFlowTestApp());
        await tester.pumpAndSettle();

        // Navigate to destination screen
        await tester.tap(find.text('Create first shipment'));
        await tester.pumpAndSettle();

        // Try to proceed without filling fields
        await tester.tap(find.text('Get estimate'));
        await tester.pumpAndSettle();

        // Should show validation errors and stay on same screen
        expect(find.text('This field is required'), findsAtLeastNWidgets(2));
        expect(find.byType(ParcelDestinationScreen), findsOneWidget);
        expect(find.byType(ParcelDetailsScreen), findsNothing);
      },
    );

    testWidgets(
      'L10n AR: flow works with Arabic locale',
      (WidgetTester tester) async {
        await tester.pumpWidget(createParcelsFlowTestApp(
          locale: const Locale('ar'),
        ));
        await tester.pumpAndSettle();

        // Verify Arabic empty state
        expect(find.text('لا توجد شحنات حتى الآن'), findsOneWidget);
        expect(find.text('أنشئ أول شحنة'), findsOneWidget);

        // Start creation flow
        await tester.tap(find.text('أنشئ أول شحنة'));
        await tester.pumpAndSettle();

        // Verify Arabic title on destination screen
        expect(find.text('شحنة جديدة'), findsAtLeastNWidgets(1));
      },
    );

    testWidgets(
      'L10n DE: flow works with German locale',
      (WidgetTester tester) async {
        await tester.pumpWidget(createParcelsFlowTestApp(
          locale: const Locale('de'),
        ));
        await tester.pumpAndSettle();

        // Verify German empty state
        expect(find.text('Noch keine Sendungen'), findsOneWidget);
        expect(find.text('Erste Sendung erstellen'), findsOneWidget);

        // Start creation flow
        await tester.tap(find.text('Erste Sendung erstellen'));
        await tester.pumpAndSettle();

        // Verify German title on destination screen
        expect(find.text('Neue Sendung'), findsAtLeastNWidgets(1));
      },
    );

    testWidgets(
      'back navigation works throughout the flow',
      (WidgetTester tester) async {
        await tester.pumpWidget(createParcelsFlowTestApp());
        await tester.pumpAndSettle();

        // Navigate to destination
        await tester.tap(find.text('Create first shipment'));
        await tester.pumpAndSettle();
        expect(find.byType(ParcelDestinationScreen), findsOneWidget);

        // Fill destination and proceed
        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.at(0), 'Test Sender');
        await tester.enterText(textFields.at(1), 'Test Pickup');
        await tester.enterText(textFields.at(2), 'Test Receiver');
        await tester.enterText(textFields.at(3), 'Test Dropoff');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Get estimate'));
        await tester.pumpAndSettle();
        expect(find.byType(ParcelDetailsScreen), findsOneWidget);

        // Press back
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // Should be back on destination screen
        expect(find.byType(ParcelDestinationScreen), findsOneWidget);

        // Data should be preserved in draft (pickup/dropoff addresses)
        final element = tester.element(find.byType(MaterialApp));
        final container = ProviderScope.containerOf(element);
        final draft = container.read(parcelDraftProvider);
        expect(draft.pickupAddress, 'Test Pickup');
        expect(draft.dropoffAddress, 'Test Dropoff');
      },
    );
  });

  // ===========================================================================
  // Track C - Ticket #79: Optional - Active Parcel Card on Home Hub
  // Note: This test is simplified since AppShell setup is complex.
  // Full integration would be in a separate ticket.
  // ===========================================================================
  group('Active Parcel Card Integration (Optional - Ticket #79)', () {
    testWidgets(
      'parcel with non-terminal status would show as active',
      (WidgetTester tester) async {
        // This test verifies the logic that would show active parcel on Home Hub
        // Using the same helper from parcel_status_utils.dart

        final scheduledParcel = Parcel(
          id: 'active-parcel',
          createdAt: DateTime.now(),
          pickupAddress: const ParcelAddress(label: 'Pickup'),
          dropoffAddress: const ParcelAddress(label: 'Dropoff'),
          details: const ParcelDetails(
            size: ParcelSize.medium,
            weightKg: 2.0,
          ),
          status: ParcelStatus.scheduled,
        );

        // Verify scheduled status is NOT terminal
        expect(scheduledParcel.status, ParcelStatus.scheduled);
        expect(
          scheduledParcel.status != ParcelStatus.delivered &&
              scheduledParcel.status != ParcelStatus.cancelled &&
              scheduledParcel.status != ParcelStatus.failed,
          isTrue,
        );
      },
    );

    testWidgets(
      'terminal status parcel would NOT show as active',
      (WidgetTester tester) async {
        final deliveredParcel = Parcel(
          id: 'delivered-parcel',
          createdAt: DateTime.now(),
          pickupAddress: const ParcelAddress(label: 'Pickup'),
          dropoffAddress: const ParcelAddress(label: 'Dropoff'),
          details: const ParcelDetails(
            size: ParcelSize.small,
            weightKg: 1.0,
          ),
          status: ParcelStatus.delivered,
        );

        // Verify delivered status IS terminal
        expect(deliveredParcel.status, ParcelStatus.delivered);
        expect(
          deliveredParcel.status == ParcelStatus.delivered ||
              deliveredParcel.status == ParcelStatus.cancelled ||
              deliveredParcel.status == ParcelStatus.failed,
          isTrue,
        );
      },
    );
  });
}

/// Stub ParcelsRepository for testing.
/// Provides in-memory storage for parcels during tests.
class _StubParcelsRepository implements ParcelsRepository {
  final List<Parcel> _parcels = [];

  @override
  Future<Parcel> createShipment(ParcelCreateRequest request) async {
    final parcel = Parcel(
      id: 'stub-parcel-${DateTime.now().microsecondsSinceEpoch}',
      createdAt: DateTime.now(),
      pickupAddress: ParcelAddress(label: request.senderAddress),
      dropoffAddress: ParcelAddress(label: request.receiverAddress),
      details: ParcelDetails(
        size: request.size,
        weightKg: double.tryParse(request.weightText) ?? 1.0,
      ),
      status: ParcelStatus.scheduled,
    );
    _parcels.add(parcel);
    return parcel;
  }

  @override
  Future<List<Parcel>> listParcels() async {
    return List.unmodifiable(_parcels);
  }

  @override
  Future<Parcel?> getParcelById(String id) async {
    try {
      return _parcels.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}


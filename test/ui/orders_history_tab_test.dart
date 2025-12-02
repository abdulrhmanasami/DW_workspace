import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parcels_shims/parcels_shims.dart';

import '../../lib/app_shell/app_shell.dart';
import '../../lib/state/orders/orders_history_providers.dart';
import '../../lib/l10n/generated/app_localizations.dart';

/// Test file for Orders History Tab
/// Track C - Ticket #152

void main() {
  group('Orders History Tab Tests', () {
    late List<ParcelShipment> mockShipments;

    setUp(() {
      // Create mock parcel shipments
      mockShipments = [
        ParcelShipment(
          id: '1',
          sender: const ParcelContact(
            name: 'John Doe',
            phone: '+966500000000',
          ),
          receiver: const ParcelContact(
            name: 'Jane Smith',
            phone: '+966500000001',
          ),
          status: ParcelShipmentStatus.created,
          pickupAddress: const ParcelAddress(
            label: 'Home',
            streetLine1: '123 Main St',
            city: 'Riyadh',
            countryCode: 'SA',
          ),
          dropoffAddress: const ParcelAddress(
            label: 'Office',
            streetLine1: '456 Business Ave',
            city: 'Riyadh',
            countryCode: 'SA',
          ),
          weightKg: 1.0,
          sizeLabel: 'Small',
          notes: 'Documents',
          estimatedPrice: 15.50,
          currencyCode: 'SAR',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now(),
        ),
        ParcelShipment(
          id: '2',
          sender: const ParcelContact(
            name: 'Store Owner',
            phone: '+966500000002',
          ),
          receiver: const ParcelContact(
            name: 'Customer',
            phone: '+966500000003',
          ),
          status: ParcelShipmentStatus.delivered,
          pickupAddress: const ParcelAddress(
            label: 'Store',
            streetLine1: '789 Shop St',
            city: 'Jeddah',
            countryCode: 'SA',
          ),
          dropoffAddress: const ParcelAddress(
            label: 'Customer',
            streetLine1: '321 Customer Rd',
            city: 'Jeddah',
            countryCode: 'SA',
          ),
          weightKg: 2.5,
          sizeLabel: 'Medium',
          notes: 'Package',
          estimatedPrice: 25.00,
          currencyCode: 'SAR',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          updatedAt: DateTime.now(),
        ),
      ];
    });

    testWidgets('displays Empty State when no shipments exist',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ordersHistoryProvider.overrideWithValue(
              const AsyncData<List<OrderHistoryItem>>([]),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AppShell(),
          ),
        ),
      );

      // Navigate to Orders tab
      await tester.tap(find.byIcon(Icons.receipt_long_outlined));
      await tester.pumpAndSettle();

      // Verify empty state is shown
      expect(find.text('No orders yet'), findsOneWidget);
      expect(find.text('You don\'t have any orders yet. Start by creating a new shipment.'), findsOneWidget);
      expect(find.text('Create first shipment'), findsOneWidget);
    });

    testWidgets('displays list of Parcel Orders when shipments exist',
        (WidgetTester tester) async {
      final orderItems = mockShipments
          .map((s) => ParcelOrderHistoryItem(s))
          .toList();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ordersHistoryProvider.overrideWithValue(
              AsyncData<List<OrderHistoryItem>>(orderItems),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AppShell(),
          ),
        ),
      );

      // Navigate to Orders tab
      await tester.tap(find.byIcon(Icons.receipt_long_outlined));
      await tester.pumpAndSettle();

      // Verify shipments are displayed
      expect(find.text('Office'), findsOneWidget);
      expect(find.text('Customer'), findsOneWidget);
      expect(find.text('Created'), findsOneWidget);
      expect(find.text('Delivered'), findsOneWidget);
    });

    testWidgets('Parcels filter shows only parcel orders',
        (WidgetTester tester) async {
      final orderItems = mockShipments
          .map((s) => ParcelOrderHistoryItem(s))
          .toList();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ordersHistoryProvider.overrideWithValue(
              AsyncData<List<OrderHistoryItem>>(orderItems),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AppShell(),
          ),
        ),
      );

      // Navigate to Orders tab
      await tester.tap(find.byIcon(Icons.receipt_long_outlined));
      await tester.pumpAndSettle();

      // Tap on Parcels filter
      await tester.tap(find.text('Parcels'));
      await tester.pumpAndSettle();

      // Verify parcel orders are still displayed
      expect(find.text('Office'), findsOneWidget);
      expect(find.text('Customer'), findsOneWidget);
    });

    testWidgets('Rides filter shows empty state when no rides',
        (WidgetTester tester) async {
      final orderItems = mockShipments
          .map((s) => ParcelOrderHistoryItem(s))
          .toList();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ordersHistoryProvider.overrideWithValue(
              AsyncData<List<OrderHistoryItem>>(orderItems),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AppShell(),
          ),
        ),
      );

      // Navigate to Orders tab
      await tester.tap(find.byIcon(Icons.receipt_long_outlined));
      await tester.pumpAndSettle();

      // Tap on Rides filter
      await tester.tap(find.text('Rides'));
      await tester.pumpAndSettle();

      // Verify empty state is shown (no rides)
      expect(find.text('No orders yet'), findsOneWidget);
    });

    testWidgets('displays loading state while fetching data',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ordersHistoryProvider.overrideWithValue(
              const AsyncLoading<List<OrderHistoryItem>>(),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AppShell(),
          ),
        ),
      );

      // Navigate to Orders tab
      await tester.tap(find.byIcon(Icons.receipt_long_outlined));
      await tester.pump(); // Don't settle to see loading state

      // Verify skeleton loader is shown (ListView with skeleton items)
      expect(find.byType(ListView), findsWidgets);
      // Check for skeleton containers
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('displays error state when provider returns error',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ordersHistoryProvider.overrideWithValue(
              AsyncError<List<OrderHistoryItem>>(
                Exception('Failed to load orders'),
                StackTrace.empty,
              ),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AppShell(),
          ),
        ),
      );

      // Navigate to Orders tab
      await tester.tap(find.byIcon(Icons.receipt_long_outlined));
      await tester.pumpAndSettle();

      // Verify error state is shown
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Unable to load orders'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('order cards display correct information',
        (WidgetTester tester) async {
      final orderItems = [ParcelOrderHistoryItem(mockShipments.first)];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ordersHistoryProvider.overrideWithValue(
              AsyncData<List<OrderHistoryItem>>(orderItems),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AppShell(),
          ),
        ),
      );

      // Navigate to Orders tab
      await tester.tap(find.byIcon(Icons.receipt_long_outlined));
      await tester.pumpAndSettle();

      // Verify card displays correct information
      expect(find.text('Office'), findsOneWidget); // Dropoff address label
      expect(find.text('Created'), findsOneWidget); // Status
      expect(find.text('Home → Office'), findsOneWidget); // Route
      expect(find.text('15.50 SAR'), findsOneWidget); // Price
    });
  });
}

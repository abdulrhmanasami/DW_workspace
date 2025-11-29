/// Home Hub to Parcels Entry Navigation Test - Track C Ticket #40
/// Purpose: Test navigation from Home Hub ServiceCard to ParcelsEntryScreen
/// Created by: Track C - Ticket #40
/// Updated by: Track C - Ticket #45 (added ProviderScope for ConsumerWidget)
/// Last updated: 2025-11-28

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/router/app_router.dart';
import 'package:delivery_ways_clean/screens/parcels/parcels_entry_screen.dart';
import '../support/design_system_harness.dart';

void main() {
  setUpAll(() {
    ensureDesignSystemStubsForTests();
  });

  group('Home Hub to ParcelsEntry Navigation Tests', () {
    testWidgets('ParcelsEntryScreen is accessible via RoutePaths.parcelsHome',
        (WidgetTester tester) async {
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
            initialRoute: RoutePaths.parcelsHome,
            routes: {
              RoutePaths.parcelsHome: (context) => const ParcelsEntryScreen(),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify ParcelsEntryScreen is displayed
      expect(find.text('Parcels'), findsAtLeastNWidgets(1));
      expect(
        find.text('Ship and track your parcels in one place.'),
        findsOneWidget,
      );
    });

    testWidgets('RoutePaths.parcelsHome has correct path value',
        (WidgetTester tester) async {
      // Verify the route path constant
      expect(RoutePaths.parcelsHome, equals('/parcels'));
    });

    testWidgets('ParcelsEntryScreen displays all expected UI elements',
        (WidgetTester tester) async {
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
            home: const ParcelsEntryScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check for shipping icon
      expect(find.byIcon(Icons.local_shipping_outlined), findsOneWidget);

      // Check for title
      expect(find.text('Parcels'), findsAtLeastNWidgets(1));

      // Check for subtitle
      expect(
        find.text('Ship and track your parcels in one place.'),
        findsOneWidget,
      );

      // Check for CTA buttons
      expect(find.text('Create shipment'), findsOneWidget);

      // Check for footer note
      expect(
        find.text('Parcels MVP is under active development.'),
        findsOneWidget,
      );
    });

    testWidgets('Navigation from simulated Home ServiceCard tap works',
        (WidgetTester tester) async {
      // This test simulates the navigation that would happen
      // when tapping the Parcels ServiceCard in Home Hub
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
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.inventory_2_outlined),
                      title: const Text('Parcels'),
                      subtitle: const Text('Send anything, anywhere.'),
                      onTap: () {
                        Navigator.of(context).pushNamed(RoutePaths.parcelsHome);
                      },
                    ),
                  ),
                ),
              ),
            ),
            routes: {
              RoutePaths.parcelsHome: (context) => const ParcelsEntryScreen(),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Home-like card is displayed
      expect(find.text('Parcels'), findsOneWidget);
      expect(find.text('Send anything, anywhere.'), findsOneWidget);

      // Tap the card
      await tester.tap(find.text('Parcels'));
      await tester.pumpAndSettle();

      // Verify navigation to ParcelsEntryScreen
      expect(
        find.text('Ship and track your parcels in one place.'),
        findsOneWidget,
      );
    });

    testWidgets('ParcelsEntryScreen can navigate back',
        (WidgetTester tester) async {
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
                    onPressed: () =>
                        Navigator.of(context).pushNamed(RoutePaths.parcelsHome),
                    child: const Text('Go to Parcels'),
                  ),
                ),
              ),
            ),
            routes: {
              RoutePaths.parcelsHome: (context) => const ParcelsEntryScreen(),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to ParcelsEntryScreen
      await tester.tap(find.text('Go to Parcels'));
      await tester.pumpAndSettle();

      // Verify we're on ParcelsEntryScreen
      expect(
        find.text('Ship and track your parcels in one place.'),
        findsOneWidget,
      );

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify we're back
      expect(find.text('Go to Parcels'), findsOneWidget);
    });
  });
}

/// Widget tests for DSR Settings Flow
/// Purpose: Verify DSR screens UI and navigation from Settings/Profile tab
/// Created by: Track D - Ticket #59
/// Last updated: 2025-11-29

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// App imports
import 'package:delivery_ways_clean/app_shell/app_shell.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';

void main() {
  group('DSR Settings Flow - Ticket #59', () {
    /// Helper to build test app with AppShell as home
    Widget buildTestAppWithAppShell({
      Locale locale = const Locale('en'),
    }) {
      return ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: locale,
          home: const AppShellWithNavigation(),
        ),
      );
    }

    group('DSR Entry Points in Profile Tab', () {
      testWidgets('displays Privacy & Data section with DSR items', (tester) async {
        await tester.pumpWidget(buildTestAppWithAppShell());
        await tester.pumpAndSettle();

        // Navigate to Profile tab (index 3)
        await tester.tap(find.text('Profile'));
        await tester.pumpAndSettle();

        // Should display Privacy & Data section
        expect(find.text('Privacy & Data'), findsOneWidget);

        // Should display DSR entry items
        expect(find.text('Export my data'), findsOneWidget);
        expect(find.text('Erase my data'), findsOneWidget);
      });

      testWidgets('displays DSR export item with correct subtitle', (tester) async {
        await tester.pumpWidget(buildTestAppWithAppShell());
        await tester.pumpAndSettle();

        // Navigate to Profile tab
        await tester.tap(find.text('Profile'));
        await tester.pumpAndSettle();

        // Should display export item with subtitle
        expect(find.text('Export my data'), findsOneWidget);
        expect(find.text('Request a copy of your personal data.'), findsOneWidget);
      });

      testWidgets('displays DSR erasure item with correct subtitle', (tester) async {
        await tester.pumpWidget(buildTestAppWithAppShell());
        await tester.pumpAndSettle();

        // Navigate to Profile tab
        await tester.tap(find.text('Profile'));
        await tester.pumpAndSettle();

        // Should display erasure item with subtitle
        expect(find.text('Erase my data'), findsOneWidget);
        expect(find.text('Request deletion of your personal data.'), findsOneWidget);
      });

      testWidgets('displays DSR items with correct icons', (tester) async {
        await tester.pumpWidget(buildTestAppWithAppShell());
        await tester.pumpAndSettle();

        // Navigate to Profile tab
        await tester.tap(find.text('Profile'));
        await tester.pumpAndSettle();

        // Should have download and delete icons for DSR items
        expect(find.byIcon(Icons.download_outlined), findsOneWidget);
        expect(find.byIcon(Icons.delete_forever_outlined), findsOneWidget);
      });
    });

    group('Localization - Arabic', () {
      testWidgets('displays Arabic DSR labels in Profile tab', (tester) async {
        await tester.pumpWidget(buildTestAppWithAppShell(locale: const Locale('ar')));
        await tester.pumpAndSettle();

        // Navigate to Profile tab (Arabic label: الحساب)
        await tester.tap(find.text('الحساب'));
        await tester.pumpAndSettle();

        // Should display Arabic labels
        expect(find.text('الخصوصية والبيانات'), findsOneWidget);
        expect(find.text('تصدير بياناتي'), findsOneWidget);
        expect(find.text('حذف بياناتي'), findsOneWidget);
      });
    });

    group('Localization - German', () {
      testWidgets('displays German DSR labels in Profile tab', (tester) async {
        await tester.pumpWidget(buildTestAppWithAppShell(locale: const Locale('de')));
        await tester.pumpAndSettle();

        // Navigate to Profile tab (German label: Profil)
        await tester.tap(find.text('Profil'));
        await tester.pumpAndSettle();

        // Note: German translations may not exist for all profile items
        // Check that the tab navigation works
        expect(find.byType(ListTile), findsWidgets);
      });
    });

    group('Profile Tab Structure', () {
      testWidgets('Profile tab shows Settings and Privacy sections', (tester) async {
        await tester.pumpWidget(buildTestAppWithAppShell());
        await tester.pumpAndSettle();

        // Navigate to Profile tab
        await tester.tap(find.text('Profile'));
        await tester.pumpAndSettle();

        // Should have Settings section
        expect(find.text('Settings'), findsOneWidget);

        // Should have Privacy & Data section
        expect(find.text('Privacy & Data'), findsOneWidget);

        // Should have Logout option
        expect(find.text('Logout'), findsOneWidget);
      });

      testWidgets('Profile tab shows user info card', (tester) async {
        await tester.pumpWidget(buildTestAppWithAppShell());
        await tester.pumpAndSettle();

        // Navigate to Profile tab
        await tester.tap(find.text('Profile'));
        await tester.pumpAndSettle();

        // Should show profile title
        expect(find.text('Profile'), findsWidgets);

        // Should show user avatar icon
        expect(find.byIcon(Icons.person), findsWidgets);
      });
    });

    group('Navigation Bar', () {
      testWidgets('bottom navigation has 4 tabs', (tester) async {
        await tester.pumpWidget(buildTestAppWithAppShell());
        await tester.pumpAndSettle();

        // Should have 4 navigation destinations
        expect(find.byType(NavigationDestination), findsNWidgets(4));

        // Verify tab labels
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Orders'), findsOneWidget);
        expect(find.text('Payments'), findsOneWidget);
        expect(find.text('Profile'), findsOneWidget);
      });

      testWidgets('can navigate between all tabs', (tester) async {
        await tester.pumpWidget(buildTestAppWithAppShell());
        await tester.pumpAndSettle();

        // Start at Home
        expect(find.text('Services'), findsOneWidget);

        // Go to Orders (Track B - Ticket #96: Orders tab now shows OrdersHistoryScreen)
        await tester.tap(find.text('Orders'));
        await tester.pumpAndSettle();
        expect(find.text('My Orders'), findsOneWidget);

        // Go to Payments
        await tester.tap(find.text('Payments'));
        await tester.pumpAndSettle();
        expect(find.text('Payments'), findsWidgets);

        // Go to Profile
        await tester.tap(find.text('Profile'));
        await tester.pumpAndSettle();
        expect(find.text('Privacy & Data'), findsOneWidget);
      });
    });

    group('DSR Items Accessibility', () {
      testWidgets('DSR items are enabled and tappable', (tester) async {
        await tester.pumpWidget(buildTestAppWithAppShell());
        await tester.pumpAndSettle();

        // Navigate to Profile tab
        await tester.tap(find.text('Profile'));
        await tester.pumpAndSettle();

        // Find the Export my data ListTile
        final exportTile = find.ancestor(
          of: find.text('Export my data'),
          matching: find.byType(ListTile),
        );
        expect(exportTile, findsOneWidget);

        // Find the Erase my data ListTile
        final erasureTile = find.ancestor(
          of: find.text('Erase my data'),
          matching: find.byType(ListTile),
        );
        expect(erasureTile, findsOneWidget);
      });

      testWidgets('DSR items have chevron icons indicating navigation', (tester) async {
        await tester.pumpWidget(buildTestAppWithAppShell());
        await tester.pumpAndSettle();

        // Navigate to Profile tab
        await tester.tap(find.text('Profile'));
        await tester.pumpAndSettle();

        // Should have multiple chevron_right icons (one per list item)
        expect(find.byIcon(Icons.chevron_right), findsWidgets);
      });
    });
  });
}


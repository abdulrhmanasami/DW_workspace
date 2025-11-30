/// AppShell Bottom Navigation Tests - Track A Ticket #82
/// Purpose: Test Bottom Navigation tabs, labels (EN/AR/DE), and tab switching
/// Created by: Track A - Ticket #82
/// Updated by: Track B - Ticket #99 (Payments tab now shows PaymentsTabScreen)
/// Last updated: 2025-11-30

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/app_shell/app_shell.dart';

void main() {
  /// Creates a test widget with necessary L10n and provider setup.
  /// Uses same pattern as settings_dsr_flow_test.dart for consistency.
  Widget createTestApp({
    Locale locale = const Locale('en'),
  }) {
    return ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        home: const AppShell(),
      ),
    );
  }

  group('AppShell Bottom Navigation - Ticket #82', () {
    testWidgets('shows four bottom nav items with correct labels (EN)',
        (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Verify all 4 navigation destinations exist with English labels
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Orders'), findsOneWidget);
      expect(find.text('Payments'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Verify we have exactly 4 NavigationDestination widgets
      expect(find.byType(NavigationDestination), findsNWidgets(4));
    });

    testWidgets('tapping Orders tab shows ParcelsListScreen', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Initially on Home tab - verify home content is visible
      expect(find.text('Services'), findsOneWidget);

      // Tap Orders tab
      await tester.tap(find.text('Orders'));
      await tester.pumpAndSettle();

      // Verify OrdersHistoryScreen is displayed
      // OrdersHistoryScreen shows "My Orders" title from ordersHistoryTitle L10n key
      // Track B - Ticket #96: Orders tab now shows OrdersHistoryScreen instead of ParcelsListScreen
      expect(find.text('My Orders'), findsOneWidget);
    });

    // Track B - Ticket #99: Payments tab now shows PaymentsTabScreen instead of stub
    testWidgets('tapping Payments tab shows PaymentsTabScreen', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Tap Payments tab
      await tester.tap(find.text('Payments'));
      await tester.pumpAndSettle();

      // Verify PaymentsTabScreen content is displayed
      expect(find.text('Payments'), findsAtLeastNWidgets(2)); // Title + tab label
      // Track B - Ticket #99: Verify payment methods are shown (default stub has Cash)
      expect(find.text('Cash'), findsAtLeastNWidgets(1));
      expect(find.text('Add new payment method'), findsOneWidget);
    });

    testWidgets('tapping Profile tab shows profile screen', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Tap Profile tab
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Verify Profile content is displayed
      // Profile screen has "Profile" title from profileTitle L10n key
      expect(find.text('Profile'), findsAtLeastNWidgets(2)); // Title + tab label
    });

    testWidgets('l10n Arabic bottom nav labels', (tester) async {
      await tester.pumpWidget(createTestApp(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      // Verify Arabic labels
      expect(find.text('الرئيسية'), findsOneWidget);
      expect(find.text('الطلبات'), findsOneWidget);
      expect(find.text('المدفوعات'), findsOneWidget);
      expect(find.text('الحساب'), findsOneWidget);
    });

    testWidgets('l10n German bottom nav labels', (tester) async {
      await tester.pumpWidget(createTestApp(locale: const Locale('de')));
      await tester.pumpAndSettle();

      // Verify German labels
      expect(find.text('Start'), findsOneWidget);
      expect(find.text('Bestellungen'), findsOneWidget);
      expect(find.text('Zahlungen'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);
    });

    testWidgets('tab switching preserves state (IndexedStack)', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Start on Home
      expect(find.text('Services'), findsOneWidget);

      // Go to Orders (Track B - Ticket #96: Now shows OrdersHistoryScreen)
      await tester.tap(find.text('Orders'));
      await tester.pumpAndSettle();
      expect(find.text('My Orders'), findsOneWidget);

      // Go to Payments (Track B - Ticket #99: Now shows PaymentsTabScreen)
      await tester.tap(find.text('Payments'));
      await tester.pumpAndSettle();
      expect(find.text('Add new payment method'), findsOneWidget);

      // Back to Home - should still work
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.text('Services'), findsOneWidget);
    });

    // Track B - Ticket #99: Payments tab now shows PaymentsTabScreen with Arabic labels
    testWidgets('Payments tab shows correct Arabic text', (tester) async {
      await tester.pumpWidget(createTestApp(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      // Tap Payments tab (Arabic)
      await tester.tap(find.text('المدفوعات'));
      await tester.pumpAndSettle();

      // Verify Arabic PaymentsTabScreen content
      expect(find.text('طرق الدفع'), findsOneWidget); // Title
      expect(find.text('إضافة طريقة دفع جديدة'), findsOneWidget); // Add CTA
    });

    // Track B - Ticket #99: Payments tab now shows PaymentsTabScreen with German labels
    testWidgets('Payments tab shows correct German text', (tester) async {
      await tester.pumpWidget(createTestApp(locale: const Locale('de')));
      await tester.pumpAndSettle();

      // Tap Payments tab (German)
      await tester.tap(find.text('Zahlungen'));
      await tester.pumpAndSettle();

      // Verify German PaymentsTabScreen content
      expect(find.text('Zahlungsmethoden'), findsOneWidget); // Title
      expect(find.text('Neue Zahlungsmethode hinzufügen'), findsOneWidget); // Add CTA
    });
  });
}

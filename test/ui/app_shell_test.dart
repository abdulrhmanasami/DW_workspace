/// AppShell Tests - Track A Ticket #217
/// Purpose: Test AppShell v1 with Bottom Navigation
/// Created by: Track A - Ticket #217
/// Last updated: 2025-12-04

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/app_shell/app_shell.dart';

void main() {
  /// Creates a test widget with necessary L10n and provider setup.
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

  group('AppShell Widget Tests - Ticket #217', () {
    testWidgets('AppShell shows 4 bottom nav items', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Verify all 4 navigation destinations exist
      expect(find.byType(NavigationDestination), findsNWidgets(4));
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Orders'), findsOneWidget);
      expect(find.text('Payments'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('Tapping bottom nav item changes the active tab', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Start on Home tab - verify home content is visible
      expect(find.text('Services'), findsOneWidget);

      // Tap Orders tab
      await tester.tap(find.text('Orders'));
      await tester.pumpAndSettle();

      // Verify Orders content is displayed
      expect(find.text('My Orders'), findsOneWidget);
      // Home content should no longer be visible
      expect(find.text('Services'), findsNothing);
    });

    testWidgets('AppShell respects RTL', (tester) async {
      await tester.pumpWidget(createTestApp(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      // Verify Arabic labels are displayed
      expect(find.text('الرئيسية'), findsOneWidget);
      expect(find.text('الطلبات'), findsOneWidget);
      expect(find.text('المدفوعات'), findsOneWidget);
      expect(find.text('الحساب'), findsOneWidget);

      // Verify no crashes in RTL layout
      expect(find.byType(NavigationBar), findsOneWidget);
    });
  });
}

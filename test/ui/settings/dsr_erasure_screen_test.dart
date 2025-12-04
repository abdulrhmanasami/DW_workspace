/// DSR Erasure Screen UI Tests
/// Purpose: Test DSR erasure screen navigation and basic UI
/// Created by: Ticket #239 - Track D-6 DSR Quick Win

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/app_shell/app_shell.dart';

void main() {
  group('DSR Erasure Screen - Ticket #239', () {
    /// Helper to build test app with AppShell navigation
    Widget buildTestApp({
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

    testWidgets('navigates to DSR Erasure screen from Profile tab', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Navigate to Profile tab
      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();

      // Verify Profile screen is displayed
      expect(find.widgetWithText(AppBar, 'Profile'), findsOneWidget);

      // Tap on "Erase my data" item
      await tester.tap(find.text('Erase my data'));
      await tester.pumpAndSettle();

      // Verify DSR Erasure screen is displayed with correct title
      expect(find.text('Erase Account'), findsOneWidget);
      expect(find.text('Request deletion of your personal data'), findsOneWidget);

      // Verify request button is present
      expect(find.text('Request Account Deletion'), findsOneWidget);
    });

    testWidgets('DSR Erasure screen displays in Arabic', (tester) async {
      await tester.pumpWidget(buildTestApp(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      // Navigate to Profile tab
      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();

      // Tap on Arabic "حذف بياناتي" item
      await tester.tap(find.text('حذف بياناتي'));
      await tester.pumpAndSettle();

      // Verify Arabic title is displayed
      expect(find.text('حذف الحساب'), findsOneWidget);
    });
  });
}

/// Profile Tab Screen Tests - Track A Ticket #227
/// Purpose: Test Profile tab with ProfileHeaderCard, ProfileMenuItem, LTR/RTL support
/// Created by: Track A - Ticket #227
/// Last updated: 2025-12-04

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/app_shell/app_shell.dart';

void main() {
  /// Creates a test widget with necessary L10n and provider setup.
  /// Uses same pattern as other UI tests for consistency.
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

  group('Profile Tab Screen - Ticket #227', () {
    testWidgets('Profile tab loads without exceptions (LTR)', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Navigate to Profile tab using icon
      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();

      // Verify Profile screen is displayed (AppBar title)
      expect(find.widgetWithText(AppBar, 'Profile'), findsOneWidget);

      // Just verify the screen loads without exceptions
      // The actual content verification would be in integration tests
    });

    testWidgets('Profile tab loads without exceptions (RTL)', (tester) async {
      await tester.pumpWidget(createTestApp(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      // Navigate to Profile tab using icon (same in RTL)
      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();

      // Verify Profile screen is displayed (AppBar title in Arabic)
      expect(find.widgetWithText(AppBar, 'الملف الشخصي'), findsOneWidget);

      // Just verify the screen loads without exceptions in RTL
    });
  });
}

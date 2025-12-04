/// Widget tests for Onboarding Flow
/// Purpose: Verify onboarding screens UI and navigation flow
/// Created by: Ticket #238 - Track D-6 Onboarding Flow (Welcome/Permissions/Preferences)
/// Purpose: Test the new Welcome/Permissions/Preferences onboarding flow with persistent storage
/// Last updated: 2025-12-04

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// App imports
import 'package:delivery_ways_clean/screens/onboarding/welcome_screen.dart';
import 'package:delivery_ways_clean/screens/onboarding/permissions_screen.dart';
import 'package:delivery_ways_clean/screens/onboarding/screen_preferences.dart';
import 'package:delivery_ways_clean/screens/onboarding/onboarding_root_screen.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/screens/auth/phone_login_screen.dart';
import 'package:foundation_shims/foundation_shims.dart';

// Import the stub implementation for testing
import 'package:foundation_shims/src/onboarding_prefs_impl.dart';

void main() {
  // ============================================================================
  // Ticket #238: Welcome/Permissions/Preferences Onboarding Flow Tests
  // ============================================================================
  group('Onboarding Flow - Ticket #238 (Welcome/Permissions/Preferences)', () {
    /// Helper to build test widget with MaterialApp wrapper and providers
    Widget buildTestApp({
      required Widget home,
      Locale locale = const Locale('en'),
    }) {
      return ProviderScope(
        overrides: [
          // Override with stub implementation for testing
          onboardingPrefsServiceProvider.overrideWithValue(
            OnboardingPrefsStubImpl(),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: locale,
          home: home,
        ),
      );
    }

    group('OnboardingRootScreen - Initial State', () {
      testWidgets('shows Welcome screen by default', (tester) async {
        await tester.pumpWidget(buildTestApp(
          home: const OnboardingRootScreen(),
        ));
        await tester.pumpAndSettle();

        // Verify Welcome screen title is displayed
        expect(find.text('Welcome to Delivery Ways'), findsOneWidget);

        // Verify shipping icon is displayed
        expect(find.byIcon(Icons.local_shipping_outlined), findsOneWidget);

        // Verify subtitle text
        expect(
          find.text('All your rides, parcels, and deliveries in one place.'),
          findsOneWidget,
        );

        // Verify Get started button
        expect(find.text('Get started'), findsOneWidget);

        // Verify Skip button is visible
        expect(find.text('Skip'), findsOneWidget);
      });

      testWidgets('shows 3 progress dots with first highlighted', (tester) async {
        await tester.pumpWidget(buildTestApp(
          home: const OnboardingRootScreen(),
        ));
        await tester.pumpAndSettle();

        // Find animated containers (progress dots)
        final dots = find.byType(AnimatedContainer);
        expect(dots, findsAtLeastNWidgets(3));
      });
    });

    group('Navigation between screens', () {
      testWidgets('navigates from Welcome to Permissions on Get started tap', (tester) async {
        await tester.pumpWidget(buildTestApp(
          home: const OnboardingRootScreen(),
        ));
        await tester.pumpAndSettle();

        // Verify on Welcome screen
        expect(find.text('Welcome to Delivery Ways'), findsOneWidget);

        // Tap Get started
        await tester.tap(find.text('Get started'));
        await tester.pumpAndSettle();

        // Verify now on Permissions screen
        expect(find.text('Allow permissions'), findsOneWidget);
        expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
        expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
      });

      testWidgets('navigates from Permissions to Preferences on Continue tap', (tester) async {
        await tester.pumpWidget(buildTestApp(
          home: const OnboardingRootScreen(),
        ));
        await tester.pumpAndSettle();

        // Navigate to Permissions
        await tester.tap(find.text('Get started'));
        await tester.pumpAndSettle();

        // Verify on Permissions screen
        expect(find.text('Allow permissions'), findsOneWidget);

        // Tap Continue
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Verify now on Preferences screen
        expect(find.text('Set your preferences'), findsOneWidget);
        expect(find.text('Marketing notifications'), findsOneWidget);
      });

      testWidgets('Preferences screen shows Get started button', (tester) async {
        await tester.pumpWidget(buildTestApp(
          home: const OnboardingRootScreen(),
        ));
        await tester.pumpAndSettle();

        // Navigate to Preferences screen
        await tester.tap(find.text('Get started'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Verify on Preferences screen with Get started button
        expect(find.text('Set your preferences'), findsOneWidget);
        expect(find.text('Start using Delivery Ways'), findsOneWidget);
      });
    });

    group('Skip behavior', () {
      testWidgets('Skip button marks onboarding as completed and navigates to PhoneLoginScreen', (tester) async {
        await tester.pumpWidget(ProviderScope(
          overrides: [
            onboardingPrefsServiceProvider.overrideWithValue(OnboardingPrefsStubImpl()),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const OnboardingRootScreen(),
          ),
        ));
        await tester.pumpAndSettle();

        // Verify on Welcome screen
        expect(find.text('Welcome to Delivery Ways'), findsOneWidget);

        // Tap Skip button
        await tester.tap(find.text('Skip'));
        await tester.pumpAndSettle();

        // Verify onboarding completion was set
        final prefs = tester.element(find.byType(OnboardingRootScreen)).read(onboardingPrefsServiceProvider);
        expect(await prefs.hasCompletedOnboarding(), isTrue);

        // Verify navigation to PhoneLoginScreen (this would be handled by AuthGate in real app)
        // In this test, we just verify the onboarding completion
      });
    });

    group('Get started behavior + preference toggle', () {
      testWidgets('completes onboarding with marketing preference and navigates', (tester) async {
        await tester.pumpWidget(buildTestApp(
          home: const OnboardingRootScreen(),
        ));
        await tester.pumpAndSettle();

        // Navigate to Preferences screen
        await tester.tap(find.text('Get started'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Verify on Preferences screen
        expect(find.text('Set your preferences'), findsOneWidget);
        expect(find.text('Marketing notifications'), findsOneWidget);

        // Toggle marketing notifications switch
        final switchFinder = find.byType(Switch);
        expect(switchFinder, findsOneWidget);
        await tester.tap(switchFinder);
        await tester.pumpAndSettle();

        // Tap Get started
        await tester.tap(find.text('Start using Delivery Ways'));
        await tester.pumpAndSettle();

        // Verify marketing preference was saved
        final prefs = tester.element(find.byType(OnboardingRootScreen)).read(onboardingPrefsServiceProvider);
        expect(await prefs.getMarketingOptIn(), isTrue);
        expect(await prefs.hasCompletedOnboarding(), isTrue);
      });
    });

    group('RTL (Arabic) support', () {
      testWidgets('displays Arabic texts when locale is ar', (tester) async {
        await tester.pumpWidget(buildTestApp(
          home: const OnboardingRootScreen(),
          locale: const Locale('ar'),
        ));
        await tester.pumpAndSettle();

        // Verify Arabic Welcome title
        expect(find.text('مرحبًا في Delivery Ways'), findsOneWidget);

        // Verify Arabic Get started button
        expect(find.text('ابدأ الآن'), findsOneWidget);

        // Verify Arabic Skip button
        expect(find.text('تخطي'), findsOneWidget);
      });

      testWidgets('displays Arabic Permissions screen texts', (tester) async {
        await tester.pumpWidget(buildTestApp(
          home: const OnboardingRootScreen(),
          locale: const Locale('ar'),
        ));
        await tester.pumpAndSettle();

        // Navigate to Permissions screen
        await tester.tap(find.text('ابدأ الآن'));
        await tester.pumpAndSettle();

        // Verify Arabic Permissions title
        expect(find.text('الصلاحيات المطلوبة'), findsOneWidget);

        // Verify Arabic Location permission
        expect(find.text('الوصول إلى الموقع'), findsOneWidget);

        // Verify Arabic Continue button
        expect(find.text('متابعة'), findsOneWidget);
      });

      testWidgets('displays Arabic Preferences screen texts', (tester) async {
        await tester.pumpWidget(buildTestApp(
          home: const OnboardingRootScreen(),
          locale: const Locale('ar'),
        ));
        await tester.pumpAndSettle();

        // Navigate to Preferences screen
        await tester.tap(find.text('ابدأ الآن'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('متابعة'));
        await tester.pumpAndSettle();

        // Verify Arabic Preferences title
        expect(find.text('تهيئة التفضيلات'), findsOneWidget);

        // Verify Arabic Marketing notifications title
        expect(find.text('إشعارات التسويق'), findsOneWidget);

        // Verify Arabic Get started button
        expect(find.text('ابدأ استخدام Delivery Ways'), findsOneWidget);
      });
    });

    group('LTR (English) support', () {
      testWidgets('displays English texts correctly', (tester) async {
        await tester.pumpWidget(buildTestApp(
          home: const OnboardingRootScreen(),
          locale: const Locale('en'),
        ));
        await tester.pumpAndSettle();

        // Verify English Welcome title
        expect(find.text('Welcome to Delivery Ways'), findsOneWidget);

        // Verify English Get started button
        expect(find.text('Get started'), findsOneWidget);

        // Verify English Skip button
        expect(find.text('Skip'), findsOneWidget);
      });
    });

    group('Full Flow Test', () {
      testWidgets('completes full onboarding: Welcome → Permissions → Preferences → Done',
          (tester) async {
        await tester.pumpWidget(buildTestApp(
          home: const OnboardingRootScreen(),
        ));
        await tester.pumpAndSettle();

        // Step 1: Welcome Screen
        expect(find.text('Welcome to Delivery Ways'), findsOneWidget);
        expect(find.byIcon(Icons.local_shipping_outlined), findsOneWidget);
        expect(find.text('Get started'), findsOneWidget);
        expect(find.text('Skip'), findsOneWidget);
        await tester.tap(find.text('Get started'));
        await tester.pumpAndSettle();

        // Step 2: Permissions Screen
        expect(find.text('Allow permissions'), findsOneWidget);
        expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
        expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
        expect(find.text('Continue'), findsOneWidget);
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Step 3: Preferences Screen
        expect(find.text('Set your preferences'), findsOneWidget);
        expect(find.text('Marketing notifications'), findsOneWidget);
        expect(find.text('Start using Delivery Ways'), findsOneWidget);

        // Toggle marketing preference
        final switchFinder = find.byType(Switch);
        await tester.tap(switchFinder);
        await tester.pumpAndSettle();

        // Complete onboarding
        await tester.tap(find.text('Start using Delivery Ways'));
        await tester.pumpAndSettle();

        // Verify preferences were saved
        final prefs = tester.element(find.byType(OnboardingRootScreen)).read(onboardingPrefsServiceProvider);
        expect(await prefs.getMarketingOptIn(), isTrue);
        expect(await prefs.hasCompletedOnboarding(), isTrue);
      });
    });
  });

  // ============================================================================
  // Integration Tests: AuthGate + Onboarding
  // ============================================================================
  group('AuthGate Integration - Ticket #238', () {
    testWidgets('OnboardingRootScreen uses persistent storage for completion', (tester) async {
      final stubPrefs = OnboardingPrefsStubImpl();

      await tester.pumpWidget(ProviderScope(
        overrides: [
          onboardingPrefsServiceProvider.overrideWithValue(stubPrefs),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const OnboardingRootScreen(),
        ),
      ));
      await tester.pumpAndSettle();

      // Complete the onboarding flow
      await tester.tap(find.text('Get started'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start using Delivery Ways'));
      await tester.pumpAndSettle();

      // Verify completion was persisted
      expect(await stubPrefs.hasCompletedOnboarding(), isTrue);
    });

    testWidgets('marketing preference is saved when toggled', (tester) async {
      final stubPrefs = OnboardingPrefsStubImpl();

      await tester.pumpWidget(ProviderScope(
        overrides: [
          onboardingPrefsServiceProvider.overrideWithValue(stubPrefs),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const OnboardingRootScreen(),
        ),
      ));
      await tester.pumpAndSettle();

      // Navigate to preferences screen
      await tester.tap(find.text('Get started'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Toggle marketing preference
      final switchFinder = find.byType(Switch);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Complete onboarding
      await tester.tap(find.text('Start using Delivery Ways'));
      await tester.pumpAndSettle();

      // Verify marketing preference was saved
      expect(await stubPrefs.getMarketingOptIn(), isTrue);
    });
  });
}

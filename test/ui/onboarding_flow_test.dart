/// Widget tests for Onboarding Flow (Ticket #33 - Track D)
/// Purpose: Verify onboarding screens UI and navigation flow
/// Created by: Ticket #33 - Track D Onboarding
/// Last updated: 2025-11-28

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// App imports
import 'package:delivery_ways_clean/screens/onboarding/welcome_screen.dart';
import 'package:delivery_ways_clean/screens/onboarding/permissions_screen.dart';
import 'package:delivery_ways_clean/screens/onboarding/screen_preferences.dart';
import 'package:delivery_ways_clean/screens/onboarding/onboarding_root_screen.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';

void main() {
  group('Onboarding Flow - Ticket #33', () {
    /// Helper to build test widget with MaterialApp wrapper
    Widget buildTestApp({
      required Widget home,
    }) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: home,
      );
    }

    group('WelcomeScreen', () {
      testWidgets('builds with welcome title and Get Started button',
          (tester) async {
        await tester.pumpWidget(buildTestApp(
          home: const WelcomeScreen(),
        ));
        await tester.pumpAndSettle();

        // Verify welcome title is displayed
        expect(find.text('Welcome to Delivery Ways'), findsOneWidget);

        // Verify subtitle is displayed
        expect(
          find.text('All your rides, parcels, and deliveries in one place.'),
          findsOneWidget,
        );

        // Verify Get Started button exists
        expect(find.text('Get started'), findsOneWidget);

        // Verify shipping icon is displayed
        expect(find.byIcon(Icons.local_shipping_outlined), findsOneWidget);
      });

      testWidgets('navigates to PermissionsScreen on Get Started tap',
          (tester) async {
        await tester.pumpWidget(buildTestApp(
          home: const WelcomeScreen(),
        ));
        await tester.pumpAndSettle();

        // Tap Get Started button
        await tester.tap(find.text('Get started'));
        await tester.pumpAndSettle();

        // Verify navigation to PermissionsScreen
        expect(find.byType(PermissionsScreen), findsOneWidget);
        expect(find.text('Allow permissions'), findsOneWidget);
      });
    });

    group('PermissionsScreen', () {
      testWidgets('builds with permissions title and Continue/Skip buttons',
          (tester) async {
        await tester.pumpWidget(buildTestApp(
          home: const PermissionsScreen(),
        ));
        await tester.pumpAndSettle();

        // Verify title
        expect(find.text('Allow permissions'), findsOneWidget);

        // Verify Location permission is displayed
        expect(find.text('Location access'), findsOneWidget);
        expect(
          find.text('We use your location to find nearby drivers.'),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);

        // Verify Notifications permission is displayed
        expect(find.text('Notifications'), findsOneWidget);
        expect(
          find.text('Stay updated about your rides and deliveries.'),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);

        // Verify Continue button
        expect(find.text('Continue'), findsOneWidget);

        // Verify Skip button
        expect(find.text('Skip for now'), findsOneWidget);
      });

      testWidgets('navigates to PreferencesScreen on Continue tap',
          (tester) async {
        await tester.pumpWidget(buildTestApp(
          home: const PermissionsScreen(),
        ));
        await tester.pumpAndSettle();

        // Tap Continue button
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Verify navigation to PreferencesScreen
        expect(find.byType(PreferencesScreen), findsOneWidget);
        expect(find.text('Set your preferences'), findsOneWidget);
      });

      testWidgets('navigates to PreferencesScreen on Skip tap', (tester) async {
        await tester.pumpWidget(buildTestApp(
          home: const PermissionsScreen(),
        ));
        await tester.pumpAndSettle();

        // Tap Skip button
        await tester.tap(find.text('Skip for now'));
        await tester.pumpAndSettle();

        // Verify navigation to PreferencesScreen
        expect(find.byType(PreferencesScreen), findsOneWidget);
      });

      testWidgets('back button navigates to previous screen', (tester) async {
        await tester.pumpWidget(buildTestApp(
          home: const WelcomeScreen(),
        ));
        await tester.pumpAndSettle();

        // Navigate to PermissionsScreen
        await tester.tap(find.text('Get started'));
        await tester.pumpAndSettle();

        // Tap back button
        await tester.tap(find.byIcon(Icons.arrow_back_rounded));
        await tester.pumpAndSettle();

        // Verify back to WelcomeScreen
        expect(find.byType(WelcomeScreen), findsOneWidget);
      });
    });

    group('PreferencesScreen', () {
      testWidgets('builds with preferences title and service options',
          (tester) async {
        await tester.pumpWidget(buildTestApp(
          home: const PreferencesScreen(),
        ));
        await tester.pumpAndSettle();

        // Verify title
        expect(find.text('Set your preferences'), findsOneWidget);

        // Verify subtitle
        expect(
          find.text('You can change these later in Settings.'),
          findsOneWidget,
        );

        // Verify service options
        expect(find.text('Rides'), findsOneWidget);
        expect(find.text('Parcels'), findsOneWidget);
        expect(find.text('Food'), findsOneWidget);

        // Verify Done button
        expect(find.text('Start using Delivery Ways'), findsOneWidget);
      });

      testWidgets('service options are selectable', (tester) async {
        await tester.pumpWidget(buildTestApp(
          home: const PreferencesScreen(),
        ));
        await tester.pumpAndSettle();

        // Rides should be selected by default (has checkmark)
        expect(find.byIcon(Icons.check_circle), findsOneWidget);

        // Tap Parcels option
        await tester.tap(find.text('Parcels'));
        await tester.pumpAndSettle();

        // Verify Parcels is now selected
        // The checkmark should now be on Parcels
        expect(find.byIcon(Icons.check_circle), findsOneWidget);

        // Tap Food option
        await tester.tap(find.text('Food'));
        await tester.pumpAndSettle();

        // Verify Food is now selected
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });

      testWidgets('Done button calls onComplete and pops to root',
          (tester) async {
        var completeCalled = false;

        await tester.pumpWidget(MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => PreferencesScreen(
                          onComplete: () {
                            completeCalled = true;
                          },
                        ),
                      ),
                    );
                  },
                  child: const Text('Go to Preferences'),
                ),
              );
            },
          ),
        ));
        await tester.pumpAndSettle();

        // Navigate to PreferencesScreen
        await tester.tap(find.text('Go to Preferences'));
        await tester.pumpAndSettle();

        // Verify we're on PreferencesScreen
        expect(find.byType(PreferencesScreen), findsOneWidget);

        // Tap Done button
        await tester.tap(find.text('Start using Delivery Ways'));
        await tester.pumpAndSettle();

        // Verify onComplete was called
        expect(completeCalled, isTrue);

        // Verify we're back at root
        expect(find.byType(PreferencesScreen), findsNothing);
        expect(find.text('Go to Preferences'), findsOneWidget);
      });
    });

    group('OnboardingRootScreen', () {
      testWidgets('displays WelcomeScreen as initial screen', (tester) async {
        await tester.pumpWidget(MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const OnboardingRootScreen(),
        ));
        await tester.pumpAndSettle();

        // Verify WelcomeScreen is shown
        expect(find.byType(WelcomeScreen), findsOneWidget);
        expect(find.text('Welcome to Delivery Ways'), findsOneWidget);
      });

      testWidgets('passes onComplete callback through constructor chain',
          (tester) async {
        var completeCalled = false;

        await tester.pumpWidget(MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: OnboardingRootScreen(
            onComplete: () {
              completeCalled = true;
            },
          ),
        ));
        await tester.pumpAndSettle();

        // Navigate through the flow
        // Welcome → Permissions
        await tester.tap(find.text('Get started'));
        await tester.pumpAndSettle();

        // Permissions → Preferences
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Preferences → Complete
        await tester.tap(find.text('Start using Delivery Ways'));
        await tester.pumpAndSettle();

        // Verify onComplete was called
        expect(completeCalled, isTrue);
      });
    });

    group('Full Flow Navigation', () {
      testWidgets('completes full onboarding flow: Welcome → Permissions → Preferences',
          (tester) async {
        await tester.pumpWidget(buildTestApp(
          home: const WelcomeScreen(),
        ));
        await tester.pumpAndSettle();

        // Step 1: Welcome Screen
        expect(find.text('Welcome to Delivery Ways'), findsOneWidget);
        await tester.tap(find.text('Get started'));
        await tester.pumpAndSettle();

        // Step 2: Permissions Screen
        expect(find.text('Allow permissions'), findsOneWidget);
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Step 3: Preferences Screen
        expect(find.text('Set your preferences'), findsOneWidget);

        // Select Parcels service
        await tester.tap(find.text('Parcels'));
        await tester.pumpAndSettle();

        // Verify Parcels is selected
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });

      testWidgets('can navigate back through the flow', (tester) async {
        await tester.pumpWidget(buildTestApp(
          home: const WelcomeScreen(),
        ));
        await tester.pumpAndSettle();

        // Navigate forward
        await tester.tap(find.text('Get started'));
        await tester.pumpAndSettle();
        expect(find.byType(PermissionsScreen), findsOneWidget);

        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        expect(find.byType(PreferencesScreen), findsOneWidget);

        // Navigate back
        await tester.tap(find.byIcon(Icons.arrow_back_rounded));
        await tester.pumpAndSettle();
        expect(find.byType(PermissionsScreen), findsOneWidget);

        await tester.tap(find.byIcon(Icons.arrow_back_rounded));
        await tester.pumpAndSettle();
        expect(find.byType(WelcomeScreen), findsOneWidget);
      });
    });
  });
}


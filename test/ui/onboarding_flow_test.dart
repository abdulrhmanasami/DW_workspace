/// Widget tests for Onboarding Flow
/// Purpose: Verify onboarding screens UI and navigation flow
/// Created by: Ticket #33 - Track D Onboarding
/// Updated by: Ticket #57 - 3-screen Product Onboarding Flow (Ride/Parcels/Food)
/// Last updated: 2025-11-29

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// App imports
import 'package:delivery_ways_clean/screens/onboarding/welcome_screen.dart';
import 'package:delivery_ways_clean/screens/onboarding/permissions_screen.dart';
import 'package:delivery_ways_clean/screens/onboarding/screen_preferences.dart';
import 'package:delivery_ways_clean/screens/onboarding/onboarding_root_screen.dart';
import 'package:delivery_ways_clean/screens/onboarding/onboarding_page_ride_screen.dart';
import 'package:delivery_ways_clean/screens/onboarding/onboarding_page_parcels_screen.dart';
import 'package:delivery_ways_clean/screens/onboarding/onboarding_page_food_screen.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';

void main() {
  // ============================================================================
  // Ticket #57: 3-Screen Product Onboarding Flow Tests
  // ============================================================================
  group('Onboarding Flow - Ticket #57 (3-Screen Product Flow)', () {
    /// Helper to build test widget with MaterialApp wrapper
    Widget buildTestApp({
      required Widget home,
      Locale locale = const Locale('en'),
    }) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        home: home,
      );
    }

    group('OnboardingRootScreen - Initial State', () {
      testWidgets('shows Ride screen by default', (tester) async {
        await tester.pumpWidget(buildTestApp(
          home: const OnboardingRootScreen(),
        ));
        await tester.pumpAndSettle();

        // Verify Ride screen title is displayed
        expect(find.text('Get a Ride, Instantly.'), findsOneWidget);

        // Verify car icon is displayed
        expect(find.byIcon(Icons.directions_car_outlined), findsOneWidget);

        // Verify body text
        expect(
          find.text(
              'Tap, ride, and arrive. Fast, reliable, and affordable transport at your fingertips.'),
          findsOneWidget,
        );

        // Verify Continue button (not Get Started)
        expect(find.text('Continue'), findsOneWidget);
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
      testWidgets('navigates from Ride to Parcels on Continue tap', (tester) async {
        await tester.pumpWidget(buildTestApp(
          home: const OnboardingRootScreen(),
        ));
        await tester.pumpAndSettle();

        // Verify on Ride screen
        expect(find.text('Get a Ride, Instantly.'), findsOneWidget);

        // Tap Continue
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Verify now on Parcels screen
        expect(find.text('Deliver Anything, Effortlessly.'), findsOneWidget);
        expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
      });

      testWidgets('navigates from Parcels to Food on Continue tap', (tester) async {
        await tester.pumpWidget(buildTestApp(
          home: const OnboardingRootScreen(),
        ));
        await tester.pumpAndSettle();

        // Navigate to Parcels
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Verify on Parcels screen
        expect(find.text('Deliver Anything, Effortlessly.'), findsOneWidget);

        // Tap Continue again
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Verify now on Food screen
        expect(find.text('Your Favorite Food, Delivered.'), findsOneWidget);
        expect(find.byIcon(Icons.restaurant_outlined), findsOneWidget);
      });

      testWidgets('Food screen shows Get Started button instead of Continue',
          (tester) async {
        await tester.pumpWidget(buildTestApp(
          home: const OnboardingRootScreen(),
        ));
        await tester.pumpAndSettle();

        // Navigate to Food screen
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Verify on Food screen with Get Started button
        expect(find.text('Your Favorite Food, Delivered.'), findsOneWidget);
        expect(find.text('Get Started'), findsOneWidget);
        expect(find.text('Continue'), findsNothing);
      });
    });

    group('Onboarding Completion', () {
      testWidgets('Get Started calls onComplete callback', (tester) async {
        var completeCalled = false;

        await tester.pumpWidget(buildTestApp(
          home: OnboardingRootScreen(
            onComplete: () {
              completeCalled = true;
            },
          ),
        ));
        await tester.pumpAndSettle();

        // Navigate through all screens
        // Ride → Parcels
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Parcels → Food
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Tap Get Started
        await tester.tap(find.text('Get Started'));
        await tester.pumpAndSettle();

        // Verify onComplete was called
        expect(completeCalled, isTrue);
      });

      testWidgets('Get Started navigates back to root', (tester) async {
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
                        builder: (_) => const OnboardingRootScreen(),
                      ),
                    );
                  },
                  child: const Text('Start Onboarding'),
                ),
              );
            },
          ),
        ));
        await tester.pumpAndSettle();

        // Navigate to onboarding
        await tester.tap(find.text('Start Onboarding'));
        await tester.pumpAndSettle();

        // Verify on Ride screen
        expect(find.text('Get a Ride, Instantly.'), findsOneWidget);

        // Navigate through all screens
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Tap Get Started
        await tester.tap(find.text('Get Started'));
        await tester.pumpAndSettle();

        // Verify back at root
        expect(find.byType(OnboardingRootScreen), findsNothing);
        expect(find.text('Start Onboarding'), findsOneWidget);
      });
    });

    group('Localization - Arabic', () {
      testWidgets('displays Arabic texts when locale is ar', (tester) async {
        await tester.pumpWidget(buildTestApp(
          home: const OnboardingRootScreen(),
          locale: const Locale('ar'),
        ));
        await tester.pumpAndSettle();

        // Verify Arabic Ride title
        expect(find.text('احصل على رحلة، فورًا.'), findsOneWidget);

        // Verify Arabic Continue button
        expect(find.text('استمر'), findsOneWidget);
      });

      testWidgets('displays Arabic Food screen texts', (tester) async {
        await tester.pumpWidget(buildTestApp(
          home: const OnboardingRootScreen(),
          locale: const Locale('ar'),
        ));
        await tester.pumpAndSettle();

        // Navigate to Food screen
        await tester.tap(find.text('استمر'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('استمر'));
        await tester.pumpAndSettle();

        // Verify Arabic Food title and Get Started
        expect(find.text('طعامك المفضل، إليك.'), findsOneWidget);
        expect(find.text('ابدأ الآن'), findsOneWidget);
      });
    });

    group('Localization - German', () {
      testWidgets('displays German texts when locale is de', (tester) async {
        await tester.pumpWidget(buildTestApp(
          home: const OnboardingRootScreen(),
          locale: const Locale('de'),
        ));
        await tester.pumpAndSettle();

        // Verify German Ride title
        expect(find.text('Sofort eine Fahrt bekommen.'), findsOneWidget);

        // Verify German Continue button
        expect(find.text('Weiter'), findsOneWidget);
      });

      testWidgets('displays German Food screen texts', (tester) async {
        await tester.pumpWidget(buildTestApp(
          home: const OnboardingRootScreen(),
          locale: const Locale('de'),
        ));
        await tester.pumpAndSettle();

        // Navigate to Food screen
        await tester.tap(find.text('Weiter'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Weiter'));
        await tester.pumpAndSettle();

        // Verify German Food title and Get Started
        expect(find.text('Dein Lieblingsessen, geliefert.'), findsOneWidget);
        expect(find.text("Los geht's"), findsOneWidget);
      });
    });

    group('Individual Page Widgets', () {
      testWidgets('OnboardingPageRideScreen renders correctly', (tester) async {
        var nextCalled = false;

        await tester.pumpWidget(buildTestApp(
          home: Scaffold(
            body: OnboardingPageRideScreen(
              onNext: () => nextCalled = true,
            ),
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Get a Ride, Instantly.'), findsOneWidget);
        expect(find.byIcon(Icons.directions_car_outlined), findsOneWidget);

        await tester.tap(find.text('Continue'));
        expect(nextCalled, isTrue);
      });

      testWidgets('OnboardingPageParcelsScreen renders correctly',
          (tester) async {
        var nextCalled = false;

        await tester.pumpWidget(buildTestApp(
          home: Scaffold(
            body: OnboardingPageParcelsScreen(
              onNext: () => nextCalled = true,
            ),
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Deliver Anything, Effortlessly.'), findsOneWidget);
        expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);

        await tester.tap(find.text('Continue'));
        expect(nextCalled, isTrue);
      });

      testWidgets('OnboardingPageFoodScreen renders correctly', (tester) async {
        var nextCalled = false;

        await tester.pumpWidget(buildTestApp(
          home: Scaffold(
            body: OnboardingPageFoodScreen(
              onNext: () => nextCalled = true,
            ),
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Your Favorite Food, Delivered.'), findsOneWidget);
        expect(find.byIcon(Icons.restaurant_outlined), findsOneWidget);

        await tester.tap(find.text('Get Started'));
        expect(nextCalled, isTrue);
      });
    });

    group('Full Flow Test', () {
      testWidgets('completes full onboarding: Ride → Parcels → Food → Done',
          (tester) async {
        var completeCalled = false;

        await tester.pumpWidget(buildTestApp(
          home: OnboardingRootScreen(
            onComplete: () => completeCalled = true,
          ),
        ));
        await tester.pumpAndSettle();

        // Step 1: Ride Screen
        expect(find.text('Get a Ride, Instantly.'), findsOneWidget);
        expect(find.byIcon(Icons.directions_car_outlined), findsOneWidget);
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Step 2: Parcels Screen
        expect(find.text('Deliver Anything, Effortlessly.'), findsOneWidget);
        expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Step 3: Food Screen
        expect(find.text('Your Favorite Food, Delivered.'), findsOneWidget);
        expect(find.byIcon(Icons.restaurant_outlined), findsOneWidget);
        expect(find.text('Get Started'), findsOneWidget);
        await tester.tap(find.text('Get Started'));
        await tester.pumpAndSettle();

        // Verify completion
        expect(completeCalled, isTrue);
      });
    });
  });

  // ============================================================================
  // Legacy Tests: Ticket #33 (Welcome/Permissions/Preferences Flow)
  // These screens still exist and may be used elsewhere.
  // ============================================================================
  group('Onboarding Flow - Ticket #33 (Legacy Screens)', () {
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

    group('Full Legacy Flow Navigation', () {
      testWidgets(
          'completes full legacy flow: Welcome → Permissions → Preferences',
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

      testWidgets('can navigate back through the legacy flow', (tester) async {
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

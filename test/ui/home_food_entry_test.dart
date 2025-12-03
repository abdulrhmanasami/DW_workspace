/// Home Hub to Food Entry Navigation Test - Track C Ticket #48
/// Purpose: Test navigation from Home Hub Food ServiceCard based on Feature Flag
/// Created by: Track C - Ticket #48
/// Updated by: Track C - Ticket #52 (Added enableFoodMvp == true tests)
/// Updated by: Track C - Ticket #56 (Updated texts for Production-Ready UX)
/// Last updated: 2025-11-29

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:delivery_ways_clean/config/feature_flags.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/screens/food/food_coming_soon_screen.dart';
import 'package:delivery_ways_clean/screens/food/food_restaurants_list_screen.dart';
import '../support/design_system_harness.dart';

void main() {
  setUpAll(() {
    ensureDesignSystemStubsForTests();
  });

  // Track C - Ticket #56: Reset feature flags after each test
  setUp(() {
    FeatureFlags.resetForTests();
  });

  tearDown(() {
    FeatureFlags.resetForTests();
  });

  group('Home Hub Food ServiceCard Navigation Tests', () {
    testWidgets('FoodComingSoonScreen is displayed when Food feature is disabled',
        (WidgetTester tester) async {
      // Track C - Ticket #56: Use injectable FeatureFlags
      FeatureFlags.overrideForTests(const FeatureFlags(
        enableFoodMvpValue: false,
        enableParcelsMvpValue: true,
      ));

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
                      leading: const Icon(Icons.fastfood_outlined),
                      title: const Text('Food'),
                      subtitle: const Text('Your favorite food, delivered.'),
                      onTap: () {
                        // Uses injectable FeatureFlags
                        if (!FeatureFlags.enableFoodMvp) {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const FoodComingSoonScreen(),
                            ),
                          );
                          return;
                        }
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const FoodRestaurantsListScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Home-like card is displayed
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Your favorite food, delivered.'), findsOneWidget);

      // Tap the card
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      // Verify navigation to FoodComingSoonScreen
      // Track C - Ticket #56: Updated texts (uses homeFoodComingSoonLabel/Message)
      expect(find.text('Coming soon'), findsOneWidget);
      expect(
        find.text('Food delivery is not available yet in your area.'),
        findsOneWidget,
      );
    });

    testWidgets('FoodComingSoonScreen allows navigation back via AppBar',
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
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const FoodComingSoonScreen(),
                      ),
                    ),
                    child: const Text('Go to Food'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to FoodComingSoonScreen
      await tester.tap(find.text('Go to Food'));
      await tester.pumpAndSettle();

      // Verify we're on FoodComingSoonScreen
      // Track C - Ticket #56: Updated text
      expect(find.text('Coming soon'), findsOneWidget);

      // Track C - Ticket #56: Use AppBar back button (no CTA per requirements)
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Verify we're back
      expect(find.text('Go to Food'), findsOneWidget);
    });

    testWidgets('FoodComingSoonScreen displays correct AppBar title',
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
            home: const FoodComingSoonScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check AppBar title
      expect(find.text('Food delivery'), findsOneWidget);
    });

    testWidgets('FoodComingSoonScreen displays icon correctly',
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
            home: const FoodComingSoonScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check for food icon
      expect(find.byIcon(Icons.fastfood_outlined), findsOneWidget);
    });

    testWidgets('FoodComingSoonScreen displays Arabic content when locale is ar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('ar'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
            ],
            home: const FoodComingSoonScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check Arabic texts (Track C - Ticket #56: Updated texts)
      expect(find.text('توصيل الطعام'), findsOneWidget); // AppBar
      expect(find.text('قريباً'), findsOneWidget); // homeFoodComingSoonLabel
      expect(
        find.text('خدمة توصيل الطعام غير متاحة بعد في منطقتك.'),
        findsOneWidget,
      ); // homeFoodComingSoonMessage
    });

    testWidgets('FoodComingSoonScreen displays German content when locale is de',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('de'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('de'),
            ],
            home: const FoodComingSoonScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check German texts (Track C - Ticket #56: Updated texts)
      expect(find.text('Essenslieferung'), findsOneWidget); // AppBar
      expect(find.text('Kommt bald'), findsOneWidget); // homeFoodComingSoonLabel
      expect(
        find.text('Essenslieferung ist in deiner Region noch nicht verfügbar.'),
        findsOneWidget,
      ); // homeFoodComingSoonMessage
    });

    // Track C - Ticket #52: Tests for enableFoodMvp == true
    testWidgets('FoodRestaurantsListScreen is displayed when Food feature is enabled',
        (WidgetTester tester) async {
      // Track C - Ticket #56: Use injectable FeatureFlags
      FeatureFlags.overrideForTests(const FeatureFlags(
        enableFoodMvpValue: true,
        enableParcelsMvpValue: true,
      ));

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
                      leading: const Icon(Icons.fastfood_outlined),
                      title: const Text('Food'),
                      subtitle: const Text('Your favorite food, delivered.'),
                      onTap: () {
                        // Uses injectable FeatureFlags
                        if (!FeatureFlags.enableFoodMvp) {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const FoodComingSoonScreen(),
                            ),
                          );
                          return;
                        }
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const FoodRestaurantsListScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Home-like card is displayed
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Your favorite food, delivered.'), findsOneWidget);

      // Tap the card
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      // Verify navigation to FoodRestaurantsListScreen
      expect(find.text('Food delivery'), findsOneWidget);
    });

    testWidgets('FoodRestaurantsListScreen displays restaurant list when enabled',
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
            home: const FoodRestaurantsListScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check AppBar title (from foodRestaurantsAppBarTitle)
      expect(find.text('Food delivery'), findsOneWidget);

      // Check search field exists
      expect(find.byType(TextField), findsOneWidget);

      // Check filter chips exist (use ChoiceChip to avoid confusion with restaurant cuisine text)
      expect(find.widgetWithText(ChoiceChip, 'All'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Burgers'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Italian'), findsOneWidget);
    });
  });
}


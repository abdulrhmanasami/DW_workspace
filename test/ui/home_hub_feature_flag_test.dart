/// Home Hub Feature Flag Tests - Track C Ticket #55, #56
/// Purpose: Test Home Hub Food ServiceCard behavior based on Feature Flag
/// Created by: Track C - Ticket #55
/// Updated by: Track C - Ticket #56 (Injectable FeatureFlags for testing)
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

  // Reset feature flags after each test to prevent state leakage
  setUp(() {
    FeatureFlags.resetForTests();
  });

  tearDown(() {
    FeatureFlags.resetForTests();
  });

  // ============================================================================
  // Home Hub Feature Flag Tests - Track C - Ticket #55, #56
  // ============================================================================
  // Ticket #56: FeatureFlags is now injectable via overrideForTests()
  // This allows proper testing of both enableFoodMvp = true and false scenarios.
  //
  // When enableFoodMvp == false (default):
  // - Food ServiceCard onTap navigates to FoodComingSoonScreen
  // - User sees "Coming soon" messaging
  //
  // When enableFoodMvp == true:
  // - Food ServiceCard onTap navigates to FoodRestaurantsListScreen
  // - User can access full Food flow
  // ============================================================================

  group('Home Hub Food Feature Flag - enableFoodMvp = false (default)', () {
    testWidgets(
        'Food card navigates to FoodComingSoonScreen when Food MVP is disabled',
        (WidgetTester tester) async {
      // Arrange: Explicitly set feature flag to false
      FeatureFlags.overrideForTests(const FeatureFlags(enableFoodMvpValue: false));

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
                        // Uses the injectable FeatureFlags
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

      // Verify Food card is displayed
      expect(find.text('Food'), findsOneWidget);

      // Act: Tap the card
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      // Assert: Should navigate to FoodComingSoonScreen
      expect(find.byType(FoodComingSoonScreen), findsOneWidget);
      // Updated text per Ticket #56 (uses homeFoodComingSoonLabel)
      expect(find.text('Coming soon'), findsOneWidget);
    });

    testWidgets('FoodComingSoonScreen shows correct content (English)',
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

      // Verify content (updated per Ticket #56)
      expect(find.text('Food delivery'), findsOneWidget); // AppBar title
      expect(find.text('Coming soon'), findsOneWidget); // homeFoodComingSoonLabel
      expect(
        find.text('Food delivery is not available yet in your area.'),
        findsOneWidget,
      ); // homeFoodComingSoonMessage
      expect(find.byIcon(Icons.fastfood_outlined), findsOneWidget);
      // Note: No CTA button per Ticket #56 requirements
      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('FoodComingSoonScreen AppBar back button works',
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
      expect(find.text('Coming soon'), findsOneWidget);

      // Tap the AppBar back button (per Ticket #56: no CTA, use AppBar back)
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Verify we're back
      expect(find.text('Go to Food'), findsOneWidget);
    });
  });

  group('Home Hub Food Feature Flag - enableFoodMvp = true', () {
    testWidgets(
        'Food card navigates to FoodRestaurantsListScreen when Food MVP is enabled',
        (WidgetTester tester) async {
      // Arrange: Enable Food MVP via injectable FeatureFlags
      FeatureFlags.overrideForTests(const FeatureFlags(enableFoodMvpValue: true));

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
                        // Uses the injectable FeatureFlags
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

      // Verify Food card is displayed
      expect(find.text('Food'), findsOneWidget);

      // Act: Tap the card
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      // Assert: Should navigate to FoodRestaurantsListScreen
      expect(find.byType(FoodRestaurantsListScreen), findsOneWidget);
      expect(find.text('Food delivery'), findsOneWidget);
    });

    testWidgets('FoodRestaurantsListScreen shows restaurant list',
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

      // Verify restaurant list screen content
      expect(find.text('Food delivery'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget); // Search field
      expect(find.widgetWithText(ChoiceChip, 'All'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Burgers'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Italian'), findsOneWidget);
    });
  });

  group('Home Hub Food Feature Flag - L10n Tests', () {
    testWidgets('FoodComingSoonScreen displays Arabic content',
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

      // Verify Arabic content (updated per Ticket #56)
      expect(find.text('توصيل الطعام'), findsOneWidget); // AppBar title
      expect(find.text('قريباً'), findsOneWidget); // homeFoodComingSoonLabel
      expect(
        find.text('خدمة توصيل الطعام غير متاحة بعد في منطقتك.'),
        findsOneWidget,
      ); // homeFoodComingSoonMessage
    });

    testWidgets('FoodComingSoonScreen displays German content',
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

      // Verify German content (updated per Ticket #56)
      expect(find.text('Essenslieferung'), findsOneWidget); // AppBar title
      expect(find.text('Kommt bald'), findsOneWidget); // homeFoodComingSoonLabel
      expect(
        find.text('Essenslieferung ist in deiner Region noch nicht verfügbar.'),
        findsOneWidget,
      ); // homeFoodComingSoonMessage
    });
  });

  group('FeatureFlags Injectable API Tests (Ticket #56)', () {
    testWidgets('FeatureFlags.overrideForTests() changes enableFoodMvp value',
        (WidgetTester tester) async {
      // Default value is false (from environment)
      FeatureFlags.resetForTests();
      expect(FeatureFlags.enableFoodMvp, isFalse);

      // Override to true
      FeatureFlags.overrideForTests(const FeatureFlags(enableFoodMvpValue: true));
      expect(FeatureFlags.enableFoodMvp, isTrue);

      // Override to false
      FeatureFlags.overrideForTests(const FeatureFlags(enableFoodMvpValue: false));
      expect(FeatureFlags.enableFoodMvp, isFalse);

      // Reset restores default
      FeatureFlags.resetForTests();
      expect(FeatureFlags.enableFoodMvp, isFalse);
    });

    testWidgets('FeatureFlags.current provides access to current flags',
        (WidgetTester tester) async {
      // Set up custom flags
      FeatureFlags.overrideForTests(const FeatureFlags(enableFoodMvpValue: true));
      
      // Access via current
      expect(FeatureFlags.current.enableFoodMvpValue, isTrue);
      
      // Static getter should match
      expect(FeatureFlags.enableFoodMvp, isTrue);
    });
  });
}

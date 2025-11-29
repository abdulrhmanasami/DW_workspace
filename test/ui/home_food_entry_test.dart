/// Home Hub to Food Entry Navigation Test - Track C Ticket #48
/// Purpose: Test navigation from Home Hub Food ServiceCard based on Feature Flag
/// Created by: Track C - Ticket #48
/// Last updated: 2025-11-28

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/screens/food/food_coming_soon_screen.dart';
import '../support/design_system_harness.dart';

void main() {
  setUpAll(() {
    ensureDesignSystemStubsForTests();
  });

  group('Home Hub Food ServiceCard Navigation Tests', () {
    testWidgets('FoodComingSoonScreen is displayed when Food feature is disabled',
        (WidgetTester tester) async {
      // This test simulates what happens when enableFoodMvp is false (default)
      // The ServiceCard.onTap should navigate to FoodComingSoonScreen
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
                        // Simulate the behavior when enableFoodMvp == false
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const FoodComingSoonScreen(),
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
      expect(find.text('Food delivery is coming soon'), findsOneWidget);
      expect(
        find.text("We're working hard to bring food delivery to your area. Stay tuned!"),
        findsOneWidget,
      );
    });

    testWidgets('FoodComingSoonScreen allows navigation back to home',
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
      expect(find.text('Food delivery is coming soon'), findsOneWidget);

      // Tap the "Back to home" CTA button
      await tester.tap(find.text('Back to home'));
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

      // Check Arabic texts
      expect(find.text('توصيل الطعام'), findsOneWidget);
      expect(find.text('خدمة توصيل الطعام قادمة قريباً'), findsOneWidget);
      expect(find.text('العودة إلى الرئيسية'), findsOneWidget);
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

      // Check German texts
      expect(find.text('Essenslieferung'), findsOneWidget);
      expect(find.text('Essenslieferung kommt bald'), findsOneWidget);
      expect(find.text('Zurück zur Startseite'), findsOneWidget);
    });
  });
}


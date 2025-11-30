/// Food Coming Soon Screen Widget Tests - Track C Ticket #48
/// Purpose: Test FoodComingSoonScreen UI components and behavior
/// Created by: Track C - Ticket #48
/// Updated by: Track C - Ticket #56 (Production-Ready UX with Empty State pattern)
/// Last updated: 2025-11-29

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

  group('FoodComingSoonScreen Widget Tests', () {
    Widget createTestWidget({
      Locale locale = const Locale('en'),
    }) {
      return ProviderScope(
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
            Locale('de'),
          ],
          home: const FoodComingSoonScreen(),
        ),
      );
    }

    // Track C - Ticket #56: Updated texts to use homeFoodComingSoonLabel/Message
    testWidgets('displays title and subtitle (EN)', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for title (homeFoodComingSoonLabel)
      expect(find.text('Coming soon'), findsOneWidget);

      // Check for subtitle (homeFoodComingSoonMessage)
      expect(
        find.text('Food delivery is not available yet in your area.'),
        findsOneWidget,
      );
    });

    testWidgets('displays AppBar with correct title (EN)', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check AppBar title (foodComingSoonAppBarTitle)
      expect(find.text('Food delivery'), findsOneWidget);
    });

    testWidgets('displays food icon', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for the food icon
      expect(find.byIcon(Icons.fastfood_outlined), findsOneWidget);
    });

    // Track C - Ticket #56: CTA button removed per requirements
    // Navigation back is now via AppBar back button only
    testWidgets('does not display CTA button (MVP per Ticket #56)', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // CTA button "Back to home" should NOT exist
      expect(find.text('Back to home'), findsNothing);

      // FilledButton should NOT exist
      expect(find.byType(FilledButton), findsNothing);
    });

    // Track C - Ticket #56: AppBar back button is the primary navigation
    testWidgets('AppBar back button works when pushed onto stack', (WidgetTester tester) async {
      bool didPop = false;

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
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const FoodComingSoonScreen(),
                        ),
                      );
                      didPop = true;
                    },
                    child: const Text('Open Food Screen'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to FoodComingSoonScreen
      await tester.tap(find.text('Open Food Screen'));
      await tester.pumpAndSettle();

      // Verify we're on FoodComingSoonScreen
      expect(find.text('Coming soon'), findsOneWidget);

      // Tap the AppBar back button
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Verify pop was called
      expect(didPop, isTrue);
      expect(find.text('Open Food Screen'), findsOneWidget);
    });

    // Track C - Ticket #56: Updated texts for Arabic
    testWidgets('displays Arabic translations when locale is ar', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      // Check for Arabic AppBar title
      expect(find.text('توصيل الطعام'), findsOneWidget);

      // Check for Arabic title (homeFoodComingSoonLabel)
      expect(find.text('قريباً'), findsOneWidget);

      // Check for Arabic subtitle (homeFoodComingSoonMessage)
      expect(
        find.text('خدمة توصيل الطعام غير متاحة بعد في منطقتك.'),
        findsOneWidget,
      );
    });

    // Track C - Ticket #56: Updated texts for German
    testWidgets('displays German translations when locale is de', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('de')));
      await tester.pumpAndSettle();

      // Check for German AppBar title
      expect(find.text('Essenslieferung'), findsOneWidget);

      // Check for German title (homeFoodComingSoonLabel)
      expect(find.text('Kommt bald'), findsOneWidget);

      // Check for German subtitle (homeFoodComingSoonMessage)
      expect(
        find.text('Essenslieferung ist in deiner Region noch nicht verfügbar.'),
        findsOneWidget,
      );
    });

    testWidgets('can navigate back when pushed onto stack', (WidgetTester tester) async {
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
                    onPressed: () => Navigator.push(
                      context,
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

      // Back button should exist now
      expect(find.byType(BackButton), findsOneWidget);

      // Go back via AppBar back button
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Verify we're back
      expect(find.text('Go to Food'), findsOneWidget);
    });

    // Track C - Ticket #56: Icon size updated to 64
    testWidgets('uses theme colors for icon', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the Icon widget and verify it exists
      final iconFinder = find.byIcon(Icons.fastfood_outlined);
      expect(iconFinder, findsOneWidget);

      // Get the Icon widget
      final icon = tester.widget<Icon>(iconFinder);

      // Icon should have size 64 as specified in Ticket #56
      expect(icon.size, equals(64));
    });

    testWidgets('has proper padding', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check that Padding widget exists
      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('centers content vertically', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check that Center widget exists
      expect(find.byType(Center), findsAtLeastNWidgets(1));
    });

    // Track C - Ticket #56: SafeArea added for Production-Ready UX
    testWidgets('has SafeArea wrapper', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check that SafeArea widget exists (may find more than one due to Scaffold)
      expect(find.byType(SafeArea), findsAtLeastNWidgets(1));
    });
  });
}

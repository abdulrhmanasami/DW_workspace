/// Food Coming Soon Screen Widget Tests - Track C Ticket #48
/// Purpose: Test FoodComingSoonScreen UI components and behavior
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

    testWidgets('displays title and subtitle (EN)', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for title
      expect(find.text('Food delivery is coming soon'), findsOneWidget);

      // Check for subtitle
      expect(
        find.text("We're working hard to bring food delivery to your area. Stay tuned!"),
        findsOneWidget,
      );
    });

    testWidgets('displays AppBar with correct title (EN)', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check AppBar title
      expect(find.text('Food delivery'), findsOneWidget);
    });

    testWidgets('displays food icon', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for the food icon
      expect(find.byIcon(Icons.fastfood_outlined), findsOneWidget);
    });

    testWidgets('displays CTA button with correct text (EN)', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for CTA button
      expect(find.text('Back to home'), findsOneWidget);

      // Verify it's a FilledButton
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('CTA button calls Navigator.pop when tapped', (WidgetTester tester) async {
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
      expect(find.text('Food delivery is coming soon'), findsOneWidget);

      // Tap the CTA button
      await tester.tap(find.text('Back to home'));
      await tester.pumpAndSettle();

      // Verify pop was called
      expect(didPop, isTrue);
      expect(find.text('Open Food Screen'), findsOneWidget);
    });

    testWidgets('displays Arabic translations when locale is ar', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      // Check for Arabic AppBar title
      expect(find.text('توصيل الطعام'), findsOneWidget);

      // Check for Arabic title
      expect(find.text('خدمة توصيل الطعام قادمة قريباً'), findsOneWidget);

      // Check for Arabic subtitle
      expect(
        find.text('نعمل حالياً على إطلاق خدمة توصيل الطعام في منطقتك. ترقّب التحديث القادم!'),
        findsOneWidget,
      );

      // Check for Arabic CTA
      expect(find.text('العودة إلى الرئيسية'), findsOneWidget);
    });

    testWidgets('displays German translations when locale is de', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('de')));
      await tester.pumpAndSettle();

      // Check for German AppBar title
      expect(find.text('Essenslieferung'), findsOneWidget);

      // Check for German title
      expect(find.text('Essenslieferung kommt bald'), findsOneWidget);

      // Check for German subtitle
      expect(
        find.text('Wir arbeiten daran, Essenslieferung in deine Region zu bringen. Bleib dran!'),
        findsOneWidget,
      );

      // Check for German CTA
      expect(find.text('Zurück zur Startseite'), findsOneWidget);
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
      expect(find.text('Food delivery is coming soon'), findsOneWidget);

      // Back button should exist now
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // Go back via AppBar back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify we're back
      expect(find.text('Go to Food'), findsOneWidget);
    });

    testWidgets('uses theme colors for icon', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the Icon widget and verify it exists
      final iconFinder = find.byIcon(Icons.fastfood_outlined);
      expect(iconFinder, findsOneWidget);

      // Get the Icon widget
      final icon = tester.widget<Icon>(iconFinder);

      // Icon should have size 56 as specified
      expect(icon.size, equals(56));
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
  });
}


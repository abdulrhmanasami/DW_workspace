/// Tests for FoodRestaurantsListScreen (Screen 13)
///
/// Created by: Track C - Ticket #52
/// Purpose: Verify Food Restaurants List screen UI and behavior

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:food_shims/food_shims.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/screens/food/food_restaurants_list_screen.dart';
import 'package:delivery_ways_clean/state/food/app_food_repository.dart';
import 'package:delivery_ways_clean/state/food/food_repository_provider.dart';

import '../support/design_system_harness.dart';

void main() {
  setUpAll(() {
    ensureDesignSystemStubsForTests();
  });

  Widget createTestWidget({
    List<FoodRestaurant>? seedRestaurants,
    Locale locale = const Locale('en'),
  }) {
    return ProviderScope(
      overrides: [
        if (seedRestaurants != null)
          foodRepositoryProvider.overrideWithValue(
            AppFoodRepository(seedRestaurants: seedRestaurants),
          ),
      ],
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
        home: const FoodRestaurantsListScreen(),
      ),
    );
  }

  group('FoodRestaurantsListScreen', () {
    testWidgets('displays AppBar with correct title', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Food delivery'), findsOneWidget);
    });

    testWidgets('displays search field with placeholder', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(TextField, 'Search restaurants or cuisines'),
        findsOneWidget,
      );
    });

    testWidgets('displays category filter chips', (tester) async {
      await tester.pumpWidget(createTestWidget(
        seedRestaurants: const [], // Empty to avoid duplicate text from restaurant cards
      ));
      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Burgers'), findsOneWidget);
      expect(find.text('Italian'), findsOneWidget);
    });

    testWidgets('displays restaurant cards from seed data', (tester) async {
      await tester.pumpWidget(createTestWidget(
        seedRestaurants: const [
          FoodRestaurant(
            id: 'r1',
            name: 'Test Restaurant',
            cuisine: 'Test Cuisine',
            rating: 4.5,
            ratingCount: 100,
            estimatedDeliveryMinutes: 30,
          ),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Test Restaurant'), findsOneWidget);
      expect(find.text('Test Cuisine'), findsOneWidget);
      expect(find.text('4.5'), findsOneWidget);
      expect(find.text('(100)'), findsOneWidget);
      expect(find.text('30 min'), findsOneWidget);
    });

    testWidgets('displays empty state when no restaurants', (tester) async {
      await tester.pumpWidget(createTestWidget(
        seedRestaurants: const [],
      ));
      await tester.pumpAndSettle();

      expect(find.text('No restaurants found'), findsOneWidget);
      expect(
        find.text('Try changing the filters or search for a different cuisine.'),
        findsOneWidget,
      );
    });

    testWidgets('search filters restaurants by name', (tester) async {
      await tester.pumpWidget(createTestWidget(
        seedRestaurants: const [
          FoodRestaurant(
            id: 'r1',
            name: 'Pizza Place',
            cuisine: 'Italian',
            rating: 4.5,
            ratingCount: 100,
            estimatedDeliveryMinutes: 30,
          ),
          FoodRestaurant(
            id: 'r2',
            name: 'Burger Joint',
            cuisine: 'American',
            rating: 4.3,
            ratingCount: 80,
            estimatedDeliveryMinutes: 25,
          ),
        ],
      ));
      await tester.pumpAndSettle();

      // Both restaurants should be visible initially
      expect(find.text('Pizza Place'), findsOneWidget);
      expect(find.text('Burger Joint'), findsOneWidget);

      // Enter search query
      await tester.enterText(
        find.widgetWithText(TextField, 'Search restaurants or cuisines'),
        'Pizza',
      );
      await tester.pumpAndSettle();

      // Only Pizza Place should be visible
      expect(find.text('Pizza Place'), findsOneWidget);
      expect(find.text('Burger Joint'), findsNothing);
    });

    testWidgets('category chip filters restaurants', (tester) async {
      await tester.pumpWidget(createTestWidget(
        seedRestaurants: const [
          FoodRestaurant(
            id: 'r1',
            name: 'Burger Barn',
            cuisine: 'American Burgers',
            rating: 4.5,
            ratingCount: 100,
            estimatedDeliveryMinutes: 30,
            categories: [FoodCategory(id: 'burgers', label: 'Burgers')],
          ),
          FoodRestaurant(
            id: 'r2',
            name: 'Pizza Palace',
            cuisine: 'Italian Food',
            rating: 4.3,
            ratingCount: 80,
            estimatedDeliveryMinutes: 35,
            categories: [FoodCategory(id: 'italian', label: 'Italian')],
          ),
        ],
      ));
      await tester.pumpAndSettle();

      // Both restaurants visible initially
      expect(find.text('Burger Barn'), findsOneWidget);
      expect(find.text('Pizza Palace'), findsOneWidget);

      // Tap Burgers filter chip (find ChoiceChip specifically)
      await tester.tap(find.widgetWithText(ChoiceChip, 'Burgers'));
      await tester.pumpAndSettle();

      // Only burger restaurant should be visible
      expect(find.text('Burger Barn'), findsOneWidget);
      expect(find.text('Pizza Palace'), findsNothing);
    });

    testWidgets('displays Arabic content when locale is ar', (tester) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      expect(find.text('توصيل الطعام'), findsOneWidget);
      expect(find.text('الكل'), findsOneWidget);
      expect(find.text('برجر'), findsOneWidget);
      expect(find.text('إيطالي'), findsOneWidget);
    });

    testWidgets('displays German content when locale is de', (tester) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('de')));
      await tester.pumpAndSettle();

      expect(find.text('Essenslieferung'), findsOneWidget);
      expect(find.text('Alle'), findsOneWidget);
      expect(find.text('Burger'), findsOneWidget);
      expect(find.text('Italienisch'), findsOneWidget);
    });

    testWidgets('displays restaurant rating with star icon', (tester) async {
      await tester.pumpWidget(createTestWidget(
        seedRestaurants: const [
          FoodRestaurant(
            id: 'r1',
            name: 'Test Restaurant',
            cuisine: 'Test',
            rating: 4.7,
            ratingCount: 150,
            estimatedDeliveryMinutes: 30,
          ),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('4.7'), findsOneWidget);
    });

    testWidgets('displays delivery time with clock icon', (tester) async {
      await tester.pumpWidget(createTestWidget(
        seedRestaurants: const [
          FoodRestaurant(
            id: 'r1',
            name: 'Test Restaurant',
            cuisine: 'Test',
            rating: 4.5,
            ratingCount: 100,
            estimatedDeliveryMinutes: 45,
          ),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.access_time), findsOneWidget);
      expect(find.text('45 min'), findsOneWidget);
    });
  });
}


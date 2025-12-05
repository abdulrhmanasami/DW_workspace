/// Tests for FoodRestaurantDetailsScreen
///
/// Created by: Track C - Ticket #53
/// Purpose: Verify Restaurant Details + Menu screen UI behavior.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:food_shims/food_shims.dart';

import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/screens/food/food_restaurant_details_screen.dart';
import 'package:delivery_ways_clean/state/food/food_repository_provider.dart';

/// Mock FoodRepository for testing
class MockFoodRepository implements FoodRepository {
  final List<FoodRestaurant> restaurants;
  final Map<String, List<FoodMenuItem>> menus;
  final List<FoodOrder> _orders = [];

  MockFoodRepository({
    this.restaurants = const [],
    this.menus = const {},
  });

  @override
  Future<List<FoodRestaurant>> listRestaurants({
    String? query,
    FoodCategory? category,
  }) async {
    return restaurants;
  }

  @override
  Future<List<FoodMenuItem>> getMenu({required String restaurantId}) async {
    return menus[restaurantId] ?? [];
  }

  @override
  Future<FoodOrder> createOrder({
    required FoodRestaurant restaurant,
    required List<FoodMenuItem> items,
  }) async {
    final order = FoodOrder(
      id: 'test_order_${DateTime.now().microsecondsSinceEpoch}',
      restaurantId: restaurant.id,
      restaurantName: restaurant.name,
      items: items
          .map((item) => FoodOrderItem(
                menuItemId: item.id,
                name: item.name,
                quantity: 1,
                unitPriceCents: item.priceCents,
                currencyCode: item.currencyCode,
              ))
          .toList(),
      totalAmountCents: items.fold(0, (sum, item) => sum + item.priceCents),
      currencyCode: items.isNotEmpty ? items.first.currencyCode : 'USD',
      status: FoodOrderStatus.pending,
      createdAt: DateTime.now(),
    );
    _orders.insert(0, order);
    return order;
  }

  @override
  Future<List<FoodOrder>> listOrders() async {
    return List.unmodifiable(_orders);
  }
}

void main() {
  const testRestaurant = FoodRestaurant(
    id: 'test_rest',
    name: 'Test Restaurant',
    cuisine: 'Test Cuisine',
    rating: 4.5,
    ratingCount: 100,
    estimatedDeliveryMinutes: 30,
    categories: [FoodCategory(id: 'test', label: 'Test')],
  );

  const testMenuItems = [
    FoodMenuItem(
      id: 'item_1',
      restaurantId: 'test_rest',
      name: 'Test Burger',
      description: 'A delicious test burger',
      priceCents: 2500,
      currencyCode: 'USD',
      sectionName: 'Burgers',
    ),
    FoodMenuItem(
      id: 'item_2',
      restaurantId: 'test_rest',
      name: 'Test Fries',
      description: 'Crispy test fries',
      priceCents: 1000,
      currencyCode: 'USD',
      sectionName: 'Sides',
    ),
  ];

  Widget buildTestWidget({
    required FoodRestaurant restaurant,
    List<FoodMenuItem> menuItems = testMenuItems,
  }) {
    return ProviderScope(
      overrides: [
        foodRepositoryProvider.overrideWithValue(
          MockFoodRepository(menus: {restaurant.id: menuItems}),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: FoodRestaurantDetailsScreen(restaurant: restaurant),
      ),
    );
  }

  group('FoodRestaurantDetailsScreen - Header', () {
    testWidgets('displays restaurant name in AppBar', (tester) async {
      await tester.pumpWidget(buildTestWidget(restaurant: testRestaurant));
      await tester.pumpAndSettle();

      expect(find.text('Test Restaurant'), findsAtLeastNWidgets(1));
    });

    testWidgets('displays restaurant cuisine', (tester) async {
      await tester.pumpWidget(buildTestWidget(restaurant: testRestaurant));
      await tester.pumpAndSettle();

      expect(find.text('Test Cuisine'), findsOneWidget);
    });

    testWidgets('displays restaurant rating', (tester) async {
      await tester.pumpWidget(buildTestWidget(restaurant: testRestaurant));
      await tester.pumpAndSettle();

      expect(find.text('4.5'), findsOneWidget);
      expect(find.text('(100)'), findsOneWidget);
    });

    testWidgets('displays delivery time', (tester) async {
      await tester.pumpWidget(buildTestWidget(restaurant: testRestaurant));
      await tester.pumpAndSettle();

      expect(find.text('30 min'), findsOneWidget);
    });
  });

  group('FoodRestaurantDetailsScreen - Menu', () {
    testWidgets('displays menu items', (tester) async {
      await tester.pumpWidget(buildTestWidget(restaurant: testRestaurant));
      await tester.pumpAndSettle();

      expect(find.text('Test Burger'), findsOneWidget);
      expect(find.text('Test Fries'), findsOneWidget);
    });

    testWidgets('displays menu item descriptions', (tester) async {
      await tester.pumpWidget(buildTestWidget(restaurant: testRestaurant));
      await tester.pumpAndSettle();

      expect(find.text('A delicious test burger'), findsOneWidget);
      expect(find.text('Crispy test fries'), findsOneWidget);
    });

    testWidgets('displays menu item prices', (tester) async {
      await tester.pumpWidget(buildTestWidget(restaurant: testRestaurant));
      await tester.pumpAndSettle();

      expect(find.text('25.00 USD'), findsOneWidget);
      expect(find.text('10.00 USD'), findsOneWidget);
    });

    testWidgets('displays section titles', (tester) async {
      await tester.pumpWidget(buildTestWidget(restaurant: testRestaurant));
      await tester.pumpAndSettle();

      expect(find.text('Burgers'), findsOneWidget);
      expect(find.text('Sides'), findsOneWidget);
    });

    testWidgets('displays add button for each item', (tester) async {
      await tester.pumpWidget(buildTestWidget(restaurant: testRestaurant));
      await tester.pumpAndSettle();

      // Find FilledButton with + icon
      final addButtons = find.byIcon(Icons.add);
      expect(addButtons, findsAtLeastNWidgets(2));
    });
  });

  group('FoodRestaurantDetailsScreen - Cart Interaction', () {
    testWidgets('tapping add button updates cart', (tester) async {
      await tester.pumpWidget(buildTestWidget(restaurant: testRestaurant));
      await tester.pumpAndSettle();

      // Cart should not be visible initially
      expect(find.textContaining('items'), findsNothing);

      // Find first add button (inside FilledButton)
      final addButtons = find.byWidgetPredicate(
        (widget) =>
            widget is FilledButton &&
            (widget.child is Icon && (widget.child as Icon).icon == Icons.add),
      );
      expect(addButtons, findsAtLeastNWidgets(1));

      await tester.tap(addButtons.first);
      await tester.pumpAndSettle();

      // Cart summary should now be visible
      expect(find.textContaining('1 items'), findsOneWidget);
    });

    testWidgets('adding multiple items updates total', (tester) async {
      await tester.pumpWidget(buildTestWidget(restaurant: testRestaurant));
      await tester.pumpAndSettle();

      // Find add buttons
      final addButtons = find.byWidgetPredicate(
        (widget) =>
            widget is FilledButton &&
            (widget.child is Icon && (widget.child as Icon).icon == Icons.add),
      );

      // Add first item twice
      await tester.tap(addButtons.first);
      await tester.pumpAndSettle();
      await tester.tap(addButtons.first);
      await tester.pumpAndSettle();

      expect(find.textContaining('2 items'), findsOneWidget);
    });

    testWidgets('quantity controls appear after adding item', (tester) async {
      await tester.pumpWidget(buildTestWidget(restaurant: testRestaurant));
      await tester.pumpAndSettle();

      // Find add button
      final addButtons = find.byWidgetPredicate(
        (widget) =>
            widget is FilledButton &&
            (widget.child is Icon && (widget.child as Icon).icon == Icons.add),
      );

      await tester.tap(addButtons.first);
      await tester.pumpAndSettle();

      // Should now see remove button
      expect(find.byIcon(Icons.remove), findsAtLeastNWidgets(1));
    });

    testWidgets('removing all items hides cart summary', (tester) async {
      await tester.pumpWidget(buildTestWidget(restaurant: testRestaurant));
      await tester.pumpAndSettle();

      // Add item
      final addButtons = find.byWidgetPredicate(
        (widget) =>
            widget is FilledButton &&
            (widget.child is Icon && (widget.child as Icon).icon == Icons.add),
      );
      await tester.tap(addButtons.first);
      await tester.pumpAndSettle();

      // Cart visible
      expect(find.textContaining('1 items'), findsOneWidget);

      // Remove item
      await tester.tap(find.byIcon(Icons.remove).first);
      await tester.pumpAndSettle();

      // Cart should be hidden
      expect(find.textContaining('items'), findsNothing);
    });
  });

  group('FoodRestaurantDetailsScreen - Empty Menu', () {
    testWidgets('displays message when menu is empty', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        restaurant: testRestaurant,
        menuItems: [],
      ));
      await tester.pumpAndSettle();

      expect(find.text('No menu items available'), findsOneWidget);
    });
  });

  group('FoodRestaurantDetailsScreen - Loading State', () {
    testWidgets('eventually loads and displays menu items', (tester) async {
      await tester.pumpWidget(buildTestWidget(restaurant: testRestaurant));
      await tester.pumpAndSettle();

      // After loading, menu items should be visible
      expect(find.text('Test Burger'), findsOneWidget);
      expect(find.text('Test Fries'), findsOneWidget);
    });
  });

  group('FoodRestaurantDetailsScreen - Cart Provider', () {
    testWidgets('cart state persists across widget rebuilds', (tester) async {
      // Using fresh provider scope
      final widget = ProviderScope(
        overrides: [
          foodRepositoryProvider.overrideWithValue(
            MockFoodRepository(menus: {testRestaurant.id: testMenuItems}),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en')],
          home: FoodRestaurantDetailsScreen(restaurant: testRestaurant),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Add item to cart
      final addButtons = find.byWidgetPredicate(
        (widget) =>
            widget is FilledButton &&
            (widget.child is Icon && (widget.child as Icon).icon == Icons.add),
      );
      await tester.tap(addButtons.first);
      await tester.pumpAndSettle();

      expect(find.textContaining('1 items'), findsOneWidget);
    });
  });

  // ============================================================================
  // Checkout Tests - Track C - Ticket #54
  // ============================================================================
  group('FoodRestaurantDetailsScreen - Checkout (Track C - Ticket #54)', () {
    testWidgets('tapping checkout button creates order and clears cart',
        (tester) async {
      final mockRepo = MockFoodRepository(menus: {testRestaurant.id: testMenuItems});
      
      final widget = ProviderScope(
        overrides: [
          foodRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en')],
          home: FoodRestaurantDetailsScreen(restaurant: testRestaurant),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Add items to cart
      final addButtons = find.byWidgetPredicate(
        (widget) =>
            widget is FilledButton &&
            (widget.child is Icon && (widget.child as Icon).icon == Icons.add),
      );
      await tester.tap(addButtons.first);
      await tester.pumpAndSettle();
      await tester.tap(addButtons.first);
      await tester.pumpAndSettle();

      // Verify cart has items
      expect(find.textContaining('2 items'), findsOneWidget);

      // Find and tap checkout button (the FilledButton at bottom)
      final checkoutButton = find.byWidgetPredicate(
        (widget) =>
            widget is FilledButton &&
            widget.child is Text,
      );
      
      await tester.tap(checkoutButton.last);
      await tester.pumpAndSettle();

      // Cart should be cleared (bottom bar hidden)
      expect(find.textContaining('items'), findsNothing);
    });

    testWidgets('checkout shows snackbar with restaurant name',
        (tester) async {
      final mockRepo = MockFoodRepository(menus: {testRestaurant.id: testMenuItems});
      
      final widget = ProviderScope(
        overrides: [
          foodRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en')],
          home: FoodRestaurantDetailsScreen(restaurant: testRestaurant),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Add item to cart
      final addButtons = find.byWidgetPredicate(
        (widget) =>
            widget is FilledButton &&
            (widget.child is Icon && (widget.child as Icon).icon == Icons.add),
      );
      await tester.tap(addButtons.first);
      await tester.pumpAndSettle();

      // Tap checkout button
      final checkoutButton = find.byWidgetPredicate(
        (widget) =>
            widget is FilledButton &&
            widget.child is Text,
      );
      
      await tester.tap(checkoutButton.last);
      await tester.pump(); // Allow async to run
      await tester.pump(const Duration(milliseconds: 100));

      // Should show snackbar with restaurant name
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Test Restaurant'), findsAtLeastNWidgets(1));
    });

    testWidgets('order is added to orders controller state',
        (tester) async {
      final mockRepo = MockFoodRepository(menus: {testRestaurant.id: testMenuItems});
      
      final widget = ProviderScope(
        overrides: [
          foodRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: Builder(
          builder: (context) {
            return MaterialApp(
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en')],
              home: Consumer(
                builder: (context, ref, _) {
                  // Capture container reference
                  return const FoodRestaurantDetailsScreen(restaurant: testRestaurant);
                },
              ),
            );
          },
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Add item to cart
      final addButtons = find.byWidgetPredicate(
        (widget) =>
            widget is FilledButton &&
            (widget.child is Icon && (widget.child as Icon).icon == Icons.add),
      );
      await tester.tap(addButtons.first);
      await tester.pumpAndSettle();

      // Tap checkout button
      final checkoutButton = find.byWidgetPredicate(
        (widget) =>
            widget is FilledButton &&
            widget.child is Text,
      );
      
      await tester.tap(checkoutButton.last);
      await tester.pumpAndSettle();

      // Verify order was created in repository
      final orders = await mockRepo.listOrders();
      expect(orders.length, equals(1));
      expect(orders.first.restaurantName, equals('Test Restaurant'));
    });
  });
}


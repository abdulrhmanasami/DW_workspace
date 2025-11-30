/// Tests for AppFoodRepository
///
/// Created by: Track C - Ticket #52
/// Purpose: Verify in-memory food repository behavior

import 'package:flutter_test/flutter_test.dart';
import 'package:food_shims/food_shims.dart';
import 'package:delivery_ways_clean/state/food/app_food_repository.dart';

void main() {
  group('AppFoodRepository', () {
    late AppFoodRepository repository;

    setUp(() {
      // Use seed data for tests
      repository = AppFoodRepository(
        seedRestaurants: const [
          FoodRestaurant(
            id: 'test_1',
            name: 'Burger Barn',
            cuisine: 'Burgers',
            rating: 4.5,
            ratingCount: 100,
            estimatedDeliveryMinutes: 30,
            categories: [FoodCategory(id: 'burgers', label: 'Burgers')],
          ),
          FoodRestaurant(
            id: 'test_2',
            name: 'Pizza Paradise',
            cuisine: 'Italian',
            rating: 4.8,
            ratingCount: 200,
            estimatedDeliveryMinutes: 35,
            categories: [FoodCategory(id: 'italian', label: 'Italian')],
          ),
          FoodRestaurant(
            id: 'test_3',
            name: 'Gourmet Grill',
            cuisine: 'American',
            rating: 4.2,
            ratingCount: 50,
            estimatedDeliveryMinutes: 25,
            categories: [FoodCategory(id: 'american', label: 'American')],
          ),
          FoodRestaurant(
            id: 'test_4',
            name: 'Patty Palace',
            cuisine: 'Burgers',
            rating: 4.6,
            ratingCount: 150,
            estimatedDeliveryMinutes: 20,
            categories: [FoodCategory(id: 'burgers', label: 'Burgers')],
          ),
        ],
      );
    });

    test('returns initial restaurants when no filters applied', () async {
      final result = await repository.listRestaurants();

      expect(result, hasLength(4));
      expect(result[0].name, equals('Burger Barn'));
      expect(result[1].name, equals('Pizza Paradise'));
    });

    test('filters restaurants by query on name', () async {
      final result = await repository.listRestaurants(query: 'Pizza');

      expect(result, hasLength(1));
      expect(result[0].name, equals('Pizza Paradise'));
    });

    test('filters restaurants by query on cuisine', () async {
      final result = await repository.listRestaurants(query: 'Italian');

      expect(result, hasLength(1));
      expect(result[0].name, equals('Pizza Paradise'));
    });

    test('filters restaurants by category', () async {
      final burgersCategory = const FoodCategory(id: 'burgers', label: 'Burgers');
      final result = await repository.listRestaurants(category: burgersCategory);

      expect(result, hasLength(2));
      expect(result.every((r) => r.cuisine == 'Burgers'), isTrue);
    });

    test('returns empty list when query does not match', () async {
      final result = await repository.listRestaurants(query: 'Sushi');

      expect(result, isEmpty);
    });

    test('category burger returns only burger restaurants', () async {
      final burgersCategory = const FoodCategory(id: 'burgers', label: 'Burgers');
      final result = await repository.listRestaurants(category: burgersCategory);

      expect(result, hasLength(2));
      expect(result[0].name, equals('Burger Barn'));
      expect(result[1].name, equals('Patty Palace'));
    });

    test('query is case-insensitive', () async {
      final result = await repository.listRestaurants(query: 'PIZZA');

      expect(result, hasLength(1));
      expect(result[0].name, equals('Pizza Paradise'));
    });

    test('combines query and category filters', () async {
      final burgersCategory = const FoodCategory(id: 'burgers', label: 'Burgers');
      final result = await repository.listRestaurants(
        query: 'Patty',
        category: burgersCategory,
      );

      expect(result, hasLength(1));
      expect(result[0].name, equals('Patty Palace'));
    });

    test('uses default restaurants when no seed provided', () async {
      final defaultRepo = AppFoodRepository();
      final result = await defaultRepo.listRestaurants();

      expect(result, isNotEmpty);
      // Default data should have at least some restaurants
      expect(result.length, greaterThanOrEqualTo(3));
    });
  });

  group('AppFoodRepository - getMenu (Track C - Ticket #53)', () {
    late AppFoodRepository repository;

    setUp(() {
      repository = AppFoodRepository();
    });

    test('returns non-empty menu for known restaurant id (rest_1)', () async {
      final menu = await repository.getMenu(restaurantId: 'rest_1');

      expect(menu, isNotEmpty);
      expect(menu.length, greaterThanOrEqualTo(2));
    });

    test('menu items contain correct restaurantId', () async {
      final menu = await repository.getMenu(restaurantId: 'rest_1');

      expect(menu, isNotEmpty);
      for (final item in menu) {
        expect(item.restaurantId, equals('rest_1'));
      }
    });

    test('menu items have positive price', () async {
      final menu = await repository.getMenu(restaurantId: 'rest_1');

      expect(menu, isNotEmpty);
      for (final item in menu) {
        expect(item.priceCents, greaterThan(0));
        expect(item.price, greaterThan(0.0));
      }
    });

    test('menu items have required fields populated', () async {
      final menu = await repository.getMenu(restaurantId: 'rest_1');

      expect(menu, isNotEmpty);
      for (final item in menu) {
        expect(item.id, isNotEmpty);
        expect(item.name, isNotEmpty);
        expect(item.description, isNotEmpty);
        expect(item.currencyCode, isNotEmpty);
        expect(item.sectionName, isNotEmpty);
      }
    });

    test('returns menu for rest_2 (Pizza Palace)', () async {
      final menu = await repository.getMenu(restaurantId: 'rest_2');

      expect(menu, isNotEmpty);
      expect(menu.any((item) => item.sectionName == 'Pizzas'), isTrue);
    });

    test('returns menu for rest_3 (Sushi Express)', () async {
      final menu = await repository.getMenu(restaurantId: 'rest_3');

      expect(menu, isNotEmpty);
      expect(
        menu.any((item) =>
            item.sectionName == 'Nigiri' || item.sectionName == 'Rolls'),
        isTrue,
      );
    });

    test('returns empty list for unknown restaurant id', () async {
      final menu = await repository.getMenu(restaurantId: 'unknown_restaurant');

      expect(menu, isEmpty);
    });

    test('price getter calculates correctly from priceCents', () async {
      final menu = await repository.getMenu(restaurantId: 'rest_1');

      // Find an item with known price
      final classicBurger = menu.firstWhere(
        (item) => item.name == 'Classic Burger',
        orElse: () => menu.first,
      );

      // Classic Burger is 2800 cents = $28.00
      expect(classicBurger.priceCents, equals(2800));
      expect(classicBurger.price, equals(28.00));
    });

    test('menu items have different sections', () async {
      final menu = await repository.getMenu(restaurantId: 'rest_1');

      final sections = menu.map((item) => item.sectionName).toSet();
      // Burger Corner should have Burgers, Sides, Drinks sections
      expect(sections.length, greaterThanOrEqualTo(2));
    });
  });

  // ============================================================================
  // Food Orders Tests - Track C - Ticket #54
  // ============================================================================
  group('AppFoodRepository - createOrder (Track C - Ticket #54)', () {
    late AppFoodRepository repository;

    setUp(() {
      repository = AppFoodRepository();
    });

    test('createOrder creates order with correct restaurant info', () async {
      const restaurant = FoodRestaurant(
        id: 'rest_1',
        name: 'Burger Corner',
        cuisine: 'Burgers',
        rating: 4.5,
        ratingCount: 100,
        estimatedDeliveryMinutes: 30,
      );
      const menuItems = [
        FoodMenuItem(
          id: 'item_1',
          restaurantId: 'rest_1',
          name: 'Classic Burger',
          description: 'A classic burger',
          priceCents: 1500,
          currencyCode: 'USD',
          sectionName: 'Burgers',
        ),
      ];

      final order = await repository.createOrder(
        restaurant: restaurant,
        items: menuItems,
      );

      expect(order.restaurantId, equals('rest_1'));
      expect(order.restaurantName, equals('Burger Corner'));
    });

    test('createOrder calculates correct total for single item', () async {
      const restaurant = FoodRestaurant(
        id: 'rest_1',
        name: 'Burger Corner',
        cuisine: 'Burgers',
        rating: 4.5,
        ratingCount: 100,
        estimatedDeliveryMinutes: 30,
      );
      const menuItems = [
        FoodMenuItem(
          id: 'item_1',
          restaurantId: 'rest_1',
          name: 'Classic Burger',
          description: 'A classic burger',
          priceCents: 1500,
          currencyCode: 'USD',
          sectionName: 'Burgers',
        ),
      ];

      final order = await repository.createOrder(
        restaurant: restaurant,
        items: menuItems,
      );

      expect(order.totalAmountCents, equals(1500));
      expect(order.totalAmount, equals(15.00));
    });

    test('createOrder calculates correct total for multiple items', () async {
      const restaurant = FoodRestaurant(
        id: 'rest_1',
        name: 'Burger Corner',
        cuisine: 'Burgers',
        rating: 4.5,
        ratingCount: 100,
        estimatedDeliveryMinutes: 30,
      );
      const menuItems = [
        FoodMenuItem(
          id: 'item_1',
          restaurantId: 'rest_1',
          name: 'Classic Burger',
          description: 'A classic burger',
          priceCents: 1500,
          currencyCode: 'USD',
          sectionName: 'Burgers',
        ),
        FoodMenuItem(
          id: 'item_2',
          restaurantId: 'rest_1',
          name: 'Fries',
          description: 'Crispy fries',
          priceCents: 500,
          currencyCode: 'USD',
          sectionName: 'Sides',
        ),
      ];

      final order = await repository.createOrder(
        restaurant: restaurant,
        items: menuItems,
      );

      expect(order.totalAmountCents, equals(2000));
      expect(order.totalAmount, equals(20.00));
    });

    test('createOrder handles duplicate items as quantity', () async {
      const restaurant = FoodRestaurant(
        id: 'rest_1',
        name: 'Burger Corner',
        cuisine: 'Burgers',
        rating: 4.5,
        ratingCount: 100,
        estimatedDeliveryMinutes: 30,
      );
      const burger = FoodMenuItem(
        id: 'item_1',
        restaurantId: 'rest_1',
        name: 'Classic Burger',
        description: 'A classic burger',
        priceCents: 1500,
        currencyCode: 'USD',
        sectionName: 'Burgers',
      );
      final menuItems = [burger, burger, burger]; // 3 burgers

      final order = await repository.createOrder(
        restaurant: restaurant,
        items: menuItems,
      );

      // Should be 3 × 1500 = 4500 cents
      expect(order.totalAmountCents, equals(4500));
      // Order items should be grouped by ID
      expect(order.items.length, equals(1));
      expect(order.items.first.quantity, equals(3));
    });

    test('createOrder sets status to pending', () async {
      const restaurant = FoodRestaurant(
        id: 'rest_1',
        name: 'Burger Corner',
        cuisine: 'Burgers',
        rating: 4.5,
        ratingCount: 100,
        estimatedDeliveryMinutes: 30,
      );
      const menuItems = [
        FoodMenuItem(
          id: 'item_1',
          restaurantId: 'rest_1',
          name: 'Classic Burger',
          description: 'A classic burger',
          priceCents: 1500,
          currencyCode: 'USD',
          sectionName: 'Burgers',
        ),
      ];

      final order = await repository.createOrder(
        restaurant: restaurant,
        items: menuItems,
      );

      expect(order.status, equals(FoodOrderStatus.pending));
    });

    test('createOrder generates unique ID', () async {
      const restaurant = FoodRestaurant(
        id: 'rest_1',
        name: 'Burger Corner',
        cuisine: 'Burgers',
        rating: 4.5,
        ratingCount: 100,
        estimatedDeliveryMinutes: 30,
      );
      const menuItems = [
        FoodMenuItem(
          id: 'item_1',
          restaurantId: 'rest_1',
          name: 'Classic Burger',
          description: 'A classic burger',
          priceCents: 1500,
          currencyCode: 'USD',
          sectionName: 'Burgers',
        ),
      ];

      final order1 = await repository.createOrder(
        restaurant: restaurant,
        items: menuItems,
      );
      final order2 = await repository.createOrder(
        restaurant: restaurant,
        items: menuItems,
      );

      expect(order1.id, isNot(equals(order2.id)));
    });

    test('createOrder preserves currency code', () async {
      const restaurant = FoodRestaurant(
        id: 'rest_1',
        name: 'Burger Corner',
        cuisine: 'Burgers',
        rating: 4.5,
        ratingCount: 100,
        estimatedDeliveryMinutes: 30,
      );
      const menuItems = [
        FoodMenuItem(
          id: 'item_1',
          restaurantId: 'rest_1',
          name: 'Classic Burger',
          description: 'A classic burger',
          priceCents: 1500,
          currencyCode: 'SAR',
          sectionName: 'Burgers',
        ),
      ];

      final order = await repository.createOrder(
        restaurant: restaurant,
        items: menuItems,
      );

      expect(order.currencyCode, equals('SAR'));
    });
  });

  group('AppFoodRepository - listOrders (Track C - Ticket #54)', () {
    late AppFoodRepository repository;

    setUp(() {
      repository = AppFoodRepository();
    });

    test('listOrders returns empty list initially', () async {
      final orders = await repository.listOrders();

      expect(orders, isEmpty);
    });

    test('listOrders returns most recent order first', () async {
      const restaurant = FoodRestaurant(
        id: 'rest_1',
        name: 'Burger Corner',
        cuisine: 'Burgers',
        rating: 4.5,
        ratingCount: 100,
        estimatedDeliveryMinutes: 30,
      );
      const menuItems = [
        FoodMenuItem(
          id: 'item_1',
          restaurantId: 'rest_1',
          name: 'Classic Burger',
          description: 'A classic burger',
          priceCents: 1500,
          currencyCode: 'USD',
          sectionName: 'Burgers',
        ),
      ];

      final order1 = await repository.createOrder(
        restaurant: restaurant,
        items: menuItems,
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));
      final order2 = await repository.createOrder(
        restaurant: restaurant,
        items: menuItems,
      );

      final orders = await repository.listOrders();

      expect(orders.length, equals(2));
      expect(orders[0].id, equals(order2.id)); // Most recent first
      expect(orders[1].id, equals(order1.id));
    });

    test('multiple orders are preserved', () async {
      const restaurant = FoodRestaurant(
        id: 'rest_1',
        name: 'Burger Corner',
        cuisine: 'Burgers',
        rating: 4.5,
        ratingCount: 100,
        estimatedDeliveryMinutes: 30,
      );
      const menuItems = [
        FoodMenuItem(
          id: 'item_1',
          restaurantId: 'rest_1',
          name: 'Classic Burger',
          description: 'A classic burger',
          priceCents: 1500,
          currencyCode: 'USD',
          sectionName: 'Burgers',
        ),
      ];

      await repository.createOrder(restaurant: restaurant, items: menuItems);
      await repository.createOrder(restaurant: restaurant, items: menuItems);
      await repository.createOrder(restaurant: restaurant, items: menuItems);

      final orders = await repository.listOrders();

      expect(orders.length, equals(3));
    });

    test('listOrders returns unmodifiable list', () async {
      const restaurant = FoodRestaurant(
        id: 'rest_1',
        name: 'Burger Corner',
        cuisine: 'Burgers',
        rating: 4.5,
        ratingCount: 100,
        estimatedDeliveryMinutes: 30,
      );
      const menuItems = [
        FoodMenuItem(
          id: 'item_1',
          restaurantId: 'rest_1',
          name: 'Classic Burger',
          description: 'A classic burger',
          priceCents: 1500,
          currencyCode: 'USD',
          sectionName: 'Burgers',
        ),
      ];

      await repository.createOrder(restaurant: restaurant, items: menuItems);
      final orders = await repository.listOrders();

      expect(
        () => orders.add(orders.first),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });
}


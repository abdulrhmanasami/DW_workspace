/// Tests for FoodOrdersState and FoodOrdersController
///
/// Created by: Track C - Ticket #54
/// Purpose: Verify food orders state management behavior

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_shims/food_shims.dart';

import 'package:delivery_ways_clean/state/food/food_orders_state.dart';
import 'package:delivery_ways_clean/state/food/food_repository_provider.dart';
import 'package:delivery_ways_clean/state/food/app_food_repository.dart';

/// Mock FoodRepository for testing
class MockFoodRepository implements FoodRepository {
  final List<FoodOrder> _orders = [];

  @override
  Future<List<FoodRestaurant>> listRestaurants({
    String? query,
    FoodCategory? category,
  }) async {
    return [];
  }

  @override
  Future<List<FoodMenuItem>> getMenu({required String restaurantId}) async {
    return [];
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
  group('FoodOrdersState', () {
    test('initial state has empty orders', () {
      const state = FoodOrdersState();

      expect(state.orders, isEmpty);
      expect(state.isLoading, isFalse);
    });

    test('copyWith preserves values when not specified', () {
      final state = FoodOrdersState(
        orders: [
          FoodOrder(
            id: 'test1',
            restaurantId: 'rest1',
            restaurantName: 'Test Restaurant',
            items: const [],
            totalAmountCents: 1000,
            currencyCode: 'USD',
            status: FoodOrderStatus.pending,
            createdAt: DateTime(2024, 1, 1),
          ),
        ],
        isLoading: true,
      );

      final newState = state.copyWith();

      expect(newState.orders.length, equals(1));
      expect(newState.isLoading, isTrue);
    });

    test('copyWith updates orders when specified', () {
      const state = FoodOrdersState();
      final newOrders = [
        FoodOrder(
          id: 'test1',
          restaurantId: 'rest1',
          restaurantName: 'Test Restaurant',
          items: const [],
          totalAmountCents: 1000,
          currencyCode: 'USD',
          status: FoodOrderStatus.pending,
          createdAt: DateTime(2024, 1, 1),
        ),
      ];

      final newState = state.copyWith(orders: newOrders);

      expect(newState.orders.length, equals(1));
    });

    test('copyWith updates isLoading when specified', () {
      const state = FoodOrdersState();

      final newState = state.copyWith(isLoading: true);

      expect(newState.isLoading, isTrue);
    });

    test('equality compares orders correctly', () {
      final order = FoodOrder(
        id: 'test1',
        restaurantId: 'rest1',
        restaurantName: 'Test Restaurant',
        items: const [],
        totalAmountCents: 1000,
        currencyCode: 'USD',
        status: FoodOrderStatus.pending,
        createdAt: DateTime(2024, 1, 1),
      );

      final state1 = FoodOrdersState(orders: [order]);
      final state2 = FoodOrdersState(orders: [order]);

      expect(state1, equals(state2));
    });
  });

  group('FoodOrdersController', () {
    late ProviderContainer container;
    late MockFoodRepository mockRepository;

    setUp(() {
      mockRepository = MockFoodRepository();
      container = ProviderContainer(
        overrides: [
          foodRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state has empty orders', () {
      final state = container.read(foodOrdersControllerProvider);

      expect(state.orders, isEmpty);
      expect(state.isLoading, isFalse);
    });

    test('createOrderFromItems adds order to state', () async {
      const restaurant = FoodRestaurant(
        id: 'rest_1',
        name: 'Test Restaurant',
        cuisine: 'Test',
        rating: 4.5,
        ratingCount: 100,
        estimatedDeliveryMinutes: 30,
      );
      const menuItems = [
        FoodMenuItem(
          id: 'item_1',
          restaurantId: 'rest_1',
          name: 'Test Item',
          description: 'A test item',
          priceCents: 1500,
          currencyCode: 'USD',
          sectionName: 'Main',
        ),
      ];

      final controller =
          container.read(foodOrdersControllerProvider.notifier);

      final order = await controller.createOrderFromItems(
        restaurant: restaurant,
        items: menuItems,
      );

      final state = container.read(foodOrdersControllerProvider);

      expect(state.orders, isNotEmpty);
      expect(state.orders.first.id, equals(order.id));
    });

    test('createOrderFromItems returns the created order', () async {
      const restaurant = FoodRestaurant(
        id: 'rest_1',
        name: 'Test Restaurant',
        cuisine: 'Test',
        rating: 4.5,
        ratingCount: 100,
        estimatedDeliveryMinutes: 30,
      );
      const menuItems = [
        FoodMenuItem(
          id: 'item_1',
          restaurantId: 'rest_1',
          name: 'Test Item',
          description: 'A test item',
          priceCents: 1500,
          currencyCode: 'USD',
          sectionName: 'Main',
        ),
      ];

      final controller =
          container.read(foodOrdersControllerProvider.notifier);

      final order = await controller.createOrderFromItems(
        restaurant: restaurant,
        items: menuItems,
      );

      expect(order.restaurantId, equals('rest_1'));
      expect(order.restaurantName, equals('Test Restaurant'));
      expect(order.totalAmountCents, equals(1500));
    });

    test('multiple orders are added most recent first', () async {
      const restaurant = FoodRestaurant(
        id: 'rest_1',
        name: 'Test Restaurant',
        cuisine: 'Test',
        rating: 4.5,
        ratingCount: 100,
        estimatedDeliveryMinutes: 30,
      );
      const menuItems = [
        FoodMenuItem(
          id: 'item_1',
          restaurantId: 'rest_1',
          name: 'Test Item',
          description: 'A test item',
          priceCents: 1500,
          currencyCode: 'USD',
          sectionName: 'Main',
        ),
      ];

      final controller =
          container.read(foodOrdersControllerProvider.notifier);

      final order1 = await controller.createOrderFromItems(
        restaurant: restaurant,
        items: menuItems,
      );
      final order2 = await controller.createOrderFromItems(
        restaurant: restaurant,
        items: menuItems,
      );

      final state = container.read(foodOrdersControllerProvider);

      expect(state.orders.length, equals(2));
      expect(state.orders[0].id, equals(order2.id)); // Most recent first
      expect(state.orders[1].id, equals(order1.id));
    });

    test('refresh loads orders from repository', () async {
      const restaurant = FoodRestaurant(
        id: 'rest_1',
        name: 'Test Restaurant',
        cuisine: 'Test',
        rating: 4.5,
        ratingCount: 100,
        estimatedDeliveryMinutes: 30,
      );
      const menuItems = [
        FoodMenuItem(
          id: 'item_1',
          restaurantId: 'rest_1',
          name: 'Test Item',
          description: 'A test item',
          priceCents: 1500,
          currencyCode: 'USD',
          sectionName: 'Main',
        ),
      ];

      // Create order directly in mock repository
      await mockRepository.createOrder(
        restaurant: restaurant,
        items: menuItems,
      );

      final controller =
          container.read(foodOrdersControllerProvider.notifier);

      // Initially state should be empty (hasn't loaded from repo)
      var state = container.read(foodOrdersControllerProvider);
      expect(state.orders, isEmpty);

      // Refresh to load from repository
      await controller.refresh();

      state = container.read(foodOrdersControllerProvider);
      expect(state.orders.length, equals(1));
    });
  });

  group('FoodOrdersController with real AppFoodRepository', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          foodRepositoryProvider.overrideWithValue(AppFoodRepository()),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('integration: createOrderFromItems works with real repository',
        () async {
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

      final controller =
          container.read(foodOrdersControllerProvider.notifier);

      final order = await controller.createOrderFromItems(
        restaurant: restaurant,
        items: menuItems,
      );

      expect(order.restaurantName, equals('Burger Corner'));
      expect(order.totalAmountCents, equals(2000));
      expect(order.status, equals(FoodOrderStatus.pending));

      final state = container.read(foodOrdersControllerProvider);
      expect(state.orders.length, equals(1));
    });
  });
}


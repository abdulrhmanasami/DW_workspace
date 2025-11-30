/// Tests for FoodCartState and FoodCartController
///
/// Created by: Track C - Ticket #53
/// Purpose: Verify local cart functionality for Food ordering MVP.

import 'package:flutter_test/flutter_test.dart';
import 'package:food_shims/food_shims.dart';
import 'package:delivery_ways_clean/state/food/food_cart_state.dart';

void main() {
  // Test menu items
  const testItem1 = FoodMenuItem(
    id: 'item_1',
    restaurantId: 'rest_1',
    name: 'Classic Burger',
    description: 'Beef patty with cheese',
    priceCents: 2500,
    currencyCode: 'USD',
    sectionName: 'Burgers',
  );

  const testItem2 = FoodMenuItem(
    id: 'item_2',
    restaurantId: 'rest_1',
    name: 'Fries',
    description: 'Crispy french fries',
    priceCents: 1000,
    currencyCode: 'USD',
    sectionName: 'Sides',
  );

  const testItem3 = FoodMenuItem(
    id: 'item_3',
    restaurantId: 'rest_1',
    name: 'Drink',
    description: 'Soft drink',
    priceCents: 500,
    currencyCode: 'USD',
    sectionName: 'Drinks',
  );

  group('FoodCartItem', () {
    test('creates with correct properties', () {
      final item = FoodCartItem(menuItem: testItem1, quantity: 2);

      expect(item.menuItem, equals(testItem1));
      expect(item.quantity, equals(2));
    });

    test('copyWith updates quantity', () {
      final item = FoodCartItem(menuItem: testItem1, quantity: 1);
      final updated = item.copyWith(quantity: 3);

      expect(updated.quantity, equals(3));
      expect(updated.menuItem, equals(testItem1));
    });

    test('copyWith preserves quantity when not specified', () {
      final item = FoodCartItem(menuItem: testItem1, quantity: 5);
      final updated = item.copyWith();

      expect(updated.quantity, equals(5));
    });

    test('equality works correctly', () {
      final item1 = FoodCartItem(menuItem: testItem1, quantity: 2);
      final item2 = FoodCartItem(menuItem: testItem1, quantity: 2);
      final item3 = FoodCartItem(menuItem: testItem1, quantity: 3);
      final item4 = FoodCartItem(menuItem: testItem2, quantity: 2);

      expect(item1, equals(item2));
      expect(item1, isNot(equals(item3)));
      expect(item1, isNot(equals(item4)));
    });
  });

  group('FoodCartState', () {
    test('initial state has empty items', () {
      const state = FoodCartState();

      expect(state.items, isEmpty);
      expect(state.totalItems, equals(0));
      expect(state.totalPrice, equals(0.0));
    });

    test('totalItems sums quantities', () {
      final state = FoodCartState(items: [
        FoodCartItem(menuItem: testItem1, quantity: 2),
        FoodCartItem(menuItem: testItem2, quantity: 3),
      ]);

      expect(state.totalItems, equals(5));
    });

    test('totalPrice calculates correctly', () {
      final state = FoodCartState(items: [
        FoodCartItem(menuItem: testItem1, quantity: 2), // 2 * 25.00 = 50.00
        FoodCartItem(menuItem: testItem2, quantity: 1), // 1 * 10.00 = 10.00
      ]);

      expect(state.totalPrice, equals(60.0));
    });

    test('quantityOf returns correct quantity', () {
      final state = FoodCartState(items: [
        FoodCartItem(menuItem: testItem1, quantity: 3),
        FoodCartItem(menuItem: testItem2, quantity: 1),
      ]);

      expect(state.quantityOf('item_1'), equals(3));
      expect(state.quantityOf('item_2'), equals(1));
      expect(state.quantityOf('item_3'), equals(0));
    });

    test('copyWith updates items', () {
      const state = FoodCartState();
      final updated = state.copyWith(items: [
        FoodCartItem(menuItem: testItem1, quantity: 1),
      ]);

      expect(updated.items, hasLength(1));
    });

    test('equality works correctly', () {
      final state1 = FoodCartState(items: [
        FoodCartItem(menuItem: testItem1, quantity: 2),
      ]);
      final state2 = FoodCartState(items: [
        FoodCartItem(menuItem: testItem1, quantity: 2),
      ]);
      final state3 = FoodCartState(items: [
        FoodCartItem(menuItem: testItem1, quantity: 3),
      ]);

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });
  });

  group('FoodCartController', () {
    late FoodCartController controller;

    setUp(() {
      controller = FoodCartController();
    });

    test('initial state is empty', () {
      expect(controller.state.items, isEmpty);
      expect(controller.state.totalItems, equals(0));
      expect(controller.state.totalPrice, equals(0.0));
    });

    test('addItem adds new item with quantity 1', () {
      controller.addItem(testItem1);

      expect(controller.state.items, hasLength(1));
      expect(controller.state.totalItems, equals(1));
      expect(controller.state.items[0].menuItem.id, equals('item_1'));
      expect(controller.state.items[0].quantity, equals(1));
    });

    test('addItem increments quantity for existing item', () {
      controller.addItem(testItem1);
      controller.addItem(testItem1);

      expect(controller.state.items, hasLength(1));
      expect(controller.state.totalItems, equals(2));
      expect(controller.state.items[0].quantity, equals(2));
    });

    test('addItem adds different items separately', () {
      controller.addItem(testItem1);
      controller.addItem(testItem2);

      expect(controller.state.items, hasLength(2));
      expect(controller.state.totalItems, equals(2));
    });

    test('totalPrice updates correctly after adding items', () {
      controller.addItem(testItem1); // 25.00
      controller.addItem(testItem2); // 10.00
      controller.addItem(testItem1); // 25.00 more

      expect(controller.state.totalPrice, equals(60.0)); // 50 + 10
    });

    test('removeOne decrements quantity', () {
      controller.addItem(testItem1);
      controller.addItem(testItem1);
      controller.removeOne(testItem1);

      expect(controller.state.items, hasLength(1));
      expect(controller.state.items[0].quantity, equals(1));
    });

    test('removeOne removes item when quantity reaches 0', () {
      controller.addItem(testItem1);
      controller.removeOne(testItem1);

      expect(controller.state.items, isEmpty);
      expect(controller.state.totalItems, equals(0));
    });

    test('removeOne does nothing for non-existent item', () {
      controller.addItem(testItem1);
      controller.removeOne(testItem2);

      expect(controller.state.items, hasLength(1));
      expect(controller.state.items[0].menuItem.id, equals('item_1'));
    });

    test('removeItem removes all units of an item', () {
      controller.addItem(testItem1);
      controller.addItem(testItem1);
      controller.addItem(testItem1);
      controller.removeItem(testItem1);

      expect(controller.state.items, isEmpty);
    });

    test('clear empties the cart', () {
      controller.addItem(testItem1);
      controller.addItem(testItem2);
      controller.addItem(testItem3);
      controller.clear();

      expect(controller.state.items, isEmpty);
      expect(controller.state.totalItems, equals(0));
      expect(controller.state.totalPrice, equals(0.0));
    });

    test('complex cart operations work correctly', () {
      // Add items
      controller.addItem(testItem1); // 1 burger
      controller.addItem(testItem1); // 2 burgers
      controller.addItem(testItem2); // 1 fries
      controller.addItem(testItem3); // 1 drink
      controller.addItem(testItem3); // 2 drinks

      expect(controller.state.totalItems, equals(5));
      // 2*25 + 1*10 + 2*5 = 50 + 10 + 10 = 70
      expect(controller.state.totalPrice, equals(70.0));

      // Remove one burger
      controller.removeOne(testItem1); // 1 burger left

      expect(controller.state.totalItems, equals(4));
      // 1*25 + 1*10 + 2*5 = 25 + 10 + 10 = 45
      expect(controller.state.totalPrice, equals(45.0));

      // Remove all drinks
      controller.removeItem(testItem3);

      expect(controller.state.totalItems, equals(2));
      // 1*25 + 1*10 = 35
      expect(controller.state.totalPrice, equals(35.0));
    });
  });
}


/// Food Cart State and Controller for managing local cart.
///
/// Created by: Track C - Ticket #53
/// Purpose: Provides local cart functionality for Food ordering MVP.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_shims/food_shims.dart';

/// Represents a single item in the cart with quantity.
class FoodCartItem {
  const FoodCartItem({
    required this.menuItem,
    required this.quantity,
  });

  final FoodMenuItem menuItem;
  final int quantity;

  FoodCartItem copyWith({int? quantity}) {
    return FoodCartItem(
      menuItem: menuItem,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodCartItem &&
          runtimeType == other.runtimeType &&
          menuItem.id == other.menuItem.id &&
          quantity == other.quantity;

  @override
  int get hashCode => Object.hash(menuItem.id, quantity);

  @override
  String toString() =>
      'FoodCartItem(menuItem: ${menuItem.name}, quantity: $quantity)';
}

/// State representing the current cart contents.
class FoodCartState {
  const FoodCartState({
    this.items = const <FoodCartItem>[],
  });

  final List<FoodCartItem> items;

  /// Total number of items in the cart (sum of quantities).
  int get totalItems =>
      items.fold(0, (sum, item) => sum + item.quantity);

  /// Total price of all items in the cart.
  double get totalPrice => items.fold(
        0.0,
        (sum, item) => sum + item.menuItem.price * item.quantity,
      );

  /// Returns the quantity of a specific menu item in the cart.
  int quantityOf(String menuItemId) {
    final index = items.indexWhere((i) => i.menuItem.id == menuItemId);
    if (index == -1) return 0;
    return items[index].quantity;
  }

  FoodCartState copyWith({List<FoodCartItem>? items}) {
    return FoodCartState(
      items: items ?? this.items,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodCartState &&
          runtimeType == other.runtimeType &&
          _listEquals(items, other.items);

  @override
  int get hashCode => Object.hashAll(items);

  @override
  String toString() =>
      'FoodCartState(items: ${items.length}, total: $totalPrice)';

  static bool _listEquals(List<FoodCartItem> a, List<FoodCartItem> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Controller for managing cart operations.
class FoodCartController extends StateNotifier<FoodCartState> {
  FoodCartController() : super(const FoodCartState());

  /// Adds one unit of the menu item to the cart.
  /// If the item already exists, increments the quantity.
  void addItem(FoodMenuItem menuItem) {
    final items = List<FoodCartItem>.from(state.items);
    final index = items.indexWhere((i) => i.menuItem.id == menuItem.id);

    if (index == -1) {
      items.add(FoodCartItem(menuItem: menuItem, quantity: 1));
    } else {
      final existing = items[index];
      items[index] = existing.copyWith(quantity: existing.quantity + 1);
    }

    state = state.copyWith(items: items);
  }

  /// Removes one unit of the menu item from the cart.
  /// If quantity becomes 0, removes the item entirely.
  void removeOne(FoodMenuItem menuItem) {
    final items = List<FoodCartItem>.from(state.items);
    final index = items.indexWhere((i) => i.menuItem.id == menuItem.id);

    if (index == -1) return;

    final existing = items[index];
    if (existing.quantity <= 1) {
      items.removeAt(index);
    } else {
      items[index] = existing.copyWith(quantity: existing.quantity - 1);
    }

    state = state.copyWith(items: items);
  }

  /// Removes all units of a specific menu item from the cart.
  void removeItem(FoodMenuItem menuItem) {
    final items = List<FoodCartItem>.from(state.items);
    items.removeWhere((i) => i.menuItem.id == menuItem.id);
    state = state.copyWith(items: items);
  }

  /// Clears all items from the cart.
  void clear() {
    state = const FoodCartState(items: <FoodCartItem>[]);
  }
}

/// Provider for the food cart controller.
final foodCartControllerProvider =
    StateNotifierProvider<FoodCartController, FoodCartState>(
  (ref) => FoodCartController(),
);

/// Extension on FoodCartState to convert cart items to menu items list.
///
/// Track C - Ticket #54
extension FoodCartStateX on FoodCartState {
  /// Flattens cart items into a list of menu items,
  /// each item repeated by its quantity.
  ///
  /// Used when creating a FoodOrder from the cart.
  List<FoodMenuItem> asMenuItems() {
    final result = <FoodMenuItem>[];
    for (final cartItem in items) {
      for (var i = 0; i < cartItem.quantity; i++) {
        result.add(cartItem.menuItem);
      }
    }
    return result;
  }
}


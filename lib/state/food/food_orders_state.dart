/// Food Orders State and Controller for managing food orders.
///
/// Created by: Track C - Ticket #54
/// Purpose: Provides state management for Food orders in My Orders screen.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_shims/food_shims.dart';

import 'food_repository_provider.dart';

/// State representing the current food orders.
class FoodOrdersState {
  const FoodOrdersState({
    this.orders = const <FoodOrder>[],
    this.isLoading = false,
  });

  /// List of food orders, most recent first.
  final List<FoodOrder> orders;

  /// Whether orders are being loaded.
  final bool isLoading;

  FoodOrdersState copyWith({
    List<FoodOrder>? orders,
    bool? isLoading,
  }) {
    return FoodOrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodOrdersState &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          _listEquals(orders, other.orders);

  @override
  int get hashCode => Object.hash(isLoading, Object.hashAll(orders));

  static bool _listEquals(List<FoodOrder> a, List<FoodOrder> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Controller for managing food orders operations.
class FoodOrdersController extends StateNotifier<FoodOrdersState> {
  FoodOrdersController(this._ref) : super(const FoodOrdersState());

  final Ref _ref;

  FoodRepository get _repository => _ref.read(foodRepositoryProvider);

  /// Refresh orders from the repository.
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    try {
      final list = await _repository.listOrders();
      state = state.copyWith(orders: list, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Create a new order from the given restaurant and menu items.
  ///
  /// Returns the created [FoodOrder].
  Future<FoodOrder> createOrderFromItems({
    required FoodRestaurant restaurant,
    required List<FoodMenuItem> items,
  }) async {
    final order = await _repository.createOrder(
      restaurant: restaurant,
      items: items,
    );
    // Update local cache with new order at the front
    final updated = [order, ...state.orders];
    state = state.copyWith(orders: updated);
    return order;
  }
}

/// Provider for the food orders controller.
///
/// Track C - Ticket #54
final foodOrdersControllerProvider =
    StateNotifierProvider<FoodOrdersController, FoodOrdersState>(
  (ref) => FoodOrdersController(ref),
);


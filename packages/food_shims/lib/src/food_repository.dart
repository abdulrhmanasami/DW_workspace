import 'food_models.dart';

/// Port (abstract interface) for Food vertical.
///
/// Responsible for listing restaurants, menus, and creating food orders.
/// This follows the Ports/Adapters pattern - concrete implementations
/// can be in-memory (for MVP) or backend-connected (production).
///
/// Track C - Ticket #52
abstract class FoodRepository {
  /// Returns a list of nearby restaurants, optionally filtered by query/category.
  ///
  /// [query] - Optional search text to filter by restaurant name or cuisine
  /// [category] - Optional category to filter by
  Future<List<FoodRestaurant>> listRestaurants({
    String? query,
    FoodCategory? category,
  });

  /// Returns the menu items for a given restaurant.
  ///
  /// [restaurantId] - The ID of the restaurant to get the menu for
  /// Track C - Ticket #53
  Future<List<FoodMenuItem>> getMenu({
    required String restaurantId,
  });

  /// Creates a new food order from the given restaurant and items.
  ///
  /// [restaurant] - The restaurant to order from
  /// [items] - List of menu items to order (can contain duplicates for quantity)
  /// Track C - Ticket #54
  Future<FoodOrder> createOrder({
    required FoodRestaurant restaurant,
    required List<FoodMenuItem> items,
  });

  /// Returns all food orders, most recent first.
  ///
  /// Track C - Ticket #54
  Future<List<FoodOrder>> listOrders();
}


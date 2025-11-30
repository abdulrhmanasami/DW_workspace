/// App-side in-memory implementation of FoodRepository for MVP.
///
/// Created by: Track C - Ticket #52
/// Purpose: Provides stub data for Food Restaurants List screen.
/// Later can be replaced with real backend integration.

import 'package:food_shims/food_shims.dart';

/// App-side in-memory implementation of FoodRepository for MVP.
/// لاحقاً يمكن استبداله بتكامل حقيقي مع الـ backend.
class AppFoodRepository implements FoodRepository {
  AppFoodRepository({
    List<FoodRestaurant>? seedRestaurants,
  }) : _restaurants = List<FoodRestaurant>.from(
          seedRestaurants ?? _defaultRestaurants,
        );

  final List<FoodRestaurant> _restaurants;
  final List<FoodOrder> _orders = <FoodOrder>[];

  @override
  Future<List<FoodRestaurant>> listRestaurants({
    String? query,
    FoodCategory? category,
  }) async {
    Iterable<FoodRestaurant> result = _restaurants;

    if (category != null) {
      result = result.where(
        (r) => r.categories.any((c) => c.id == category.id),
      );
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase().trim();
      result = result.where(
        (r) =>
            r.name.toLowerCase().contains(q) ||
            r.cuisine.toLowerCase().contains(q),
      );
    }

    return result.toList(growable: false);
  }

  @override
  Future<List<FoodMenuItem>> getMenu({
    required String restaurantId,
  }) async {
    // Return menu based on restaurant ID
    // In production, this would call a backend API
    return _defaultMenus[restaurantId] ?? const <FoodMenuItem>[];
  }

  @override
  Future<FoodOrder> createOrder({
    required FoodRestaurant restaurant,
    required List<FoodMenuItem> items,
  }) async {
    // Group items by ID and calculate quantities
    final itemCounts = <String, int>{};
    final itemMap = <String, FoodMenuItem>{};

    for (final item in items) {
      itemCounts[item.id] = (itemCounts[item.id] ?? 0) + 1;
      itemMap[item.id] = item;
    }

    // Build order items with proper quantities
    final orderItems = <FoodOrderItem>[];
    int totalCents = 0;

    for (final entry in itemCounts.entries) {
      final menuItem = itemMap[entry.key]!;
      final quantity = entry.value;

      orderItems.add(
        FoodOrderItem(
          menuItemId: menuItem.id,
          name: menuItem.name,
          quantity: quantity,
          unitPriceCents: menuItem.priceCents,
          currencyCode: menuItem.currencyCode,
        ),
      );

      totalCents += menuItem.priceCents * quantity;
    }

    final now = DateTime.now();
    final order = FoodOrder(
      id: 'food_order_${now.microsecondsSinceEpoch}',
      restaurantId: restaurant.id,
      restaurantName: restaurant.name,
      items: orderItems,
      totalAmountCents: totalCents,
      currencyCode: items.isNotEmpty ? items.first.currencyCode : 'USD',
      status: FoodOrderStatus.pending,
      createdAt: now,
    );

    _orders.insert(0, order);
    return order;
  }

  @override
  Future<List<FoodOrder>> listOrders() async {
    return List<FoodOrder>.unmodifiable(_orders);
  }
}

/// Seed menu data for local development.
/// ⚠️ هذه بيانات in-memory فقط، لا تُعتبر production data.
/// Track C - Ticket #53
const Map<String, List<FoodMenuItem>> _defaultMenus = {
  'rest_1': [
    // Burger Corner
    FoodMenuItem(
      id: 'item_burger_1',
      restaurantId: 'rest_1',
      name: 'Classic Burger',
      description: 'Beef patty, cheese, lettuce, tomato, pickles.',
      priceCents: 2800,
      currencyCode: 'USD',
      sectionName: 'Burgers',
    ),
    FoodMenuItem(
      id: 'item_burger_2',
      restaurantId: 'rest_1',
      name: 'Double Cheeseburger',
      description: 'Two beef patties with double cheese and special sauce.',
      priceCents: 3800,
      currencyCode: 'USD',
      sectionName: 'Burgers',
    ),
    FoodMenuItem(
      id: 'item_fries_1',
      restaurantId: 'rest_1',
      name: 'Fries',
      description: 'Crispy french fries.',
      priceCents: 1200,
      currencyCode: 'USD',
      sectionName: 'Sides',
    ),
    FoodMenuItem(
      id: 'item_drink_1',
      restaurantId: 'rest_1',
      name: 'Soft Drink',
      description: 'Choice of Coke, Sprite, or Fanta.',
      priceCents: 500,
      currencyCode: 'USD',
      sectionName: 'Drinks',
    ),
  ],
  'rest_2': [
    // Pizza Palace
    FoodMenuItem(
      id: 'item_pizza_1',
      restaurantId: 'rest_2',
      name: 'Margherita Pizza',
      description: 'Fresh tomato sauce, mozzarella, and basil.',
      priceCents: 3500,
      currencyCode: 'USD',
      sectionName: 'Pizzas',
    ),
    FoodMenuItem(
      id: 'item_pizza_2',
      restaurantId: 'rest_2',
      name: 'Pepperoni Pizza',
      description: 'Classic pepperoni with melted cheese.',
      priceCents: 4000,
      currencyCode: 'USD',
      sectionName: 'Pizzas',
    ),
    FoodMenuItem(
      id: 'item_pasta_1',
      restaurantId: 'rest_2',
      name: 'Spaghetti Carbonara',
      description: 'Creamy pasta with bacon and parmesan.',
      priceCents: 3200,
      currencyCode: 'USD',
      sectionName: 'Pasta',
    ),
  ],
  'rest_3': [
    // Sushi Express
    FoodMenuItem(
      id: 'item_sushi_1',
      restaurantId: 'rest_3',
      name: 'Salmon Nigiri (2 pcs)',
      description: 'Fresh salmon over pressed rice.',
      priceCents: 1800,
      currencyCode: 'USD',
      sectionName: 'Nigiri',
    ),
    FoodMenuItem(
      id: 'item_sushi_2',
      restaurantId: 'rest_3',
      name: 'California Roll (8 pcs)',
      description: 'Crab, avocado, and cucumber.',
      priceCents: 2400,
      currencyCode: 'USD',
      sectionName: 'Rolls',
    ),
  ],
};

/// Seed data for local development.
/// ⚠️ هذه بيانات in-memory فقط، لا تُعتبر production data.
const List<FoodRestaurant> _defaultRestaurants = <FoodRestaurant>[
  FoodRestaurant(
    id: 'rest_1',
    name: 'Burger Corner',
    cuisine: 'Burgers',
    rating: 4.6,
    ratingCount: 124,
    estimatedDeliveryMinutes: 30,
    categories: [
      FoodCategory(id: 'burgers', label: 'Burgers'),
    ],
  ),
  FoodRestaurant(
    id: 'rest_2',
    name: 'Pizza Palace',
    cuisine: 'Italian',
    rating: 4.8,
    ratingCount: 256,
    estimatedDeliveryMinutes: 35,
    categories: [
      FoodCategory(id: 'italian', label: 'Italian'),
    ],
  ),
  FoodRestaurant(
    id: 'rest_3',
    name: 'Sushi Express',
    cuisine: 'Japanese',
    rating: 4.5,
    ratingCount: 89,
    estimatedDeliveryMinutes: 40,
    categories: [
      FoodCategory(id: 'japanese', label: 'Japanese'),
    ],
  ),
  FoodRestaurant(
    id: 'rest_4',
    name: 'Taco Fiesta',
    cuisine: 'Mexican',
    rating: 4.3,
    ratingCount: 167,
    estimatedDeliveryMinutes: 25,
    categories: [
      FoodCategory(id: 'mexican', label: 'Mexican'),
    ],
  ),
  FoodRestaurant(
    id: 'rest_5',
    name: 'Grill House',
    cuisine: 'Burgers',
    rating: 4.7,
    ratingCount: 203,
    estimatedDeliveryMinutes: 28,
    categories: [
      FoodCategory(id: 'burgers', label: 'Burgers'),
    ],
  ),
];


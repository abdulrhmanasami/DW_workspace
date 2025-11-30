import 'package:meta/meta.dart';

/// Category for food restaurants filtering.
///
/// Track C - Ticket #52
@immutable
class FoodCategory {
  const FoodCategory({
    required this.id,
    required this.label,
  });

  /// Unique identifier for the category (e.g. "burgers", "italian")
  final String id;

  /// Display label for the category (e.g. "Burgers", "Italian")
  final String label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodCategory &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Restaurant model for Food delivery vertical.
///
/// Contains basic info displayed in the restaurants list (Screen 13).
/// Track C - Ticket #52
@immutable
class FoodRestaurant {
  const FoodRestaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.rating,
    required this.ratingCount,
    required this.estimatedDeliveryMinutes,
    this.heroImageUrl,
    this.categories = const <FoodCategory>[],
  });

  /// Unique identifier for the restaurant
  final String id;

  /// Restaurant name
  final String name;

  /// Primary cuisine type (e.g. "Burgers", "Italian")
  final String cuisine;

  /// Average rating (0.0 - 5.0)
  final double rating;

  /// Number of ratings
  final int ratingCount;

  /// Estimated delivery time in minutes
  final int estimatedDeliveryMinutes;

  /// Optional hero image URL for the restaurant
  final String? heroImageUrl;

  /// Categories this restaurant belongs to
  final List<FoodCategory> categories;
}

/// Menu item model for Food delivery vertical.
///
/// Represents a single item on a restaurant's menu.
/// Track C - Ticket #53
@immutable
class FoodMenuItem {
  const FoodMenuItem({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.priceCents,
    required this.currencyCode,
    required this.sectionName,
  });

  /// Unique identifier for the menu item
  final String id;

  /// ID of the restaurant this item belongs to
  final String restaurantId;

  /// Item name (e.g. "Classic Burger")
  final String name;

  /// Item description
  final String description;

  /// Price in cents (e.g. 2800 = $28.00)
  final int priceCents;

  /// Currency code (e.g. "USD", "SAR")
  final String currencyCode;

  /// Section name for grouping (e.g. "Burgers", "Drinks", "Sides")
  final String sectionName;

  /// Price as a decimal value
  double get price => priceCents / 100.0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodMenuItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// ============================================================================
// Food Order Domain Models - Track C - Ticket #54
// ============================================================================

/// Status of a food order.
///
/// Track C - Ticket #54
enum FoodOrderStatus {
  /// Order is being processed
  pending,

  /// Restaurant is preparing the order
  inPreparation,

  /// Order is on the way to the customer
  onTheWay,

  /// Order has been delivered
  delivered,

  /// Order was cancelled
  cancelled,
}

/// Single item in a food order with quantity.
///
/// Track C - Ticket #54
@immutable
class FoodOrderItem {
  const FoodOrderItem({
    required this.menuItemId,
    required this.name,
    required this.quantity,
    required this.unitPriceCents,
    required this.currencyCode,
  });

  /// ID of the original menu item
  final String menuItemId;

  /// Name of the item
  final String name;

  /// Number of units ordered
  final int quantity;

  /// Price per unit in cents
  final int unitPriceCents;

  /// Currency code (e.g. "USD", "SAR")
  final String currencyCode;

  /// Unit price as decimal
  double get unitPrice => unitPriceCents / 100.0;

  /// Total price for this line item (quantity × unit price)
  double get lineTotal => (unitPriceCents * quantity) / 100.0;

  /// Total price in cents for this line item
  int get lineTotalCents => unitPriceCents * quantity;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodOrderItem &&
          runtimeType == other.runtimeType &&
          menuItemId == other.menuItemId &&
          quantity == other.quantity;

  @override
  int get hashCode => Object.hash(menuItemId, quantity);
}

/// A completed food order.
///
/// Track C - Ticket #54
@immutable
class FoodOrder {
  const FoodOrder({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.items,
    required this.totalAmountCents,
    required this.currencyCode,
    required this.status,
    required this.createdAt,
  });

  /// Unique order ID
  final String id;

  /// ID of the restaurant
  final String restaurantId;

  /// Name of the restaurant (for display)
  final String restaurantName;

  /// List of items in the order
  final List<FoodOrderItem> items;

  /// Total amount in cents
  final int totalAmountCents;

  /// Currency code (e.g. "USD", "SAR")
  final String currencyCode;

  /// Current status of the order
  final FoodOrderStatus status;

  /// When the order was created
  final DateTime createdAt;

  /// Total amount as decimal
  double get totalAmount => totalAmountCents / 100.0;

  /// Total number of items (sum of quantities)
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodOrder &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

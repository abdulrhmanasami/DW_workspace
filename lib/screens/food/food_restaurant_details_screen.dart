/// Food Restaurant Details Screen (Screen 14)
///
/// Created by: Track C - Ticket #53
/// Purpose: Display restaurant details with menu and local cart functionality.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart'
    show DWSpacing, DWRadius;
import 'package:food_shims/food_shims.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../state/food/food_menu_providers.dart';
import '../../state/food/food_cart_state.dart';
import '../../state/food/food_orders_state.dart';

/// Screen displaying restaurant details, menu, and cart summary.
///
/// Features:
/// - Restaurant header with name, cuisine, rating, and delivery time
/// - Menu list grouped by section
/// - Add to cart functionality
/// - Bottom cart summary bar with checkout CTA
class FoodRestaurantDetailsScreen extends ConsumerWidget {
  const FoodRestaurantDetailsScreen({
    super.key,
    required this.restaurant,
  });

  final FoodRestaurant restaurant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cartState = ref.watch(foodCartControllerProvider);
    final cartController = ref.read(foodCartControllerProvider.notifier);
    final menuAsync = ref.watch(restaurantMenuProvider(restaurant.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(restaurant.name),
      ),
      body: Column(
        children: [
          _RestaurantHeader(restaurant: restaurant),
          Expanded(
            child: menuAsync.when(
              data: (items) => _MenuList(
                items: items,
                cartState: cartState,
                onAdd: cartController.addItem,
                onRemove: cartController.removeOne,
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(DWSpacing.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: DWSpacing.sm),
                      Text(
                        l10n.foodRestaurantMenuError,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: cartState.totalItems == 0
          ? null
          : _CartSummaryBar(
              cartState: cartState,
              onCheckout: () async {
                final ordersController =
                    ref.read(foodOrdersControllerProvider.notifier);

                final items = cartState.asMenuItems();
                if (items.isEmpty) return;

                final order = await ordersController.createOrderFromItems(
                  restaurant: restaurant,
                  items: items,
                );

                // Clear the cart after successful order creation
                cartController.clear();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.foodCartOrderCreatedSnackbar(
                          order.restaurantName,
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
    );
  }
}

/// Restaurant header with basic info.
class _RestaurantHeader extends StatelessWidget {
  const _RestaurantHeader({required this.restaurant});

  final FoodRestaurant restaurant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(DWSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            restaurant.name,
            style: textTheme.headlineSmall,
          ),
          const SizedBox(height: DWSpacing.xs),
          Text(
            restaurant.cuisine,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: DWSpacing.sm),
          Row(
            children: [
              Icon(
                Icons.star,
                size: 18,
                color: colorScheme.primary,
              ),
              const SizedBox(width: DWSpacing.xxs),
              Text(
                restaurant.rating.toStringAsFixed(1),
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: DWSpacing.xxs),
              Text(
                '(${restaurant.ratingCount})',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: DWSpacing.md),
              Icon(
                Icons.access_time,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: DWSpacing.xxs),
              Text(
                '${restaurant.estimatedDeliveryMinutes} min',
                style: textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Menu list grouped by section.
class _MenuList extends StatelessWidget {
  const _MenuList({
    required this.items,
    required this.cartState,
    required this.onAdd,
    required this.onRemove,
  });

  final List<FoodMenuItem> items;
  final FoodCartState cartState;
  final ValueChanged<FoodMenuItem> onAdd;
  final ValueChanged<FoodMenuItem> onRemove;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(DWSpacing.lg),
          child: Text(
            'No menu items available',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      );
    }

    // Group items by sectionName
    final sections = <String, List<FoodMenuItem>>{};
    for (final item in items) {
      sections.putIfAbsent(item.sectionName, () => []).add(item);
    }

    final sectionEntries = sections.entries.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(DWSpacing.md),
      itemCount: sectionEntries.length,
      itemBuilder: (context, index) {
        final entry = sectionEntries[index];
        return _MenuSection(
          title: entry.key,
          items: entry.value,
          cartState: cartState,
          onAdd: onAdd,
          onRemove: onRemove,
        );
      },
    );
  }
}

/// A section of menu items with a title.
class _MenuSection extends StatelessWidget {
  const _MenuSection({
    required this.title,
    required this.items,
    required this.cartState,
    required this.onAdd,
    required this.onRemove,
  });

  final String title;
  final List<FoodMenuItem> items;
  final FoodCartState cartState;
  final ValueChanged<FoodMenuItem> onAdd;
  final ValueChanged<FoodMenuItem> onRemove;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: DWSpacing.sm),
        ...items.map(
          (item) => _MenuItemTile(
            item: item,
            quantity: cartState.quantityOf(item.id),
            onAdd: onAdd,
            onRemove: onRemove,
          ),
        ),
        const SizedBox(height: DWSpacing.lg),
      ],
    );
  }
}

/// A single menu item tile with add/remove controls.
class _MenuItemTile extends StatelessWidget {
  const _MenuItemTile({
    required this.item,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  final FoodMenuItem item;
  final int quantity;
  final ValueChanged<FoodMenuItem> onAdd;
  final ValueChanged<FoodMenuItem> onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: DWSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(DWSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: DWSpacing.xs),
                  Text(
                    item.description,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: DWSpacing.xs),
                  Text(
                    '${item.price.toStringAsFixed(2)} ${item.currencyCode}',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: DWSpacing.sm),
            _QuantityControls(
              quantity: quantity,
              onAdd: () => onAdd(item),
              onRemove: () => onRemove(item),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quantity controls for adding/removing items.
class _QuantityControls extends StatelessWidget {
  const _QuantityControls({
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (quantity == 0) {
      return FilledButton(
        onPressed: onAdd,
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 36),
          padding: const EdgeInsets.symmetric(horizontal: DWSpacing.sm),
        ),
        child: const Icon(Icons.add, size: 20),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DWRadius.md),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.remove, size: 18),
            constraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
            padding: EdgeInsets.zero,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DWSpacing.xs),
            child: Text(
              quantity.toString(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          IconButton(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 18),
            constraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

/// Bottom bar showing cart summary and checkout CTA.
class _CartSummaryBar extends StatelessWidget {
  const _CartSummaryBar({
    required this.cartState,
    required this.onCheckout,
  });

  final FoodCartState cartState;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      minimum: const EdgeInsets.all(DWSpacing.md),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: onCheckout,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: DWSpacing.lg,
              vertical: DWSpacing.md,
            ),
          ),
          child: Text(
            l10n.foodCartSummaryCta(
              cartState.totalItems.toString(),
              cartState.totalPrice.toStringAsFixed(2),
            ),
          ),
        ),
      ),
    );
  }
}


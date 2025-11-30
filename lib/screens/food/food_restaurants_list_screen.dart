/// Food Restaurants List Screen (Screen 13)
///
/// Created by: Track C - Ticket #52
/// Purpose: Display list of nearby restaurants with search and category filters.
/// Last updated: 2025-11-29

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart'
    show DWSpacing, DWRadius;
import 'package:food_shims/food_shims.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../state/food/food_restaurants_state.dart';
import 'food_restaurant_details_screen.dart';

/// Screen displaying the list of food restaurants.
///
/// Features:
/// - AppBar with title
/// - Search text field
/// - Category filter chips (All, Burgers, Italian, etc.)
/// - Restaurant cards list
/// - Empty state when no results
class FoodRestaurantsListScreen extends ConsumerWidget {
  const FoodRestaurantsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(foodRestaurantsControllerProvider);
    final controller = ref.read(foodRestaurantsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.foodRestaurantsAppBarTitle),
      ),
      body: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.all(DWSpacing.md),
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.foodRestaurantsSearchPlaceholder,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DWRadius.md),
                ),
              ),
              onChanged: controller.applyQuery,
            ),
          ),

          // Category filter chips
          _CategoriesChipsRow(
            selected: state.selectedCategory,
            onSelected: controller.selectCategory,
          ),

          const SizedBox(height: DWSpacing.sm),

          // Restaurants list
          Expanded(
            child: _RestaurantsList(state: state),
          ),
        ],
      ),
    );
  }
}

/// Horizontal scrollable row of category filter chips.
class _CategoriesChipsRow extends StatelessWidget {
  const _CategoriesChipsRow({
    required this.selected,
    required this.onSelected,
  });

  final FoodCategory? selected;
  final ValueChanged<FoodCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Define available categories
    final categories = <_CategoryItem>[
      _CategoryItem(id: 'all', label: l10n.foodRestaurantsFilterAll),
      _CategoryItem(id: 'burgers', label: l10n.foodRestaurantsFilterBurgers),
      _CategoryItem(id: 'italian', label: l10n.foodRestaurantsFilterItalian),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: DWSpacing.md),
      child: Row(
        children: categories.map((category) {
          final isAll = category.id == 'all';
          final isSelected =
              selected?.id == category.id || (selected == null && isAll);

          return Padding(
            padding: const EdgeInsets.only(right: DWSpacing.xs),
            child: ChoiceChip(
              label: Text(category.label),
              selected: isSelected,
              onSelected: (_) {
                onSelected(
                  isAll ? null : FoodCategory(id: category.id, label: category.label),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Helper class for category items in the chips row.
class _CategoryItem {
  const _CategoryItem({required this.id, required this.label});
  final String id;
  final String label;
}

/// List of restaurant cards with loading and empty states.
class _RestaurantsList extends StatelessWidget {
  const _RestaurantsList({required this.state});

  final FoodRestaurantsState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Loading state
    if (state.isLoading && state.restaurants.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Empty state
    if (state.restaurants.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(DWSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.restaurant_outlined,
                size: 48,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: DWSpacing.sm),
              Text(
                l10n.foodRestaurantsEmptyTitle,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: DWSpacing.xs),
              Text(
                l10n.foodRestaurantsEmptySubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Restaurant list
    return ListView.builder(
      padding: const EdgeInsets.all(DWSpacing.md),
      itemCount: state.restaurants.length,
      itemBuilder: (context, index) {
        final restaurant = state.restaurants[index];
        return _FoodRestaurantCard(restaurant: restaurant);
      },
    );
  }
}

/// Card widget displaying restaurant information.
class _FoodRestaurantCard extends StatelessWidget {
  const _FoodRestaurantCard({required this.restaurant});

  final FoodRestaurant restaurant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: DWSpacing.sm),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => FoodRestaurantDetailsScreen(
                restaurant: restaurant,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(DWRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(DWSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Restaurant name
              Text(
                restaurant.name,
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: DWSpacing.xs),

              // Cuisine type
              Text(
                restaurant.cuisine,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: DWSpacing.xs),

              // Rating and delivery time row
              Row(
                children: [
                  Icon(
                    Icons.star,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: DWSpacing.xxs),
                  Text(
                    restaurant.rating.toStringAsFixed(1),
                    style: textTheme.bodySmall,
                  ),
                  const SizedBox(width: DWSpacing.xxs),
                  Text(
                    '(${restaurant.ratingCount})',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: DWSpacing.xxs),
                  Text(
                    '${restaurant.estimatedDeliveryMinutes} min',
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


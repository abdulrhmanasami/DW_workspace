/// Food Menu Providers for restaurant menu data.
///
/// Created by: Track C - Ticket #53
/// Purpose: Provides FutureProvider for fetching restaurant menus.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_shims/food_shims.dart';

import 'food_repository_provider.dart';

/// Provider to fetch the menu for a specific restaurant.
///
/// Usage:
/// ```dart
/// final menuAsync = ref.watch(restaurantMenuProvider(restaurantId));
/// menuAsync.when(
///   data: (items) => ...,
///   loading: () => ...,
///   error: (e, s) => ...,
/// );
/// ```
final restaurantMenuProvider =
    FutureProvider.family<List<FoodMenuItem>, String>((ref, restaurantId) async {
  final repo = ref.read(foodRepositoryProvider);
  return repo.getMenu(restaurantId: restaurantId);
});


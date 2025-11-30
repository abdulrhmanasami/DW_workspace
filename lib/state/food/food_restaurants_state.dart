/// State and Controller for Food Restaurants List screen.
///
/// Created by: Track C - Ticket #52
/// Purpose: Manages restaurant list, loading state, search and filters.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_shims/food_shims.dart';

import 'food_repository_provider.dart';

/// State for the Food Restaurants List screen.
class FoodRestaurantsState {
  const FoodRestaurantsState({
    this.isLoading = false,
    this.restaurants = const <FoodRestaurant>[],
    this.query = '',
    this.selectedCategory,
  });

  /// Whether data is currently being loaded
  final bool isLoading;

  /// List of restaurants to display
  final List<FoodRestaurant> restaurants;

  /// Current search query
  final String query;

  /// Currently selected category filter (null = "All")
  final FoodCategory? selectedCategory;

  FoodRestaurantsState copyWith({
    bool? isLoading,
    List<FoodRestaurant>? restaurants,
    String? query,
    FoodCategory? selectedCategory,
    bool clearCategory = false,
  }) {
    return FoodRestaurantsState(
      isLoading: isLoading ?? this.isLoading,
      restaurants: restaurants ?? this.restaurants,
      query: query ?? this.query,
      selectedCategory:
          clearCategory ? null : (selectedCategory ?? this.selectedCategory),
    );
  }
}

/// Controller for the Food Restaurants List screen.
///
/// Manages loading, search, and filtering of restaurants.
class FoodRestaurantsController extends StateNotifier<FoodRestaurantsState> {
  FoodRestaurantsController(this._ref) : super(const FoodRestaurantsState());

  final Ref _ref;

  FoodRepository get _repository => _ref.read(foodRepositoryProvider);

  /// Load initial list of restaurants.
  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true);
    final list = await _repository.listRestaurants();
    state = state.copyWith(isLoading: false, restaurants: list);
  }

  /// Apply a search query filter.
  Future<void> applyQuery(String query) async {
    state = state.copyWith(query: query, isLoading: true);
    final list = await _repository.listRestaurants(
      query: query,
      category: state.selectedCategory,
    );
    state = state.copyWith(isLoading: false, restaurants: list);
  }

  /// Select a category filter.
  ///
  /// Pass `null` to clear the category filter (show all).
  Future<void> selectCategory(FoodCategory? category) async {
    state = state.copyWith(
      selectedCategory: category,
      clearCategory: category == null,
      isLoading: true,
    );
    final list = await _repository.listRestaurants(
      query: state.query,
      category: category,
    );
    state = state.copyWith(isLoading: false, restaurants: list);
  }
}

/// Provider for the FoodRestaurantsController.
///
/// Auto-loads initial data when first accessed.
final foodRestaurantsControllerProvider =
    StateNotifierProvider<FoodRestaurantsController, FoodRestaurantsState>(
  (ref) => FoodRestaurantsController(ref)..loadInitial(),
);


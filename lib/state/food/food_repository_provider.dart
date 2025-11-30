/// Provider for FoodRepository.
///
/// Created by: Track C - Ticket #52
/// Purpose: Exposes FoodRepository to the app via Riverpod.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_shims/food_shims.dart';

import 'app_food_repository.dart';

/// Provider for the FoodRepository port.
///
/// Defaults to [AppFoodRepository] (in-memory).
/// Can be overridden in tests or when backend is ready.
final foodRepositoryProvider = Provider<FoodRepository>((ref) {
  return AppFoodRepository();
});


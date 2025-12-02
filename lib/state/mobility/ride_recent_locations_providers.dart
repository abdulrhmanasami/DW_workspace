/// Recent Locations Providers - Track B Ticket #145
/// Purpose: Provide RecentLocationsRepository to the app layer via Riverpod
/// Created by: Track B - Ticket #145
/// Last updated: 2025-12-02

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobility_shims/mobility_shims.dart';

/// Track B - Ticket #145: Provide RecentLocationsRepository to the app layer.
/// 
/// This provider creates a singleton instance of the repository that
/// survives for the entire app lifecycle.
final recentLocationsRepositoryProvider =
    Provider<RecentLocationsRepository>((ref) {
  // Simple in-memory implementation for now.
  // Later we can swap this with a persistent implementation.
  final repo = InMemoryRecentLocationsRepository();
  
  // Initialize with empty state
  repo.init();
  
  // Clean up when provider is disposed
  ref.onDispose(repo.dispose);
  
  return repo;
});

/// Stream of recent locations for UI consumption.
/// 
/// This provider watches the repository's stream and provides
/// the list of recent locations to UI components.
final recentLocationsProvider =
    StreamProvider.autoDispose<List<RecentLocation>>((ref) {
  final repo = ref.watch(recentLocationsRepositoryProvider);
  return repo.watchRecentLocations();
});

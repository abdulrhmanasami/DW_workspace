/// Recent Locations Repository Interface - Track B Ticket #145
/// Purpose: Repository interface for managing recent ride locations
/// Created by: Track B - Ticket #145
/// Last updated: 2025-12-02
///
/// This repository provides an interface for managing recently visited locations
/// in the ride booking flow. Implementations can be in-memory (for session) or
/// persistent (for long-term storage).

import 'dart:async';
import '../place_models.dart';

/// Repository interface for managing recent ride locations.
/// Track B - Ticket #145
abstract class RecentLocationsRepository {
  /// Stream of most recent locations, ordered from most-recent to oldest.
  Stream<List<RecentLocation>> watchRecentLocations();

  /// Add or update a recent location (e.g., after a completed ride).
  Future<void> upsertRecentLocation(RecentLocation location);

  /// Remove all stored recent locations.
  Future<void> clearAll();
}

/// In-memory implementation of RecentLocationsRepository.
/// Track B - Ticket #145
/// 
/// This implementation stores recent locations in memory during app session.
/// Data is lost when app is terminated. For persistent storage, a different
/// implementation should be used.
class InMemoryRecentLocationsRepository implements RecentLocationsRepository {
  InMemoryRecentLocationsRepository({this.maxItems = 10});

  final int maxItems;

  final _controller = StreamController<List<RecentLocation>>.broadcast();
  final List<RecentLocation> _items = [];

  /// Initialize with empty list
  void init() {
    _controller.add(const []);
  }

  @override
  Stream<List<RecentLocation>> watchRecentLocations() => _controller.stream;

  @override
  Future<void> upsertRecentLocation(RecentLocation location) async {
    // Remove any existing entry with same id
    _items.removeWhere((it) => it.id == location.id);

    // Insert at start (most recent first)
    _items.insert(0, location);

    // Trim to maxItems
    if (_items.length > maxItems) {
      _items.removeRange(maxItems, _items.length);
    }

    _controller.add(List.unmodifiable(_items));
  }

  @override
  Future<void> clearAll() async {
    _items.clear();
    _controller.add(const []);
  }

  void dispose() {
    _controller.close();
  }
}

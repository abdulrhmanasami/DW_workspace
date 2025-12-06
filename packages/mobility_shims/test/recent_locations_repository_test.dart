/// RecentLocationsRepository Test Suite - Track B Ticket #145
/// Purpose: Test InMemoryRecentLocationsRepository behavior
/// Created by: Track B - Ticket #145
/// Last updated: 2025-12-02

import 'package:flutter_test/flutter_test.dart';
import 'package:mobility_shims/mobility_shims.dart';

void main() {
  group('InMemoryRecentLocationsRepository', () {
    late InMemoryRecentLocationsRepository repository;

    setUp(() {
      repository = InMemoryRecentLocationsRepository(maxItems: 5);
      repository.init();
    });

    tearDown(() {
      repository.dispose();
    });

    test('starts with empty list', () async {
      // Subscribe to stream first, then check it emits empty list
      expectLater(
        repository.watchRecentLocations(),
        emitsInOrder([[]]),
      );
    });

    test('adds new location to the list', () async {
      const location = RecentLocation(
        id: 'loc_1',
        title: 'Test Place',
        subtitle: 'Test Address',
        type: MobilityPlaceType.recent,
      );

      // Add location
      await repository.upsertRecentLocation(location);

      // Should emit list with one item
      expect(
        repository.watchRecentLocations(),
        emits([location]),
      );
    });

    test('updates existing location with same id', () async {
      const location1 = RecentLocation(
        id: 'loc_1',
        title: 'Old Title',
        subtitle: 'Old Address',
        type: MobilityPlaceType.recent,
      );

      const location2 = RecentLocation(
        id: 'loc_1', // Same ID
        title: 'New Title',
        subtitle: 'New Address',
        type: MobilityPlaceType.recent,
      );

      // Add first location
      await repository.upsertRecentLocation(location1);

      // Update with new data
      await repository.upsertRecentLocation(location2);

      // Should have only one item with updated data
      expect(
        repository.watchRecentLocations(),
        emits([location2]),
      );
    });

    test('maintains most recent first order', () async {
      const location1 = RecentLocation(
        id: 'loc_1',
        title: 'First Place',
        type: MobilityPlaceType.recent,
      );

      const location2 = RecentLocation(
        id: 'loc_2',
        title: 'Second Place',
        type: MobilityPlaceType.recent,
      );

      const location3 = RecentLocation(
        id: 'loc_3',
        title: 'Third Place',
        type: MobilityPlaceType.recent,
      );

      // Add locations in sequence
      await repository.upsertRecentLocation(location1);
      await repository.upsertRecentLocation(location2);
      await repository.upsertRecentLocation(location3);

      // Most recent should be first
      expect(
        repository.watchRecentLocations(),
        emits([location3, location2, location1]),
      );
    });

    test('respects maxItems limit', () async {
      // Repository is configured with maxItems = 5
      final locations = List.generate(
        10,
        (i) => RecentLocation(
          id: 'loc_$i',
          title: 'Place $i',
          type: MobilityPlaceType.recent,
        ),
      );

      // Add more than maxItems
      for (final location in locations) {
        await repository.upsertRecentLocation(location);
      }

      // Should only keep last 5 items (newest first)
      expect(
        repository.watchRecentLocations(),
        emitsThrough(
          predicate<List<RecentLocation>>((list) {
            return list.length == 5 &&
                list[0].id == 'loc_9' && // Most recent
                list[4].id == 'loc_5'; // Oldest kept
          }),
        ),
      );
    });

    test('clears all locations', () async {
      // Add some locations
      await repository.upsertRecentLocation(
        const RecentLocation(
          id: 'loc_1',
          title: 'Place 1',
          type: MobilityPlaceType.recent,
        ),
      );

      await repository.upsertRecentLocation(
        const RecentLocation(
          id: 'loc_2',
          title: 'Place 2',
          type: MobilityPlaceType.recent,
        ),
      );

      // Clear all
      await repository.clearAll();

      // Should emit empty list
      expect(
        repository.watchRecentLocations(),
        emits([]),
      );
    });

    test('moves existing location to top when re-added', () async {
      const location1 = RecentLocation(
        id: 'loc_1',
        title: 'Place 1',
        type: MobilityPlaceType.recent,
      );

      const location2 = RecentLocation(
        id: 'loc_2',
        title: 'Place 2',
        type: MobilityPlaceType.recent,
      );

      const location3 = RecentLocation(
        id: 'loc_3',
        title: 'Place 3',
        type: MobilityPlaceType.recent,
      );

      // Add three locations
      await repository.upsertRecentLocation(location1);
      await repository.upsertRecentLocation(location2);
      await repository.upsertRecentLocation(location3);

      // Re-add first location
      await repository.upsertRecentLocation(location1);

      // Location 1 should now be at the top
      expect(
        repository.watchRecentLocations(),
        emits([location1, location3, location2]),
      );
    });
  });
}

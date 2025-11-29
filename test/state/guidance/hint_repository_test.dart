/// Hint Repository Unit Tests
/// Created by: Cursor B-central (CENT-008)
/// Purpose: Unit tests for SharedPreferencesHintRepository
/// Last updated: 2025-11-26

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:b_ux/guidance_ux.dart';

import 'package:delivery_ways_clean/state/guidance/guidance_providers_bridge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late SharedPreferencesHintRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repository = SharedPreferencesHintRepository(prefs);
  });

  tearDown(() async {
    await prefs.clear();
  });

  group('SharedPreferencesHintRepository', () {
    const testHintId = 'test_hint_001';

    group('getDisplayState', () {
      test('returns default state for unknown hint', () async {
        final state = await repository.getDisplayState(testHintId);

        expect(state.hintId, equals(testHintId));
        expect(state.showCount, equals(0));
        expect(state.lastShownAt, isNull);
        expect(state.dismissed, isFalse);
        expect(state.dismissedAt, isNull);
      });
    });

    group('markShown', () {
      test('increments show count', () async {
        await repository.markShown(testHintId);
        var state = await repository.getDisplayState(testHintId);
        expect(state.showCount, equals(1));

        await repository.markShown(testHintId);
        state = await repository.getDisplayState(testHintId);
        expect(state.showCount, equals(2));
      });

      test('updates lastShownAt timestamp', () async {
        final beforeMark = DateTime.now();
        await repository.markShown(testHintId);
        final afterMark = DateTime.now();

        final state = await repository.getDisplayState(testHintId);
        expect(state.lastShownAt, isNotNull);
        expect(
          state.lastShownAt!.isAfter(beforeMark.subtract(const Duration(seconds: 1))),
          isTrue,
        );
        expect(
          state.lastShownAt!.isBefore(afterMark.add(const Duration(seconds: 1))),
          isTrue,
        );
      });
    });

    group('markDismissed', () {
      test('sets dismissed flag to true', () async {
        await repository.markDismissed(testHintId);
        final state = await repository.getDisplayState(testHintId);

        expect(state.dismissed, isTrue);
        expect(state.dismissedAt, isNotNull);
      });

      test('preserves show count when dismissing', () async {
        await repository.markShown(testHintId);
        await repository.markShown(testHintId);
        await repository.markDismissed(testHintId);

        final state = await repository.getDisplayState(testHintId);
        expect(state.showCount, equals(2));
        expect(state.dismissed, isTrue);
      });
    });

    group('saveDisplayState', () {
      test('persists all fields correctly', () async {
        final now = DateTime.now();
        final stateToSave = InAppHintDisplayState(
          hintId: testHintId,
          showCount: 5,
          lastShownAt: now,
          dismissed: true,
          dismissedAt: now,
        );

        await repository.saveDisplayState(stateToSave);
        final loaded = await repository.getDisplayState(testHintId);

        expect(loaded.showCount, equals(5));
        expect(loaded.dismissed, isTrue);
        expect(loaded.dismissedAt, isNotNull);
      });
    });

    group('resetHint', () {
      test('clears all data for a specific hint', () async {
        await repository.markShown(testHintId);
        await repository.markDismissed(testHintId);

        await repository.resetHint(testHintId);

        final state = await repository.getDisplayState(testHintId);
        expect(state.showCount, equals(0));
        expect(state.dismissed, isFalse);
      });

      test('does not affect other hints', () async {
        const otherHintId = 'other_hint';

        await repository.markShown(testHintId);
        await repository.markShown(otherHintId);

        await repository.resetHint(testHintId);

        final testState = await repository.getDisplayState(testHintId);
        final otherState = await repository.getDisplayState(otherHintId);

        expect(testState.showCount, equals(0));
        expect(otherState.showCount, equals(1));
      });
    });

    group('resetAll', () {
      test('clears all hint data', () async {
        const hint1 = 'hint_1';
        const hint2 = 'hint_2';

        await repository.markShown(hint1);
        await repository.markShown(hint2);

        await repository.resetAll();

        final state1 = await repository.getDisplayState(hint1);
        final state2 = await repository.getDisplayState(hint2);

        expect(state1.showCount, equals(0));
        expect(state2.showCount, equals(0));
      });
    });
  });

  group('InAppHintDisplayState', () {
    group('incrementShowCount', () {
      test('creates new state with incremented count', () {
        final original = InAppHintDisplayState(
          hintId: 'test',
          showCount: 2,
          lastShownAt: null,
          dismissed: false,
          dismissedAt: null,
        );

        final incremented = original.incrementShowCount();

        expect(incremented.showCount, equals(3));
        expect(incremented.lastShownAt, isNotNull);
        expect(incremented.hintId, equals('test'));
      });
    });

    group('markDismissed', () {
      test('creates new state with dismissed flag', () {
        final original = InAppHintDisplayState(
          hintId: 'test',
          showCount: 1,
          lastShownAt: DateTime.now(),
          dismissed: false,
          dismissedAt: null,
        );

        final dismissed = original.markDismissed();

        expect(dismissed.dismissed, isTrue);
        expect(dismissed.dismissedAt, isNotNull);
        expect(dismissed.showCount, equals(1)); // Preserved
      });
    });
  });
}


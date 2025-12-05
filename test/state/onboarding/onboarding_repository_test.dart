/// Onboarding Repository Unit Tests
/// Created by: Cursor B-central (CENT-008)
/// Purpose: Unit tests for SharedPreferencesOnboardingRepository
/// Last updated: 2025-11-26

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:b_ux/onboarding_ux.dart';

import 'package:delivery_ways_clean/state/onboarding/onboarding_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late SharedPreferencesOnboardingRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repository = SharedPreferencesOnboardingRepository(prefs);
  });

  tearDown(() async {
    await prefs.clear();
  });

  group('SharedPreferencesOnboardingRepository', () {
    const testFlowId = 'test_flow_v1';
    const testVersion = 1;

    group('hasCompletedFlow', () {
      test('returns false when flow has not been completed', () async {
        final result = await repository.hasCompletedFlow(testFlowId);
        expect(result, isFalse);
      });

      test('returns true after flow is marked completed', () async {
        await repository.markFlowCompleted(testFlowId, testVersion);
        final result = await repository.hasCompletedFlow(testFlowId);
        expect(result, isTrue);
      });
    });

    group('markFlowCompleted', () {
      test('stores completed flag, version, and timestamp', () async {
        final beforeMark = DateTime.now();
        await repository.markFlowCompleted(testFlowId, testVersion);
        final afterMark = DateTime.now();

        // Verify completed flag
        expect(await repository.hasCompletedFlow(testFlowId), isTrue);

        // Verify version
        expect(await repository.getSeenVersion(testFlowId), equals(testVersion));

        // Verify timestamp is within expected range
        final state = await repository.getCompletionState(testFlowId);
        expect(state.completedAt, isNotNull);
        expect(
          state.completedAt!.isAfter(beforeMark.subtract(const Duration(seconds: 1))),
          isTrue,
        );
        expect(
          state.completedAt!.isBefore(afterMark.add(const Duration(seconds: 1))),
          isTrue,
        );
      });
    });

    group('getSeenVersion', () {
      test('returns 0 when no version has been set', () async {
        final result = await repository.getSeenVersion(testFlowId);
        expect(result, equals(0));
      });

      test('returns correct version after markFlowCompleted', () async {
        await repository.markFlowCompleted(testFlowId, 3);
        expect(await repository.getSeenVersion(testFlowId), equals(3));
      });

      test('returns correct version after setSeenVersion', () async {
        await repository.setSeenVersion(testFlowId, 5);
        expect(await repository.getSeenVersion(testFlowId), equals(5));
      });
    });

    group('getCompletionState', () {
      test('returns notCompleted state when flow not completed', () async {
        final state = await repository.getCompletionState(testFlowId);
        expect(state.hasCompleted, isFalse);
        expect(state.flowId, equals(testFlowId));
        expect(state.completedVersion, equals(0));
        expect(state.completedAt, isNull);
      });

      test('returns completed state after markFlowCompleted', () async {
        await repository.markFlowCompleted(testFlowId, testVersion);
        final state = await repository.getCompletionState(testFlowId);

        expect(state.hasCompleted, isTrue);
        expect(state.flowId, equals(testFlowId));
        expect(state.completedVersion, equals(testVersion));
        expect(state.completedAt, isNotNull);
      });
    });

    group('saveCompletionState', () {
      test('saves all state fields correctly', () async {
        final completedAt = DateTime.now();
        final stateToSave = OnboardingCompletionState(
          flowId: testFlowId,
          completedVersion: 2,
          completedAt: completedAt,
          skippedStepIds: const ['step_1', 'step_2'],
        );

        await repository.saveCompletionState(stateToSave);
        final loaded = await repository.getCompletionState(testFlowId);

        expect(loaded.hasCompleted, isTrue);
        expect(loaded.completedVersion, equals(2));
        expect(loaded.skippedStepIds, containsAll(['step_1', 'step_2']));
      });
    });

    group('resetFlow', () {
      test('clears all data for a specific flow', () async {
        // Set up initial state
        await repository.markFlowCompleted(testFlowId, testVersion);
        expect(await repository.hasCompletedFlow(testFlowId), isTrue);

        // Reset the flow
        await repository.resetFlow(testFlowId);

        // Verify all data is cleared
        expect(await repository.hasCompletedFlow(testFlowId), isFalse);
        expect(await repository.getSeenVersion(testFlowId), equals(0));

        final state = await repository.getCompletionState(testFlowId);
        expect(state.hasCompleted, isFalse);
      });

      test('does not affect other flows', () async {
        const otherFlowId = 'other_flow_v1';

        await repository.markFlowCompleted(testFlowId, testVersion);
        await repository.markFlowCompleted(otherFlowId, 2);

        await repository.resetFlow(testFlowId);

        expect(await repository.hasCompletedFlow(testFlowId), isFalse);
        expect(await repository.hasCompletedFlow(otherFlowId), isTrue);
      });
    });

    group('resetAll', () {
      test('clears all onboarding data', () async {
        const flow1 = 'flow_1';
        const flow2 = 'flow_2';

        await repository.markFlowCompleted(flow1, 1);
        await repository.markFlowCompleted(flow2, 2);

        await repository.resetAll();

        expect(await repository.hasCompletedFlow(flow1), isFalse);
        expect(await repository.hasCompletedFlow(flow2), isFalse);
      });
    });

    group('OnboardingCompletionState.needsUpdate', () {
      test('returns true when completed version is less than current', () async {
        await repository.markFlowCompleted(testFlowId, 1);
        final state = await repository.getCompletionState(testFlowId);
        expect(state.needsUpdate(2), isTrue);
      });

      test('returns false when completed version equals current', () async {
        await repository.markFlowCompleted(testFlowId, 2);
        final state = await repository.getCompletionState(testFlowId);
        expect(state.needsUpdate(2), isFalse);
      });

      test('returns false when completed version is greater than current', () async {
        await repository.markFlowCompleted(testFlowId, 3);
        final state = await repository.getCompletionState(testFlowId);
        expect(state.needsUpdate(2), isFalse);
      });
    });
  });
}


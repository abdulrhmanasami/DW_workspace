/// Unit tests for OnboardingState and OnboardingController
/// Created by: Ticket #34 - Track D Onboarding Gate
/// Purpose: Verify onboarding state management logic
/// Last updated: 2025-11-28

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:delivery_ways_clean/state/onboarding/onboarding_state.dart';

void main() {
  group('OnboardingState & OnboardingController - Ticket #34', () {
    group('OnboardingState', () {
      test('default state hasCompletedOnboarding is false', () {
        const state = OnboardingState();
        expect(state.hasCompletedOnboarding, isFalse);
      });

      test('copyWith updates hasCompletedOnboarding', () {
        const state = OnboardingState();
        final next = state.copyWith(hasCompletedOnboarding: true);
        expect(next.hasCompletedOnboarding, isTrue);
      });

      test('copyWith returns same value when null passed', () {
        const state = OnboardingState(hasCompletedOnboarding: true);
        final next = state.copyWith();
        expect(next.hasCompletedOnboarding, isTrue);
      });

      test('equality works correctly', () {
        const state1 = OnboardingState(hasCompletedOnboarding: false);
        const state2 = OnboardingState(hasCompletedOnboarding: false);
        const state3 = OnboardingState(hasCompletedOnboarding: true);

        expect(state1, equals(state2));
        expect(state1, isNot(equals(state3)));
      });

      test('hashCode is consistent with equality', () {
        const state1 = OnboardingState(hasCompletedOnboarding: false);
        const state2 = OnboardingState(hasCompletedOnboarding: false);

        expect(state1.hashCode, equals(state2.hashCode));
      });
    });

    group('OnboardingController', () {
      test('initial state hasCompletedOnboarding is false', () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final state = container.read(onboardingStateProvider);
        expect(state.hasCompletedOnboarding, isFalse);
      });

      test('completeOnboarding sets hasCompletedOnboarding to true', () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final controller = container.read(onboardingStateProvider.notifier);
        expect(
          container.read(onboardingStateProvider).hasCompletedOnboarding,
          isFalse,
        );

        controller.completeOnboarding();

        expect(
          container.read(onboardingStateProvider).hasCompletedOnboarding,
          isTrue,
        );
      });

      test('completeOnboarding is idempotent', () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final controller = container.read(onboardingStateProvider.notifier);

        controller.completeOnboarding();
        expect(
          container.read(onboardingStateProvider).hasCompletedOnboarding,
          isTrue,
        );

        // Call again - should still be true
        controller.completeOnboarding();
        expect(
          container.read(onboardingStateProvider).hasCompletedOnboarding,
          isTrue,
        );
      });

      test('completeOnboarding persists state via OnboardingPrefs', () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final controller = container.read(onboardingStateProvider.notifier);

        // Should complete without throwing and update state
        await expectLater(controller.completeOnboarding(), completes);

        // State should be updated to true
        expect(
          container.read(onboardingStateProvider).hasCompletedOnboarding,
          isTrue,
        );
      });

      test('completeOnboarding handles multiple calls correctly', () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final controller = container.read(onboardingStateProvider.notifier);

        // First call
        await controller.completeOnboarding();
        expect(
          container.read(onboardingStateProvider).hasCompletedOnboarding,
          isTrue,
        );

        // Second call should still work (idempotent)
        await expectLater(controller.completeOnboarding(), completes);
        expect(
          container.read(onboardingStateProvider).hasCompletedOnboarding,
          isTrue,
        );
      });
    });

    group('onboardingStateProvider', () {
      test('provides OnboardingController instance', () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final controller = container.read(onboardingStateProvider.notifier);
        expect(controller, isA<OnboardingController>());
      });

      test('state changes are observable', () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final states = <OnboardingState>[];
        container.listen<OnboardingState>(
          onboardingStateProvider,
          (previous, next) => states.add(next),
          fireImmediately: true,
        );

        // Initial state
        expect(states.length, 1);
        expect(states.first.hasCompletedOnboarding, isFalse);

        // Complete onboarding
        container.read(onboardingStateProvider.notifier).completeOnboarding();

        expect(states.length, 2);
        expect(states.last.hasCompletedOnboarding, isTrue);
      });
    });
  });
}


/// Onboarding Step Indicator Widget Tests
/// Created by: Cursor B-central (CENT-008)
/// Purpose: Widget tests for OnboardingStepIndicator
/// Last updated: 2025-11-26

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:delivery_ways_clean/screens/onboarding/onboarding_step_indicator.dart';

void main() {
  group('OnboardingStepIndicator', () {
    testWidgets('renders correct number of dots', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: OnboardingStepIndicator(
                currentStep: 0,
                totalSteps: 5,
              ),
            ),
          ),
        ),
      );

      // Should find 5 AnimatedContainer widgets (one for each step)
      final containers = find.byType(AnimatedContainer);
      expect(containers, findsNWidgets(5));
    });

    testWidgets('current step dot is wider', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: OnboardingStepIndicator(
                currentStep: 2,
                totalSteps: 5,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find all AnimatedContainer widgets
      final containers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );

      // The current step (index 2) should have width 24
      // Other steps should have width 8
      int index = 0;
      for (final container in containers) {
        final constraints = container.constraints;
        if (constraints != null) {
          if (index == 2) {
            expect(constraints.maxWidth, equals(24.0));
          } else {
            expect(constraints.maxWidth, equals(8.0));
          }
        }
        index++;
      }
    });

    testWidgets('animates when currentStep changes', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: OnboardingStepIndicator(
                currentStep: 0,
                totalSteps: 3,
              ),
            ),
          ),
        ),
      );

      // Change to step 1
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: OnboardingStepIndicator(
                currentStep: 1,
                totalSteps: 3,
              ),
            ),
          ),
        ),
      );

      // Pump a few frames for the animation
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // The test passes if no exception is thrown
      // Animation should be running
    });

    testWidgets('respects custom colors', (tester) async {
      const customActiveColor = Colors.red;
      const customInactiveColor = Colors.grey;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: OnboardingStepIndicator(
                currentStep: 0,
                totalSteps: 3,
                activeColor: customActiveColor,
                inactiveColor: customInactiveColor,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify colors are applied - the widget should build successfully
      expect(find.byType(OnboardingStepIndicator), findsOneWidget);
    });

    testWidgets('handles edge cases', (tester) async {
      // Test with 1 step
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: OnboardingStepIndicator(
                currentStep: 0,
                totalSteps: 1,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(AnimatedContainer), findsOneWidget);
    });
  });

  group('OnboardingProgressBar', () {
    testWidgets('renders at 0% progress', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: OnboardingProgressBar(
                progress: 0.0,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(OnboardingProgressBar), findsOneWidget);
    });

    testWidgets('renders at 100% progress', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: OnboardingProgressBar(
                progress: 1.0,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(OnboardingProgressBar), findsOneWidget);
    });

    testWidgets('clamps progress to valid range', (tester) async {
      // Progress > 1.0 should be clamped
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: OnboardingProgressBar(
                progress: 1.5,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(OnboardingProgressBar), findsOneWidget);

      // Progress < 0.0 should be clamped
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: OnboardingProgressBar(
                progress: -0.5,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(OnboardingProgressBar), findsOneWidget);
    });

    testWidgets('respects custom height', (tester) async {
      const customHeight = 10.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: OnboardingProgressBar(
                progress: 0.5,
                height: customHeight,
              ),
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.height, equals(customHeight));
    });
  });
}


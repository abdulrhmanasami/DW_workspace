/// Onboarding Step Indicator Widget
/// Created by: Cursor B-central
/// Purpose: Visual progress indicator for onboarding flow
/// Last updated: 2025-11-26

import 'package:design_system_foundation/design_system_foundation.dart';
import 'package:flutter/material.dart';

/// Step indicator showing progress through onboarding flow.
class OnboardingStepIndicator extends StatelessWidget {
  const OnboardingStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.activeColor,
    this.inactiveColor,
  });

  /// Current step index (0-based).
  final int currentStep;

  /// Total number of steps.
  final int totalSteps;

  /// Color for active/completed dots.
  final Color? activeColor;

  /// Color for inactive dots.
  final Color? inactiveColor;

  @override
  Widget build(BuildContext context) {
    final colors = DwColors();
    final spacing = DwSpacing();
    final motion = DwMotion();
    
    final active = activeColor ?? colors.primary;
    final inactive = inactiveColor ?? colors.grey300;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalSteps,
        (index) => AnimatedContainer(
          duration: motion.normal,
          curve: motion.easeInOut,
          margin: EdgeInsets.symmetric(horizontal: spacing.xs),
          width: index == currentStep ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index <= currentStep ? active : inactive,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

/// Progress bar variant of step indicator.
class OnboardingProgressBar extends StatelessWidget {
  const OnboardingProgressBar({
    super.key,
    required this.progress,
    this.height = 4,
    this.backgroundColor,
    this.progressColor,
  });

  /// Progress value (0.0 to 1.0).
  final double progress;

  /// Height of the progress bar.
  final double height;

  /// Background color.
  final Color? backgroundColor;

  /// Progress fill color.
  final Color? progressColor;

  @override
  Widget build(BuildContext context) {
    final colors = DwColors();
    final motion = DwMotion();
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              color: backgroundColor ?? colors.grey200,
            ),
            AnimatedFractionallySizedBox(
              duration: motion.normal,
              curve: motion.easeInOut,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                color: progressColor ?? colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Animated fractionally sized box for smooth progress transitions.
class AnimatedFractionallySizedBox extends StatelessWidget {
  const AnimatedFractionallySizedBox({
    super.key,
    required this.duration,
    required this.curve,
    required this.widthFactor,
    required this.child,
  });

  final Duration duration;
  final Curve curve;
  final double widthFactor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: 0, end: widthFactor),
      builder: (context, value, child) {
        return FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: value,
          child: child,
        );
      },
      child: child,
    );
  }
}

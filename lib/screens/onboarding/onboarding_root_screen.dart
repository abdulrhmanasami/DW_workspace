/// Onboarding Root Screen
/// Created by: Cursor B-central
/// Updated by: Ticket #57 - Track D Onboarding Flow (3 screens: Ride/Parcels/Food)
/// Purpose: Main onboarding flow screen with PageView-based 3-step flow
/// Last updated: 2025-11-29

import 'package:design_system_shims/design_system_shims.dart';
import 'package:flutter/material.dart';

import 'onboarding_page_ride_screen.dart';
import 'onboarding_page_parcels_screen.dart';
import 'onboarding_page_food_screen.dart';

/// Main onboarding screen that manages the product onboarding flow.
///
/// Ticket #57: Implements 3-screen onboarding flow based on Mockups:
/// Screen 1: Ride - "Get a Ride, Instantly."
/// Screen 2: Parcels - "Deliver Anything, Effortlessly."
/// Screen 3: Food - "Your Favorite Food, Delivered."
///
/// Uses internal state (index 0–2) to track current screen.
/// Does not persist completion state (handled in separate ticket).
class OnboardingRootScreen extends StatefulWidget {
  const OnboardingRootScreen({
    super.key,
    this.onComplete,
  });

  /// Callback when onboarding is completed.
  final VoidCallback? onComplete;

  @override
  State<OnboardingRootScreen> createState() => _OnboardingRootScreenState();
}

class _OnboardingRootScreenState extends State<OnboardingRootScreen> {
  int _currentIndex = 0;
  static const int _totalPages = 3;

  void _goToNext() {
    if (_currentIndex < _totalPages - 1) {
      setState(() => _currentIndex++);
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    // Notify completion if callback provided
    widget.onComplete?.call();
    // Pop back to root (initial route) - same behavior as previous flow
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Build the page widgets
    final pages = [
      OnboardingPageRideScreen(onNext: _goToNext),
      OnboardingPageParcelsScreen(onNext: _goToNext),
      OnboardingPageFoodScreen(onNext: _goToNext),
    ];

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Main content area
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(_currentIndex),
                  child: pages[_currentIndex],
                ),
              ),
            ),

            // Progress dots indicator
            Padding(
              padding: const EdgeInsets.only(bottom: DWSpacing.xl),
              child: _OnboardingProgressDots(
                currentIndex: _currentIndex,
                total: _totalPages,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Progress dots widget showing current position in onboarding flow.
class _OnboardingProgressDots extends StatelessWidget {
  const _OnboardingProgressDots({
    required this.currentIndex,
    required this.total,
  });

  final int currentIndex;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        total,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == currentIndex ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index <= currentIndex
                ? colors.primary
                : colors.outline.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

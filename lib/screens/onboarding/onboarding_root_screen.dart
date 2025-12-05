/// Onboarding Root Screen
/// Created by: Ticket #238 - Track D-6 Onboarding Flow
/// Purpose: Main onboarding flow screen with PageView-based Welcome/Permissions/Preferences flow
/// Last updated: 2025-12-04

import 'package:design_system_shims/design_system_shims.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_shims/foundation_shims.dart';

import 'welcome_screen.dart';
import 'permissions_screen.dart';
import 'screen_preferences.dart';

/// Main onboarding screen that manages the user onboarding flow.
///
/// Ticket #238: Implements 3-screen onboarding flow:
/// Screen 1: Welcome - Introduction to Delivery Ways
/// Screen 2: Permissions - Explain location/notifications permissions
/// Screen 3: Preferences - Set initial preferences including marketing opt-in
///
/// Uses PageView with PageController for smooth navigation.
/// Persists completion state and marketing preferences using OnboardingPrefs shim.
class OnboardingRootScreen extends ConsumerStatefulWidget {
  const OnboardingRootScreen({
    super.key,
    this.onComplete,
  });

  /// Callback when onboarding is completed.
  final VoidCallback? onComplete;

  @override
  ConsumerState<OnboardingRootScreen> createState() => _OnboardingRootScreenState();
}

class _OnboardingRootScreenState extends ConsumerState<OnboardingRootScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  static const int _totalPages = 3;
  late final OnboardingPrefs _onboardingPrefs;

  @override
  void initState() {
    super.initState();
    _onboardingPrefs = ref.read(onboardingPrefsServiceProvider);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNext() {
    if (_currentIndex < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _skipOnboarding() {
    _finishOnboarding();
  }

  Future<void> _finishOnboarding() async {
    // Mark onboarding as completed in persistent storage
    await _onboardingPrefs.setCompletedOnboarding(true);

    // Notify completion if callback provided
    widget.onComplete?.call();

    // Pop back to root (initial route) - same behavior as previous flow
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Build the page widgets
    final pages = [
      WelcomeScreen(onComplete: _goToNext),
      PermissionsScreen(onComplete: _goToNext),
      PreferencesScreen(onComplete: _finishOnboarding),
    ];

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button in top right (except on last page)
            if (_currentIndex < _totalPages - 1)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(DWSpacing.md),
                  child: DWButton.tertiary(
                    label: 'Skip', // TODO: Add to L10n
                    onPressed: _skipOnboarding,
                  ),
                ),
              ),

            // Main content area
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                physics: const NeverScrollableScrollPhysics(), // Disable swipe
                children: pages,
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

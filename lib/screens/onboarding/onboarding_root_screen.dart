/// Onboarding Root Screen
/// Created by: Cursor B-central
/// Updated by: Ticket #33 - Track D Basic Onboarding Flow
/// Purpose: Main onboarding flow screen - simple 3-step flow (Welcome/Permissions/Preferences)
/// Last updated: 2025-11-28

import 'package:flutter/material.dart';

import 'welcome_screen.dart';

/// Main onboarding screen that manages the basic customer onboarding flow.
/// 
/// Ticket #33: Simplified to show the 3-step basic flow:
/// Welcome → Permissions → Preferences → (complete)
/// 
/// The previous B-ux based flow is preserved in git history for future use.
class OnboardingRootScreen extends StatelessWidget {
  const OnboardingRootScreen({
    super.key,
    this.onComplete,
  });

  /// Callback when onboarding is completed.
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    // Pass onComplete callback through constructor chain
    return WelcomeScreen(onComplete: onComplete);
  }
}

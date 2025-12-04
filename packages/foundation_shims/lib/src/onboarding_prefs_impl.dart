/// Onboarding Preferences Implementation - Stub Implementation
/// Created by: Ticket #238 - Track D-6 Onboarding Flow
/// Purpose: Stub implementation of OnboardingPrefs for development/testing
/// Last updated: 2025-12-04

import 'onboarding_prefs.dart';

/// Stub implementation of OnboardingPrefs using in-memory storage.
/// This should be replaced with a real implementation using shared_preferences
/// or secure storage in production.
class OnboardingPrefsStubImpl implements OnboardingPrefs {
  bool _hasCompletedOnboarding = false;
  bool _marketingOptIn = false;

  @override
  Future<bool> hasCompletedOnboarding() async {
    return _hasCompletedOnboarding;
  }

  @override
  Future<void> setCompletedOnboarding(bool value) async {
    _hasCompletedOnboarding = value;
  }

  @override
  Future<bool> getMarketingOptIn() async {
    return _marketingOptIn;
  }

  @override
  Future<void> setMarketingOptIn(bool value) async {
    _marketingOptIn = value;
  }
}

/// Global instance for convenience
final onboardingPrefsStubImpl = OnboardingPrefsStubImpl();

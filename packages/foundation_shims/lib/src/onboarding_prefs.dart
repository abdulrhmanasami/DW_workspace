/// Onboarding Preferences - Persistent Storage for Onboarding Data
/// Created by: Ticket #238 - Track D-6 Onboarding Flow
/// Purpose: Abstract interface for onboarding preferences persistence
/// Last updated: 2025-12-04

/// Service for managing onboarding-related preferences
abstract class OnboardingPrefs {
  /// Check if the user has completed the onboarding flow
  Future<bool> hasCompletedOnboarding();

  /// Mark onboarding as completed
  Future<void> setCompletedOnboarding(bool value);

  /// Get user's marketing opt-in preference
  Future<bool> getMarketingOptIn();

  /// Set user's marketing opt-in preference
  Future<void> setMarketingOptIn(bool value);
}

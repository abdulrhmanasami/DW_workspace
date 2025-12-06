/// Onboarding Preferences Providers - Riverpod providers for onboarding prefs
/// Created by: Ticket #238 - Track D-6 Onboarding Flow
/// Purpose: Riverpod providers for OnboardingPrefs service
/// Last updated: 2025-12-04

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:foundation_shims/src/onboarding_prefs.dart';
import 'package:foundation_shims/src/onboarding_prefs_impl.dart';

/// Status of the onboarding flow
enum OnboardingStatus {
  /// Status is still being determined
  unknown,

  /// User has not completed onboarding
  notCompleted,

  /// User has completed onboarding
  completed,
}

/// OnboardingPrefs service provider
final onboardingPrefsServiceProvider = Provider<OnboardingPrefs>((ref) {
  return onboardingPrefsStubImpl;
});

/// Provider for onboarding completion status
final hasCompletedOnboardingProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(onboardingPrefsServiceProvider);
  return service.hasCompletedOnboarding();
});

/// Provider for onboarding status (enum)
final onboardingStatusProvider = FutureProvider<OnboardingStatus>((ref) async {
  final service = ref.watch(onboardingPrefsServiceProvider);
  final hasCompleted = await service.hasCompletedOnboarding();
  return hasCompleted ? OnboardingStatus.completed : OnboardingStatus.notCompleted;
});

/// Provider for marketing opt-in preference
final marketingOptInProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(onboardingPrefsServiceProvider);
  return service.getMarketingOptIn();
});

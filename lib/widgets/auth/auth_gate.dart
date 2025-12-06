/// Auth Gate Widget
/// Created by: Track D - Ticket #237 (D-5) & Ticket #238 (D-6)
/// Purpose: Root navigation gate that decides between onboarding, loading, auth flow, or app shell
/// Last updated: 2025-12-04

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_shims/foundation_shims.dart';
import 'package:delivery_ways_clean/app_shell/app_shell.dart';
import 'package:delivery_ways_clean/screens/auth/phone_login_screen.dart';
import 'package:delivery_ways_clean/screens/onboarding/onboarding_root_screen.dart';
import 'package:delivery_ways_clean/state/identity/identity_controller.dart';

/// Auth Gate Widget
///
/// This widget serves as the main navigation gate for the app, deciding what to show
/// based on the current identity session status and onboarding completion:
///
/// Priority order (Ticket #238):
/// 1. If either identity or onboarding status is unknown → Show loading
/// 2. If onboarding not completed → Show OnboardingRootScreen
/// 3. If identity unauthenticated → Show PhoneLoginScreen
/// 4. If identity authenticated → Show AppShell
///
/// Track D - Ticket #237: Auth Gate & Root Navigation - Complete IdentityController integration
/// Track D - Ticket #238: Onboarding Flow Integration - Prioritize onboarding before auth
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final identityState = ref.watch(identityControllerProvider);
    final session = identityState.session;
    final onboardingStatusAsync = ref.watch(onboardingStatusProvider);

    // Handle onboarding status loading
    return onboardingStatusAsync.when(
      loading: () => const _LoadingScreen(),
      error: (error, stack) => const _LoadingScreen(), // Fallback to loading on error
      data: (onboardingStatus) {
        // Ticket #238: Check onboarding status first
        if (session.isUnknown || onboardingStatus == OnboardingStatus.unknown) {
          return const _LoadingScreen();
        }

        if (onboardingStatus == OnboardingStatus.notCompleted) {
          // Always show onboarding before any auth screens
          return const OnboardingRootScreen();
        }

        // Onboarding completed - proceed with auth logic
        if (session.isUnauthenticated) {
          return const PhoneLoginScreen();
        }

        if (session.isAuthenticated) {
          return const AppShell();
        }

        // Fallback: should not reach here, but show loading as safety
        return const _LoadingScreen();
      },
    );
  }
}

/// Loading screen widget for unknown auth state
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }
}

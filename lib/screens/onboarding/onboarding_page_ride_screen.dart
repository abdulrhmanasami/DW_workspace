/// Onboarding Page - Ride (Screen 1)
/// Created by: Ticket #57 - Track D Onboarding Flow
/// Purpose: First onboarding screen showcasing Ride service value prop
/// Last updated: 2025-11-29

import 'package:design_system_shims/design_system_shims.dart';
import 'package:flutter/material.dart';

import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';

/// Ride onboarding page - First screen in the product onboarding flow.
/// Shows the ride service value proposition.
class OnboardingPageRideScreen extends StatelessWidget {
  const OnboardingPageRideScreen({
    super.key,
    required this.onNext,
  });

  /// Callback when user taps Continue.
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.all(DWSpacing.lg),
      child: Column(
        children: [
          const Spacer(flex: 2),

          // Illustration / Icon
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.directions_car_outlined,
              size: 70,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: DWSpacing.xl),

          // Title
          Text(
            l10n?.onboardingRideTitle ?? 'Get a Ride, Instantly.',
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DWSpacing.md),

          // Body
          Text(
            l10n?.onboardingRideBody ??
                'Tap, ride, and arrive. Fast, reliable, and affordable transport at your fingertips.',
            style: textTheme.bodyLarge?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const Spacer(flex: 3),

          // Continue Button
          DWButton.primary(
            label: l10n?.onboardingButtonContinue ?? 'Continue',
            onPressed: onNext,
          ),
          const SizedBox(height: DWSpacing.lg),
        ],
      ),
    );
  }
}


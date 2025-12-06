/// Onboarding Page - Food (Screen 3)
/// Created by: Ticket #57 - Track D Onboarding Flow
/// Purpose: Third/final onboarding screen showcasing Food service value prop
/// Last updated: 2025-11-29

import 'package:design_system_shims/design_system_shims.dart';
import 'package:flutter/material.dart';

import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';

/// Food onboarding page - Third/final screen in the product onboarding flow.
/// Shows the food delivery service value proposition.
class OnboardingPageFoodScreen extends StatelessWidget {
  const OnboardingPageFoodScreen({
    super.key,
    required this.onNext,
  });

  /// Callback when user taps "Get Started" to complete onboarding.
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
              color: colors.tertiary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.restaurant_outlined,
              size: 70,
              color: colors.tertiary,
            ),
          ),
          const SizedBox(height: DWSpacing.xl),

          // Title
          Text(
            l10n?.onboardingFoodTitle ?? 'Your Favorite Food, Delivered.',
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DWSpacing.md),

          // Body
          Text(
            l10n?.onboardingFoodBody ??
                'Explore local restaurants and enjoy fast delivery right to your door.',
            style: textTheme.bodyLarge?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const Spacer(flex: 3),

          // Get Started Button (final step)
          DWButton.primary(
            label: l10n?.onboardingButtonGetStarted ?? 'Get Started',
            onPressed: onNext,
          ),
          const SizedBox(height: DWSpacing.lg),
        ],
      ),
    );
  }
}


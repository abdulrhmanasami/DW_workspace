/// Onboarding Page - Parcels (Screen 2)
/// Created by: Ticket #57 - Track D Onboarding Flow
/// Purpose: Second onboarding screen showcasing Parcels service value prop
/// Last updated: 2025-11-29

import 'package:design_system_shims/design_system_shims.dart';
import 'package:flutter/material.dart';

import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';

/// Parcels onboarding page - Second screen in the product onboarding flow.
/// Shows the parcels/delivery service value proposition.
class OnboardingPageParcelsScreen extends StatelessWidget {
  const OnboardingPageParcelsScreen({
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
              color: colors.secondary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 70,
              color: colors.secondary,
            ),
          ),
          const SizedBox(height: DWSpacing.xl),

          // Title
          Text(
            l10n?.onboardingParcelsTitle ?? 'Deliver Anything, Effortlessly.',
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DWSpacing.md),

          // Body
          Text(
            l10n?.onboardingParcelsBody ??
                'From documents to gifts, send and track your parcels with ease and confidence.',
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


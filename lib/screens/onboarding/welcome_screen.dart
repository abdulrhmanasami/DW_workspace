/// Welcome Screen - Onboarding Step 1
/// Created by: Ticket #33 - Track D Onboarding
/// Updated by: Ticket #34 - Removed OnboardingScope dependency
/// Purpose: First screen in the basic onboarding flow
/// Last updated: 2025-11-28

import 'package:design_system_components/design_system_components.dart';
import 'package:flutter/material.dart';

import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/widgets/app_shell.dart';

/// Welcome screen - First step of onboarding flow.
/// Shows app introduction and "Get Started" CTA.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    this.onComplete,
    this.onPrimaryAction,
    this.onSecondaryAction,
  });

  /// Optional callback when onboarding is completed.
  /// Passed through constructor chain from OnboardingRootScreen.
  final VoidCallback? onComplete;
  final VoidCallback? onPrimaryAction;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppShell(
      showAppBar: false,
      showBottomNav: false,
      safeArea: true,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),

            // App icon
            Icon(
              Icons.local_shipping_outlined,
              size: 80,
              color: colors.primary,
            ),
            const SizedBox(height: DWSpacing.xl),

            // Title
            Text(
              l10n?.onboardingWelcomeTitle ?? 'Welcome to Delivery Ways',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DWSpacing.sm),

            // Subtitle
            Text(
              l10n?.onboardingWelcomeSubtitle ??
                  'All your rides, parcels, and deliveries in one place.',
              style: textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            const Spacer(),

            DwButton(
              text: l10n?.onboardingWelcomeGetStartedCta ?? 'Get started',
              onPressed: onPrimaryAction ?? onComplete,
              fullWidth: true,
              variant: DwButtonVariant.primary,
            ),
            const SizedBox(height: 12),
            DwButton(
              text: l10n?.authPhoneLoginTitle ?? 'Sign in',
              onPressed: onSecondaryAction,
              fullWidth: true,
              variant: DwButtonVariant.secondary,
            ),
          ],
        ),
      ),
    );
  }
}


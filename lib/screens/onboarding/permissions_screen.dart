/// Permissions Screen - Onboarding Step 2
/// Created by: Ticket #33 - Track D Onboarding
/// Purpose: Explains required permissions (Location/Notifications) - UI only
/// Last updated: 2025-11-28

import 'package:design_system_shims/design_system_shims.dart';
import 'package:flutter/material.dart';

import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/widgets/app_shell.dart';

/// Permissions screen - Second step of onboarding flow.
/// Shows explanation of required permissions without actually requesting them.
class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({
    super.key,
    this.onComplete,
  });

  /// Optional callback when onboarding is completed.
  final VoidCallback? onComplete;

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
        padding: const EdgeInsets.all(DWSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Custom back button area (replacing AppBar)
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(height: DWSpacing.md),

            // Title
            Text(
              l10n?.onboardingPermissionsTitle ?? 'Allow permissions',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DWSpacing.xl),

            // Permission items
            Expanded(
              child: ListView(
                children: [
                  // Location permission
                  _PermissionTile(
                    icon: Icons.location_on_outlined,
                    iconColor: colors.primary,
                    title: l10n?.onboardingPermissionsLocation ??
                        'Location access',
                    subtitle: l10n?.onboardingPermissionsLocationSubtitle ??
                        'We use your location to find nearby drivers.',
                  ),
                  const SizedBox(height: DWSpacing.md),

                  // Notifications permission
                  _PermissionTile(
                    icon: Icons.notifications_outlined,
                    iconColor: colors.secondary,
                    title: l10n?.onboardingPermissionsNotifications ??
                        'Notifications',
                    subtitle: l10n?.onboardingPermissionsNotificationsSubtitle ??
                        'Stay updated about your rides and deliveries.',
                  ),
                ],
              ),
            ),

            // Continue button
            DWButton.primary(
              label: l10n?.onboardingPermissionsContinueCta ?? 'Continue',
              onPressed: () {
                // Call onComplete to advance to next screen in PageView
                onComplete?.call();
              },
            ),
            const SizedBox(height: DWSpacing.sm),

            // Skip button
            DWButton.tertiary(
              label: l10n?.onboardingPermissionsSkipCta ?? 'Skip for now',
              onPressed: () {
                // Call onComplete to advance to next screen in PageView
                onComplete?.call();
              },
            ),
            const SizedBox(height: DWSpacing.md),
          ],
        ),
      ),
    );
  }

}

/// A tile displaying a permission with icon, title and description.
class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(DWSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(DWRadius.md),
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DWRadius.sm),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: DWSpacing.md),
          
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: DWSpacing.xxs),
                Text(
                  subtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


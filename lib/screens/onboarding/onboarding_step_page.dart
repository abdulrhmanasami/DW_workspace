/// Onboarding Step Page Widget
/// Created by: Cursor B-central
/// Purpose: Single step page in onboarding flow with different layouts per step type
/// Last updated: 2025-11-26

import 'package:b_ux/onboarding_ux.dart';
import 'package:design_system_foundation/design_system_foundation.dart';
import 'package:flutter/material.dart';

import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';

/// A single page/step in the onboarding flow.
class OnboardingStepPage extends StatelessWidget {
  const OnboardingStepPage({
    super.key,
    required this.step,
    required this.position,
    this.onPrimaryCta,
    this.onSecondaryCta,
    this.isBackendAvailable = false,
  });

  /// The step data from B-ux.
  final OnboardingStep step;

  /// Position of this step in the flow.
  final OnboardingStepPosition position;

  /// Callback for primary CTA button.
  final VoidCallback? onPrimaryCta;

  /// Callback for secondary CTA button (skip).
  final VoidCallback? onSecondaryCta;

  /// Whether the backend feature for this step is available.
  final bool isBackendAvailable;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = DwColors();
    final spacing = DwSpacing();

    return Padding(
      padding: EdgeInsets.all(spacing.xl),
      child: Column(
        children: [
          const Spacer(flex: 1),

          // Icon
          _buildIcon(context, colors),
          SizedBox(height: spacing.xl),

          // Title
          Text(
            _getLocalizedText(l10n, step.titleKey) ?? step.titleKey,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.grey900,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacing.md),

          // Body
          Text(
            _getLocalizedText(l10n, step.bodyKey) ?? step.bodyKey,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.grey600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const Spacer(flex: 2),

          // CTA Buttons
          _buildCtaButtons(context, l10n, colors, spacing),
          SizedBox(height: spacing.lg),
        ],
      ),
    );
  }

  Widget _buildIcon(BuildContext context, DwColors colors) {
    Color iconColor;
    Color bgColor;

    switch (step.type) {
      case OnboardingStepType.privacySecurity:
        iconColor = colors.success;
        bgColor = colors.success.withValues(alpha: 0.1);
        break;
      case OnboardingStepType.permission:
        iconColor = colors.warning;
        bgColor = colors.warning.withValues(alpha: 0.1);
        break;
      case OnboardingStepType.action:
        iconColor = colors.primary;
        bgColor = colors.primary.withValues(alpha: 0.1);
        break;
      default:
        iconColor = colors.primary;
        bgColor = colors.primary.withValues(alpha: 0.1);
    }

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        step.icon,
        size: 60,
        color: iconColor,
      ),
    );
  }

  Widget _buildCtaButtons(BuildContext context, AppLocalizations? l10n, DwColors colors, DwSpacing spacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Primary CTA
        if (step.primaryCtaKey != null)
          FilledButton(
            onPressed: onPrimaryCta,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(spacing.md),
              ),
            ),
            child: Text(
              _getLocalizedText(l10n, step.primaryCtaKey!) ?? step.primaryCtaKey!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

        // Secondary CTA (Skip)
        if (step.secondaryCtaKey != null) ...[
          SizedBox(height: spacing.sm),
          TextButton(
            onPressed: onSecondaryCta,
            style: TextButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
            child: Text(
              _getLocalizedText(l10n, step.secondaryCtaKey!) ?? step.secondaryCtaKey!,
              style: TextStyle(
                color: colors.grey500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Get localized text for a given key.
  /// Falls back to key itself if not found.
  String? _getLocalizedText(AppLocalizations? l10n, String key) {
    if (l10n == null) return null;

    // Map keys to localization method calls
    switch (key) {
      // Welcome
      case 'onb_welcome_title':
        return l10n.onbWelcomeTitle;
      case 'onb_welcome_body':
        return l10n.onbWelcomeBody;
      // App Intro
      case 'onb_app_intro_title':
        return l10n.onbAppIntroTitle;
      case 'onb_app_intro_body':
        return l10n.onbAppIntroBody;
      // Ride (Super-App)
      case 'onb_ride_title':
        return l10n.onbRideTitle;
      case 'onb_ride_body':
        return l10n.onbRideBody;
      // Parcels (Super-App)
      case 'onb_parcels_title':
        return l10n.onbParcelsTitle;
      case 'onb_parcels_body':
        return l10n.onbParcelsBody;
      // Food (Super-App)
      case 'onb_food_title':
        return l10n.onbFoodTitle;
      case 'onb_food_body':
        return l10n.onbFoodBody;
      // Ordering
      case 'onb_ordering_title':
        return l10n.onbOrderingTitle;
      case 'onb_ordering_body':
        return l10n.onbOrderingBody;
      // Tracking
      case 'onb_tracking_title':
        return l10n.onbTrackingTitle;
      case 'onb_tracking_body':
        return l10n.onbTrackingBody;
      // Security
      case 'onb_security_title':
        return l10n.onbSecurityTitle;
      case 'onb_security_body':
        return l10n.onbSecurityBody;
      // Notifications
      case 'onb_notifications_title':
        return l10n.onbNotificationsTitle;
      case 'onb_notifications_body':
        return l10n.onbNotificationsBody;
      // Ready
      case 'onb_ready_title':
        return l10n.onbReadyTitle;
      case 'onb_ready_body':
        return l10n.onbReadyBody;
      // CTAs
      case 'onb_cta_get_started':
        return l10n.onbCtaGetStarted;
      case 'onb_cta_next':
        return l10n.onbCtaNext;
      case 'onb_cta_skip':
        return l10n.onbCtaSkip;
      case 'onb_cta_enable_notifications':
        return l10n.onbCtaEnableNotifications;
      case 'onb_cta_start_ordering':
        return l10n.onbCtaStartOrdering;
      case 'onb_cta_done':
        return l10n.onbCtaDone;
      case 'onb_cta_back':
        return l10n.onbCtaBack;
      default:
        return null;
    }
  }
}

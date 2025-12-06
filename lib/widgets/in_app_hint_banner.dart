/// In-App Hint Banner Widget
/// Created by: Cursor B-central
/// Purpose: Display contextual hints and guidance banners in app screens
/// Last updated: 2025-11-26

import 'package:b_ux/guidance_ux.dart';
import 'package:design_system_foundation/design_system_foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/state/guidance/guidance_providers.dart';

/// A banner widget for displaying in-app hints.
class InAppHintBanner extends ConsumerWidget {
  const InAppHintBanner({
    super.key,
    required this.hint,
    this.onDismiss,
    this.onPrimaryCta,
  });

  /// The hint to display.
  final InAppHint hint;

  /// Callback when hint is dismissed.
  final VoidCallback? onDismiss;

  /// Callback for primary CTA action.
  final VoidCallback? onPrimaryCta;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(hintControllerProvider.notifier);
    final colors = DwColors();
    final spacing = DwSpacing();

    // Mark as shown when built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.markShown(hint.id);
    });

    return Container(
      margin: EdgeInsets.all(spacing.md),
      padding: EdgeInsets.all(spacing.md),
      decoration: BoxDecoration(
        color: _getBackgroundColor(colors),
        borderRadius: BorderRadius.circular(spacing.sm),
        border: Border.all(
          color: _getBorderColor(colors),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              if (hint.icon != null)
                Container(
                  padding: EdgeInsets.all(spacing.xs),
                  decoration: BoxDecoration(
                    color: _getIconBackgroundColor(colors),
                    borderRadius: BorderRadius.circular(spacing.xs),
                  ),
                  child: Icon(
                    hint.icon,
                    color: _getIconColor(colors),
                    size: 20,
                  ),
                ),
              if (hint.icon != null) SizedBox(width: spacing.sm),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getLocalizedText(l10n, hint.titleKey) ?? hint.titleKey,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: colors.grey900,
                      ),
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      _getLocalizedText(l10n, hint.bodyKey) ?? hint.bodyKey,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.grey600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // Dismiss button
              if (hint.dismissible)
                IconButton(
                  onPressed: () {
                    controller.dismiss(hint.id);
                    onDismiss?.call();
                  },
                  icon: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: colors.grey400,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
            ],
          ),

          // Primary CTA
          if (hint.primaryCtaKey != null) ...[
            SizedBox(height: spacing.sm),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onPrimaryCta,
                style: TextButton.styleFrom(
                  foregroundColor: colors.primary,
                  padding: EdgeInsets.symmetric(vertical: spacing.sm),
                ),
                child: Text(
                  _getLocalizedText(l10n, hint.primaryCtaKey!) ?? hint.primaryCtaKey!,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getBackgroundColor(DwColors colors) {
    switch (hint.category) {
      case InAppHintCategory.warning:
        return colors.warning.withValues(alpha: 0.08);
      case InAppHintCategory.error:
        return colors.error.withValues(alpha: 0.08);
      case InAppHintCategory.success:
        return colors.success.withValues(alpha: 0.08);
      case InAppHintCategory.security:
        return colors.info.withValues(alpha: 0.08);
      default:
        return colors.primary.withValues(alpha: 0.05);
    }
  }

  Color _getBorderColor(DwColors colors) {
    switch (hint.category) {
      case InAppHintCategory.warning:
        return colors.warning.withValues(alpha: 0.3);
      case InAppHintCategory.error:
        return colors.error.withValues(alpha: 0.3);
      case InAppHintCategory.success:
        return colors.success.withValues(alpha: 0.3);
      case InAppHintCategory.security:
        return colors.info.withValues(alpha: 0.3);
      default:
        return colors.primary.withValues(alpha: 0.2);
    }
  }

  Color _getIconBackgroundColor(DwColors colors) {
    switch (hint.category) {
      case InAppHintCategory.warning:
        return colors.warning.withValues(alpha: 0.15);
      case InAppHintCategory.error:
        return colors.error.withValues(alpha: 0.15);
      case InAppHintCategory.success:
        return colors.success.withValues(alpha: 0.15);
      case InAppHintCategory.security:
        return colors.info.withValues(alpha: 0.15);
      default:
        return colors.primary.withValues(alpha: 0.1);
    }
  }

  Color _getIconColor(DwColors colors) {
    switch (hint.category) {
      case InAppHintCategory.warning:
        return colors.warning;
      case InAppHintCategory.error:
        return colors.error;
      case InAppHintCategory.success:
        return colors.success;
      case InAppHintCategory.security:
        return colors.info;
      default:
        return colors.primary;
    }
  }

  /// Get localized text for a hint key.
  String? _getLocalizedText(AppLocalizations? l10n, String key) {
    if (l10n == null) return null;

    switch (key) {
      // Auth hints
      case 'hint_auth_phone_title':
        return l10n.hintAuthPhoneTitle;
      case 'hint_auth_phone_body':
        return l10n.hintAuthPhoneBody;
      case 'hint_auth_otp_title':
        return l10n.hintAuthOtpTitle;
      case 'hint_auth_otp_body':
        return l10n.hintAuthOtpBody;
      case 'hint_auth_2fa_title':
        return l10n.hintAuth2faTitle;
      case 'hint_auth_2fa_body':
        return l10n.hintAuth2faBody;
      case 'hint_auth_biometric_title':
        return l10n.hintAuthBiometricTitle;
      case 'hint_auth_biometric_body':
        return l10n.hintAuthBiometricBody;

      // Payments hints
      case 'hint_payments_methods_title':
        return l10n.hintPaymentsMethodsTitle;
      case 'hint_payments_methods_body':
        return l10n.hintPaymentsMethodsBody;
      case 'hint_payments_security_title':
        return l10n.hintPaymentsSecurityTitle;
      case 'hint_payments_security_body':
        return l10n.hintPaymentsSecurityBody;
      case 'hint_payments_limited_title':
        return l10n.hintPaymentsLimitedTitle;
      case 'hint_payments_limited_body':
        return l10n.hintPaymentsLimitedBody;

      // Tracking hints
      case 'hint_tracking_explanation_title':
        return l10n.hintTrackingExplanationTitle;
      case 'hint_tracking_explanation_body':
        return l10n.hintTrackingExplanationBody;
      case 'hint_tracking_unavailable_title':
        return l10n.hintTrackingUnavailableTitle;
      case 'hint_tracking_unavailable_body':
        return l10n.hintTrackingUnavailableBody;
      case 'hint_tracking_realtime_title':
        return l10n.hintTrackingRealtimeTitle;
      case 'hint_tracking_realtime_body':
        return l10n.hintTrackingRealtimeBody;

      // Notifications hints
      case 'hint_notifications_importance_title':
        return l10n.hintNotificationsImportanceTitle;
      case 'hint_notifications_importance_body':
        return l10n.hintNotificationsImportanceBody;
      case 'hint_notifications_permission_title':
        return l10n.hintNotificationsPermissionTitle;
      case 'hint_notifications_permission_body':
        return l10n.hintNotificationsPermissionBody;
      case 'hint_notifications_permission_cta':
        return l10n.hintNotificationsPermissionCta;

      // Orders hints
      case 'hint_orders_first_title':
        return l10n.hintOrdersFirstTitle;
      case 'hint_orders_first_body':
        return l10n.hintOrdersFirstBody;
      case 'hint_orders_empty_title':
        return l10n.hintOrdersEmptyTitle;
      case 'hint_orders_empty_body':
        return l10n.hintOrdersEmptyBody;
      case 'hint_orders_empty_cta':
        return l10n.hintOrdersEmptyCta;

      default:
        return null;
    }
  }
}

/// A wrapper that shows hints for a specific screen.
class ScreenHintsWrapper extends ConsumerWidget {
  const ScreenHintsWrapper({
    super.key,
    required this.screenId,
    required this.hintsProvider,
    required this.child,
    this.showHintsAtTop = true,
  });

  /// ID of the current screen for hint targeting.
  final String screenId;

  /// Provider that returns hints for this screen.
  final FutureProvider<List<InAppHint>> hintsProvider;

  /// The main content widget.
  final Widget child;

  /// Whether to show hints at the top (true) or bottom (false).
  final bool showHintsAtTop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hintsAsync = ref.watch(hintsProvider);

    return hintsAsync.when(
      data: (hints) {
        if (hints.isEmpty) return child;

        // Show only the highest priority hint
        final hint = hints.first;

        if (showHintsAtTop) {
          return Column(
            children: [
              InAppHintBanner(hint: hint),
              Expanded(child: child),
            ],
          );
        } else {
          return Column(
            children: [
              Expanded(child: child),
              InAppHintBanner(hint: hint),
            ],
          );
        }
      },
      loading: () => child,
      error: (_, __) => child,
    );
  }
}

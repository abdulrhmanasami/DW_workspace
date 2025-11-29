import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart';

/// Component: Unified Button Component
/// Created by: Track A - Design System Implementation
/// Purpose: Consistent button styling across the app
/// Last updated: 2025-11-27

/// Unified button component with consistent styling
class AppButtonUnified extends ConsumerWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final AppButtonStyle style;
  final IconData? icon;
  final bool fullWidth;
  final EdgeInsets? padding;

  const AppButtonUnified({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.style = AppButtonStyle.primary,
    this.icon,
    this.fullWidth = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final effectivePadding = padding ?? EdgeInsets.symmetric(
      horizontal: theme.spacing.md,
      vertical: theme.spacing.sm,
    );

    final button = _buildButton(theme);

    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: Padding(
          padding: effectivePadding,
          child: button,
        ),
      );
    }

    return Padding(
      padding: effectivePadding,
      child: button,
    );
  }

  Widget _buildButton(AppThemeData theme) {
    if (isLoading) {
      return _buildLoadingButton(theme);
    }

    if (!isEnabled) {
      return _buildDisabledButton(theme);
    }

    switch (style) {
      case AppButtonStyle.primary:
        return _buildPrimaryButton(theme);
      case AppButtonStyle.secondary:
        return _buildSecondaryButton(theme);
      case AppButtonStyle.tertiary:
        return _buildTertiaryButton(theme);
      case AppButtonStyle.danger:
        return _buildDangerButton(theme);
    }
  }

  Widget _buildPrimaryButton(AppThemeData theme) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colors.primary,
        foregroundColor: theme.colors.onPrimary,
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing.lg,
          vertical: theme.spacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(theme.spacing.mediumRadius),
        ),
        elevation: 2,
      ),
      child: _buildButtonContent(theme),
    );
  }

  Widget _buildSecondaryButton(AppThemeData theme) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: theme.colors.primary,
        side: BorderSide(color: theme.colors.primary, width: 1.5),
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing.lg,
          vertical: theme.spacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(theme.spacing.mediumRadius),
        ),
      ),
      child: _buildButtonContent(theme),
    );
  }

  Widget _buildTertiaryButton(AppThemeData theme) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: theme.colors.primary,
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing.lg,
          vertical: theme.spacing.md,
        ),
      ),
      child: _buildButtonContent(theme),
    );
  }

  Widget _buildDangerButton(AppThemeData theme) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colors.error,
        foregroundColor: theme.colors.onError,
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing.lg,
          vertical: theme.spacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(theme.spacing.mediumRadius),
        ),
        elevation: 2,
      ),
      child: _buildButtonContent(theme),
    );
  }

  Widget _buildLoadingButton(AppThemeData theme) {
    return ElevatedButton(
      onPressed: null,
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colors.primary.withValues(alpha: 0.6),
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing.lg,
          vertical: theme.spacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(theme.spacing.mediumRadius),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(theme.colors.onPrimary),
            ),
          ),
          SizedBox(width: theme.spacing.sm),
          Text(label, style: theme.typography.button),
        ],
      ),
    );
  }

  Widget _buildDisabledButton(AppThemeData theme) {
    return ElevatedButton(
      onPressed: null,
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colors.onSurface.withValues(alpha: 0.2),
        foregroundColor: theme.colors.onSurface.withValues(alpha: 0.5),
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing.lg,
          vertical: theme.spacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(theme.spacing.mediumRadius),
        ),
      ),
      child: _buildButtonContent(theme),
    );
  }

  Widget _buildButtonContent(AppThemeData theme) {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          SizedBox(width: theme.spacing.sm),
          Text(label, style: theme.typography.button),
        ],
      );
    }

    return Text(label, style: theme.typography.button);
  }
}

/// Button style enum
enum AppButtonStyle {
  primary,
  secondary,
  tertiary,
  danger,
}

/// Convenience extension for creating buttons
extension AppButtonExt on AppButtonUnified {
  static AppButtonUnified primary({
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool fullWidth = false,
    IconData? icon,
  }) {
    return AppButtonUnified(
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      style: AppButtonStyle.primary,
      fullWidth: fullWidth,
      icon: icon,
    );
  }

  static AppButtonUnified secondary({
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool fullWidth = false,
    IconData? icon,
  }) {
    return AppButtonUnified(
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      style: AppButtonStyle.secondary,
      fullWidth: fullWidth,
      icon: icon,
    );
  }

  static AppButtonUnified danger({
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool fullWidth = false,
  }) {
    return AppButtonUnified(
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      style: AppButtonStyle.danger,
      fullWidth: fullWidth,
    );
  }
}

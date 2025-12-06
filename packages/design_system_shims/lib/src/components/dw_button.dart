/// DWButton - Unified Button Component for Design System
/// Created by: Ticket #25 - Design System Track A
/// Updated by: Ticket #30 - DWTheme integration
/// Purpose: Reusable button component following design tokens
/// Last updated: 2025-11-28
///
/// This component provides three variants:
/// - primary: Main CTA buttons (filled background)
/// - secondary: Secondary actions (outlined)
/// - tertiary: Text-only actions
///
/// Usage:
/// ```dart
/// DWButton.primary(
///   label: 'Request Ride',
///   onPressed: _onRequestRide,
///   isLoading: isRequesting,
/// )
/// ```

import 'package:flutter/material.dart';

import 'package:design_system_shims/src/theme/dw_theme.dart';

/// Button variants following design system tokens
enum DWButtonVariant {
  /// Primary CTA: filled background, inverse text
  primary,

  /// Secondary: transparent background, outlined border
  secondary,

  /// Tertiary: text-only, no background or border
  tertiary,
}

/// Unified button component for Delivery Ways Design System
///
/// Implements design tokens for:
/// - Colors: primary.base, primary.variant, text.inverse
/// - Typography: type.label.button (16pt, Medium)
/// - Spacing: radius.sm (8pt), padding sm/md (12-16pt)
/// - Touch target: minimum 44px height
class DWButton extends StatelessWidget {
  const DWButton._({
    required this.label,
    required this.onPressed,
    required this.variant,
    this.isLoading = false,
    this.enabled = true,
    this.leadingIcon,
    super.key,
  });

  /// The button text label
  final String label;

  /// Callback when button is pressed. Set to null to disable.
  final VoidCallback? onPressed;

  /// The visual variant of the button
  final DWButtonVariant variant;

  /// Shows a loading spinner instead of the label
  final bool isLoading;

  /// Whether the button is enabled (in addition to onPressed being non-null)
  final bool enabled;

  /// Optional icon displayed before the label
  final Widget? leadingIcon;

  /// Primary CTA button - filled background, high emphasis
  ///
  /// Use for main actions like "Request Ride", "Confirm", "Done"
  factory DWButton.primary({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool enabled = true,
    Widget? leadingIcon,
  }) {
    return DWButton._(
      key: key,
      label: label,
      onPressed: onPressed,
      variant: DWButtonVariant.primary,
      isLoading: isLoading,
      enabled: enabled,
      leadingIcon: leadingIcon,
    );
  }

  /// Secondary button - outlined, medium emphasis
  ///
  /// Use for secondary actions that need visibility
  factory DWButton.secondary({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool enabled = true,
    Widget? leadingIcon,
  }) {
    return DWButton._(
      key: key,
      label: label,
      onPressed: onPressed,
      variant: DWButtonVariant.secondary,
      isLoading: isLoading,
      enabled: enabled,
      leadingIcon: leadingIcon,
    );
  }

  /// Tertiary button - text-only, low emphasis
  ///
  /// Use for less prominent actions like "Cancel", "View trip"
  factory DWButton.tertiary({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    bool enabled = true,
  }) {
    return DWButton._(
      key: key,
      label: label,
      onPressed: onPressed,
      variant: DWButtonVariant.tertiary,
      enabled: enabled,
    );
  }

  /// Whether the button is effectively disabled
  bool get _isDisabled => !enabled || isLoading || onPressed == null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Design token: type.label.button → labelLarge with 16pt, Medium
    final buttonTextStyle = theme.textTheme.labelLarge?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w500,
    );

    // Build the button content (label or loading indicator)
    Widget content = _buildContent(colorScheme, buttonTextStyle);

    return switch (variant) {
      DWButtonVariant.primary => _buildPrimaryButton(
          context,
          colorScheme,
          buttonTextStyle,
          content,
        ),
      DWButtonVariant.secondary => _buildSecondaryButton(
          context,
          colorScheme,
          buttonTextStyle,
          content,
        ),
      DWButtonVariant.tertiary => _buildTertiaryButton(
          context,
          colorScheme,
          buttonTextStyle,
          content,
        ),
    };
  }

  /// Build button content with optional loading state
  Widget _buildContent(ColorScheme colorScheme, TextStyle? textStyle) {
    final textColor = _getTextColor(colorScheme);

    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    final labelWidget = Text(
      label,
      style: textStyle?.copyWith(color: textColor),
    );

    if (leadingIcon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          leadingIcon!,
          const SizedBox(width: 8),
          labelWidget,
        ],
      );
    }

    return labelWidget;
  }

  /// Get text color based on variant
  Color _getTextColor(ColorScheme colorScheme) {
    if (_isDisabled) {
      return colorScheme.onSurface.withValues(alpha: 0.38);
    }

    return switch (variant) {
      // Primary: inverse text on primary background
      DWButtonVariant.primary => colorScheme.onPrimary,
      // Secondary/Tertiary: primary color text
      DWButtonVariant.secondary => colorScheme.primary,
      DWButtonVariant.tertiary => colorScheme.primary,
    };
  }

  /// Build primary (filled) button
  Widget _buildPrimaryButton(
    BuildContext context,
    ColorScheme colorScheme,
    TextStyle? textStyle,
    Widget content,
  ) {
    return SizedBox(
      height: 52, // Touch target ≥ 44px
      child: ElevatedButton(
        onPressed: _isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.12),
          disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DWRadius.sm),
          ),
        ),
        child: content,
      ),
    );
  }

  /// Build secondary (outlined) button
  Widget _buildSecondaryButton(
    BuildContext context,
    ColorScheme colorScheme,
    TextStyle? textStyle,
    Widget content,
  ) {
    return SizedBox(
      height: 52, // Touch target ≥ 44px
      child: OutlinedButton(
        onPressed: _isDisabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
          side: BorderSide(
            color: _isDisabled
                ? colorScheme.onSurface.withValues(alpha: 0.12)
                : colorScheme.primary,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DWRadius.sm),
          ),
        ),
        child: content,
      ),
    );
  }

  /// Build tertiary (text-only) button
  Widget _buildTertiaryButton(
    BuildContext context,
    ColorScheme colorScheme,
    TextStyle? textStyle,
    Widget content,
  ) {
    return SizedBox(
      height: 44, // Touch target ≥ 44px
      child: TextButton(
        onPressed: _isDisabled ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DWRadius.sm),
          ),
        ),
        child: content,
      ),
    );
  }
}


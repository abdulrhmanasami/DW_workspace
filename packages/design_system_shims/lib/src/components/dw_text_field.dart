/// DWTextField - Unified Text Input Component for Design System
/// Created by: Ticket #35 - Design System Track A
/// Purpose: Reusable text input component following design tokens
/// Last updated: 2025-11-28
///
/// This component provides two variants:
/// - filled: Default filled background (surfaceContainerHighest)
/// - outlined: Outline-only with transparent background
///
/// Usage:
/// ```dart
/// DWTextField(
///   controller: _destinationController,
///   hintText: 'Where to?',
///   prefixIcon: const Icon(Icons.search),
///   onChanged: (value) => _updateSearch(value),
/// )
/// ```

import 'package:flutter/material.dart';

import 'package:design_system_shims/src/theme/dw_theme.dart';

/// Text field variants following design system tokens
enum DWTextFieldVariant {
  /// Filled: surfaceContainerHighest background with subtle border
  filled,

  /// Outlined: transparent background with visible outline
  outlined,
}

/// Unified text input component for Delivery Ways Design System
///
/// Implements design tokens for:
/// - Colors: surface, primary (focus), error states
/// - Typography: bodyMedium for input text
/// - Spacing: DWSpacing.md horizontal, DWSpacing.sm vertical
/// - Radius: DWRadius.md for rounded corners
class DWTextField extends StatelessWidget {
  const DWTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.autofocus = false,
    this.variant = DWTextFieldVariant.filled,
  });

  /// Controller for the text field
  final TextEditingController? controller;

  /// Focus node for managing focus state
  final FocusNode? focusNode;

  /// Optional label text displayed above the field
  final String? label;

  /// Hint text displayed when field is empty
  final String? hintText;

  /// Helper text displayed below the field
  final String? helperText;

  /// Error text displayed below the field (overrides helperText)
  final String? errorText;

  /// Widget displayed at the start of the field
  final Widget? prefixIcon;

  /// Widget displayed at the end of the field
  final Widget? suffixIcon;

  /// Callback when text changes
  final ValueChanged<String>? onChanged;

  /// Callback when user submits (e.g., presses enter)
  final ValueChanged<String>? onSubmitted;

  /// Callback when field is tapped
  final VoidCallback? onTap;

  /// Keyboard type for the input
  final TextInputType? keyboardType;

  /// Action button on the keyboard
  final TextInputAction? textInputAction;

  /// Whether to obscure text (for passwords)
  final bool obscureText;

  /// Whether the field is enabled
  final bool enabled;

  /// Whether the field is read-only
  final bool readOnly;

  /// Maximum number of lines
  final int maxLines;

  /// Minimum number of lines
  final int? minLines;

  /// Maximum character length
  final int? maxLength;

  /// Whether to autofocus on build
  final bool autofocus;

  /// Visual variant of the text field
  final DWTextFieldVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Design tokens: DWRadius.md for text fields
    final borderRadius = BorderRadius.circular(DWRadius.md);

    // Border styles based on state
    final baseBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(
        color: colors.outline.withValues(alpha: 0.4),
        width: 1,
      ),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(
        color: colors.primary,
        width: 2,
      ),
    );

    final errorBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(
        color: colors.error,
        width: 1.5,
      ),
    );

    final focusedErrorBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(
        color: colors.error,
        width: 2,
      ),
    );

    final disabledBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(
        color: colors.outline.withValues(alpha: 0.2),
        width: 1,
      ),
    );

    // Determine if filled based on variant
    final filled = variant == DWTextFieldVariant.filled;

    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      readOnly: readOnly,
      obscureText: obscureText,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      autofocus: autofocus,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onTap: onTap,
      style: textTheme.bodyLarge?.copyWith(
        color: enabled ? colors.onSurface : colors.onSurface.withValues(alpha: 0.5),
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        helperText: helperText,
        errorText: errorText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        isDense: true,
        filled: filled,
        fillColor: filled
            ? (enabled
                ? colors.surfaceContainerHighest
                : colors.surfaceContainerHighest.withValues(alpha: 0.5))
            : null,
        // Design tokens: DWSpacing for padding
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DWSpacing.md,
          vertical: DWSpacing.sm,
        ),
        // Border configurations
        border: baseBorder,
        enabledBorder: baseBorder,
        focusedBorder: focusedBorder,
        errorBorder: errorBorder,
        focusedErrorBorder: focusedErrorBorder,
        disabledBorder: disabledBorder,
        // Text styles
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: colors.onSurfaceVariant,
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(
          color: colors.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        helperStyle: textTheme.bodySmall?.copyWith(
          color: colors.onSurfaceVariant,
        ),
        errorStyle: textTheme.bodySmall?.copyWith(
          color: colors.error,
        ),
        // Icon styling
        prefixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return colors.primary;
          }
          if (states.contains(WidgetState.error)) {
            return colors.error;
          }
          return colors.onSurfaceVariant;
        }),
        suffixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return colors.primary;
          }
          if (states.contains(WidgetState.error)) {
            return colors.error;
          }
          return colors.onSurfaceVariant;
        }),
      ),
    );
  }
}


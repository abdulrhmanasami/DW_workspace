/// DwButton - Design System Button Atom
/// Created by: Cursor B-ux
/// Purpose: Standardized button variants using design tokens
/// Last updated: 2025-11-11

import 'package:flutter/material.dart';
import 'package:design_system_components/src/internal/tokens_bridge.dart';

/// Button variants
enum DwButtonVariant { primary, secondary, outlined, text }

/// Button sizes
enum DwButtonSize { small, medium, large }

/// Standardized button atom using design tokens
class DwButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final DwButtonVariant variant;
  final DwButtonSize size;
  final bool enabled;
  final Widget? leadingIcon;
  final bool fullWidth;

  const DwButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = DwButtonVariant.primary,
    this.size = DwButtonSize.medium,
    this.enabled = true,
    this.leadingIcon,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle();
    final textStyle = _getTextStyle();
    final padding = _getPadding();

    Widget button = ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: buttonStyle,
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leadingIcon != null) ...[
              leadingIcon!,
              SizedBox(width: TokensBridge.spacing.xs),
            ],
            Text(text, style: textStyle),
          ],
        ),
      ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }

  ButtonStyle _getButtonStyle() {
    final baseStyle = ElevatedButton.styleFrom(
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TokensBridge.spacing.mediumRadius),
      ),
    );

    switch (variant) {
      case DwButtonVariant.primary:
        return baseStyle.copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return TokensBridge.colors.grey400;
            }
            return TokensBridge.colors.primary;
          }),
          foregroundColor: WidgetStateProperty.all(
            TokensBridge.colors.onPrimary,
          ),
        );

      case DwButtonVariant.secondary:
        return baseStyle.copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return TokensBridge.colors.grey300;
            }
            return TokensBridge.colors.surface;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return TokensBridge.colors.grey600;
            }
            return TokensBridge.colors.primary;
          }),
          side: WidgetStateProperty.resolveWith((states) {
            final color = states.contains(WidgetState.disabled)
                ? TokensBridge.colors.grey400
                : TokensBridge.colors.primary;
            return BorderSide(color: color);
          }),
        );

      case DwButtonVariant.outlined:
        return baseStyle.copyWith(
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return TokensBridge.colors.grey400;
            }
            return TokensBridge.colors.primary;
          }),
          side: WidgetStateProperty.resolveWith((states) {
            final color = states.contains(WidgetState.disabled)
                ? TokensBridge.colors.grey400
                : TokensBridge.colors.primary;
            return BorderSide(color: color);
          }),
        );

      case DwButtonVariant.text:
        return baseStyle.copyWith(
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return TokensBridge.colors.grey400;
            }
            return TokensBridge.colors.primary;
          }),
          shadowColor: WidgetStateProperty.all(Colors.transparent),
        );
    }
  }

  TextStyle _getTextStyle() {
    final baseStyle = TokensBridge.typography.button;

    switch (size) {
      case DwButtonSize.small:
        return baseStyle.copyWith(fontSize: 12);
      case DwButtonSize.medium:
        return baseStyle;
      case DwButtonSize.large:
        return baseStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w600);
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case DwButtonSize.small:
        return EdgeInsets.symmetric(
          horizontal: TokensBridge.spacing.sm,
          vertical: TokensBridge.spacing.xs,
        );
      case DwButtonSize.medium:
        return EdgeInsets.symmetric(
          horizontal: TokensBridge.spacing.md,
          vertical: TokensBridge.spacing.sm,
        );
      case DwButtonSize.large:
        return EdgeInsets.symmetric(
          horizontal: TokensBridge.spacing.lg,
          vertical: TokensBridge.spacing.md,
        );
    }
  }
}

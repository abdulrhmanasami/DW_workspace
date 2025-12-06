/// DwInput - Design System Input Atom
/// Created by: Cursor B-ux
/// Purpose: Standardized text input using design tokens
/// Last updated: 2025-11-11

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:design_system_components/src/internal/tokens_bridge.dart';

/// Input variants
enum DwInputVariant { outlined, filled, underlined }

/// Input sizes
enum DwInputSize { small, medium, large }

/// Standardized input atom using design tokens
class DwInput extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? error;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool obscureText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final DwInputVariant variant;
  final DwInputSize size;

  const DwInput({
    super.key,
    this.label,
    this.hint,
    this.error,
    this.controller,
    this.onChanged,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.variant = DwInputVariant.outlined,
    this.size = DwInputSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final inputDecoration = _getInputDecoration();
    final textStyle = _getTextStyle();

    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      style: textStyle,
      decoration: inputDecoration,
    );
  }

  InputDecoration _getInputDecoration() {
    final borderRadius = BorderRadius.circular(
      TokensBridge.spacing.mediumRadius,
    );
    final borderSide = BorderSide(color: TokensBridge.colors.grey400, width: 1);
    final errorBorderSide = BorderSide(
      color: TokensBridge.colors.error,
      width: 1,
    );
    final focusedBorderSide = BorderSide(
      color: TokensBridge.colors.primary,
      width: 2,
    );

    final baseDecoration = InputDecoration(
      labelText: label,
      hintText: hint,
      errorText: error,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      contentPadding: _getContentPadding(),
      labelStyle: TokensBridge.typography.body2.copyWith(
        color: TokensBridge.colors.onSurface.withValues(alpha: 0.7),
      ),
      hintStyle: TokensBridge.typography.body2.copyWith(
        color: TokensBridge.colors.onSurface.withValues(alpha: 0.5),
      ),
      errorStyle: TokensBridge.typography.caption.copyWith(
        color: TokensBridge.colors.error,
      ),
    );

    switch (variant) {
      case DwInputVariant.outlined:
        return baseDecoration.copyWith(
          border: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: borderSide,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: borderSide,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: focusedBorderSide,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: errorBorderSide,
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: errorBorderSide,
          ),
        );

      case DwInputVariant.filled:
        return baseDecoration.copyWith(
          filled: true,
          fillColor: TokensBridge.colors.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: focusedBorderSide,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: errorBorderSide,
          ),
        );

      case DwInputVariant.underlined:
        return baseDecoration.copyWith(
          border: UnderlineInputBorder(borderSide: borderSide),
          enabledBorder: UnderlineInputBorder(borderSide: borderSide),
          focusedBorder: UnderlineInputBorder(borderSide: focusedBorderSide),
          errorBorder: UnderlineInputBorder(borderSide: errorBorderSide),
        );
    }
  }

  TextStyle _getTextStyle() {
    return TokensBridge.typography.body1.copyWith(
      color: TokensBridge.colors.onSurface,
    );
  }

  EdgeInsets _getContentPadding() {
    switch (size) {
      case DwInputSize.small:
        return EdgeInsets.symmetric(
          horizontal: TokensBridge.spacing.sm,
          vertical: TokensBridge.spacing.xs,
        );
      case DwInputSize.medium:
        return EdgeInsets.symmetric(
          horizontal: TokensBridge.spacing.md,
          vertical: TokensBridge.spacing.sm,
        );
      case DwInputSize.large:
        return EdgeInsets.symmetric(
          horizontal: TokensBridge.spacing.lg,
          vertical: TokensBridge.spacing.md,
        );
    }
  }
}

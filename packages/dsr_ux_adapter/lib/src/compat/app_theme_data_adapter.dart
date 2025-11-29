import 'package:design_system_foundation/design_system_foundation.dart';
import 'package:flutter/material.dart';

/// Legacy AppThemeData compatibility adapter
/// Converts legacy AppThemeData to modern ThemeData using Dw* tokens
class AppThemeDataAdapter {
  const AppThemeDataAdapter._();

  /// Creates a ThemeData from Dw* design tokens
  /// This replaces the legacy AppThemeData conversion
  static ThemeData fromDwTokens({
    required DwColors colors,
    required DwTypography typography,
    required DwSpacing spacing,
  }) {
    return ThemeData(
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: colors.primary,
        onPrimary: colors.onPrimary,
        primaryContainer: colors.primaryVariant,
        onPrimaryContainer: colors.onPrimary,
        secondary: colors.secondary,
        onSecondary: colors.onSecondary,
        secondaryContainer: colors.secondaryVariant,
        onSecondaryContainer: colors.onSecondary,
        tertiary: colors.accent,
        onTertiary: Colors.white,
        tertiaryContainer: colors.accent,
        onTertiaryContainer: Colors.white,
        error: colors.error,
        onError: colors.onError,
        errorContainer: colors.error,
        onErrorContainer: colors.onError,
        surface: colors.surface,
        onSurface: colors.onSurface,
        surfaceContainerHighest: colors.surfaceVariant,
        onSurfaceVariant: colors.onSurface,
        outline: colors.outline,
        outlineVariant: colors.outline,
        shadow: Colors.black26,
        scrim: Colors.black54,
        inverseSurface: colors.onSurface,
        onInverseSurface: colors.surface,
        inversePrimary: colors.primaryVariant,
        surfaceTint: colors.primary,
      ),
      textTheme: TextTheme(
        headlineLarge: typography.headline2,
        headlineMedium: typography.headline3,
        titleMedium: typography.subtitle1,
        bodyLarge: typography.body1,
        bodyMedium: typography.body2,
        bodySmall: typography.caption,
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        shadowColor: Colors.black12,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(spacing.borderRadiusMd),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: spacing.lg,
            vertical: spacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(spacing.borderRadiusMd),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(spacing.borderRadiusMd),
          borderSide: BorderSide(color: colors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(spacing.borderRadiusMd),
          borderSide: BorderSide(color: colors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(spacing.borderRadiusMd),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.outline,
        thickness: 1,
        space: spacing.md,
      ),
    );
  }
}

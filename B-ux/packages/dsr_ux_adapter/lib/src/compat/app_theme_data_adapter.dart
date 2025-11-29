import 'package:design_system_foundation/design_system_foundation.dart';
import 'package:flutter/material.dart';

/// Legacy AppThemeData compatibility adapter
/// Converts legacy AppThemeData to modern ThemeData using Dsr* tokens
class AppThemeDataAdapter {
  const AppThemeDataAdapter._();

  /// Creates a ThemeData from Dsr* design tokens (compatibility layer)
  /// This replaces the legacy AppThemeData conversion
  static ThemeData fromDwTokens({
    required DwColors colors,
    required DwTypography typography,
    required DwSpacing spacing,
  }) {
    return ThemeData(
      // Color scheme
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: colors.primary,
        onPrimary: colors.onPrimary,
        primaryContainer: colors.primary,
        onPrimaryContainer: colors.onPrimary,
        secondary: colors.surfaceMuted,
        onSecondary: colors.onSurface,
        secondaryContainer: colors.surfaceMuted,
        onSecondaryContainer: colors.onSurface,
        tertiary: colors.success,
        onTertiary: Colors.white,
        tertiaryContainer: colors.success,
        onTertiaryContainer: Colors.white,
        error: colors.error,
        onError: Colors.white,
        errorContainer: colors.error,
        onErrorContainer: Colors.white,
        surface: colors.surface,
        onSurface: colors.onSurface,
        surfaceContainerHighest: colors.card,
        onSurfaceVariant: colors.onSurface,
        outline: colors.divider,
        outlineVariant: colors.divider,
        shadow: Colors.black26,
        scrim: Colors.black54,
        inverseSurface: colors.onSurface,
        onInverseSurface: colors.surface,
        inversePrimary: colors.primaryDark,
        surfaceTint: colors.primary,
      ),

      // Typography
      textTheme: TextTheme(
        headlineLarge: typography.headlineLarge,
        headlineMedium: typography.headlineMedium,
        titleMedium: typography.titleMedium,
        bodyLarge: typography.bodyLarge,
        bodyMedium: typography.bodyMedium,
        bodySmall: typography.bodySmall,
      ),

      // Component themes
      cardTheme: CardThemeData(
        color: colors.card,
        shadowColor: Colors.black12,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: 1,
        space: spacing.md,
      ),
    );
  }
}

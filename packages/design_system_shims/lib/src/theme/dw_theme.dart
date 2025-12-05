/// DWTheme - Unified Design System Theme
/// Created by: Track A - Ticket #30
/// Purpose: Single source of truth for ThemeData based on Design Tokens
/// Last updated: 2025-11-28
///
/// This file implements the Design Tokens from the specification:
/// - Color Tokens: Primary (#00A651), Background, Surface, Text colors
/// - Typography Tokens: Headlines, Body, Labels mapped to Material TextTheme
/// - Spacing/Radius/Elevation: Following design system guidelines

import 'package:flutter/material.dart';

// =============================================================================
// Design Tokens - Spacing
// =============================================================================

/// Design Tokens: spacing.*
/// Based on 8pt grid system from Design Tokens Specification
class DWSpacing {
  DWSpacing._();

  /// spacing.xxs = 4pt
  static const double xxs = 4.0;

  /// spacing.xs = 8pt
  static const double xs = 8.0;

  /// spacing.sm = 12pt
  static const double sm = 12.0;

  /// spacing.md = 16pt
  static const double md = 16.0;

  /// spacing.lg = 24pt
  static const double lg = 24.0;

  /// spacing.xl = 32pt
  static const double xl = 32.0;

  /// spacing.xxl = 40pt
  static const double xxl = 40.0;
}

// =============================================================================
// Design Tokens - Border Radius
// =============================================================================

/// Design Tokens: radius.*
class DWRadius {
  DWRadius._();

  /// radius.xs = 4pt
  static const double xs = 4.0;

  /// radius.sm = 8pt (buttons, cards)
  static const double sm = 8.0;

  /// radius.md = 12pt (larger cards, dialogs)
  static const double md = 12.0;

  /// radius.lg = 24pt (bottom sheets)
  static const double lg = 24.0;

  /// radius.circle = 999pt (pills, avatars)
  static const double circle = 999.0;
}

// =============================================================================
// Design Tokens - Elevation
// =============================================================================

/// Design Tokens: elevation.*
class DWElevation {
  DWElevation._();

  /// elevation.none = 0
  static const double none = 0.0;

  /// elevation.low = 1
  static const double low = 1.0;

  /// elevation.medium = 2
  static const double medium = 2.0;

  /// elevation.high = 4
  static const double high = 4.0;

  /// elevation.highest = 8
  static const double highest = 8.0;
}

// =============================================================================
// Light Color Scheme
// =============================================================================

/// Design Tokens Color Scheme - Light Mode
/// Based on Design Tokens Specification
ColorScheme _buildLightColorScheme() {
  return const ColorScheme(
    brightness: Brightness.light,
    // Primary colors from tokens: color.primary.base = #00A651
    primary: Color(0xFF00A651),
    onPrimary: Color(0xFFFFFFFF),
    // Primary variant: color.primary.variant = #008C44
    primaryContainer: Color(0xFF008C44),
    onPrimaryContainer: Color(0xFFFFFFFF),
    // Secondary colors: color.secondary.base = #007BFF
    secondary: Color(0xFF007BFF),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFE3F0FF),
    onSecondaryContainer: Color(0xFF003166),
    // Tertiary/Accent: color.state.success = #388E3C
    tertiary: Color(0xFF388E3C),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFE3F5E4),
    onTertiaryContainer: Color(0xFF153619),
    // Error state: color.state.error = #D32F2F
    error: Color(0xFFD32F2F),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFE5E5),
    onErrorContainer: Color(0xFF5B0000),
    // Background: color.background.default = #FFFFFF
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1A1A1A),
    // Surface variant: color.surface.elevated = #F8F8F8
    surfaceContainerHighest: Color(0xFFF8F8F8),
    onSurfaceVariant: Color(0xFF666666),
    // Outline: color.text.muted / border
    outline: Color(0xFFAAAAAA),
    outlineVariant: Color(0xFFE0E0E0),
    // Shadow
    shadow: Color(0x1A000000),
    scrim: Color(0xFF000000),
    // Inverse colors
    inverseSurface: Color(0xFF1A1A1A),
    onInverseSurface: Color(0xFFF5F5F5),
    inversePrimary: Color(0xFF69F0AE),
  );
}

// =============================================================================
// Text Theme
// =============================================================================

/// Design Tokens Text Theme
/// Based on Design Tokens Specification:
/// - type.headline.h1 → 32pt Bold → headlineLarge
/// - type.headline.h2 → 24pt Bold → headlineMedium
/// - type.headline.h3 → 20pt Medium → headlineSmall
/// - type.title.default → 18pt Medium → titleMedium
/// - type.body.regular → 14pt Regular → bodyMedium
/// - type.caption.default → 12pt Regular → bodySmall
/// - type.label.button → 16pt Medium → labelLarge
TextTheme _buildTextTheme(ColorScheme colors) {
  return TextTheme(
    // Display styles (larger headlines)
    displayLarge: TextStyle(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      height: 1.12,
      color: colors.onSurface,
    ),
    displayMedium: TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.16,
      color: colors.onSurface,
    ),
    displaySmall: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.22,
      color: colors.onSurface,
    ),
    // Headlines - from tokens
    // type.headline.h1 = 32pt Bold
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      height: 1.25,
      color: colors.onSurface,
    ),
    // type.headline.h2 = 24pt Bold
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      height: 1.29,
      color: colors.onSurface,
    ),
    // type.headline.h3 = 20pt Medium
    headlineSmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
      height: 1.33,
      color: colors.onSurface,
    ),
    // Titles
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
      height: 1.27,
      color: colors.onSurface,
    ),
    // type.title.default = 18pt Medium
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      height: 1.33,
      color: colors.onSurface,
    ),
    // type.subtitle.default = 16pt Regular
    titleSmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.1,
      height: 1.43,
      color: colors.onSurface,
    ),
    // Body text
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      height: 1.5,
      color: colors.onSurface,
    ),
    // type.body.regular = 14pt Regular
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 1.43,
      color: colors.onSurface,
    ),
    // type.caption.default = 12pt Regular
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      height: 1.33,
      color: colors.onSurfaceVariant,
    ),
    // Labels
    // type.label.button = 16pt Medium
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.43,
      color: colors.onSurface,
    ),
    labelMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.43,
      color: colors.onSurface,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.45,
      color: colors.onSurfaceVariant,
    ),
  );
}

// =============================================================================
// Button Themes
// =============================================================================

ElevatedButtonThemeData _buildElevatedButtonTheme(
  ColorScheme colorScheme,
  TextTheme textTheme,
) {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.12),
      disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
      elevation: DWElevation.medium,
      padding: const EdgeInsets.symmetric(
        horizontal: DWSpacing.lg,
        vertical: DWSpacing.sm,
      ),
      minimumSize: const Size(64, 44), // Touch target ≥ 44px
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DWRadius.sm),
      ),
      textStyle: textTheme.labelLarge,
    ),
  );
}

OutlinedButtonThemeData _buildOutlinedButtonTheme(
  ColorScheme colorScheme,
  TextTheme textTheme,
) {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: colorScheme.primary,
      disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
      side: BorderSide(color: colorScheme.primary),
      padding: const EdgeInsets.symmetric(
        horizontal: DWSpacing.lg,
        vertical: DWSpacing.sm,
      ),
      minimumSize: const Size(64, 44),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DWRadius.sm),
      ),
      textStyle: textTheme.labelLarge,
    ),
  );
}

TextButtonThemeData _buildTextButtonTheme(
  ColorScheme colorScheme,
  TextTheme textTheme,
) {
  return TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: colorScheme.primary,
      disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
      padding: const EdgeInsets.symmetric(
        horizontal: DWSpacing.md,
        vertical: DWSpacing.xs,
      ),
      minimumSize: const Size(64, 44),
      textStyle: textTheme.labelLarge,
    ),
  );
}

// =============================================================================
// DWTheme - Main Theme Class
// =============================================================================

/// DWTheme - Unified Theme Data for Delivery Ways App
/// Implements Design Tokens from specification documents
///
/// Track A - Ticket #30
///
/// Usage:
/// ```dart
/// MaterialApp(
///   theme: DWTheme.light(),
///   // ...
/// )
/// ```
class DWTheme {
  const DWTheme._();

  /// Light theme based on Design Tokens
  static ThemeData light() {
    final colorScheme = _buildLightColorScheme();
    final textTheme = _buildTextTheme(colorScheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      // Scaffold background from tokens: color.background.default
      scaffoldBackgroundColor: colorScheme.surface,
      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: DWElevation.none,
        centerTitle: true,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      // Card theme from tokens
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: DWElevation.medium,
        shadowColor: colorScheme.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DWRadius.md),
        ),
        margin: const EdgeInsets.all(DWSpacing.xs),
      ),
      // Button themes
      elevatedButtonTheme: _buildElevatedButtonTheme(colorScheme, textTheme),
      outlinedButtonTheme: _buildOutlinedButtonTheme(colorScheme, textTheme),
      textButtonTheme: _buildTextButtonTheme(colorScheme, textTheme),
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DWSpacing.md,
          vertical: DWSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DWRadius.sm),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DWRadius.sm),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DWRadius.sm),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DWRadius.sm),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DWRadius.sm),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        errorStyle: textTheme.bodySmall?.copyWith(
          color: colorScheme.error,
        ),
      ),
      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: DWElevation.highest,
        selectedLabelStyle: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: textTheme.labelSmall,
      ),
      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: DWElevation.high,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DWRadius.md),
        ),
      ),
      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        actionTextColor: colorScheme.inversePrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DWRadius.sm),
        ),
      ),
      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        elevation: DWElevation.highest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DWRadius.md),
        ),
        titleTextStyle: textTheme.headlineSmall?.copyWith(
          color: colorScheme.onSurface,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      // Divider theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.primaryContainer,
        disabledColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(
          horizontal: DWSpacing.sm,
          vertical: DWSpacing.xxs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DWRadius.sm),
        ),
      ),
      // Icon theme
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: 24,
      ),
      // Progress indicator theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        circularTrackColor: colorScheme.surfaceContainerHighest,
        linearTrackColor: colorScheme.surfaceContainerHighest,
      ),
    );
  }
}


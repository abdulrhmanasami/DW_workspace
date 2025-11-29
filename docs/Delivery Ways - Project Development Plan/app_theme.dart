import 'package:flutter/material.dart';
import '../colors.dart';
import '../theme.dart' as theme_contract;

/// Exports for design system interfaces
export '../colors.dart' show AppColors;
export '../theme.dart' show AppTypography, AppSpacing;

/// Canonical App Theme Data - Single source of truth
/// Created by: UX-DSHIMS-PHASE-02
/// Purpose: Unified theme data implementing design system contract
/// Last updated: 2025-11-17

/// Abstract theme interface
abstract class _AppThemeDataInterface {
  AppColors get colors;
  theme_contract.AppTypography get typography;
  theme_contract.AppSpacing get spacing;
  Brightness get brightness;
}

/// Concrete theme data implementing the design system interface
class AppThemeData implements _AppThemeDataInterface {
  final int primary; // ARGB color value
  final int onPrimary; // ARGB color value
  final int background; // ARGB color value
  final int onBackground; // ARGB color value
  final int error; // ARGB color value
  final int onError; // ARGB color value
  final int surface; // ARGB color value
  final int onSurface; // ARGB color value
  final String name; // Theme name (e.g., "light", "dark")

  AppThemeData({
    this.primary = 0xFF0066FF,
    this.onPrimary = 0xFFFFFFFF,
    this.background = 0xFFF7F7F7,
    this.onBackground = 0xFF222222,
    this.error = 0xFFD32F2F,
    this.onError = 0xFFFFFFFF,
    this.surface = 0xFFFFFFFF,
    this.onSurface = 0xFF222222,
    this.name = 'light',
  });

  /// Light theme preset
  factory AppThemeData.light() => AppThemeData(
    primary: 0xFF0066FF,
    onPrimary: 0xFFFFFFFF,
    background: 0xFFF7F7F7,
    onBackground: 0xFF222222,
    error: 0xFFD32F2F,
    onError: 0xFFFFFFFF,
    surface: 0xFFFFFFFF,
    onSurface: 0xFF222222,
    name: 'light',
  );

  /// Dark theme preset
  factory AppThemeData.dark() => AppThemeData(
    primary: 0xFF0066FF,
    onPrimary: 0xFFFFFFFF,
    background: 0xFF121212,
    onBackground: 0xFFE0E0E0,
    error: 0xFFCF6679,
    onError: 0xFF000000,
    surface: 0xFF1E1E1E,
    onSurface: 0xFFE0E0E0,
    name: 'dark',
  );

  // Convert ARGB int to Color
  Color _colorFromArgb(int argb) => Color(argb);

  @override
  late final AppColors colors = _AppColors(this);
  @override
  late final theme_contract.AppTypography typography = const _AppTypography();
  @override
  late final theme_contract.AppSpacing spacing = const _AppSpacing();
  @override
  Brightness get brightness =>
      name == 'dark' ? Brightness.dark : Brightness.light;
}

/// Internal colors implementation
class _AppColors implements AppColors {
  const _AppColors(this.theme);

  final AppThemeData theme;

  @override
  Color get primary => theme._colorFromArgb(theme.primary);
  @override
  Color get primaryVariant => theme._colorFromArgb(theme.primary); // Simplified
  @override
  Color get secondary => theme._colorFromArgb(theme.primary); // Simplified
  @override
  Color get secondaryVariant => theme._colorFromArgb(theme.primary); // Simplified
  @override
  Color get accent => theme._colorFromArgb(theme.primary); // Simplified
  @override
  Color get error => theme._colorFromArgb(theme.error);
  @override
  Color get warning => theme._colorFromArgb(theme.error); // Simplified
  @override
  Color get success => theme._colorFromArgb(theme.primary); // Simplified
  @override
  Color get info => theme._colorFromArgb(theme.primary); // Simplified
  @override
  Color get background => theme._colorFromArgb(theme.background);
  @override
  Color get surface => theme._colorFromArgb(theme.surface);
  @override
  Color get surfaceVariant => theme._colorFromArgb(theme.surface); // Simplified
  @override
  Color get onPrimary => theme._colorFromArgb(theme.onPrimary);
  @override
  Color get onSecondary => theme._colorFromArgb(theme.onPrimary); // Simplified
  @override
  Color get onBackground => theme._colorFromArgb(theme.onBackground);
  @override
  Color get onSurface => theme._colorFromArgb(theme.onSurface);
  @override
  Color get onError => theme._colorFromArgb(theme.onError);
  @override
  Color get outline => theme._colorFromArgb(0xFFBDBDBD); // Default outline
  @override
  Color get grey50 => const Color(0xFFFAFAFA);
  @override
  Color get grey100 => const Color(0xFFF5F5F5);
  @override
  Color get grey200 => const Color(0xFFEEEEEE);
  @override
  Color get grey300 => const Color(0xFFE0E0E0);
  @override
  Color get grey400 => const Color(0xFFBDBDBD);
  @override
  Color get grey500 => const Color(0xFF9E9E9E);
  @override
  Color get grey600 => const Color(0xFF757575);
  @override
  Color get grey700 => const Color(0xFF616161);
  @override
  Color get grey800 => const Color(0xFF424242);
  @override
  Color get grey900 => const Color(0xFF212121);
}

/// Internal typography implementation
class _AppTypography implements theme_contract.AppTypography {
  const _AppTypography();

  @override
  TextStyle get headline1 =>
      const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1.25);
  @override
  TextStyle get headline2 =>
      const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.29);
  @override
  TextStyle get headline3 =>
      const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, height: 1.33);
  @override
  TextStyle get headline4 =>
      const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.4);
  @override
  TextStyle get headline5 =>
      const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.44);
  @override
  TextStyle get headline6 =>
      const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.5);
  @override
  TextStyle get subtitle1 => const TextStyle(fontSize: 16, height: 1.5);
  @override
  TextStyle get subtitle2 =>
      const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.57);
  @override
  TextStyle get body1 => const TextStyle(fontSize: 16, height: 1.5);
  @override
  TextStyle get body2 => const TextStyle(fontSize: 14, height: 1.43);
  @override
  TextStyle get button => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43,
    letterSpacing: 0.5,
  );
  @override
  TextStyle get caption =>
      const TextStyle(fontSize: 12, height: 1.33, letterSpacing: 0.4);
}

/// Internal spacing implementation
class _AppSpacing implements theme_contract.AppSpacing {
  const _AppSpacing();

  @override
  double get xs => 4;
  @override
  double get sm => 8;
  @override
  double get md => 16;
  @override
  double get lg => 24;
  @override
  double get xl => 32;
  @override
  double get xxl => 48;
  @override
  double get mediumRadius => 8;
  @override
  double get largeRadius => 12;
  @override
  double get thin => 1;
  @override
  double get hairline => 0.5;
}

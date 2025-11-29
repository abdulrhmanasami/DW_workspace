import 'package:flutter/material.dart';

/// Typography tokens exposed by the design system.
abstract class AppTypography {
  const AppTypography();

  TextStyle get headline1;
  TextStyle get headline2;
  TextStyle get headline3;
  TextStyle get headline4;
  TextStyle get headline5;
  TextStyle get headline6;
  TextStyle get subtitle1;
  TextStyle get subtitle2;
  TextStyle get body1;
  TextStyle get body2;
  TextStyle get button;
  TextStyle get caption;
}

/// Spacing, radii and stroke tokens.
abstract class AppSpacing {
  const AppSpacing();

  double get xs;
  double get sm;
  double get md;
  double get lg;
  double get xl;
  double get xxl;

  double get mediumRadius;
  double get largeRadius;

  double get thin;
  double get hairline;
}

// Note: AppThemeData interface moved to app_theme.dart to avoid naming conflicts
// The concrete AppThemeData class now implements the interface directly

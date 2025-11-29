import 'package:flutter/material.dart';

/// Canonical color contract for the design system.
abstract class AppColors {
  const AppColors();

  Color get primary;
  Color get primaryVariant;
  Color get secondary;
  Color get secondaryVariant;
  Color get accent;
  Color get error;
  Color get warning;
  Color get success;
  Color get info;

  Color get background;
  Color get surface;
  Color get surfaceVariant;
  Color get onPrimary;
  Color get onSecondary;
  Color get onBackground;
  Color get onSurface;
  Color get onError;

  Color get outline;

  Color get grey50;
  Color get grey100;
  Color get grey200;
  Color get grey300;
  Color get grey400;
  Color get grey500;
  Color get grey600;
  Color get grey700;
  Color get grey800;
  Color get grey900;
}

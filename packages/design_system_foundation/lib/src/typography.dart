/// Design System Typography Tokens
/// Created by: Cursor B-ux (auto-generated)
/// Purpose: Typography tokens and text styles scale
/// Last updated: 2025-11-11
/// Note: This package contains only design tokens, not UI components

import 'package:flutter/material.dart';

/// Abstract design system typography tokens interface
abstract class DwTypographyTokens {
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
  TextStyle get overline;
}

/// Delivery Ways typography tokens implementation
class DwTypography implements DwTypographyTokens {
  @override
  TextStyle get headline1 => const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w300,
    letterSpacing: -1.5,
    height: 1.2,
  );

  @override
  TextStyle get headline2 => const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w300,
    letterSpacing: -0.5,
    height: 1.2,
  );

  @override
  TextStyle get headline3 => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    height: 1.2,
  );

  @override
  TextStyle get headline4 => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.2,
  );

  @override
  TextStyle get headline5 => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    height: 1.2,
  );

  @override
  TextStyle get headline6 => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.2,
  );

  @override
  TextStyle get subtitle1 => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.4,
  );

  @override
  TextStyle get subtitle2 => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
  );

  @override
  TextStyle get body1 => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );

  @override
  TextStyle get body2 => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.5,
  );

  @override
  TextStyle get button => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.25,
    height: 1.2,
  );

  @override
  TextStyle get caption => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.4,
  );

  @override
  TextStyle get overline => const TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    letterSpacing: 1.5,
    height: 1.2,
  );

  // Material 3 style aliases for compatibility
  TextStyle get headlineLarge => headline1;
  TextStyle get headlineMedium => headline2;
  TextStyle get titleMedium => headline5;
  TextStyle get bodyLarge => body1;
  TextStyle get bodyMedium => body2;
  TextStyle get bodySmall => caption;
}

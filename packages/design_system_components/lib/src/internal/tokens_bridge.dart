/// Tokens Bridge - Light connection to design_system_foundation
/// Created by: Cursor B-ux
/// Purpose: Bridge atoms to foundation tokens without heavy logic
/// Last updated: 2025-11-11

import 'package:design_system_foundation/design_system_foundation.dart';

/// Light bridge to access design tokens
/// This ensures atoms consume tokens without domain logic
class TokensBridge {
  TokensBridge._();

  // Singleton instances
  static final DwColors _colors = DwColors();
  static final DwTypography _typography = DwTypography();
  static final DwSpacing _spacing = DwSpacing();
  static final DwShadows _shadows = DwShadows();
  static final DwMotion _motion = DwMotion();
  static final DwBorders _borders = DwBorders();

  // Colors
  static DwColors get colors => _colors;
  static DwColorTokens get colorTokens => _colors;

  // Typography
  static DwTypography get typography => _typography;
  static DwTypographyTokens get typographyTokens => _typography;

  // Spacing
  static DwSpacing get spacing => _spacing;
  static DwSpacingTokens get spacingTokens => _spacing;

  // Shadows
  static DwShadows get shadows => _shadows;
  static DwShadowTokens get shadowTokens => _shadows;

  // Motion
  static DwMotion get motion => _motion;
  static DwMotionTokens get motionTokens => _motion;

  // Borders
  static DwBorders get borders => _borders;
  static DwBorderTokens get borderTokens => _borders;
}

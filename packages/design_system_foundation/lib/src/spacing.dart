/// Design System Spacing Tokens
/// Created by: Cursor B-ux (auto-generated)
/// Purpose: Spacing tokens and layout system
/// Last updated: 2025-11-11
/// Note: This package contains only design tokens, not UI components

import 'package:flutter/material.dart';

/// Abstract design system spacing tokens interface
abstract class DwSpacingTokens {
  double get xxs; // 2
  double get xs; // 4
  double get sm; // 8
  double get md; // 16
  double get lg; // 24
  double get xl; // 32
  double get xxl; // 48
  double get xxxl; // 64

  // Additional spacing for specific use cases
  double get iconSm; // 12
  double get iconMd; // 16
  double get iconLg; // 24

  double get borderRadiusSm; // 4
  double get borderRadiusMd; // 8
  double get borderRadiusLg; // 12
  double get borderRadiusXl; // 16

  // Aliases for convenience
  double get smallRadius => borderRadiusSm;
  double get mediumRadius => borderRadiusMd;
  double get largeRadius => borderRadiusLg;
  double get extraLargeRadius => borderRadiusXl;
}

/// Delivery Ways spacing tokens implementation
class DwSpacing implements DwSpacingTokens {
  @override
  double get xxs => 2;

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
  double get xxxl => 64;

  @override
  double get iconSm => 12;

  @override
  double get iconMd => 16;

  @override
  double get iconLg => 24;

  @override
  double get borderRadiusSm => 4;

  @override
  double get borderRadiusMd => 8;

  @override
  double get borderRadiusLg => 12;

  @override
  double get borderRadiusXl => 16;

  @override
  double get smallRadius => borderRadiusSm;

  @override
  double get mediumRadius => borderRadiusMd;

  @override
  double get largeRadius => borderRadiusLg;

  @override
  double get extraLargeRadius => borderRadiusXl;

  // Convenience methods for EdgeInsets
  EdgeInsets all(double value) => EdgeInsets.all(value);

  EdgeInsets symmetric({double horizontal = 0, double vertical = 0}) =>
      EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);

  EdgeInsets only({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) =>
      EdgeInsets.only(left: left, top: top, right: right, bottom: bottom);
}

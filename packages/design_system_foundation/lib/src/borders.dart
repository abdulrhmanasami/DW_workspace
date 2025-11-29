/// Design System Border Tokens
/// Created by: Cursor B-ux (auto-generated)
/// Purpose: Border tokens and styling system
/// Last updated: 2025-11-11
/// Note: This package contains only design tokens, not UI components

import 'package:flutter/material.dart';

/// Abstract design system border tokens interface
abstract class DwBorderTokens {
  // Border width tokens
  double get none; // 0
  double get thin; // 1
  double get medium; // 2
  double get thick; // 4

  // Border radius tokens
  double get noneRadius; // 0
  double get smallRadius; // 4
  double get mediumRadius; // 8
  double get largeRadius; // 12
  double get fullRadius; // 999 (effectively full)

  // Common border styles
  Border get thinBorder;
  Border get mediumBorder;
  Border get focusBorder;

  // Border side tokens
  BorderSide get thinSide;
  BorderSide get mediumSide;
  BorderSide get thickSide;
}

/// Delivery Ways border tokens implementation
class DwBorders implements DwBorderTokens {
  @override
  double get none => 0;

  @override
  double get thin => 1;

  @override
  double get medium => 2;

  @override
  double get thick => 4;

  @override
  double get noneRadius => 0;

  @override
  double get smallRadius => 4;

  @override
  double get mediumRadius => 8;

  @override
  double get largeRadius => 12;

  @override
  double get fullRadius => 999;

  @override
  Border get thinBorder => Border.all(width: thin, color: Colors.black12);

  @override
  Border get mediumBorder => Border.all(width: medium, color: Colors.black26);

  @override
  Border get focusBorder =>
      Border.all(width: 2, color: const Color(0xFF1976D2));

  @override
  BorderSide get thinSide => const BorderSide(width: 1, color: Colors.black12);

  @override
  BorderSide get mediumSide =>
      const BorderSide(width: 2, color: Colors.black26);

  @override
  BorderSide get thickSide => const BorderSide(width: 4, color: Colors.black38);
}

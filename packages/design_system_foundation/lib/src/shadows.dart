/// Design System Shadow Tokens
/// Created by: Cursor B-ux (auto-generated)
/// Purpose: Shadow tokens and elevation system
/// Last updated: 2025-11-11
/// Note: This package contains only design tokens, not UI components

import 'package:flutter/material.dart';

/// Abstract design system shadow tokens interface
abstract class DwShadowTokens {
  List<BoxShadow> get elevation0;
  List<BoxShadow> get elevation1;
  List<BoxShadow> get elevation2;
  List<BoxShadow> get elevation3;
  List<BoxShadow> get elevation4;
  List<BoxShadow> get elevation6;
  List<BoxShadow> get elevation8;
  List<BoxShadow> get elevation12;
  List<BoxShadow> get elevation16;
  List<BoxShadow> get elevation24;
}

/// Delivery Ways shadow tokens implementation
class DwShadows implements DwShadowTokens {
  @override
  List<BoxShadow> get elevation0 => [];

  @override
  List<BoxShadow> get elevation1 => [
    const BoxShadow(
      color: Color(0x1F000000),
      offset: Offset(0, 2),
      blurRadius: 1,
      spreadRadius: -1,
    ),
  ];

  @override
  List<BoxShadow> get elevation2 => [
    const BoxShadow(
      color: Color(0x1F000000),
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
    const BoxShadow(
      color: Color(0x0F000000),
      offset: Offset(0, 1),
      blurRadius: 1,
      spreadRadius: 0,
    ),
  ];

  @override
  List<BoxShadow> get elevation3 => [
    const BoxShadow(
      color: Color(0x1F000000),
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
    const BoxShadow(
      color: Color(0x0F000000),
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 3,
    ),
  ];

  @override
  List<BoxShadow> get elevation4 => [
    const BoxShadow(
      color: Color(0x1F000000),
      offset: Offset(0, 2),
      blurRadius: 3,
      spreadRadius: -1,
    ),
    const BoxShadow(
      color: Color(0x0F000000),
      offset: Offset(0, 4),
      blurRadius: 4,
      spreadRadius: -2,
    ),
  ];

  @override
  List<BoxShadow> get elevation6 => [
    const BoxShadow(
      color: Color(0x1F000000),
      offset: Offset(0, 3),
      blurRadius: 5,
      spreadRadius: -1,
    ),
    const BoxShadow(
      color: Color(0x0F000000),
      offset: Offset(0, 6),
      blurRadius: 10,
      spreadRadius: 0,
    ),
  ];

  @override
  List<BoxShadow> get elevation8 => [
    const BoxShadow(
      color: Color(0x1F000000),
      offset: Offset(0, 5),
      blurRadius: 5,
      spreadRadius: -3,
    ),
    const BoxShadow(
      color: Color(0x0F000000),
      offset: Offset(0, 8),
      blurRadius: 10,
      spreadRadius: 1,
    ),
  ];

  @override
  List<BoxShadow> get elevation12 => [
    const BoxShadow(
      color: Color(0x1F000000),
      offset: Offset(0, 7),
      blurRadius: 8,
      spreadRadius: -4,
    ),
    const BoxShadow(
      color: Color(0x0F000000),
      offset: Offset(0, 12),
      blurRadius: 17,
      spreadRadius: 2,
    ),
  ];

  @override
  List<BoxShadow> get elevation16 => [
    const BoxShadow(
      color: Color(0x1F000000),
      offset: Offset(0, 8),
      blurRadius: 10,
      spreadRadius: -5,
    ),
    const BoxShadow(
      color: Color(0x0F000000),
      offset: Offset(0, 16),
      blurRadius: 24,
      spreadRadius: 2,
    ),
  ];

  @override
  List<BoxShadow> get elevation24 => [
    const BoxShadow(
      color: Color(0x1F000000),
      offset: Offset(0, 11),
      blurRadius: 15,
      spreadRadius: -7,
    ),
    const BoxShadow(
      color: Color(0x0F000000),
      offset: Offset(0, 24),
      blurRadius: 38,
      spreadRadius: 3,
    ),
  ];

  // Semantic shadow aliases
  List<BoxShadow> get card => elevation2;
}

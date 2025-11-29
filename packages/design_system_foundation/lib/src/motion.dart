/// Design System Motion Tokens
/// Created by: Cursor B-ux (auto-generated)
/// Purpose: Motion tokens and animation curves
/// Last updated: 2025-11-11
/// Note: This package contains only design tokens, not UI components

import 'package:flutter/material.dart';

/// Abstract design system motion tokens interface
abstract class DwMotionTokens {
  // Duration tokens
  Duration get instant; // 0ms
  Duration get fast; // 150ms
  Duration get normal; // 300ms
  Duration get slow; // 500ms

  // Curve tokens
  Curve get easeIn;
  Curve get easeOut;
  Curve get easeInOut;
  Curve get bounce;
  Curve get linear;

  // Common animations
  Duration get buttonPressDuration;
  Duration get pageTransitionDuration;
  Duration get fadeDuration;
  Curve get buttonPressCurve;
  Curve get pageTransitionCurve;
}

/// Delivery Ways motion tokens implementation
class DwMotion implements DwMotionTokens {
  @override
  Duration get instant => const Duration(milliseconds: 0);

  @override
  Duration get fast => const Duration(milliseconds: 150);

  @override
  Duration get normal => const Duration(milliseconds: 300);

  @override
  Duration get slow => const Duration(milliseconds: 500);

  @override
  Curve get easeIn => Curves.easeIn;

  @override
  Curve get easeOut => Curves.easeOut;

  @override
  Curve get easeInOut => Curves.easeInOut;

  @override
  Curve get bounce => Curves.bounceOut;

  @override
  Curve get linear => Curves.linear;

  @override
  Duration get buttonPressDuration => const Duration(milliseconds: 100);

  @override
  Duration get pageTransitionDuration => const Duration(milliseconds: 300);

  @override
  Duration get fadeDuration => const Duration(milliseconds: 200);

  @override
  Curve get buttonPressCurve => Curves.easeInOut;

  @override
  Curve get pageTransitionCurve => Curves.easeInOut;
}

/// Design System Color Tokens
/// Created by: Cursor B-ux (auto-generated)
/// Purpose: Color tokens and design language for the app
/// Last updated: 2025-11-11
/// Note: This package contains only design tokens, not UI components

import 'package:flutter/material.dart';

/// Abstract design system color tokens interface
abstract class DwColorTokens {
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
}

/// Delivery Ways color tokens implementation
class DwColors implements DwColorTokens {
  @override
  Color get primary => const Color(0xFF1976D2); // Blue 700

  @override
  Color get primaryVariant => const Color(0xFF0D47A1); // Blue 900

  @override
  Color get secondary => const Color(0xFFFF6F00); // Orange 800

  @override
  Color get secondaryVariant => const Color(0xFFE65100); // Orange 900

  @override
  Color get accent => const Color(0xFF00ACC1); // Cyan 600

  @override
  Color get error => const Color(0xFFD32F2F); // Red 700

  @override
  Color get warning => const Color(0xFFF57C00); // Orange 700

  @override
  Color get success => const Color(0xFF388E3C); // Green 700

  @override
  Color get info => const Color(0xFF1976D2); // Blue 700

  @override
  Color get background => const Color(0xFFFAFAFA); // Grey 50

  @override
  Color get surface => Colors.white;

  @override
  Color get surfaceVariant => const Color(0xFFF5F5F5); // Grey 100

  @override
  Color get onPrimary => Colors.white;

  @override
  Color get onSecondary => Colors.white;

  @override
  Color get onBackground => Colors.black87;

  @override
  Color get onSurface => Colors.black87;

  @override
  Color get onError => Colors.white;

  // Additional colors (not in interface)
  Color get outline => const Color(0xFFBDBDBD); // Grey 400

  // Extended color palette for specific use cases
  Color get grey50 => const Color(0xFFFAFAFA);
  Color get grey100 => const Color(0xFFF5F5F5);
  Color get grey200 => const Color(0xFFEEEEEE);
  Color get grey300 => const Color(0xFFE0E0E0);
  Color get grey400 => const Color(0xFFBDBDBD);
  Color get grey500 => const Color(0xFF9E9E9E);
  Color get grey600 => const Color(0xFF757575);
  Color get grey700 => const Color(0xFF616161);
  Color get grey800 => const Color(0xFF424242);
  Color get grey900 => const Color(0xFF212121);

  // Additional semantic colors for components
  Color get card => Colors.white;
  Color get divider => grey300;
  Color get surfaceMuted => grey100;
  Color get primaryDark => const Color(0xFF0D47A1); // Blue 900
}

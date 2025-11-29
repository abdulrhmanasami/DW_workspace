import 'package:design_system_foundation/design_system_foundation.dart';
import 'package:flutter/material.dart';

/// Singleton instances for design system tokens
final DwColors _dwColors = DwColors();
final DwTypography _dwTypography = DwTypography();
final DwSpacing _dwSpacing = DwSpacing();
final DwShadows _dwShadows = DwShadows();

/// Tokens Bridge - Compatibility layer for design system tokens
/// Provides unified access to DwColors, DwTypography, DwSpacing tokens
/// without exposing internal implementation details

/// Colors compatibility bridge
/// Maps application color expectations to DwColors implementation
abstract class DsrColors {
  // Surface colors
  static Color get surface => _dwColors.surface;
  static Color get surfaceMuted => _dwColors.surfaceMuted;
  static Color get onSurface => _dwColors.onSurface;

  // Interactive colors
  static Color get primary => _dwColors.primary;
  static Color get primaryDark => _dwColors.primaryDark;
  static Color get onPrimary => _dwColors.onPrimary;

  // Semantic colors
  static Color get success => _dwColors.success;
  static Color get warning => _dwColors.warning;
  static Color get error => _dwColors.error;

  // Layout colors
  static Color get card => _dwColors.card;
  static Color get divider => _dwColors.divider;
}

/// Input field compatibility widget
/// Provides DwInput with flexible prefixIcon parameter
class DwInput extends StatelessWidget {
  const DwInput({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.onChanged,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final dynamic prefixIcon; // Accepts both IconData and Widget
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: _dwColors.surfaceMuted),
    );

    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: prefixIcon == null
            ? null
            : prefixIcon is IconData
                ? Icon(prefixIcon, color: _dwColors.onSurface.withOpacity(0.6))
                : prefixIcon as Widget,
        filled: true,
        fillColor: _dwColors.card,
        labelStyle: _dwTypography.bodyMedium.copyWith(color: _dwColors.onSurface),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: _dwColors.primary, width: 1.5),
        ),
      ),
      style: _dwTypography.bodyLarge,
    );
  }
}

/// Typography compatibility bridge
/// Maps application typography expectations to DwTypography implementation
abstract class DsrTypography {
  static TextStyle get headlineLarge => _dwTypography.headlineLarge;
  static TextStyle get headlineMedium => _dwTypography.headlineMedium;
  static TextStyle get titleMedium => _dwTypography.titleMedium;
  static TextStyle get bodyLarge => _dwTypography.bodyLarge;
  static TextStyle get bodyMedium => _dwTypography.bodyMedium;
  static TextStyle get bodySmall => _dwTypography.bodySmall;
}

/// Spacing compatibility bridge
/// Maps application spacing expectations to DwSpacing implementation
abstract class DsrSpacing {
  static double get xxs => _dwSpacing.xxs;
  static double get xs => _dwSpacing.xs;
  static double get sm => _dwSpacing.sm;
  static double get md => _dwSpacing.md;
  static double get lg => _dwSpacing.lg;
  static double get xl => _dwSpacing.xl;
  static double get xxl => _dwSpacing.xxl;

  static EdgeInsets all(double value) => _dwSpacing.all(value);
  static EdgeInsets symmetric({double vertical = 0, double horizontal = 0}) =>
      _dwSpacing.symmetric(vertical: vertical, horizontal: horizontal);
  static EdgeInsets only({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) => _dwSpacing.only(left: left, top: top, right: right, bottom: bottom);
}

/// Shadows compatibility bridge
/// Maps application shadow expectations to DwShadows implementation
abstract class DsrShadows {
  static List<BoxShadow> get card => _dwShadows.card;
  static List<BoxShadow> get elevation1 => _dwShadows.elevation1;
  static List<BoxShadow> get elevation2 => _dwShadows.elevation2;
  static List<BoxShadow> get elevation3 => _dwShadows.elevation3;
}

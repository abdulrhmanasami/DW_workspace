import 'package:design_system_foundation/design_system_foundation.dart';
import 'package:flutter/material.dart';

import 'app_button_adapter.dart';
import 'app_card_adapter.dart';
import 'app_theme_data_adapter.dart';

/// Material Design Overrides Registry
/// Provides legacy component overrides for smooth migration

/// Global material design overrides for App* components
/// This enables AppButton, AppCard, etc. to work with the new Dw* system
/// Note: Since Flutter doesn't have built-in component overrides,
/// this serves as a conceptual registry for migration purposes
final materialDesignOverrides = <String, Widget Function(Map<String, dynamic>)>{
  'AppButton.primary': _appButtonPrimaryBuilder,
  'AppButton.secondary': _appButtonSecondaryBuilder,
  'AppCard.standard': _appCardStandardBuilder,
};

/// Builder for AppButton.primary
Widget _appButtonPrimaryBuilder(Map<String, dynamic> props) {
  return AppButtonAdapter.primary(
    label: props['label'] as String,
    onPressed: props['onPressed'] as VoidCallback,
    leadingIcon: props['leadingIcon'] as Widget?,
    expanded: props['expanded'] as bool? ?? false,
  );
}

/// Builder for AppButton.secondary
Widget _appButtonSecondaryBuilder(Map<String, dynamic> props) {
  return AppButtonAdapter.secondary(
    label: props['label'] as String,
    onPressed: props['onPressed'] as VoidCallback,
    leadingIcon: props['leadingIcon'] as Widget?,
    expanded: props['expanded'] as bool? ?? false,
  );
}

/// Builder for AppCard.standard
Widget _appCardStandardBuilder(Map<String, dynamic> props) {
  return AppCardAdapter.standard(
    child: props['child'] as Widget,
    padding: props['padding'] as EdgeInsets?,
    margin: props['margin'] as EdgeInsets?,
  );
}

/// Creates AppThemeData from Dw* tokens
ThemeData createAppThemeData() {
  final colors = DwColors();
  final typography = DwTypography();
  final spacing = DwSpacing();

  return AppThemeDataAdapter.fromDwTokens(
    colors: colors,
    typography: typography,
    spacing: spacing,
  );
}

/// Global flag to ensure UX overrides are registered only once
bool _uxOverridesRegistered = false;

/// Registers UX overrides with the material design system
/// Call this function in main.dart before runApp()
/// This function is idempotent - safe to call multiple times
void registerUxOverrides() {
  // Idempotency guard - prevent duplicate registration
  if (_uxOverridesRegistered) {
    return;
  }
  _uxOverridesRegistered = true;

  // Initialize design system tokens to ensure they're available
  DwColors();
  DwTypography();
  DwSpacing();
  DwShadows();

  // This function serves as a registration checkpoint
  // In the actual implementation, component overrides are handled
  // through direct adapter usage rather than global registry

  // The registry above serves as documentation of available overrides
  // and ensures all adapters are properly initialized
}

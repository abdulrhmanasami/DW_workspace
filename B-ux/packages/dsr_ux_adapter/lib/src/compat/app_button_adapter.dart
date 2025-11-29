import 'package:design_system_components/design_system_components.dart';
import 'package:flutter/widgets.dart';

/// Legacy AppButton compatibility adapter
/// Bridges old AppButton API to new DwButton component
class AppButtonAdapter {
  const AppButtonAdapter._();

  /// Creates a primary AppButton (legacy API compatibility)
  static Widget primary({
    required String label,
    required VoidCallback onPressed,
    Widget? leadingIcon,
    bool expanded = false,
  }) {
    return DwButton(
      text: label,
      onPressed: onPressed,
      variant: DwButtonVariant.primary,
      leadingIcon: leadingIcon,
      fullWidth: expanded,
    );
  }

  /// Creates a secondary AppButton (legacy API compatibility)
  static Widget secondary({
    required String label,
    required VoidCallback onPressed,
    Widget? leadingIcon,
    bool expanded = false,
  }) {
    return DwButton(
      text: label,
      onPressed: onPressed,
      variant: DwButtonVariant.secondary,
      leadingIcon: leadingIcon,
      fullWidth: expanded,
    );
  }
}

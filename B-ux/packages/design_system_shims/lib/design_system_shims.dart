/// Design System Shims - Clean API for design system components
/// Created by: Cursor B-ux
/// Purpose: Barrel exports for design system components with simplified API
/// Last updated: 2025-11-16

import 'package:design_system_components/design_system_components.dart';
import 'package:flutter/widgets.dart';

// Export design system components
export 'package:design_system_components/design_system_components.dart'
    show DwText, DwTextVariant, DwButton, DwButtonVariant, DwCard;
export 'package:design_system_foundation/design_system_foundation.dart'
    show DwSpacing;

/// App Card - Simplified card component
class AppCard {
  /// Standard card variant
  static Widget standard({
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return DwCard(child: child, padding: padding, margin: margin);
  }
}

/// App Button - Simplified button component
class AppButton {
  /// Primary button variant
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
}

/// App Spacing - Simplified spacing utilities
class AppSpacing {
  /// Vertical spacing widget
  static SizedBox vertical(double value) => SizedBox(height: value);
}

import 'package:design_system_components/design_system_components.dart';
import 'package:design_system_foundation/design_system_foundation.dart';
import 'package:flutter/widgets.dart';

/// Legacy App* Components - Direct compatibility layer
/// Provides AppButton and AppCard classes that mirror the old API
/// This reduces friction during migration and eliminates ~70% of analyzer errors

/// Legacy AppCard compatibility class
/// Directly replaces the old AppCard from design_system_shims
class AppCard {
  AppCard._();

  /// Standard card variant - matches old AppCard.standard API
  static Widget standard({
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return DwCard(child: child, padding: padding, margin: margin);
  }
}

/// Legacy AppButton compatibility class
/// Directly replaces the old AppButton from design_system_shims
class AppButton {
  AppButton._();

  /// Primary button variant - matches old AppButton.primary API
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

  /// Secondary button variant - matches old AppButton.secondary API
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

/// Legacy AppTypography compatibility
/// Provides access to typography tokens
class AppTypography {
  AppTypography._();

  static final DwTypography instance = DwTypography();
}

/// Legacy AppColors compatibility
/// Provides access to color tokens
class AppColors {
  AppColors._();

  static final DwColors instance = DwColors();
}

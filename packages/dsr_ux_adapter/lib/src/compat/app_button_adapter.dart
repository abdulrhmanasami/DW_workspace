import 'package:design_system_shims/design_system_shims.dart' as ds;
import 'package:flutter/material.dart';

/// Legacy AppButton compatibility adapter
/// Bridges old AppButton API to new AppButton shim implementation
class AppButtonAdapter {
  const AppButtonAdapter._();

  /// Creates a primary AppButton (legacy API compatibility)
  static Widget primary({
    required String label,
    required VoidCallback? onPressed,
    IconData? leadingIcon,
    bool expanded = false,
    bool loading = false,
  }) {
    return AppButton.primary(
      label: label,
      onPressed: onPressed,
      leadingIcon: leadingIcon,
      expanded: expanded,
      loading: loading,
    );
  }

  /// Creates a secondary AppButton (legacy API compatibility)
  static Widget secondary({
    required String label,
    required VoidCallback? onPressed,
    IconData? leadingIcon,
    bool expanded = false,
    bool loading = false,
  }) {
    return AppButton.secondary(
      label: label,
      onPressed: onPressed,
      leadingIcon: leadingIcon,
      expanded: expanded,
      loading: loading,
    );
  }
}

/// Legacy AppButton widget for direct construction
/// Provides AppButton.primary() and AppButton.secondary() constructor compatibility
class AppButton extends StatelessWidget {
  const AppButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.leadingIcon,
    this.expanded = false,
    this.loading = false,
  }) : variant = AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.leadingIcon,
    this.expanded = false,
    this.loading = false,
  }) : variant = AppButtonVariant.secondary;

  final String label;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final bool expanded;
  final bool loading;
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final leading = leadingIcon != null ? Icon(leadingIcon) : null;
    // Secondary buttons fallback to primary styling until DS exposes variants.
    return ds.AppButton.primary(
      label: label,
      onPressed: onPressed,
      expanded: expanded,
      loading: loading,
      leadingIcon: leading,
    );
  }
}

/// Button variant type for AppButton
enum AppButtonVariant { primary, secondary }

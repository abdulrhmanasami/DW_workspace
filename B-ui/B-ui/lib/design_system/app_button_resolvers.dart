/// Component: AppButtonResolvers
/// Created by: DW-UI-PHASE4-UI-RESOLVERS-APPBUTTON
/// Purpose: Bridge design_system_shims.AppButton to B-ui components
/// Last updated: 2025-11-25

import 'package:design_system_components/design_system_components.dart';
import 'package:design_system_shims/design_system_shims.dart' as ds;
import 'package:flutter/material.dart';

bool _appButtonResolversRegistered = false;

/// Registers the concrete resolvers required by design_system_shims.AppButton.
void registerAppButtonResolvers() {
  if (_appButtonResolversRegistered) {
    return;
  }

  ds.registerAppButtonPrimaryResolver(_buildPrimaryButton);
  _appButtonResolversRegistered = true;
}

ds.AppButton _buildPrimaryButton({
  Key? key,
  required String label,
  VoidCallback? onPressed,
  bool expanded = false,
  bool loading = false,
  Widget? leadingIcon,
}) {
  return _BuiAppButtonPrimary(
    key: key,
    label: label,
    onPressed: onPressed,
    expanded: expanded,
    loading: loading,
    leadingIcon: leadingIcon,
  );
}

class _BuiAppButtonPrimary extends ds.AppButton {
  const _BuiAppButtonPrimary({
    super.key,
    required this.label,
    this.onPressed,
    this.expanded = false,
    this.loading = false,
    this.leadingIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expanded;
  final bool loading;
  final Widget? leadingIcon;

  @override
  Widget build(BuildContext context) {
    final button = DwButton(
      text: label,
      onPressed: onPressed,
      leadingIcon: leadingIcon,
      variant: DwButtonVariant.primary,
      fullWidth: expanded,
      enabled: !loading && onPressed != null,
    );

    if (!loading) {
      return button;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(
          opacity: 0.5,
          child: IgnorePointer(child: button),
        ),
        const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ],
    );
  }
}


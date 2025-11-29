import 'package:design_system_shims/design_system_shims.dart' as ds;
import 'package:flutter/material.dart';

/// Compatibility wrapper for DwButton to support legacy 'label' parameter
class DwButton extends StatelessWidget {
  DwButton({
    super.key,
    String? label, // Legacy parameter name
    String? text, // New parameter name
    required VoidCallback? onPressed,
    DwButtonVariant variant = DwButtonVariant.primary,
    DwButtonSize size = DwButtonSize.medium,
    bool enabled = true,
    Widget? leadingIcon,
    bool fullWidth = false,
    bool? expanded, // Legacy parameter name
  })  : _config = _DwButtonConfig(
          label: text ?? label ?? '',
          onPressed: onPressed,
          leadingIcon: leadingIcon,
          fullWidth: expanded ?? fullWidth,
          enabled: enabled,
          variant: variant,
          size: size,
        );

  final _DwButtonConfig _config;

  @override
  Widget build(BuildContext context) {
    // Until the shims expose variants/sizes we defer to AppButton.primary.
    return ds.AppButton.primary(
      label: _config.label,
      onPressed: _config.enabled ? _config.onPressed : null,
      expanded: _config.fullWidth,
      leadingIcon: _config.leadingIcon,
    );
  }
}

/// Legacy enum placeholder to keep call sites compiling.
enum DwButtonVariant { primary, secondary }

/// Legacy enum placeholder for size tokens.
enum DwButtonSize { small, medium, large }

class _DwButtonConfig {
  final String label;
  final VoidCallback? onPressed;
  final DwButtonVariant variant;
  final DwButtonSize size;
  final bool enabled;
  final Widget? leadingIcon;
  final bool fullWidth;

  const _DwButtonConfig({
    required this.label,
    required this.onPressed,
    required this.variant,
    required this.size,
    required this.enabled,
    required this.leadingIcon,
    required this.fullWidth,
  });
}

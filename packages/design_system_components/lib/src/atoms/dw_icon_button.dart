import 'package:flutter/material.dart';

import 'package:design_system_components/src/internal/tokens_bridge.dart';

class DwIconButton extends StatelessWidget {
  const DwIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: TokensBridge.colors.primary),
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        padding: EdgeInsets.all(TokensBridge.spacing.xs),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            TokensBridge.spacing.mediumRadius,
          ),
        ),
        backgroundColor: TokensBridge.colors.surface,
      ),
    );
  }
}

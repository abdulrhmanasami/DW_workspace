import 'package:design_system_foundation/design_system_foundation.dart';
import 'package:flutter/material.dart';

class DwIconButton extends StatelessWidget {
  const DwIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  static final DwColors _colors = DwColors();
  static final DwSpacing _spacing = DwSpacing();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, color: _colors.primary),
      style: IconButton.styleFrom(
        backgroundColor: _colors.card,
        padding: _spacing.all(_spacing.sm),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

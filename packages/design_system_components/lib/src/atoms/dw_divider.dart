/// DwDivider - Design System Divider Atom
/// Created by: Cursor B-ux
/// Purpose: Standardized divider using design tokens
/// Last updated: 2025-11-11

import 'package:flutter/material.dart';
import 'package:design_system_components/src/internal/tokens_bridge.dart';

/// Divider variants
enum DwDividerVariant { horizontal, vertical }

/// Standardized divider atom using design tokens
class DwDivider extends StatelessWidget {
  final DwDividerVariant variant;
  final double? thickness;
  final Color? color;
  final double? indent;
  final double? endIndent;

  const DwDivider({
    super.key,
    this.variant = DwDividerVariant.horizontal,
    this.thickness,
    this.color,
    this.indent,
    this.endIndent,
  });

  @override
  Widget build(BuildContext context) {
    final dividerColor =
        color ?? TokensBridge.colors.onSurface.withValues(alpha: 0.12);
    final dividerThickness = thickness ?? TokensBridge.borders.thin;

    if (variant == DwDividerVariant.vertical) {
      return Container(
        width: dividerThickness,
        color: dividerColor,
        margin: EdgeInsets.symmetric(horizontal: TokensBridge.spacing.xs),
      );
    }

    return Divider(
      height: TokensBridge.spacing.sm,
      thickness: dividerThickness,
      color: dividerColor,
      indent: indent,
      endIndent: endIndent,
    );
  }
}

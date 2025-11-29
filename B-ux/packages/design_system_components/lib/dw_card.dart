import 'package:design_system_foundation/design_system_foundation.dart';
import 'package:flutter/material.dart';

class DwCard extends StatelessWidget {
  const DwCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;

  static final DwColors _colors = DwColors();
  static final DwSpacing _spacing = DwSpacing();
  static final DwShadows _shadows = DwShadows();

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ?? _spacing.all(_spacing.md),
      decoration: BoxDecoration(
        color: _colors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _shadows.card,
      ),
      child: child,
    );

    final tappable = onTap == null
        ? card
        : InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: card,
          );

    return Container(
      margin: margin ?? _spacing.only(bottom: _spacing.md),
      child: tappable,
    );
  }
}

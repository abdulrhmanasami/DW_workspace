import 'package:design_system_foundation/design_system_foundation.dart';
import 'package:flutter/material.dart';

enum DwButtonVariant { primary, secondary, text, outlined }

class DwButton extends StatelessWidget {
  const DwButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = DwButtonVariant.primary,
    this.leadingIcon,
    this.fullWidth = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final DwButtonVariant variant;
  final Widget? leadingIcon;
  final bool fullWidth;

  static final DwColors _colors = DwColors();
  static final DwTypography _typography = DwTypography();
  static final DwSpacing _spacing = DwSpacing();

  @override
  Widget build(BuildContext context) {
    final labelText = Text(
      text,
      style: _typography.bodyLarge.copyWith(color: _foregroundColor),
      textAlign: TextAlign.center,
    );

    final child = leadingIcon == null
        ? labelText
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              leadingIcon!,
              SizedBox(width: _spacing.xs),
              labelText,
            ],
          );

    final button = ElevatedButton(
      style: _buttonStyle,
      onPressed: onPressed,
      child: child,
    );

    if (!fullWidth) {
      return button;
    }

    return SizedBox(width: double.infinity, child: button);
  }

  ButtonStyle get _buttonStyle {
    final base = ElevatedButton.styleFrom(
      elevation: variant == DwButtonVariant.text ? 0 : 1,
      padding: _spacing.symmetric(
        horizontal: _spacing.lg,
        vertical: _spacing.sm,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: variant == DwButtonVariant.secondary || variant == DwButtonVariant.outlined
            ? BorderSide(color: _colors.primary)
            : BorderSide.none,
      ),
    );

    switch (variant) {
      case DwButtonVariant.primary:
        return base.copyWith(
          backgroundColor: WidgetStateProperty.all(_colors.primary),
          foregroundColor: WidgetStateProperty.all(_colors.onPrimary),
        );
      case DwButtonVariant.secondary:
        return base.copyWith(
          backgroundColor: WidgetStateProperty.all(_colors.card),
          foregroundColor: WidgetStateProperty.all(_colors.primary),
        );
      case DwButtonVariant.outlined:
        return base.copyWith(
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          foregroundColor: WidgetStateProperty.all(_colors.primary),
        );
      case DwButtonVariant.text:
        return base.copyWith(
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          foregroundColor: WidgetStateProperty.all(_colors.primary),
          shadowColor: WidgetStateProperty.all(Colors.transparent),
        );
    }
  }

  Color get _foregroundColor {
    switch (variant) {
      case DwButtonVariant.primary:
        return _colors.onPrimary;
      case DwButtonVariant.secondary:
      case DwButtonVariant.outlined:
      case DwButtonVariant.text:
        return _colors.primary;
    }
  }
}

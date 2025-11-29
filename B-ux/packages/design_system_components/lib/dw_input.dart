import 'package:design_system_foundation/design_system_foundation.dart';
import 'package:flutter/material.dart';

class DwInput extends StatelessWidget {
  const DwInput({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.onChanged,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final dynamic prefixIcon; // Accepts both IconData and Widget for compatibility
  final ValueChanged<String>? onChanged;

  static final DwColors _colors = DwColors();
  static final DwTypography _typography = DwTypography();

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: _colors.surfaceMuted),
    );

    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: prefixIcon == null
            ? null
            : prefixIcon is IconData
                ? Icon(prefixIcon, color: _colors.onSurface.withOpacity(0.6))
                : prefixIcon as Widget,
        filled: true,
        fillColor: _colors.card,
        labelStyle: _typography.bodyMedium.copyWith(color: _colors.onSurface),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: _colors.primary, width: 1.5),
        ),
      ),
      style: _typography.bodyLarge,
    );
  }
}

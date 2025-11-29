import 'package:design_system_foundation/design_system_foundation.dart';
import 'package:flutter/widgets.dart';

enum DwTextVariant { headline, title, body, bodyMuted, label }

class DwText extends StatelessWidget {
  const DwText(
    this.data, {
    super.key,
    this.variant = DwTextVariant.body,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String data;
  final DwTextVariant variant;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final colors = DwColors();
    final typography = DwTypography();

    return Text(
      data,
      style: _textStyle(colors, typography),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  TextStyle _textStyle(DwColors colors, DwTypography typography) {
    switch (variant) {
      case DwTextVariant.headline:
        return typography.headlineMedium.copyWith(color: colors.onSurface);
      case DwTextVariant.title:
        return typography.titleMedium.copyWith(color: colors.onSurface);
      case DwTextVariant.body:
        return typography.bodyMedium.copyWith(color: colors.onSurface);
      case DwTextVariant.bodyMuted:
        return typography.bodyMedium.copyWith(
          color: colors.onSurface.withOpacity(0.7),
        );
      case DwTextVariant.label:
        return typography.bodySmall.copyWith(
          color: colors.onSurface.withOpacity(0.6),
          letterSpacing: 0.2,
        );
    }
  }
}

import 'package:flutter/widgets.dart';

import '../internal/tokens_bridge.dart';

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

  const DwText.headline(
    this.data, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : variant = DwTextVariant.headline;

  final String data;
  final DwTextVariant variant;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: _resolveStyle(),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  TextStyle _resolveStyle() {
    final colors = TokensBridge.colors;
    final typography = TokensBridge.typography;

    switch (variant) {
      case DwTextVariant.headline:
        return typography.headline5.copyWith(color: colors.onSurface);
      case DwTextVariant.title:
        return typography.headline6.copyWith(color: colors.onSurface);
      case DwTextVariant.body:
        return typography.body1.copyWith(color: colors.onSurface);
      case DwTextVariant.bodyMuted:
        return typography.body2.copyWith(
          color: colors.onSurface.withOpacity(0.7),
        );
      case DwTextVariant.label:
        return typography.caption.copyWith(
          color: colors.onSurface.withOpacity(0.6),
          letterSpacing: 0.2,
        );
    }
  }
}

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:design_system_shims/design_system_shims.dart';

/// Unified app-level card widget.
///
/// الهدف:
/// - توحيد شكل البطاقات (radius + shadow + padding + colors).
/// - تقليل تكرار BoxDecoration و BoxShadow في الشاشات.
/// - الاعتماد على Theme + Design Tokens (DWRadius, DWSpacing, etc).
class AppCardUnified extends ConsumerWidget {
  const AppCardUnified({
    super.key,
    required this.child,
    this.onTap,
    this.variant = AppCardVariant.elevated,
    this.padding,
    this.margin,
    this.clipBehavior = Clip.antiAlias,
  });

  /// محتوى الكارد.
  final Widget child;

  /// حدث الضغط (اختياري).
  final VoidCallback? onTap;

  /// نمط الكارد (elevated / outlined / subtle).
  final AppCardVariant variant;

  /// هوامش داخلية (padding).
  final EdgeInsets? padding;

  /// هوامش خارجية (margin).
  final EdgeInsets? margin;

  final Clip clipBehavior;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // اختيارات النمط حسب variant.
    final Color backgroundColor;
    final BoxBorder? border;
    final List<BoxShadow>? boxShadow;

    switch (variant) {
      case AppCardVariant.elevated:
        backgroundColor = colorScheme.surface;
        border = null;
        boxShadow = [
          BoxShadow(
            blurRadius: 12,
            offset: const Offset(0, 4),
            color: colorScheme.shadow.withValues(alpha: 0.12),
          ),
        ];
        break;
      case AppCardVariant.outlined:
        backgroundColor = colorScheme.surface;
        border = Border.all(
          color: colorScheme.outlineVariant,
          width: 1,
        );
        boxShadow = null;
        break;
      case AppCardVariant.subtle:
        backgroundColor = colorScheme.surfaceContainerHighest;
        border = null;
        boxShadow = null;
        break;
    }

    Widget content = Container(
      margin: margin ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(DWRadius.lg),
        border: border,
        boxShadow: boxShadow,
      ),
      child: Padding(
        padding: padding ??
            const EdgeInsets.all(
              DWSpacing.md,
            ),
        child: child,
      ),
    );

    // دعم onTap مع InkWell.
    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(DWRadius.lg),
        clipBehavior: clipBehavior,
        child: InkWell(
          onTap: onTap,
          child: content,
        ),
      );
    }

    return content;
  }
}

/// أنماط الكارد على مستوى التطبيق.
enum AppCardVariant {
  elevated,
  outlined,
  subtle,
}

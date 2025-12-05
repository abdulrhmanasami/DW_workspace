import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_components/design_system_components.dart';

/// Unified app-level button wrapping the underlying design system button.
///
/// هدفه:
/// - منع تكرار إعدادات DwButton في كل شاشة.
/// - توحيد الـ variants (primary / secondary / outlined / text).
/// - توحيد الـ loading / enabled behavior.
class AppButtonUnified extends ConsumerWidget {
  const AppButtonUnified({
    super.key,
    required this.label,
    this.onPressed,
    this.style = AppButtonStyle.primary,
    this.isLoading = false,
    this.fullWidth = true,
    this.enabled = true,
    this.leadingIcon,
  });

  final String label;
  final VoidCallback? onPressed;

  /// هل الزر في حالة تحميل (يُعطّل onPressed ويعرض مؤشر تحميل).
  final bool isLoading;

  /// هل الزر مفعّل منطقياً (حتى لو onPressed != null).
  final bool enabled;

  /// نمط الزر (primary / secondary / outlined / text).
  final AppButtonStyle style;

  /// هل يأخذ العرض الكامل.
  final bool fullWidth;

  /// أيقونة اختيارية في بداية الزر (ستُستبدل بمؤشر تحميل عند isLoading).
  final Widget? leadingIcon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // الزر يكون فعّال فقط إذا:
    // - مفعّل منطقيًا
    // - ليس في حالة تحميل
    // - لديه onPressed
    final bool isEffectivelyEnabled =
        enabled && !isLoading && onPressed != null;

    // حدد variant الخاص بـ DwButton حسب style.
    final dwVariant = _mapStyleToVariant(style);

    // لو isLoading = true نعرض CircularProgressIndicator صغير مكان الأيقونة.
    final Widget? effectiveLeadingIcon;
    if (isLoading) {
      effectiveLeadingIcon = SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            colorScheme.onPrimary,
          ),
        ),
      );
    } else {
      effectiveLeadingIcon = leadingIcon;
    }

    return DwButton(
      text: label,
      onPressed: isEffectivelyEnabled ? onPressed : null,
      enabled: isEffectivelyEnabled,
      fullWidth: fullWidth,
      variant: dwVariant,
      size: DwButtonSize.large,
      leadingIcon: effectiveLeadingIcon,
    );
  }

  /// Factory مريحة لحالات الاستخدام الأكثر شيوعًا.

  factory AppButtonUnified.primary({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool fullWidth = true,
  }) {
    return AppButtonUnified(
      key: key,
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      style: AppButtonStyle.primary,
      fullWidth: fullWidth,
    );
  }

  factory AppButtonUnified.secondary({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool fullWidth = true,
  }) {
    return AppButtonUnified(
      key: key,
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      style: AppButtonStyle.secondary,
      fullWidth: fullWidth,
    );
  }

  factory AppButtonUnified.outlined({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool fullWidth = true,
  }) {
    return AppButtonUnified(
      key: key,
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      style: AppButtonStyle.outlined,
      fullWidth: fullWidth,
    );
  }

  factory AppButtonUnified.text({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool fullWidth = true,
  }) {
    return AppButtonUnified(
      key: key,
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      style: AppButtonStyle.text,
      fullWidth: fullWidth,
    );
  }
}

/// أنماط الأزرار على مستوى التطبيق.
enum AppButtonStyle {
  primary,
  secondary,
  outlined,
  text,
}

/// دالة خاصة لتحويل AppButtonStyle إلى DwButtonVariant.
///
DwButtonVariant _mapStyleToVariant(AppButtonStyle style) {
  switch (style) {
    case AppButtonStyle.primary:
      return DwButtonVariant.primary;
    case AppButtonStyle.secondary:
      return DwButtonVariant.secondary;
    case AppButtonStyle.outlined:
      return DwButtonVariant.outlined;
    case AppButtonStyle.text:
      return DwButtonVariant.text;
  }
}

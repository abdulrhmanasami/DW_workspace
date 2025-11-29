/// Component: UI State Containers
/// Created by: DW-UI-UI-005
/// Purpose: Reusable state containers (Empty/Error/Unavailable) using Design System tokens
/// Last updated: 2025-11-25

import 'package:flutter/widgets.dart';
import 'package:design_system_foundation/design_system_foundation.dart';
import 'package:design_system_components/design_system_components.dart';

/// Empty state widget with icon, title, subtitle and optional action.
/// Use when a list or view has no data to display.
class UiEmptyState extends StatelessWidget {
  const UiEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconSize,
    this.action,
    this.actionLabel,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final double? iconSize;
  final VoidCallback? action;
  final String? actionLabel;

  static final _colors = DwColors();
  static final _spacing = DwSpacing();

  @override
  Widget build(BuildContext context) {
    final effectiveIconSize = iconSize ?? _spacing.xxxl;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(_spacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              _UiStateIcon(
                icon: icon!,
                size: effectiveIconSize,
                color: _colors.grey500.withValues(alpha: 0.6),
              ),
            if (icon != null) SizedBox(height: _spacing.lg),
            DwText(
              title,
              variant: DwTextVariant.headline,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: _spacing.md - _spacing.xs),
              DwText(
                subtitle!,
                variant: DwTextVariant.bodyMuted,
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null && actionLabel != null) ...[
              SizedBox(height: _spacing.lg),
              DwButton(
                text: actionLabel!,
                onPressed: action,
                variant: DwButtonVariant.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error state widget with message and optional retry action.
/// Use when an operation fails and user can retry.
class UiErrorState extends StatelessWidget {
  const UiErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel,
    this.icon,
    this.iconSize,
  });

  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;
  final IconData? icon;
  final double? iconSize;

  static final _colors = DwColors();
  static final _spacing = DwSpacing();

  @override
  Widget build(BuildContext context) {
    final effectiveIconSize = iconSize ?? _spacing.xxxl;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(_spacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              _UiStateIcon(
                icon: icon!,
                size: effectiveIconSize,
                color: _colors.error.withValues(alpha: 0.8),
              ),
            if (icon != null) SizedBox(height: _spacing.lg),
            DwText(
              message,
              variant: DwTextVariant.body,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: _spacing.lg),
              UiRetryButton(
                onPressed: onRetry!,
                label: retryLabel ?? 'Retry',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Unavailable feature state widget.
/// Use when a feature is disabled or not available (Sale-Only behavior).
class UiUnavailableFeature extends StatelessWidget {
  const UiUnavailableFeature({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.iconSize,
  });

  final String title;
  final String message;
  final IconData? icon;
  final double? iconSize;

  static final _colors = DwColors();
  static final _spacing = DwSpacing();

  @override
  Widget build(BuildContext context) {
    final effectiveIconSize = iconSize ?? _spacing.xxxl;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(_spacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              _UiStateIcon(
                icon: icon!,
                size: effectiveIconSize,
                color: _colors.grey500.withValues(alpha: 0.5),
              ),
            if (icon != null) SizedBox(height: _spacing.lg),
            DwText(
              title,
              variant: DwTextVariant.title,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: _spacing.md - _spacing.xs),
            DwText(
              message,
              variant: DwTextVariant.bodyMuted,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Retry button with refresh icon.
class UiRetryButton extends StatelessWidget {
  const UiRetryButton({
    super.key,
    required this.onPressed,
    this.label = 'Retry',
  });

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DwButton(
      text: label,
      onPressed: onPressed,
      variant: DwButtonVariant.primary,
      leadingIcon: const _UiRefreshIcon(),
    );
  }
}

/// Internal icon wrapper to avoid direct Material Icons dependency.
/// Uses CustomPaint for common state icons.
class _UiStateIcon extends StatelessWidget {
  const _UiStateIcon({
    required this.icon,
    required this.size,
    required this.color,
  });

  final IconData icon;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    // Use Flutter's Icon widget but from widgets package
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: _IconPainter(iconData: icon, color: color),
      ),
    );
  }
}

/// Simple refresh icon using CustomPaint.
class _UiRefreshIcon extends StatelessWidget {
  const _UiRefreshIcon();

  static final _colors = DwColors();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: CustomPaint(
        painter: _RefreshIconPainter(color: _colors.onPrimary),
      ),
    );
  }
}

/// Paints a simple refresh/reload icon.
class _RefreshIconPainter extends CustomPainter {
  _RefreshIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    // Draw arc
    const pi = 3.141592653589793;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, -pi / 4, 1.5 * pi, false, paint);

    // Draw arrow head
    final arrowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final arrowPath = Path();
    final arrowTip = Offset(center.dx + radius * 0.7, center.dy - radius * 0.7);
    arrowPath.moveTo(arrowTip.dx, arrowTip.dy);
    arrowPath.lineTo(arrowTip.dx - 4, arrowTip.dy - 2);
    arrowPath.lineTo(arrowTip.dx - 2, arrowTip.dy + 4);
    arrowPath.close();
    canvas.drawPath(arrowPath, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant _RefreshIconPainter oldDelegate) =>
      color != oldDelegate.color;
}

/// Generic icon painter that draws basic icon shapes.
class _IconPainter extends CustomPainter {
  _IconPainter({required this.iconData, required this.color});

  final IconData iconData;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw a simple placeholder circle for icons
    // In production, you'd use Icon widget or actual icon fonts
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 4;

    canvas.drawCircle(center, radius, paint);

    // Draw center dot
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.2, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _IconPainter oldDelegate) =>
      color != oldDelegate.color || iconData != oldDelegate.iconData;
}


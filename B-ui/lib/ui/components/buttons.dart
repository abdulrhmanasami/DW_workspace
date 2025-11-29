/// Component: UI Buttons
/// Created by: DW-UI-UI-005
/// Purpose: Reusable button components with loading states using Design System tokens
/// Last updated: 2025-11-25

import 'package:flutter/widgets.dart';
import 'package:design_system_foundation/design_system_foundation.dart';
import 'package:design_system_components/design_system_components.dart';

/// Animated loading button content with spinner.
/// Use inside any button widget to show loading state.
class UiLoadingButtonContent extends StatelessWidget {
  const UiLoadingButtonContent({
    super.key,
    required this.label,
    required this.isLoading,
    this.loadingLabel,
    this.spinnerSize,
    this.spinnerColor,
    this.labelColor,
  });

  final String label;
  final bool isLoading;
  final String? loadingLabel;
  final double? spinnerSize;
  final Color? spinnerColor;
  final Color? labelColor;

  static final _spacing = DwSpacing();
  static final _motion = DwMotion();

  @override
  Widget build(BuildContext context) {
    final size = spinnerSize ?? 20.0;
    final showLabel = loadingLabel != null;

    return AnimatedSwitcher(
      duration: _motion.fadeDuration,
      switchInCurve: _motion.easeInOut,
      switchOutCurve: _motion.easeInOut,
      child: isLoading
          ? Row(
              key: const ValueKey('loading'),
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                UiSpinner(size: size, color: spinnerColor),
              if (showLabel) ...[
                SizedBox(width: _spacing.md - _spacing.xs),
                _ButtonLabel(
                  text: loadingLabel!,
                  color: labelColor,
                ),
              ],
            ],
          )
          : _ButtonLabel(
              key: const ValueKey('label'),
              text: label,
              color: labelColor,
            ),
    );
  }
}

/// A button wrapper that handles loading state automatically.
/// Wraps DwButton from design_system_components with loading behavior.
class UiLoadingButton extends StatelessWidget {
  const UiLoadingButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.loadingLabel,
    this.variant = DwButtonVariant.primary,
    this.size = DwButtonSize.medium,
    this.fullWidth = false,
    this.leadingIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? loadingLabel;
  final DwButtonVariant variant;
  final DwButtonSize size;
  final bool fullWidth;
  final Widget? leadingIcon;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;
    final effectiveLabel = isLoading ? (loadingLabel ?? label) : label;

    // Use DwButton with loading indicator overlay
    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(
          opacity: isLoading ? 0.5 : 1.0,
          child: IgnorePointer(
            ignoring: isLoading,
            child: DwButton(
              text: effectiveLabel,
              onPressed: effectiveOnPressed,
              variant: variant,
              size: size,
              fullWidth: fullWidth,
              leadingIcon: isLoading ? null : leadingIcon,
              enabled: !isLoading && onPressed != null,
            ),
          ),
        ),
        if (isLoading)
          const UiSpinner(size: 18),
      ],
    );
  }
}

/// Minimal spinner widget using Design System colors.
/// Custom painted for consistency across platforms.
class UiSpinner extends StatefulWidget {
  const UiSpinner({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeWidth,
  });

  final double size;
  final Color? color;
  final double? strokeWidth;

  @override
  State<UiSpinner> createState() => _UiSpinnerState();
}

class _UiSpinnerState extends State<UiSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _duration = Duration(milliseconds: 900);
  static const _strokeRatio = 0.1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) => Transform.rotate(
        angle: _controller.value * 2 * 3.141592653589793,
        child: child,
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _SpinnerPainter(
            color: widget.color,
            strokeWidth: widget.strokeWidth ?? (size * _strokeRatio),
          ),
        ),
      ),
    );
  }
}

/// Internal button label with optional color override.
class _ButtonLabel extends StatelessWidget {
  const _ButtonLabel({
    super.key,
    required this.text,
    this.color,
  });

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (color != null) {
      return Text(
        text,
        style: TextStyle(color: color),
      );
    }
    return DwText(text, variant: DwTextVariant.body);
  }
}

class _SpinnerPainter extends CustomPainter {
  _SpinnerPainter({this.color, required this.strokeWidth});

  final Color? color;
  final double strokeWidth;

  static final _colors = DwColors();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset(strokeWidth / 2, strokeWidth / 2) &
        Size(size.width - strokeWidth, size.height - strokeWidth);

    final paintBg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = _colors.grey300;

    final paintFg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..color = color ?? _colors.grey600;

    const pi = 3.141592653589793;
    canvas.drawArc(rect, 0, 2 * pi, false, paintBg);
    canvas.drawArc(rect, 0, 1.5 * pi, false, paintFg);
  }

  @override
  bool shouldRepaint(covariant _SpinnerPainter oldDelegate) =>
      color != oldDelegate.color || strokeWidth != oldDelegate.strokeWidth;
}


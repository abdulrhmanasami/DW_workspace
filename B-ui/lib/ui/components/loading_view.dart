import 'package:flutter/widgets.dart';
import 'dart:math' as math;
import 'package:b_ui/ui/ui.dart';

class LoadingView extends StatelessWidget {
  final String? message;
  const LoadingView({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _Spinner(size: AppSpacing.loadingSpinnerSize),
          if (message != null) SizedBox(height: DwSpacing().sm),
          if (message != null) DwText(message!, variant: DwTextVariant.body),
        ],
      ),
    );
  }
}

class _Spinner extends StatefulWidget {
  final double size;
  const _Spinner({this.size = AppSpacing.loadingSpinnerSizeSmall});

  @override
  State<_Spinner> createState() => _SpinnerState();
}

class _SpinnerState extends State<_Spinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: AppSpacing.loadingAnimationDuration,
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) =>
          Transform.rotate(angle: _c.value * 2 * math.pi, child: child),
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _SpinnerPainter()),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * AppSpacing.loadingStrokeRatio;
    final rect =
        Offset(stroke / 2, stroke / 2) &
        Size(size.width - stroke, size.height - stroke);

    final paintBg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = DwColors().grey300;

    final paintFg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke
      ..color = DwColors().grey600;

    canvas.drawArc(rect, 0, 2 * math.pi, false, paintBg);
    canvas.drawArc(rect, 0, 1.5 * math.pi, false, paintFg);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

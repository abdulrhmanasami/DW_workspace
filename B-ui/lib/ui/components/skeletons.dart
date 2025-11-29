/// Component: UI Skeletons
/// Created by: DW-UI-UI-005
/// Purpose: Skeleton loading placeholders with shimmer effect using Design System tokens
/// Last updated: 2025-11-25

import 'package:flutter/widgets.dart';
import 'package:design_system_foundation/design_system_foundation.dart';

/// Skeleton shimmer effect wrapper for loading placeholders.
/// Wraps child widgets with an animated shimmer gradient.
class UiSkeletonShimmer extends StatefulWidget {
  const UiSkeletonShimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.enabled = true,
    this.duration,
  });

  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final bool enabled;
  final Duration? duration;

  @override
  State<UiSkeletonShimmer> createState() => _UiSkeletonShimmerState();
}

class _UiSkeletonShimmerState extends State<UiSkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  static final _colors = DwColors();
  static const _defaultDuration = Duration(milliseconds: 1500);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? _defaultDuration,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(UiSkeletonShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.enabled && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    final baseColor = widget.baseColor ?? _colors.grey200;
    final highlightColor = widget.highlightColor ?? _colors.grey100;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Skeleton line placeholder for text content.
class UiSkeletonLine extends StatelessWidget {
  const UiSkeletonLine({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  final double? width;
  final double? height;
  final double? borderRadius;

  static final _colors = DwColors();
  static final _spacing = DwSpacing();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height ?? _spacing.md,
      decoration: BoxDecoration(
        color: _colors.grey200,
        borderRadius: BorderRadius.circular(borderRadius ?? _spacing.borderRadiusSm),
      ),
    );
  }
}

/// Skeleton card placeholder for list items.
class UiSkeletonCard extends StatelessWidget {
  const UiSkeletonCard({
    super.key,
    this.height,
    this.padding,
    this.showIcon = true,
    this.lineCount = 2,
  });

  final double? height;
  final EdgeInsets? padding;
  final bool showIcon;
  final int lineCount;

  static final _colors = DwColors();
  static final _spacing = DwSpacing();

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? EdgeInsets.all(_spacing.md);
    final effectiveHeight = height ?? 80.0;

    return Container(
      height: effectiveHeight,
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: _colors.grey100.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(_spacing.borderRadiusLg),
        border: Border.all(
          color: _colors.grey300.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          if (showIcon) ...[
            Container(
              width: _spacing.xxl,
              height: _spacing.xxl,
              decoration: BoxDecoration(
                color: _colors.grey200,
                borderRadius: BorderRadius.circular(_spacing.borderRadiusMd),
              ),
            ),
            SizedBox(width: _spacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildLines(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLines() {
    final lines = <Widget>[];
    for (var i = 0; i < lineCount; i++) {
      if (i > 0) {
        lines.add(SizedBox(height: _spacing.sm));
      }
      lines.add(
        UiSkeletonLine(
          width: i == 0 ? null : 120,
          height: i == 0 ? 14 : 12,
        ),
      );
    }
    return lines;
  }
}

/// Skeleton list for loading states with multiple items.
class UiSkeletonList extends StatelessWidget {
  const UiSkeletonList({
    super.key,
    this.itemCount = 3,
    this.itemHeight,
    this.spacing,
    this.padding,
    this.showIcons = true,
  });

  final int itemCount;
  final double? itemHeight;
  final double? spacing;
  final EdgeInsets? padding;
  final bool showIcons;

  static final _spacing = DwSpacing();

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? EdgeInsets.all(_spacing.md);
    final effectiveSpacing = spacing ?? _spacing.md - _spacing.xs;
    final effectiveHeight = itemHeight ?? 80.0;

    return UiSkeletonShimmer(
      child: Padding(
        padding: effectivePadding,
        child: Column(
          children: List.generate(
            itemCount,
            (index) => Padding(
              padding: EdgeInsets.only(
                bottom: index < itemCount - 1 ? effectiveSpacing : 0,
              ),
              child: UiSkeletonCard(
                height: effectiveHeight,
                showIcon: showIcons,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Skeleton tile for toggle/switch rows (e.g., notification settings).
class UiSkeletonTile extends StatelessWidget {
  const UiSkeletonTile({
    super.key,
    this.height,
    this.padding,
    this.showToggle = true,
  });

  final double? height;
  final EdgeInsets? padding;
  final bool showToggle;

  static final _colors = DwColors();
  static final _spacing = DwSpacing();

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? EdgeInsets.all(_spacing.md);
    final effectiveHeight = height ?? 56.0;

    return Container(
      height: effectiveHeight,
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: _colors.grey100.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(_spacing.borderRadiusMd),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const UiSkeletonLine(height: 14),
                SizedBox(height: _spacing.xs),
                UiSkeletonLine(width: 180, height: 12),
              ],
            ),
          ),
          if (showToggle) ...[
            SizedBox(width: _spacing.md),
            Container(
              width: 48,
              height: 28,
              decoration: BoxDecoration(
                color: _colors.grey200,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Skeleton for notification settings screen.
class UiSkeletonSettingsList extends StatelessWidget {
  const UiSkeletonSettingsList({
    super.key,
    this.itemCount = 4,
    this.spacing,
    this.padding,
  });

  final int itemCount;
  final double? spacing;
  final EdgeInsets? padding;

  static final _spacing = DwSpacing();

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? EdgeInsets.all(_spacing.md);
    final effectiveSpacing = spacing ?? _spacing.sm;

    return UiSkeletonShimmer(
      child: Padding(
        padding: effectivePadding,
        child: Column(
          children: List.generate(
            itemCount,
            (index) => Padding(
              padding: EdgeInsets.only(
                bottom: index < itemCount - 1 ? effectiveSpacing : 0,
              ),
              child: const UiSkeletonTile(),
            ),
          ),
        ),
      ),
    );
  }
}


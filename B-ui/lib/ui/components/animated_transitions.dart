/// Component: UI Animated Transitions
/// Created by: DW-UI-UI-005
/// Purpose: Animated state transition wrappers using Design System motion tokens
/// Last updated: 2025-11-25

import 'package:flutter/widgets.dart';
import 'package:design_system_foundation/design_system_foundation.dart';

/// Animated state transition wrapper for smooth content switching.
/// Wraps child with fade and slide animations when content changes.
/// Use to transition between loading, data, empty, and error states.
class UiAnimatedStateTransition extends StatelessWidget {
  const UiAnimatedStateTransition({
    super.key,
    required this.child,
    this.duration,
    this.curve,
    this.slideOffset,
    this.fadeOnly = false,
  });

  final Widget child;
  final Duration? duration;
  final Curve? curve;
  final Offset? slideOffset;
  final bool fadeOnly;

  static final _motion = DwMotion();

  @override
  Widget build(BuildContext context) {
    final effectiveDuration = duration ?? _motion.normal;
    final effectiveCurve = curve ?? _motion.easeInOut;
    final effectiveSlideOffset = slideOffset ?? const Offset(0, 0.05);

    return AnimatedSwitcher(
      duration: effectiveDuration,
      switchInCurve: effectiveCurve,
      switchOutCurve: effectiveCurve,
      transitionBuilder: (child, animation) {
        if (fadeOnly) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        }

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: effectiveSlideOffset,
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Animated opacity wrapper for simple fade transitions.
class UiAnimatedFade extends StatelessWidget {
  const UiAnimatedFade({
    super.key,
    required this.child,
    required this.visible,
    this.duration,
    this.curve,
  });

  final Widget child;
  final bool visible;
  final Duration? duration;
  final Curve? curve;

  static final _motion = DwMotion();

  @override
  Widget build(BuildContext context) {
    final effectiveDuration = duration ?? _motion.fadeDuration;
    final effectiveCurve = curve ?? _motion.easeInOut;

    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: effectiveDuration,
      curve: effectiveCurve,
      child: visible ? child : const SizedBox.shrink(),
    );
  }
}

/// Animated scale wrapper for enter/exit animations.
class UiAnimatedScale extends StatelessWidget {
  const UiAnimatedScale({
    super.key,
    required this.child,
    required this.visible,
    this.duration,
    this.curve,
    this.initialScale = 0.95,
  });

  final Widget child;
  final bool visible;
  final Duration? duration;
  final Curve? curve;
  final double initialScale;

  static final _motion = DwMotion();

  @override
  Widget build(BuildContext context) {
    final effectiveDuration = duration ?? _motion.fast;
    final effectiveCurve = curve ?? _motion.easeOut;

    return AnimatedScale(
      scale: visible ? 1.0 : initialScale,
      duration: effectiveDuration,
      curve: effectiveCurve,
      child: AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        duration: effectiveDuration,
        curve: effectiveCurve,
        child: child,
      ),
    );
  }
}

/// Staggered animation controller for list items.
/// Creates cascading enter animations for list content.
class UiStaggeredList extends StatefulWidget {
  const UiStaggeredList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.staggerDelay,
    this.duration,
    this.curve,
    this.reverse = false,
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index, Animation<double> animation) itemBuilder;
  final Duration? staggerDelay;
  final Duration? duration;
  final Curve? curve;
  final bool reverse;

  @override
  State<UiStaggeredList> createState() => _UiStaggeredListState();
}

class _UiStaggeredListState extends State<UiStaggeredList>
    with TickerProviderStateMixin {
  final List<AnimationController> _controllers = [];
  final List<Animation<double>> _animations = [];

  static final _motion = DwMotion();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  @override
  void didUpdateWidget(UiStaggeredList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemCount != widget.itemCount) {
      _disposeAnimations();
      _initializeAnimations();
      _startAnimations();
    }
  }

  void _initializeAnimations() {
    final duration = widget.duration ?? _motion.normal;
    final curve = widget.curve ?? _motion.easeOut;

    for (var i = 0; i < widget.itemCount; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: duration,
      );
      final animation = CurvedAnimation(
        parent: controller,
        curve: curve,
      );
      _controllers.add(controller);
      _animations.add(animation);
    }
  }

  Future<void> _startAnimations() async {
    final delay = widget.staggerDelay ?? const Duration(milliseconds: 50);

    for (var i = 0; i < _controllers.length; i++) {
      if (!mounted) return;
      final index = widget.reverse ? (_controllers.length - 1 - i) : i;
      _controllers[index].forward();
      await Future<void>.delayed(delay);
    }
  }

  void _disposeAnimations() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    _controllers.clear();
    _animations.clear();
  }

  @override
  void dispose() {
    _disposeAnimations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        widget.itemCount,
        (index) {
          if (index >= _animations.length) {
            return widget.itemBuilder(
              context,
              index,
              const AlwaysStoppedAnimation(1.0),
            );
          }
          return widget.itemBuilder(context, index, _animations[index]);
        },
      ),
    );
  }
}

/// Animated list item with fade and slide.
class UiAnimatedListItem extends StatelessWidget {
  const UiAnimatedListItem({
    super.key,
    required this.animation,
    required this.child,
    this.slideOffset,
  });

  final Animation<double> animation;
  final Widget child;
  final Offset? slideOffset;

  @override
  Widget build(BuildContext context) {
    final effectiveSlideOffset = slideOffset ?? const Offset(0, 0.1);

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: effectiveSlideOffset,
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}


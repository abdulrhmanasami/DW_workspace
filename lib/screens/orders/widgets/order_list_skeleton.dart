/// Order List Skeleton Widget
/// Created by: Track B - Ticket #127
/// Updated by: Track B - Ticket #128 (Pulsing/Shimmer animation per Design System)
/// Purpose: Skeleton loader for order lists (Orders History + Parcels)
/// Shows placeholder cards while data is loading per Design System Utility/SkeletonLoader.
/// Track B - Ticket #128: Now includes animated pulsing effect (~1500ms cycle).
///
/// Last updated: 2025-12-01

import 'package:design_system_shims/design_system_shims.dart';
import 'package:flutter/material.dart';

/// A skeleton loader widget that displays placeholder order cards.
///
/// Used in Orders History and Parcels screens during loading state
/// to provide visual feedback that data is being loaded.
///
/// Track B - Ticket #127: Implements Design System `Utility/SkeletonLoader` pattern.
class OrderListSkeleton extends StatelessWidget {
  const OrderListSkeleton({
    super.key,
    this.itemCount = 4,
  });

  /// Number of skeleton cards to display.
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(DWSpacing.md),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: DWSpacing.sm),
      itemBuilder: (context, index) {
        return const _OrderCardSkeleton();
      },
    );
  }
}

/// Individual skeleton card matching the Order Card layout.
///
/// Mimics the structure of RideOrderCard and ParcelOrderCard:
/// - Service icon placeholder (circle)
/// - Title + subtitle lines
/// - Status chip placeholder
/// - Price placeholder
///
/// Track B - Ticket #128: Now wrapped with DWSkeletonPulse for animated effect.
class _OrderCardSkeleton extends StatelessWidget {
  const _OrderCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surfaceContainerHighest;

    return Semantics(
      label: 'Loading order',
      // Track B - Ticket #128: Wrap card with pulsing animation
      child: DWSkeletonPulse(
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(DWSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service icon placeholder (circle)
                    _SkeletonBox(
                      height: 48,
                      width: 48,
                      borderRadius: DWRadius.sm,
                      color: surface,
                    ),
                    const SizedBox(width: DWSpacing.sm),

                    // Title and subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SkeletonBox(
                            height: 16,
                            width: 140,
                            color: surface,
                          ),
                          const SizedBox(height: DWSpacing.xs),
                          _SkeletonBox(
                            height: 12,
                            width: 200,
                            color: surface,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: DWSpacing.sm),

                    // Status chip placeholder
                    _SkeletonBox(
                      height: 24,
                      width: 70,
                      borderRadius: 999, // Pill shape
                      color: surface,
                    ),
                  ],
                ),
                const SizedBox(height: DWSpacing.sm),

                // Bottom row: date + price
                Row(
                  children: [
                    _SkeletonBox(
                      height: 10,
                      width: 100,
                      color: surface,
                    ),
                    const Spacer(),
                    _SkeletonBox(
                      height: 14,
                      width: 60,
                      color: surface,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A simple skeleton placeholder box with shimmer-like appearance.
class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.height,
    required this.width,
    required this.color,
    this.borderRadius = 8,
  });

  final double height;
  final double width;
  final Color color;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

// =============================================================================
// Track B - Ticket #128: DWSkeletonPulse Animation Widget
// =============================================================================

/// A skeleton pulsing animation widget per Design System Utility/SkeletonLoader.
///
/// Wraps a child widget and applies a smooth pulsing opacity animation
/// with a ~1500ms cycle as specified in the Flutter Handoff Notes.
/// This creates an "Uber-like" loading experience that's not abrupt or static.
///
/// Usage:
/// ```dart
/// DWSkeletonPulse(
///   child: Container(
///     width: 100,
///     height: 20,
///     color: Colors.grey,
///   ),
/// )
/// ```
///
/// Track B - Ticket #128: Created for animated skeleton loading.
class DWSkeletonPulse extends StatefulWidget {
  /// Creates a skeleton pulse animation wrapper.
  const DWSkeletonPulse({
    super.key,
    required this.child,
  });

  /// The child widget to apply pulsing animation to.
  final Widget child;

  @override
  State<DWSkeletonPulse> createState() => _DWSkeletonPulseState();
}

class _DWSkeletonPulseState extends State<DWSkeletonPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    // Per Design System: ~1500ms cycle for pulsing animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true); // Creates smooth pulsing effect

    // Opacity range: 0.4 to 1.0 for subtle but noticeable pulsing
    _opacity = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}


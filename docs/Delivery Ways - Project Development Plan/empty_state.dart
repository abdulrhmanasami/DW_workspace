import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart';

/// Empty State View - Standardized empty state interface
/// Created by: UI-PHASE-01
/// Purpose: Consistent empty state display across UI layer
/// Last updated: 2025-11-16

class EmptyState extends ConsumerWidget {
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final IconData icon;

  const EmptyState({
    super.key,
    required this.title,
    this.message,
    this.actionLabel,
    this.onActionPressed,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final spacing = theme.spacing;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(spacing.lg),
        child: AppCard.standard(
          child: Padding(
            padding: EdgeInsets.all(spacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 64.0,
                  color: theme.colors.onSurface.withValues(alpha: 0.5),
                ),
                SizedBox(height: spacing.md),
                Text(
                  title,
                  style: theme.typography.headline6.copyWith(
                    color: theme.colors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (message != null) ...[
                  SizedBox(height: spacing.sm),
                  Text(
                    message!,
                    style: theme.typography.body2.copyWith(
                      color: theme.colors.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (actionLabel != null && onActionPressed != null) ...[
                  SizedBox(height: spacing.lg),
                  AppButton.primary(
                    label: actionLabel!,
                    onPressed: onActionPressed,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

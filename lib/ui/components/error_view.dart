import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart';

/// Error View - Standardized error interface using Design System
/// Created by: UI-PHASE-01
/// Purpose: Consistent error display across UI layer
/// Last updated: 2025-11-16

class ErrorView extends ConsumerWidget {
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final IconData icon;

  const ErrorView({
    super.key,
    required this.title,
    this.message,
    this.actionLabel,
    this.onActionPressed,
    this.icon = Icons.error_outline,
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
                Icon(icon, size: 64.0, color: theme.colors.error),
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

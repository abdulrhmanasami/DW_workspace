import 'package:flutter/material.dart';
import 'package:design_system_shims/design_system_shims.dart';

/// Generic Empty State widget following Design System specifications
/// Provides consistent empty state display with optional icon, title, description, and action button
class DWEmptyState extends StatelessWidget {
  const DWEmptyState({
    super.key,
    required this.title,
    this.description,
    this.primaryActionLabel,
    this.onPrimaryActionTap,
    this.icon = Icons.history,
  });

  final String title;
  final String? description;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryActionTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DWSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon in a subtle circular background
            Container(
              padding: const EdgeInsets.all(DWSpacing.lg),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: DWSpacing.lg),
            // Title
            Text(
              title,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: DWSpacing.sm),
              // Description
              Text(
                description!,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (primaryActionLabel != null && onPrimaryActionTap != null) ...[
              const SizedBox(height: DWSpacing.xl),
              // Primary CTA using DWButton
              DWButton.primary(
                label: primaryActionLabel!,
                onPressed: onPrimaryActionTap,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

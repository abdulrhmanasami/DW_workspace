import 'package:flutter/material.dart';
import 'package:design_system_shims/design_system_shims.dart';

/// Placeholder widget for map area in Home Hub.
/// Created by: Track A - Ticket #228
/// Purpose: UI-only placeholder for map area in Home Hub Screen 6 (Default State).
///
/// This is a temporary placeholder that will be replaced with real map integration
/// using maps_shims in Track B/C according to Manus plan.
///
/// Design System Alignment:
/// - Uses colorScheme.surfaceVariant for background
/// - DWRadius.md for border radius
/// - DWSpacing for padding
/// - Semantics for accessibility
class HomeMapPlaceholder extends StatelessWidget {
  const HomeMapPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Semantics(
      label: 'Map preview placeholder',
      child: Container(
        padding: const EdgeInsets.all(DWSpacing.lg),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(DWRadius.md),
        ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.map,
                size: 48.0,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: DWSpacing.sm),
              Text(
                'Map will appear here',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

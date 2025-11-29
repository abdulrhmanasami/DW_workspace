/// Food Coming Soon Screen
/// Created by: Track C - Ticket #48
/// Purpose: Display "Coming Soon" message when Food feature is disabled via feature flag.
/// Last updated: 2025-11-28

import 'package:flutter/material.dart';
import 'package:design_system_shims/design_system_shims.dart' show DWSpacing;
import '../../l10n/generated/app_localizations.dart';

/// Screen displayed when the Food delivery feature is not yet enabled.
/// Shows an informative message and a CTA to return to home.
class FoodComingSoonScreen extends StatelessWidget {
  const FoodComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.foodComingSoonAppBarTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(DWSpacing.lg),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.fastfood_outlined,
                size: 56,
                color: colorScheme.outline,
              ),
              const SizedBox(height: DWSpacing.lg),
              Text(
                l10n.foodComingSoonTitle,
                style: textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DWSpacing.sm),
              Text(
                l10n.foodComingSoonSubtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DWSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.foodComingSoonPrimaryCta),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


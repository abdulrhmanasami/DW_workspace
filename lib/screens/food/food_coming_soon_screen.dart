/// Food Coming Soon Screen
/// Created by: Track C - Ticket #48
/// Updated by: Track C - Ticket #56 (Production-Ready UX with Empty State pattern)
/// Purpose: Display "Coming Soon" message when Food feature is disabled via feature flag.
/// Last updated: 2025-11-29

import 'package:flutter/material.dart';
import 'package:design_system_shims/design_system_shims.dart' show DWSpacing;
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';

/// Screen displayed when the Food delivery feature is not yet enabled.
/// Shows an informative message using the Utility/EmptyState pattern consistent
/// with other screens like OrdersHistoryScreen.
///
/// Design System compliance (Ticket #56):
/// - Uses Navigation/AppBar pattern consistent with My Orders / Payments screens
/// - Uses Utility/EmptyState pattern for the content area
/// - RTL/LTR: Layout relies on default Directionality for automatic mirroring
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DWSpacing.lg),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Empty State Icon (consistent with OrdersHistoryScreen empty state)
                Icon(
                  Icons.fastfood_outlined,
                  size: 64,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: DWSpacing.lg),

                // Empty State Title (using homeFoodComingSoonLabel per Ticket #56)
                Text(
                  l10n.homeFoodComingSoonLabel,
                  style: textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: DWSpacing.sm),

                // Empty State Body (using homeFoodComingSoonMessage per Ticket #56)
                Text(
                  l10n.homeFoodComingSoonMessage,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),

                // Note: No complex CTA per Ticket #56 requirements
                // User returns via AppBar back button (sufficient for MVP)
              ],
            ),
          ),
        ),
      ),
    );
  }
}


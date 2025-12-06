import 'package:flutter/material.dart';
import 'package:design_system_shims/design_system_shims.dart';

import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/router/app_router.dart';
import 'package:delivery_ways_clean/widgets/app_button_unified.dart';
import 'package:delivery_ways_clean/ui/home/home_service_card.dart';
import 'package:delivery_ways_clean/ui/home/home_map_placeholder.dart';
import 'package:delivery_ways_clean/config/feature_flags.dart';

/// Home Tab Screen - Screen 6 (Home Hub – Default State)
/// Created by: Track A - Ticket #228
/// Purpose: Simplified UI-only Home Hub screen without business logic
///
/// Layout: Top Bar + Map Placeholder + Service Cards (Ride/Parcels/Food) + Search Input
/// This is Track A only - no deep Ride/Parcels/Food logic, will be replaced in Track B/C
class HomeTabScreen extends StatelessWidget {
  const HomeTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              DWSpacing.md,
              DWSpacing.md,
              DWSpacing.md,
              DWSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top bar
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.homeCurrentLocationLabel,
                            style: textTheme.bodySmall,
                          ),
                          const SizedBox(height: DWSpacing.xs),
                          Text(
                            l10n.homeCurrentLocationPlaceholder,
                            style: textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // TODO: Navigate to Profile tab or account screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile/Account screen coming soon'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.person),
                    ),
                  ],
                ),

                const SizedBox(height: DWSpacing.lg),

                // ✅ Map area بارتفاع ثابت (لا Expanded)
                const SizedBox(
                  height: 240, // أو القيمة اللي استخدمتها تقريبًا
                  child: HomeMapPlaceholder(),
                ),

                const SizedBox(height: DWSpacing.lg),

                // Service Actions
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service section title
                    Text(
                      'Services',
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: DWSpacing.md),

                    // Service Action Buttons
                    Column(
                      children: [
                        // Book a Ride Button
                        AppButtonUnified(
                          label: l10n.homeServiceRideTitle,
                          onPressed: () {
                            Navigator.of(context).pushNamed(RoutePaths.rideBooking);
                          },
                          leadingIcon: const Icon(Icons.directions_car),
                          style: AppButtonStyle.primary,
                        ),
                        const SizedBox(height: DWSpacing.md),

                        // Send Package Button
                        AppButtonUnified(
                          label: l10n.homeServiceParcelsTitle,
                          onPressed: () {
                            Navigator.of(context).pushNamed(RoutePaths.parcelsList);
                          },
                          leadingIcon: const Icon(Icons.local_shipping),
                          style: AppButtonStyle.secondary,
                        ),
                        const SizedBox(height: DWSpacing.md),

                        // Food Service Button
                        if (FeatureFlags.enableFoodMvp) ...[
                          AppButtonUnified(
                            label: l10n.homeServiceFoodTitle,
                            onPressed: () {
                              Navigator.of(context).pushNamed(RoutePaths.foodRestaurants);
                            },
                            leadingIcon: const Icon(Icons.restaurant),
                            style: AppButtonStyle.secondary,
                          ),
                        ] else ...[
                          HomeServiceCard(
                            icon: Icons.restaurant,
                            title: l10n.homeServiceFoodTitle,
                            subtitle: l10n.homeServiceFoodSubtitle,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Food ordering will be enabled soon.'),
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: DWSpacing.lg),

                // Search field
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(DWRadius.md),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                      width: 1.0,
                    ),
                  ),
                  child: TextField(
                    enabled: false, // UI only for now
                    decoration: InputDecoration(
                      hintText: l10n.homeSearchPlaceholder,
                      hintStyle: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsetsDirectional.symmetric(
                        horizontal: DWSpacing.md,
                        vertical: DWSpacing.sm,
                      ),
                    ),
                    style: textTheme.bodyLarge,
                    textDirection: TextDirection.ltr,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

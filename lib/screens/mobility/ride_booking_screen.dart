/// Ride Booking Screen - Track B Ticket #6
/// Purpose: UI-only Booking Sheet for Ride vertical
/// Created by: Track B - Ticket #6
/// Updated by: Track B - Ticket #9 (RideDraftUiState integration)
/// Last updated: 2025-11-28
///
/// This screen provides the initial Ride booking interface with:
/// - Map stub (placeholder for future maps_shims integration)
/// - Bottom Sheet with pickup/destination inputs
/// - Recent locations list
///
/// NOTE: This is UI only - no FSM, Fare Engine, or Backend integration.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../router/app_router.dart';
import '../../state/mobility/ride_draft_state.dart';

/// RideBookingScreen - Main entry point for Ride booking flow
class RideBookingScreen extends ConsumerWidget {
  const RideBookingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.rideBookingTitle,
          style: textTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Map stub (background)
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.only(bottom: 200), // Space for the Sheet
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.map_outlined,
                        size: 64, color: colorScheme.onSurfaceVariant),
                    const SizedBox(height: 8),
                    Text(
                      l10n.rideBookingMapStubLabel,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Booking Sheet (Bottom)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                    color: colorScheme.shadow.withValues(alpha: 0.1),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: const _RideBookingSheetContent(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom Sheet content with pickup, destination, and recent locations
class _RideBookingSheetContent extends ConsumerStatefulWidget {
  const _RideBookingSheetContent();

  @override
  ConsumerState<_RideBookingSheetContent> createState() =>
      _RideBookingSheetContentState();
}

class _RideBookingSheetContentState
    extends ConsumerState<_RideBookingSheetContent> {
  late TextEditingController _destinationController;

  @override
  void initState() {
    super.initState();
    // Initialize controller with current state value
    final currentDestination = ref.read(rideDraftProvider).destinationQuery;
    _destinationController = TextEditingController(text: currentDestination);
  }

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final rideDraft = ref.watch(rideDraftProvider);
    final rideDraftController = ref.read(rideDraftProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Drag handle
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),

        // Title
        Text(
          l10n.rideBookingSheetTitle,
          style: textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),

        // Subtitle
        Text(
          l10n.rideBookingSheetSubtitle,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),

        // Pickup (Current Location - non editable)
        Text(
          l10n.rideBookingPickupLabel,
          style: textTheme.labelMedium,
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.my_location, color: colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.rideBookingPickupCurrentLocation,
                  style: textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Destination input
        Text(
          l10n.rideBookingDestinationLabel,
          style: textTheme.labelMedium,
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: _destinationController,
          textInputAction: TextInputAction.search,
          onChanged: (value) {
            rideDraftController.updateDestination(value);
          },
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: l10n.rideBookingDestinationHint,
          ),
        ),
        const SizedBox(height: 16),

        // Recent locations
        Text(
          l10n.rideBookingRecentTitle,
          style: textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        _RecentLocationTile(
          icon: Icons.home_outlined,
          title: l10n.rideBookingRecentHome,
          subtitle: l10n.rideBookingRecentHomeSubtitle,
        ),
        _RecentLocationTile(
          icon: Icons.work_outline,
          title: l10n.rideBookingRecentWork,
          subtitle: l10n.rideBookingRecentWorkSubtitle,
        ),
        _RecentLocationTile(
          icon: Icons.add_location_alt_outlined,
          title: l10n.rideBookingRecentAddNew,
          subtitle: l10n.rideBookingRecentAddNewSubtitle,
        ),
        const SizedBox(height: 16),
        // See options CTA button (Track B - Ticket #7)
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              final destination = rideDraft.destinationQuery.trim();
              if (destination.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.rideBookingDestinationHint)),
                );
                return;
              }
              Navigator.of(context).pushNamed(RoutePaths.rideConfirmation);
            },
            child: Text(
              l10n.rideBookingSeeOptionsCta,
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Recent location list tile widget
class _RecentLocationTile extends StatelessWidget {
  const _RecentLocationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: colorScheme.primary),
        title: Text(title, style: textTheme.bodyLarge),
        subtitle: Text(
          subtitle,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        onTap: () {
          // TODO (Track B – later): Fill destination field and continue flow
        },
      ),
    );
  }
}


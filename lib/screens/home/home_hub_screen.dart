import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maps_shims/maps_shims.dart';
import 'package:mobility_shims/mobility_shims.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../router/app_router.dart';
import '../../state/mobility/ride_trip_session.dart';
import '../../state/mobility/ride_draft_state.dart';
import '../../state/mobility/ride_recent_locations_providers.dart';
import '../../config/feature_flags.dart';
import '../mobility/widgets/ride_recent_destination_item.dart';

/// Home Hub V1 Screen
/// Ticket #180: Unified entry point for the app with Ride/Parcels/Food services
/// Ticket #181: Home Hub Map Integration V1 - Real map using maps_shims
/// Created by: Delivery Ways Team
/// Purpose: Real Home Hub screen (not demo) as main entry point
class HomeHubScreen extends ConsumerWidget {
  static const rideServiceKey = Key('home_hub_service_ride');
  static const parcelsServiceKey = Key('home_hub_service_parcels');
  static const foodServiceKey = Key('home_hub_service_food');

  // Ticket #183: HomeHub Active Ride Shortcut V1
  static const homeHubActiveRideCardKey = Key('home_hub_active_ride_card');
  static const homeHubActiveRideSubtitleKey = Key('home_hub_active_ride_subtitle');

  // Ticket #188: HomeHub Ride Search Shortcut V1
  static const homeHubSearchBarKey = Key('home_hub_search_bar');

  // Ticket #189: HomeHub Ride Recent Destinations Shortcuts V1
  static const homeHubRecentDestinationsSectionKey = Key('home_hub_recent_destinations_section');

  // Ticket #194: HomeHub Recent Destinations "See all" CTA V1
  static const homeHubRecentDestinationsSeeAllKey = Key('home_hub_recent_destinations_see_all_button');

  // Helper لإنتاج key لكل عنصر حسب الـ index
  static Key homeHubRecentDestinationItemKey(int index) =>
      Key('home_hub_recent_destination_item_$index');

  const HomeHubScreen({super.key});

  // Ticket #190: moved from local function to private instance method to satisfy lint
  String _getLocationDisplayText(AppLocalizations l10n, RideDraftUiState rideDraft) {
    final pickupPlace = rideDraft.pickupPlace;
    if (pickupPlace != null) {
      // Use the display name/label from the mobility place
      return pickupPlace.label;
    } else {
      // Fallback when location is not available
      return l10n.homeHubCurrentLocationUnavailable;
    }
  }

  // Ticket #192: Helper method to check if there's an active trip
  bool _hasActiveTrip(WidgetRef ref) {
    final session = ref.read(rideTripSessionProvider);
    return session.activeTrip != null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Ticket #183: Check for active trip to show shortcut card
    final tripSession = ref.watch(rideTripSessionProvider);
    final hasActiveTrip = tripSession.activeTrip != null;

    // Ticket #187: Get current location from ride draft provider (same as RideDestinationScreen)
    final rideDraft = ref.watch(rideDraftProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(16), // لاحقًا نربطه بـ spacing من الـ DS
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Greeting + Location (بسيطة)
            const SizedBox(height: 8),
            Text(
              l10n.homeHubTitle,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 18),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.homeHubCurrentLocationLabel,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getLocationDisplayText(l10n, rideDraft),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Ticket #188: Search bar for ride shortcut
            _HomeHubSearchBar(
              onTap: () => _onSearchTap(context, ref),
            ),

            const SizedBox(height: 16),

            // Ticket #189: Recent destinations shortcuts section
            _buildRecentDestinationsSection(context, ref),

            const SizedBox(height: 16),

            // Ticket #183: Show active ride card if trip is active
            if (hasActiveTrip)
              _ActiveRideCard(
                onTap: () => _navigateToActiveTripScreen(context),
              ),

            if (hasActiveTrip) const SizedBox(height: 16),

            // 2. Map (real map using maps_shims) - Ticket #181
            const Expanded(
              child: _HomeHubMap(),
            ),

            const SizedBox(height: 16),

            // 3. Service selector (Ride / Parcels / Food)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ServiceChip(
                  key: rideServiceKey,
                  icon: Icons.directions_car,
                  label: l10n.homeHubServiceRide,
                  // onTap: لاحقًا يربط بتدفق ride
                  onTap: () => _onRideTap(context, ref),
                ),
                if (FeatureFlags.enableParcelsMvp)
                  _ServiceChip(
                    key: parcelsServiceKey,
                    icon: Icons.local_shipping_outlined,
                    label: l10n.homeHubServiceParcels,
                    onTap: () => _onParcelsTap(context),
                  ),
                if (FeatureFlags.enableFoodMvp)
                  _ServiceChip(
                    key: foodServiceKey,
                    icon: Icons.fastfood_outlined,
                    label: l10n.homeHubServiceFood,
                    onTap: () => _onFoodTap(context),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onRecentDestinationTap(
    BuildContext context,
    WidgetRef ref,
    MobilityPlace place,
  ) {
    final hasActiveTrip = _hasActiveTrip(ref);

    if (hasActiveTrip) {
      _navigateToActiveTripScreen(context);
      return;
    }

    // لا يوجد رحلة نشطة → نفس سلوك RideDestinationScreen عند الضغط على recent
    final rideDraftController = ref.read(rideDraftProvider.notifier);

    // استخدم نفس المنطق الموجود في RideDestinationScreen:
    // - تحديث destination في rideDraft
    // - ثم عمل navigation للـ confirmation
    rideDraftController.updateDestinationPlace(place);

    Navigator.of(context).pushNamed(RoutePaths.rideConfirmation);
  }

  void _onRideTap(BuildContext context, WidgetRef ref) {
    final hasActiveTrip = _hasActiveTrip(ref);

    if (hasActiveTrip) {
      _navigateToActiveTripScreen(context);
    } else {
      // Navigate to ride destination screen using Navigator
      Navigator.of(context).pushNamed(RoutePaths.rideDestination);
    }
  }

  // Ticket #188: Search bar tap handler with same logic as ride chip
  void _onSearchTap(BuildContext context, WidgetRef ref) {
    final hasActiveTrip = _hasActiveTrip(ref);

    if (hasActiveTrip) {
      _navigateToActiveTripScreen(context);
    } else {
      Navigator.of(context).pushNamed(RoutePaths.rideDestination);
    }
  }

  // Ticket #194: See all recent destinations CTA from HomeHub
  void _onRecentDestinationsSeeAllTap(BuildContext context, WidgetRef ref) {
    if (_hasActiveTrip(ref)) {
      _navigateToActiveTripScreen(context);
    } else {
      Navigator.of(context).pushNamed(RoutePaths.rideDestination);
    }
  }

  void _navigateToActiveTripScreen(BuildContext context) {
    // Navigate to ride active trip screen using Navigator
    Navigator.of(context).pushNamed(RoutePaths.rideActive);
  }

  void _onParcelsTap(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.homeHubParcelsComingSoonMessage),
      ),
    );
  }

  void _onFoodTap(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.homeHubFoodComingSoonMessage),
      ),
    );
  }

  Widget _buildRecentDestinationsSection(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final recentLocationsAsync = ref.watch(recentLocationsProvider);

    return recentLocationsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
      data: (recentLocations) {
        if (recentLocations.isEmpty) {
          return const SizedBox.shrink();
        }

        final hasMoreThanMax = recentLocations.length > 3;
        final visiblePlaces = recentLocations.take(3).toList();

        return Column(
          key: HomeHubScreen.homeHubRecentDestinationsSectionKey,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.homeHubRecentDestinationsTitle,
                  style: theme.textTheme.titleMedium,
                ),
                if (hasMoreThanMax)
                  TextButton(
                    key: HomeHubScreen.homeHubRecentDestinationsSeeAllKey,
                    onPressed: () => _onRecentDestinationsSeeAllTap(context, ref),
                    child: Text(
                      l10n.homeHubRecentDestinationsSeeAll,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Column(
              children: [
                for (var i = 0; i < visiblePlaces.length; i++)
                  RideRecentDestinationItem(
                    key: HomeHubScreen.homeHubRecentDestinationItemKey(i),
                    label: visiblePlaces[i].title,
                    subtitle: visiblePlaces[i].subtitle,
                    icon: getMobilityPlaceIcon(visiblePlaces[i].type, visiblePlaces[i].id),
                    onTap: () => _onRecentDestinationTap(context, ref, visiblePlaces[i].toMobilityPlace()),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Active Ride Card widget - Ticket #183
class _ActiveRideCard extends StatelessWidget {
  const _ActiveRideCard({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      key: HomeHubScreen.homeHubActiveRideCardKey,
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              Icons.directions_car,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.homeHubActiveRideTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.homeHubActiveRideSubtitle,
                    key: HomeHubScreen.homeHubActiveRideSubtitleKey,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: theme.colorScheme.primary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}


/// Map widget for Home Hub using maps_shims - Ticket #181
class _HomeHubMap extends ConsumerWidget {
  static const mapKey = Key('home_hub_map');

  const _HomeHubMap();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapViewBuilder = ref.watch(mapViewBuilderProvider);

    // Use default location (Riyadh) with standard zoom for home hub
    const defaultLocation = LatLng(24.7136, 46.6753); // Riyadh, Saudi Arabia
    const defaultZoom = 12.0;

    return ClipRRect(
      key: mapKey,
      borderRadius: BorderRadius.circular(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return mapViewBuilder(
            MapViewParams(
              initialCameraPosition: MapCamera(
                target: MapPoint(
                  latitude: defaultLocation.lat,
                  longitude: defaultLocation.lng,
                ),
                zoom: defaultZoom,
              ),
              onMapReady: (_) {}, // No-op for home hub - no interactive features needed
            ),
          );
        },
      ),
    );
  }
}

/// Search bar widget for Home Hub - Ticket #188
class _HomeHubSearchBar extends StatelessWidget {
  const _HomeHubSearchBar({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      key: HomeHubScreen.homeHubSearchBarKey,
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.homeHubSearchPlaceholder,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ServiceChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: theme.colorScheme.primary.withValues(alpha: 0.06),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

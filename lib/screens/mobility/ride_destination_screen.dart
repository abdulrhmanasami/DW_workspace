/// Ride Destination Screen - Track B Ticket #20
/// Purpose: Destination input screen for ride booking flow (Screen 8 in Hi-Fi Mockups)
/// Created by: Track B - Ticket #20
/// Updated by: Track B - Ticket #21 (Direct navigation to Trip Confirmation)
/// Last updated: 2025-11-28
///
/// This screen provides:
/// - Map background (from maps_shims)
/// - Bottom Sheet with:
///   - Pickup location (Current Location - readonly)
///   - Destination input (Where to?)
///   - Recent locations list
///
/// NOTE: This is the first step in the ride booking flow:
/// Home Hub → RideDestinationScreen → RideTripConfirmationScreen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maps_shims/maps_shims.dart';
import 'package:mobility_shims/mobility_shims.dart';
import 'package:design_system_shims/design_system_shims.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../router/app_router.dart';
import '../../state/mobility/ride_draft_state.dart';
import '../../state/mobility/ride_quote_controller.dart';

/// RideDestinationScreen - Entry point for ride booking from Home Hub
/// Shows map background with bottom sheet for destination input.
class RideDestinationScreen extends ConsumerWidget {
  const RideDestinationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back,
              color: colorScheme.onSurface,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Map Background (from maps_shims)
          Positioned.fill(
            child: _MapBackground(colorScheme: colorScheme),
          ),

          // Bottom Sheet for destination input
          Align(
            alignment: Alignment.bottomCenter,
            child: _DestinationBottomSheet(l10n: l10n),
          ),
        ],
      ),
    );
  }
}

/// Map background widget using maps_shims and RideMapConfig (Track B - Ticket #28)
class _MapBackground extends ConsumerWidget {
  const _MapBackground({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(rideDraftProvider);

    // Build map config using domain helper (Track B - Ticket #28)
    final mapConfig = buildDestinationPreviewMap(
      pickup: draft.pickupPlace,
      destination: draft.destinationPlace,
    );

    return MapWidget(
      initialPosition: mapConfig.cameraTarget,
      markers: mapConfig.markers,
      polylines: mapConfig.polylines,
    );
  }
}

/// Bottom sheet with pickup, destination input, and recent locations
class _DestinationBottomSheet extends ConsumerStatefulWidget {
  const _DestinationBottomSheet({required this.l10n});

  final AppLocalizations l10n;

  @override
  ConsumerState<_DestinationBottomSheet> createState() =>
      _DestinationBottomSheetState();
}

class _DestinationBottomSheetState
    extends ConsumerState<_DestinationBottomSheet> {
  late TextEditingController _destinationController;
  final FocusNode _destinationFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final currentDestination = ref.read(rideDraftProvider).destinationQuery;
    _destinationController = TextEditingController(text: currentDestination);

    // Initialize pickup place as current location
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(rideDraftProvider.notifier);
      controller.updatePickupPlace(
        MobilityPlace.currentLocation(
          label: widget.l10n.rideDestinationPickupCurrentLocation,
        ),
      );
    });
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _destinationFocusNode.dispose();
    super.dispose();
  }

  /// Navigate to Trip Confirmation screen (Track B - Ticket #21)
  /// 
  /// This method:
  /// 1. Ensures pickup place is set (defaults to current location)
  /// 2. Updates destination place in RideDraft
  /// 3. Requests a quote via RideQuoteController
  /// 4. Navigates to the Trip Confirmation screen
  void _navigateToTripConfirmation({
    required BuildContext context,
    required WidgetRef ref,
    required MobilityPlace destinationPlace,
    required RideDraftController rideDraftController,
  }) {
    final l10n = AppLocalizations.of(context)!;
    
    // 1. Ensure pickup place is set
    final currentDraft = ref.read(rideDraftProvider);
    if (currentDraft.pickupPlace == null) {
      rideDraftController.updatePickupPlace(
        MobilityPlace.currentLocation(
          label: l10n.rideDestinationPickupCurrentLocation,
        ),
      );
    }

    // 2. Update destination place
    rideDraftController.updateDestinationPlace(destinationPlace);

    // 3. Request quote from draft
    final quoteController = ref.read(rideQuoteControllerProvider.notifier);
    final updatedDraft = ref.read(rideDraftProvider);
    quoteController.refreshFromDraft(updatedDraft);

    // 4. Navigate to Trip Confirmation
    Navigator.of(context).pushNamed(RoutePaths.rideTripConfirmation);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final l10n = widget.l10n;

    final rideDraft = ref.watch(rideDraftProvider);
    final rideDraftController = ref.read(rideDraftProvider.notifier);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.65,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            offset: const Offset(0, -4),
            color: colorScheme.shadow.withValues(alpha: 0.15),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),

              // Title
              Text(
                l10n.rideDestinationTitle,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),

              // Pickup field (readonly - Current Location)
              _LocationField(
                label: l10n.rideDestinationPickupLabel,
                value: rideDraft.pickupLabel,
                icon: Icons.my_location,
                iconColor: colorScheme.primary,
                isReadOnly: true,
              ),

              const SizedBox(height: 12),

              // Destination field (editable)
              _DestinationInputField(
                controller: _destinationController,
                focusNode: _destinationFocusNode,
                hintText: l10n.rideDestinationTitle,
                onChanged: (value) {
                  rideDraftController.updateDestination(value);
                },
                onClear: () {
                  _destinationController.clear();
                  rideDraftController.updateDestination('');
                },
              ),

              const SizedBox(height: 24),

              // Recent locations section
              Text(
                l10n.rideDestinationRecentLocationsSection,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // Recent locations list
              _RecentLocationsList(
                onLocationSelected: (location) {
                  // Track B - Ticket #21: Update draft and navigate to confirmation
                  _navigateToTripConfirmation(
                    context: context,
                    ref: ref,
                    destinationPlace: location.toMobilityPlace(),
                    rideDraftController: rideDraftController,
                  );
                  _destinationController.text = location.title;
                },
              ),

              const SizedBox(height: 20),

              // Continue CTA (visible when destination is entered)
              if (rideDraft.destinationQuery.trim().isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: DWButton.primary(
                    label: l10n.rideBookingSeeOptionsCta,
                    onPressed: () {
                      // Track B - Ticket #21: Create destination and navigate to confirmation
                      final destinationPlace = MobilityPlace(
                        label: rideDraft.destinationQuery.trim(),
                        type: MobilityPlaceType.searchResult,
                      );
                      _navigateToTripConfirmation(
                        context: context,
                        ref: ref,
                        destinationPlace: destinationPlace,
                        rideDraftController: rideDraftController,
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Readonly location field (for pickup)
class _LocationField extends StatelessWidget {
  const _LocationField({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.isReadOnly = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final bool isReadOnly;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: textTheme.bodyLarge,
                ),
              ),
              if (isReadOnly)
                Icon(
                  Icons.lock_outline,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  size: 18,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Destination input field with search icon and clear button
/// 
/// Ticket #35: Now uses DWTextField from design_system_shims
class _DestinationInputField extends StatelessWidget {
  const _DestinationInputField({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Build suffix icon based on input state
    final Widget suffixIcon = controller.text.isNotEmpty
        ? IconButton(
            icon: Icon(
              Icons.clear,
              color: colorScheme.onSurfaceVariant,
            ),
            onPressed: onClear,
          )
        : Icon(
            Icons.place_outlined,
            color: colorScheme.error,
          );

    return DWTextField(
      controller: controller,
      focusNode: focusNode,
      hintText: hintText,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      prefixIcon: const Icon(Icons.search),
      suffixIcon: suffixIcon,
      variant: DWTextFieldVariant.filled,
    );
  }
}

/// Recent locations list with mock data
class _RecentLocationsList extends StatelessWidget {
  const _RecentLocationsList({required this.onLocationSelected});

  final ValueChanged<RecentLocation> onLocationSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Mock recent locations (Track B - will be replaced with real data later)
    final recentLocations = [
      RecentLocation(
        id: 'home',
        title: l10n.rideBookingRecentHome,
        subtitle: l10n.rideBookingRecentHomeSubtitle,
        type: MobilityPlaceType.saved,
      ),
      RecentLocation(
        id: 'work',
        title: l10n.rideBookingRecentWork,
        subtitle: l10n.rideBookingRecentWorkSubtitle,
        type: MobilityPlaceType.saved,
      ),
      RecentLocation(
        id: 'recent_1',
        title: 'King Fahd Road',
        subtitle: 'Riyadh, Saudi Arabia',
        type: MobilityPlaceType.recent,
      ),
      RecentLocation(
        id: 'recent_2',
        title: 'Mall of Arabia',
        subtitle: 'Jeddah, Saudi Arabia',
        type: MobilityPlaceType.recent,
      ),
    ];

    return Column(
      children: recentLocations
          .map((location) => _RecentLocationCard(
                location: location,
                onTap: () => onLocationSelected(location),
              ))
          .toList(),
    );
  }
}

/// Individual recent location card
class _RecentLocationCard extends StatelessWidget {
  const _RecentLocationCard({
    required this.location,
    required this.onTap,
  });

  final RecentLocation location;
  final VoidCallback onTap;

  IconData _getIconForType(MobilityPlaceType type, String id) {
    if (id == 'home') return Icons.home_outlined;
    if (id == 'work') return Icons.work_outline;

    switch (type) {
      case MobilityPlaceType.saved:
        return Icons.bookmark_outline;
      case MobilityPlaceType.recent:
        return Icons.history;
      default:
        return Icons.place_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconForType(location.type, location.id),
                  color: colorScheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.title,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (location.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        location.subtitle!,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/// Ride Location Picker Screen - Track B Ticket #20, #93, #143
/// Purpose: Location picker screen for ride booking flow (Screen 8 in Hi-Fi Mockups)
/// Created by: Track B - Ticket #20
/// Updated by: Track B - Ticket #21 (Direct navigation to Trip Confirmation)
/// Updated by: Ticket #93 (Full Location Picker with editable Pickup/Dropoff + Design System)
/// Updated by: Track B - Ticket #143 (DWAppShell, proper Layout ratios, Empty State for recent locations)
/// Last updated: 2025-12-02
///
/// This screen provides:
/// - Map background (from maps_shims) with pickup/destination markers
/// - Bottom Sheet with:
///   - Pickup location input (editable, tappable to search)
///   - Destination input (editable, tappable to search)
///   - Recent locations list
///   - Continue CTA (enabled when both locations set)
///
/// NOTE: This is the first step in the ride booking flow:
/// Home Hub → RideDestinationScreen → RideTripConfirmationScreen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maps_shims/maps_shims.dart';
import 'package:mobility_shims/mobility_shims.dart';
import 'package:design_system_shims/design_system_shims.dart';

import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/router/app_router.dart';
import 'package:delivery_ways_clean/state/mobility/ride_draft_state.dart';
import 'package:delivery_ways_clean/state/mobility/ride_quote_controller.dart';
import 'package:delivery_ways_clean/state/mobility/ride_recent_locations_providers.dart';
import 'package:delivery_ways_clean/widgets/dw_app_shell.dart';
import 'widgets/ride_recent_destination_item.dart';

/// RideDestinationScreen - Location picker for ride booking from Home Hub
/// Shows map background with bottom sheet for pickup/destination input.
/// Ticket #93: Full Location Picker with editable Pickup/Dropoff + Design System
class RideDestinationScreen extends ConsumerStatefulWidget {
  const RideDestinationScreen({super.key});

  @override
  ConsumerState<RideDestinationScreen> createState() => _RideDestinationScreenState();
}

class _RideDestinationScreenState extends ConsumerState<RideDestinationScreen> {
  bool _returnResult = false;
  bool _didReadArguments = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Read route arguments to determine behavior (only once to avoid unnecessary rebuilds)
    if (!_didReadArguments) {
      _didReadArguments = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      final newValue = args is bool ? args : false;
      if (newValue != _returnResult) {
        // Use setState to ensure widget rebuilds if value changed
        setState(() {
          _returnResult = newValue;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final l10n = AppLocalizations.of(context)!;

    // Track B - Ticket #143: Use DWAppShell for consistency
    return DWAppShell(
      extendBodyBehindAppBar: true,
      applyPadding: false, // Full screen map
      useSafeArea: false, // Map extends to edges
      appBar: AppBar(
        backgroundColor: colorScheme.surface.withValues(alpha: 0.0),
        elevation: 0,
        title: Text(
          l10n.rideLocationPickerTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(DWSpacing.xs),
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
          // Map Background (from maps_shims) - Ticket #93
          Positioned.fill(
            child: _LocationPickerMap(colorScheme: colorScheme),
          ),

          // Map hint text - Ticket #93
          Positioned(
            top: MediaQuery.of(context).padding.top + kToolbarHeight + DWSpacing.sm,
            left: DWSpacing.md,
            right: DWSpacing.md,
            child: _MapHintBanner(l10n: l10n, colorScheme: colorScheme),
          ),

          // Bottom Sheet for location input - Ticket #93
          Align(
            alignment: Alignment.bottomCenter,
            child: _LocationPickerBottomSheet(l10n: l10n, returnResult: _returnResult),
          ),
        ],
      ),
    );
      },
    );
  }
}

/// Map hint banner widget - Ticket #93
class _MapHintBanner extends StatelessWidget {
  const _MapHintBanner({
    required this.l10n,
    required this.colorScheme,
  });

  final AppLocalizations l10n;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DWSpacing.md,
        vertical: DWSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(DWRadius.md),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: colorScheme.primary,
          ),
          const SizedBox(width: DWSpacing.xs),
          Expanded(
            child: Text(
              l10n.rideLocationPickerMapHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Map widget using maps_shims and RideMapConfig (Track B - Ticket #28, #93)
class _LocationPickerMap extends ConsumerWidget {
  const _LocationPickerMap({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(rideDraftProvider);

    // Build map config using domain helper (Track B - Ticket #28)
    final mapConfig = buildDestinationPreviewMap(
      pickup: draft.pickupPlace,
      destination: draft.destinationPlace,
    );

    // Use mapViewBuilderProvider for proper dependency injection (Ticket #172)
    final buildMap = ref.watch(mapViewBuilderProvider);
    return buildMap(
      MapViewParams(
        initialCameraPosition: MapCamera(
          target: MapPoint(
            latitude: mapConfig.cameraTarget.lat,
            longitude: mapConfig.cameraTarget.lng,
          ),
          zoom: mapConfig.cameraZoom,
        ),
        onMapReady: (_) {}, // No-op for location picker
      ),
    );
  }
}

/// Bottom sheet with pickup, destination input, and recent locations
/// Ticket #93: Full Location Picker with editable Pickup/Dropoff
class _LocationPickerBottomSheet extends ConsumerStatefulWidget {
  const _LocationPickerBottomSheet({
    required this.l10n,
    required this.returnResult,
  });

  final AppLocalizations l10n;
  final bool returnResult;

  @override
  ConsumerState<_LocationPickerBottomSheet> createState() =>
      _LocationPickerBottomSheetState();
}

/// Enum to track which field is currently being edited
enum _LocationFieldType { pickup }

class _LocationPickerBottomSheetState
    extends ConsumerState<_LocationPickerBottomSheet> {
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
          label: widget.l10n.rideLocationPickerPickupPlaceholder,
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

  /// Show search bottom sheet for location selection - Ticket #93
  void _showLocationSearchSheet({
    required BuildContext context,
    required _LocationFieldType fieldType,
    required RideDraftController rideDraftController,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface.withValues(alpha: 0.0),
      builder: (context) => _LocationSearchSheet(
        fieldType: fieldType,
        onLocationSelected: (place) {
          if (fieldType == _LocationFieldType.pickup) {
            rideDraftController.updatePickupPlace(place);
          } else {
            rideDraftController.updateDestinationPlace(place);
            _destinationController.text = place.label;
          }
          Navigator.of(context).pop();
        },
        l10n: l10n,
        colorScheme: colorScheme,
      ),
    );
  }

  /// Navigate to Trip Confirmation screen (Track B - Ticket #21, #93)
  /// or return the selected location if returnResult is true
  void _navigateToTripConfirmation({
    required BuildContext context,
    required WidgetRef ref,
    required RideDraftController rideDraftController,
    required bool returnResult,
  }) {
    if (returnResult) {
      // Return the selected destination location
      final currentDraft = ref.read(rideDraftProvider);
      final destinationPlace = currentDraft.destinationPlace;
      if (destinationPlace != null) {
        Navigator.of(context).pop(destinationPlace);
      } else if (currentDraft.destinationQuery.trim().isNotEmpty) {
        // Create a place from the query if no place was selected
        final place = MobilityPlace(
          label: currentDraft.destinationQuery.trim(),
          type: MobilityPlaceType.searchResult,
        );
        Navigator.of(context).pop(place);
      }
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final currentDraft = ref.read(rideDraftProvider);

    // Ensure pickup place is set
    if (currentDraft.pickupPlace == null) {
      rideDraftController.updatePickupPlace(
        MobilityPlace.currentLocation(
          label: l10n.rideLocationPickerPickupPlaceholder,
        ),
      );
    }

    // Ensure destination place is set
    if (currentDraft.destinationPlace == null &&
        currentDraft.destinationQuery.trim().isNotEmpty) {
      rideDraftController.updateDestinationPlace(
        MobilityPlace(
          label: currentDraft.destinationQuery.trim(),
          type: MobilityPlaceType.searchResult,
        ),
      );
    }

    // Request quote from draft
    final quoteController = ref.read(rideQuoteControllerProvider.notifier);
    final updatedDraft = ref.read(rideDraftProvider);
    quoteController.refreshFromDraft(updatedDraft);

    // Navigate to Trip Confirmation
    Navigator.of(context).pushNamed(RoutePaths.rideTripConfirmation);
  }

  /// Check if both locations are valid for navigation
  bool _isValidDraft(RideDraftUiState draft) {
    final hasPickup = draft.pickupPlace != null || draft.pickupLabel.isNotEmpty;
    final hasDestination = draft.destinationPlace != null || 
                           draft.destinationQuery.trim().isNotEmpty;
    return hasPickup && hasDestination;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final l10n = widget.l10n;

    final rideDraft = ref.watch(rideDraftProvider);
    final rideDraftController = ref.read(rideDraftProvider.notifier);
    final isValidDraft = _isValidDraft(rideDraft);

    // Track B - Ticket #143: Adjusted to ~45% height to match Hi-Fi
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.45,
        minHeight: MediaQuery.of(context).size.height * 0.40,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(DWRadius.lg),
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
          padding: const EdgeInsets.fromLTRB(DWSpacing.lg, DWSpacing.sm, DWSpacing.lg, DWSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: DWSpacing.md),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(DWRadius.circle),
                  ),
                ),
              ),

              // Pickup field (tappable to edit) - Ticket #93
              _TappableLocationField(
                label: l10n.rideLocationPickerPickupLabel,
                value: rideDraft.pickupLabel.isNotEmpty 
                    ? rideDraft.pickupLabel 
                    : l10n.rideLocationPickerPickupPlaceholder,
                icon: Icons.my_location,
                iconColor: colorScheme.primary,
                onTap: () => _showLocationSearchSheet(
                  context: context,
                  fieldType: _LocationFieldType.pickup,
                  rideDraftController: rideDraftController,
                ),
              ),

              const SizedBox(height: DWSpacing.sm),

              // Destination field (editable) - Ticket #93
              _DestinationInputField(
                controller: _destinationController,
                focusNode: _destinationFocusNode,
                hintText: l10n.rideLocationPickerDestinationPlaceholder,
                onChanged: (value) {
                  rideDraftController.updateDestination(value);
                },
                onClear: () {
                  _destinationController.clear();
                  rideDraftController.updateDestination('');
                },
              ),

              const SizedBox(height: DWSpacing.lg),

              // Recent locations section
              Text(
                l10n.rideDestinationRecentLocationsSection,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: DWSpacing.sm),

              // Recent locations list
              _RecentLocationsList(
                onLocationSelected: (location) {
                  // Update destination and navigate to confirmation
                  rideDraftController.updateDestinationPlace(location.toMobilityPlace());
                  _destinationController.text = location.title;
                  _navigateToTripConfirmation(
                    context: context,
                    ref: ref,
                    rideDraftController: rideDraftController,
                    returnResult: widget.returnResult,
                  );
                },
              ),

              const SizedBox(height: DWSpacing.lg),

              // Continue CTA - Ticket #93: enabled only when both locations set
              SizedBox(
                width: double.infinity,
                child: DWButton.primary(
                  label: l10n.rideLocationPickerContinueCta,
                  onPressed: isValidDraft
                      ? () => _navigateToTripConfirmation(
                            context: context,
                            ref: ref,
                            rideDraftController: rideDraftController,
                            returnResult: widget.returnResult,
                          )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tappable location field (for pickup) - Ticket #93
class _TappableLocationField extends StatelessWidget {
  const _TappableLocationField({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

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
        const SizedBox(height: DWSpacing.xxs),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DWRadius.md),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DWSpacing.md,
              vertical: DWSpacing.md,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(DWRadius.md),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 22),
                const SizedBox(width: DWSpacing.sm),
                Expanded(
                  child: Text(
                    value,
                    style: textTheme.bodyLarge,
                  ),
                ),
                Icon(
                  Icons.edit_location_outlined,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Location search bottom sheet - Ticket #93
class _LocationSearchSheet extends StatefulWidget {
  const _LocationSearchSheet({
    required this.fieldType,
    required this.onLocationSelected,
    required this.l10n,
    required this.colorScheme,
  });

  final _LocationFieldType fieldType;
  final ValueChanged<MobilityPlace> onLocationSelected;
  final AppLocalizations l10n;
  final ColorScheme colorScheme;

  @override
  State<_LocationSearchSheet> createState() => _LocationSearchSheetState();
}

class _LocationSearchSheetState extends State<_LocationSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  /// Stub search results - Ticket #93
  /// In a future ticket, this will be replaced with real geocoding API
  List<MobilityPlace> get _searchResults {
    if (_searchQuery.isEmpty) {
      // Default suggestions
      return [
        MobilityPlace.currentLocation(
          label: widget.l10n.rideLocationPickerPickupPlaceholder,
        ),
        const MobilityPlace(
          label: 'King Fahd Road',
          type: MobilityPlaceType.recent,
          location: LocationPoint(latitude: 24.7136, longitude: 46.6753),
        ),
        const MobilityPlace(
          label: 'Mall of Arabia',
          type: MobilityPlaceType.recent,
          location: LocationPoint(latitude: 21.5433, longitude: 39.1728),
        ),
        const MobilityPlace(
          label: 'Riyadh Airport (RUH)',
          type: MobilityPlaceType.searchResult,
          location: LocationPoint(latitude: 24.9576, longitude: 46.6988),
        ),
      ];
    }

    // Filter by search query (stub implementation)
    final lowerQuery = _searchQuery.toLowerCase();
    return [
      MobilityPlace(
        label: _searchQuery,
        type: MobilityPlaceType.searchResult,
      ),
      if ('king fahd road'.contains(lowerQuery))
        const MobilityPlace(
          label: 'King Fahd Road',
          type: MobilityPlaceType.searchResult,
          location: LocationPoint(latitude: 24.7136, longitude: 46.6753),
        ),
      if ('mall of arabia'.contains(lowerQuery))
        const MobilityPlace(
          label: 'Mall of Arabia',
          type: MobilityPlaceType.searchResult,
          location: LocationPoint(latitude: 21.5433, longitude: 39.1728),
        ),
      if ('airport'.contains(lowerQuery) || 'ruh'.contains(lowerQuery))
        const MobilityPlace(
          label: 'Riyadh Airport (RUH)',
          type: MobilityPlaceType.searchResult,
          location: LocationPoint(latitude: 24.9576, longitude: 46.6988),
        ),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final title = widget.fieldType == _LocationFieldType.pickup
        ? widget.l10n.rideLocationPickerPickupLabel
        : widget.l10n.rideLocationPickerDestinationLabel;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: widget.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(DWRadius.lg),
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(DWSpacing.md),
            child: Column(
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: widget.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(DWRadius.circle),
                  ),
                ),
                const SizedBox(height: DWSpacing.md),
                // Title
                Text(
                  title,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: DWSpacing.md),
                // Search field
                TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: widget.fieldType == _LocationFieldType.pickup
                        ? widget.l10n.rideLocationPickerPickupPlaceholder
                        : widget.l10n.rideLocationPickerDestinationPlaceholder,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DWRadius.md),
                    ),
                    filled: true,
                    fillColor: widget.colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
            ),
          ),

          // Search results
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: DWSpacing.md),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final place = _searchResults[index];
                return _SearchResultTile(
                  place: place,
                  onTap: () => widget.onLocationSelected(place),
                  colorScheme: widget.colorScheme,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Search result tile widget - Ticket #93
class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.place,
    required this.onTap,
    required this.colorScheme,
  });

  final MobilityPlace place;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  IconData _getIconForType(MobilityPlaceType type) {
    switch (type) {
      case MobilityPlaceType.currentLocation:
        return Icons.my_location;
      case MobilityPlaceType.saved:
        return Icons.bookmark_outline;
      case MobilityPlaceType.recent:
        return Icons.history;
      case MobilityPlaceType.searchResult:
        return Icons.place_outlined;
      case MobilityPlaceType.other:
        return Icons.location_on_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: DWSpacing.xxs),
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DWRadius.md),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(DWSpacing.xs),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(DWRadius.sm),
          ),
          child: Icon(
            _getIconForType(place.type),
            color: colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          place.label,
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: place.location != null
            ? Text(
                '${place.location!.latitude.toStringAsFixed(4)}, ${place.location!.longitude.toStringAsFixed(4)}',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
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

/// Recent locations list with empty state
/// Track B - Ticket #145: Using real recent locations provider
class _RecentLocationsList extends ConsumerWidget {
  const _RecentLocationsList({required this.onLocationSelected});

  final ValueChanged<RecentLocation> onLocationSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Track B - Ticket #145: Now using real recent locations provider
    final recentLocationsAsync = ref.watch(recentLocationsProvider);

    return recentLocationsAsync.when(
      loading: () => _RecentLocationsLoadingState(colorScheme: colorScheme),
      error: (error, stackTrace) => _RecentLocationsErrorState(
        colorScheme: colorScheme,
        textTheme: textTheme,
        error: error.toString(),
      ),
      data: (recentLocations) {
        if (recentLocations.isEmpty) {
      // Empty state UI
      return Container(
        padding: const EdgeInsets.symmetric(
          vertical: DWSpacing.lg,
          horizontal: DWSpacing.md,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(DWRadius.md),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.history_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: DWSpacing.sm),
            Text(
              'No recent locations yet',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DWSpacing.xs),
            Text(
              'Your recent destinations will appear here',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
        }

        // If we have locations, show them
        return Column(
          children: recentLocations
              .map((location) => RideRecentDestinationItem(
                    label: location.title,
                    subtitle: location.subtitle,
                    icon: getMobilityPlaceIcon(location.type, location.id),
                    onTap: () => onLocationSelected(location),
                  ))
              .toList(),
        );
      },
    );
  }
}

/// Loading state widget for recent locations
class _RecentLocationsLoadingState extends StatelessWidget {
  const _RecentLocationsLoadingState({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: DWSpacing.lg,
        horizontal: DWSpacing.md,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(DWRadius.md),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              colorScheme.primary.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }
}

/// Error state widget for recent locations
class _RecentLocationsErrorState extends StatelessWidget {
  const _RecentLocationsErrorState({
    required this.colorScheme,
    required this.textTheme,
    required this.error,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final String error;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: DWSpacing.lg,
        horizontal: DWSpacing.md,
      ),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DWRadius.md),
        border: Border.all(
          color: colorScheme.error.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: colorScheme.error.withValues(alpha: 0.6),
          ),
          const SizedBox(height: DWSpacing.sm),
          Text(
            'Failed to load recent locations',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}




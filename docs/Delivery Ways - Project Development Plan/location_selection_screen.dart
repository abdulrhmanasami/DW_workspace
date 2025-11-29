import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/app_button_unified.dart';
import '../../widgets/app_card_unified.dart';
import '../../state/mobility/ride_providers.dart';

/// Component: Location Selection Screen
/// Created by: Track B - Ride Vertical Implementation
/// Purpose: Allow users to select pickup and destination locations
/// Last updated: 2025-11-27

class LocationSelectionScreen extends ConsumerStatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  ConsumerState<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState
    extends ConsumerState<LocationSelectionScreen> {
  late TextEditingController _pickupController;
  late TextEditingController _destinationController;

  Location? _selectedPickup;
  Location? _selectedDestination;

  @override
  void initState() {
    super.initState();
    _pickupController = TextEditingController();
    _destinationController = TextEditingController();
    _initializeWithCurrentLocation();
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void _initializeWithCurrentLocation() {
    // Mock: Use a default location
    _selectedPickup = const Location(
      address: 'Current Location',
      latitude: 37.7749,
      longitude: -122.4194,
    );
    _pickupController.text = _selectedPickup!.address;
  }

  void _selectPickupLocation(Location location) {
    setState(() {
      _selectedPickup = location;
      _pickupController.text = location.address;
    });
  }

  void _selectDestinationLocation(Location location) {
    setState(() {
      _selectedDestination = location;
      _destinationController.text = location.address;
    });
  }

  void _proceedToRideOptions() {
    if (_selectedPickup == null || _selectedDestination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both locations')),
      );
      return;
    }

    // Initialize ride booking
    ref.read(rideBookingProvider.notifier).initializeBooking(
      _selectedPickup!,
      _selectedDestination!,
    );

    // Navigate to ride options
    Navigator.of(context).pushNamed('/mobility/ride-booking');
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);

    return AppShell(
      title: 'Select Locations',
      showBottomNav: false,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(theme.spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pickup location
              _buildLocationInput(
                theme,
                'Pickup Location',
                _pickupController,
                _selectedPickup,
                (location) => _selectPickupLocation(location),
              ),
              SizedBox(height: theme.spacing.lg),

              // Swap button
              Center(
                child: FloatingActionButton(
                  mini: true,
                  onPressed: () {
                    if (_selectedPickup != null && _selectedDestination != null) {
                      final temp = _selectedPickup;
                      _selectPickupLocation(_selectedDestination!);
                      _selectDestinationLocation(temp!);
                    }
                  },
                  child: const Icon(Icons.swap_vert),
                ),
              ),
              SizedBox(height: theme.spacing.lg),

              // Destination location
              _buildLocationInput(
                theme,
                'Destination',
                _destinationController,
                _selectedDestination,
                (location) => _selectDestinationLocation(location),
              ),
              SizedBox(height: theme.spacing.lg),

              // Recent locations
              if (_selectedDestination == null)
                _buildRecentLocations(theme),

              SizedBox(height: theme.spacing.xl),

              // Proceed button
              AppButtonUnified(
                label: 'Continue to Ride Options',
                fullWidth: true,
                style: AppButtonStyle.primary,
                isEnabled: _selectedPickup != null && _selectedDestination != null,
                onPressed: _proceedToRideOptions,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationInput(
    AppThemeData theme,
    String label,
    TextEditingController controller,
    Location? selectedLocation,
    Function(Location) onLocationSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.typography.subtitle1.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: theme.spacing.sm),
        AppCardUnified(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(theme.spacing.md),
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Enter $label',
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      label == 'Pickup Location'
                          ? Icons.location_on_outlined
                          : Icons.location_on,
                      color: theme.colors.primary,
                    ),
                    suffixIcon: selectedLocation != null
                        ? Icon(
                            Icons.check_circle,
                            color: theme.colors.primary,
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    // Mock: Show suggestions
                  },
                ),
              ),
              if (selectedLocation != null)
                Padding(
                  padding: EdgeInsets.all(theme.spacing.md),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colors.background,
                      borderRadius:
                          BorderRadius.circular(theme.spacing.mediumRadius),
                    ),
                    padding: EdgeInsets.all(theme.spacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedLocation.address,
                          style: theme.typography.body1.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: theme.spacing.xs),
                        Text(
                          '${selectedLocation.latitude.toStringAsFixed(4)}, ${selectedLocation.longitude.toStringAsFixed(4)}',
                          style: theme.typography.caption.copyWith(
                            color: theme.colors.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentLocations(AppThemeData theme) {
    final recentLocations = [
      const Location(
        address: 'Work - Downtown Office',
        latitude: 37.7749,
        longitude: -122.4194,
      ),
      const Location(
        address: 'Home - Residential Area',
        latitude: 37.7849,
        longitude: -122.4094,
      ),
      const Location(
        address: 'Shopping Mall - Market Street',
        latitude: 37.7849,
        longitude: -122.4294,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Locations',
          style: theme.typography.subtitle1.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: theme.spacing.md),
        ...recentLocations.map((location) {
          return Padding(
            padding: EdgeInsets.only(bottom: theme.spacing.md),
            child: AppCardUnified(
              onTap: () => _selectDestinationLocation(location),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: theme.colors.primary,
                  ),
                  SizedBox(width: theme.spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          location.address,
                          style: theme.typography.body1.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: theme.colors.onSurface.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}

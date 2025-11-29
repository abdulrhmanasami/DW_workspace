import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart' hide AppCard;
import '../../widgets/app_shell.dart';
import '../../widgets/app_button_unified.dart';
import '../../widgets/app_card_unified.dart';
import '../../state/mobility/ride_providers.dart';

/// Component: Ride Booking Screen
/// Created by: Track B - Ride Vertical Implementation
/// Purpose: Display ride options and allow user to select and book a ride
/// Last updated: 2025-11-27

class RideBookingScreen extends ConsumerStatefulWidget {
  const RideBookingScreen({super.key});

  @override
  ConsumerState<RideBookingScreen> createState() => _RideBookingScreenState();
}

class _RideBookingScreenState extends ConsumerState<RideBookingScreen> {
  String? _selectedRideOptionId;

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final rideBooking = ref.watch(rideBookingProvider);

    if (rideBooking == null) {
      return AppShell(
        title: 'Select Ride',
        showBottomNav: false,
        body: Center(
          child: Text(
            'No ride booking in progress',
            style: theme.typography.body1,
          ),
        ),
      );
    }

    final rideOptionsAsync = ref.watch(
      rideOptionsProvider((
        rideBooking.pickupLocation,
        rideBooking.destinationLocation,
      )),
    );

    return AppShell(
      title: 'Select Ride',
      showBottomNav: false,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(theme.spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trip summary
              _buildTripSummary(theme, rideBooking),
              SizedBox(height: theme.spacing.lg),

              // Ride options
              Text(
                'Available Rides',
                style: theme.typography.headline6.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: theme.spacing.md),

              rideOptionsAsync.when(
                data: (rideOptions) {
                  return Column(
                    children: rideOptions.map((option) {
                      final isSelected = _selectedRideOptionId == option.id;
                      return Padding(
                        padding: EdgeInsets.only(bottom: theme.spacing.md),
                        child: _buildRideOptionCard(
                          theme,
                          option,
                          isSelected,
                          () {
                            setState(() {
                              _selectedRideOptionId = option.id;
                              ref
                                  .read(rideBookingProvider.notifier)
                                  .setRideOption(option);
                            });
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colors.primary,
                    ),
                  ),
                ),
                error: (error, stack) => Center(
                  child: Text(
                    'Error loading ride options',
                    style: theme.typography.body1.copyWith(
                      color: theme.colors.error,
                    ),
                  ),
                ),
              ),

              SizedBox(height: theme.spacing.lg),

              // Payment method
              _buildPaymentMethodSection(theme),

              SizedBox(height: theme.spacing.xl),

              // Book ride button
              AppButtonUnified(
                label: 'Book Ride',
                fullWidth: true,
                style: AppButtonStyle.primary,
                isEnabled: _selectedRideOptionId != null,
                onPressed: _bookRide,
              ),

              SizedBox(height: theme.spacing.md),

              // Back button
              AppButtonUnified(
                label: 'Back',
                fullWidth: true,
                style: AppButtonStyle.secondary,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripSummary(AppThemeData theme, RideBooking rideBooking) {
    return AppCard.standard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      'From',
                      style: theme.typography.caption.copyWith(
                        color: theme.colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      rideBooking.pickupLocation.address,
                      style: theme.typography.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: theme.spacing.md),
          Divider(color: theme.colors.outline),
          SizedBox(height: theme.spacing.md),
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: theme.colors.primary,
              ),
              SizedBox(width: theme.spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'To',
                      style: theme.typography.caption.copyWith(
                        color: theme.colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      rideBooking.destinationLocation.address,
                      style: theme.typography.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRideOptionCard(
    AppThemeData theme,
    RideOption option,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return AppCardUnified(
      onTap: onTap,
      backgroundColor: isSelected
          ? theme.colors.primary.withValues(alpha: 0.1)
          : theme.colors.surface,
      borderSide: isSelected
          ? BorderSide(color: theme.colors.primary, width: 2)
          : null,
      child: Row(
        children: [
          // Vehicle icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: theme.colors.background,
              borderRadius: BorderRadius.circular(theme.spacing.mediumRadius),
            ),
            child: Icon(
              _getVehicleIcon(option.vehicleType),
              color: theme.colors.primary,
              size: 32,
            ),
          ),
          SizedBox(width: theme.spacing.md),

          // Ride details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option.name,
                  style: theme.typography.subtitle1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  option.description,
                  style: theme.typography.caption.copyWith(
                    color: theme.colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                SizedBox(height: theme.spacing.xs),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: theme.colors.onSurface.withValues(alpha: 0.6),
                    ),
                    SizedBox(width: theme.spacing.xs),
                    Text(
                      '${option.estimatedMinutes} min',
                      style: theme.typography.caption.copyWith(
                        color: theme.colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Fare
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${option.estimatedFare.toStringAsFixed(2)}',
                style: theme.typography.headline6.copyWith(
                  color: theme.colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: theme.colors.primary,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection(AppThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: theme.typography.subtitle1.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: theme.spacing.md),
        AppCardUnified(
          child: Row(
            children: [
              Icon(
                Icons.credit_card,
                color: theme.colors.primary,
              ),
              SizedBox(width: theme.spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Credit Card',
                      style: theme.typography.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '**** **** **** 4242',
                      style: theme.typography.caption.copyWith(
                        color: theme.colors.onSurface.withValues(alpha: 0.6),
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
      ],
    );
  }

  IconData _getVehicleIcon(String vehicleType) {
    switch (vehicleType) {
      case 'sedan':
        return Icons.directions_car;
      case 'suv':
        return Icons.directions_car;
      case 'van':
        return Icons.local_shipping;
      default:
        return Icons.directions_car;
    }
  }

  void _bookRide() {
    if (_selectedRideOptionId == null) return;

    final rideBooking = ref.read(rideBookingProvider);
    if (rideBooking == null) return;

    // Create a trip from the booking
    final trip = Trip(
      id: 'trip_${DateTime.now().millisecondsSinceEpoch}',
      booking: rideBooking,
      status: TripStatus.searching,
    );

    // Set the trip
    ref.read(tripProvider.notifier).setTrip(trip);

    // Navigate to trip tracking
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/mobility/trip-tracking',
      (route) => route.isFirst,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/app_button_unified.dart';
import '../../widgets/app_card_unified.dart';
import '../../state/mobility/ride_providers.dart';

/// Component: Trip Tracking Screen
/// Created by: Track B - Ride Vertical Implementation
/// Purpose: Display real-time trip tracking and driver information
/// Last updated: 2025-11-27

class TripTrackingScreen extends ConsumerStatefulWidget {
  const TripTrackingScreen({super.key});

  @override
  ConsumerState<TripTrackingScreen> createState() => _TripTrackingScreenState();
}

class _TripTrackingScreenState extends ConsumerState<TripTrackingScreen> {
  @override
  void initState() {
    super.initState();
    _simulateTripProgress();
  }

  void _simulateTripProgress() {
    // Simulate driver assignment after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        final trip = ref.read(tripProvider);
        if (trip != null && trip.status == TripStatus.searching) {
          ref.read(tripProvider.notifier).assignDriver(
            'driver_123',
            'John Smith',
            4.8,
            'Toyota Prius - ABC 123',
          );
        }
      }
    });

    // Simulate driver arriving after 8 seconds
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) {
        final trip = ref.read(tripProvider);
        if (trip != null && trip.status == TripStatus.driverAssigned) {
          ref.read(tripProvider.notifier).updateTripStatus(TripStatus.driverArriving);
          ref.read(tripProvider.notifier).updateEstimatedArrival(2);
        }
      }
    });

    // Simulate trip in progress after 13 seconds
    Future.delayed(const Duration(seconds: 13), () {
      if (mounted) {
        final trip = ref.read(tripProvider);
        if (trip != null && trip.status == TripStatus.driverArriving) {
          ref.read(tripProvider.notifier).updateTripStatus(TripStatus.tripInProgress);
          ref.read(tripProvider.notifier).updateEstimatedArrival(8);
        }
      }
    });

    // Simulate trip completion after 25 seconds
    Future.delayed(const Duration(seconds: 25), () {
      if (mounted) {
        final trip = ref.read(tripProvider);
        if (trip != null && trip.status == TripStatus.tripInProgress) {
          ref.read(tripProvider.notifier).completeTrip(12.50);
          // Navigate to completion screen
          Navigator.of(context).pushReplacementNamed('/mobility/trip-completion');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final trip = ref.watch(tripProvider);

    if (trip == null) {
      return AppShell(
        title: 'Trip Tracking',
        showBottomNav: false,
        body: Center(
          child: Text(
            'No active trip',
            style: theme.typography.body1,
          ),
        ),
      );
    }

    return AppShell(
      title: 'Trip Tracking',
      showBottomNav: false,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(theme.spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trip status
              _buildTripStatusCard(theme, trip),
              SizedBox(height: theme.spacing.lg),

              // Map placeholder
              _buildMapPlaceholder(theme, trip),
              SizedBox(height: theme.spacing.lg),

              // Driver information (if assigned)
              if (trip.driverId != null)
                _buildDriverInfoCard(theme, trip),
              if (trip.driverId != null)
                SizedBox(height: theme.spacing.lg),

              // Trip details
              _buildTripDetailsCard(theme, trip),
              SizedBox(height: theme.spacing.lg),

              // Action buttons
              _buildActionButtons(theme, trip),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripStatusCard(AppThemeData theme, Trip trip) {
    final statusText = _getTripStatusText(trip.status);
    final statusColor = _getTripStatusColor(theme, trip.status);

    return AppCardUnified(
      backgroundColor: statusColor.withValues(alpha: 0.1),
      borderSide: BorderSide(color: statusColor, width: 1.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getTripStatusIcon(trip.status),
                color: statusColor,
                size: 32,
              ),
              SizedBox(width: theme.spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trip Status',
                      style: theme.typography.caption.copyWith(
                        color: theme.colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      statusText,
                      style: theme.typography.headline6.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (trip.estimatedArrivalMinutes != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${trip.estimatedArrivalMinutes} min',
                      style: theme.typography.headline6.copyWith(
                        color: theme.colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder(AppThemeData theme, Trip trip) {
    return AppCardUnified(
      padding: EdgeInsets.zero,
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          color: theme.colors.background,
          borderRadius: BorderRadius.circular(theme.spacing.mediumRadius),
        ),
        child: Stack(
          children: [
            // Map background
            Center(
              child: Icon(
                Icons.map,
                size: 80,
                color: theme.colors.onSurface.withValues(alpha: 0.2),
              ),
            ),

            // Pickup marker
            Positioned(
              left: 50,
              top: 100,
              child: Column(
                children: [
                  Icon(
                    Icons.location_on,
                    color: theme.colors.primary,
                    size: 32,
                  ),
                  Text(
                    'Pickup',
                    style: theme.typography.caption,
                  ),
                ],
              ),
            ),

            // Driver marker
            if (trip.driverLocation != null)
              Positioned(
                right: 80,
                top: 150,
                child: Column(
                  children: [
                    Icon(
                      Icons.directions_car,
                      color: theme.colors.primary,
                      size: 32,
                    ),
                    Text(
                      'Driver',
                      style: theme.typography.caption,
                    ),
                  ],
                ),
              ),

            // Destination marker
            Positioned(
              right: 50,
              bottom: 50,
              child: Column(
                children: [
                  Icon(
                    Icons.location_on,
                    color: theme.colors.error,
                    size: 32,
                  ),
                  Text(
                    'Destination',
                    style: theme.typography.caption,
                  ),
                ],
              ),
            ),

            // Route line (simplified)
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              bottom: 0,
              child: CustomPaint(
                painter: _RoutePainter(theme.colors.primary.withValues(alpha: 0.3)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverInfoCard(AppThemeData theme, Trip trip) {
    return AppCardUnified(
      child: Row(
        children: [
          // Driver avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: theme.colors.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.person,
                color: theme.colors.primary,
                size: 32,
              ),
            ),
          ),
          SizedBox(width: theme.spacing.md),

          // Driver details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.driverName ?? 'Driver',
                  style: theme.typography.subtitle1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (trip.vehicleInfo != null)
                  Text(
                    trip.vehicleInfo!,
                    style: theme.typography.caption.copyWith(
                      color: theme.colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                if (trip.driverRating != null)
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 14,
                        color: Colors.amber,
                      ),
                      SizedBox(width: theme.spacing.xs),
                      Text(
                        '${trip.driverRating}',
                        style: theme.typography.caption,
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Contact button
          IconButton(
            icon: Icon(Icons.phone, color: theme.colors.primary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Calling driver...')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTripDetailsCard(AppThemeData theme, Trip trip) {
    return AppCardUnified(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trip Details',
            style: theme.typography.subtitle1.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: theme.spacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'From',
                    style: theme.typography.caption.copyWith(
                      color: theme.colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    trip.booking.pickupLocation.address,
                    style: theme.typography.body2.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: theme.spacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'To',
                    style: theme.typography.caption.copyWith(
                      color: theme.colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    trip.booking.destinationLocation.address,
                    style: theme.typography.body2.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: theme.spacing.md),
          Divider(color: theme.colors.outline),
          SizedBox(height: theme.spacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estimated Fare',
                style: theme.typography.body2.copyWith(
                  color: theme.colors.onSurface.withValues(alpha: 0.6),
                ),
              ),
              Text(
                '\$${trip.booking.selectedRideOption.estimatedFare.toStringAsFixed(2)}',
                style: theme.typography.headline6.copyWith(
                  color: theme.colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AppThemeData theme, Trip trip) {
    return Column(
      children: [
        AppButtonUnified(
          label: 'Contact Driver',
          fullWidth: true,
          style: AppButtonStyle.secondary,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Opening contact options...')),
            );
          },
        ),
        SizedBox(height: theme.spacing.md),
        AppButtonUnified(
          label: 'Cancel Trip',
          fullWidth: true,
          style: AppButtonStyle.danger,
          onPressed: () {
            _showCancelConfirmation(context, theme);
          },
        ),
      ],
    );
  }

  void _showCancelConfirmation(BuildContext context, AppThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Trip?'),
        content: const Text('Are you sure you want to cancel this trip?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Trip'),
          ),
          TextButton(
            onPressed: () {
              ref.read(tripProvider.notifier).cancelTrip();
              Navigator.pop(context);
              Navigator.of(context).pushReplacementNamed('/');
            },
            child: const Text('Cancel Trip'),
          ),
        ],
      ),
    );
  }

  String _getTripStatusText(TripStatus status) {
    switch (status) {
      case TripStatus.idle:
        return 'Idle';
      case TripStatus.searching:
        return 'Finding a driver...';
      case TripStatus.driverAssigned:
        return 'Driver assigned';
      case TripStatus.driverArriving:
        return 'Driver arriving';
      case TripStatus.tripInProgress:
        return 'On the way';
      case TripStatus.completed:
        return 'Completed';
      case TripStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _getTripStatusColor(AppThemeData theme, TripStatus status) {
    switch (status) {
      case TripStatus.searching:
        return Colors.orange;
      case TripStatus.driverAssigned:
      case TripStatus.driverArriving:
      case TripStatus.tripInProgress:
        return theme.colors.primary;
      case TripStatus.completed:
        return Colors.green;
      case TripStatus.cancelled:
        return theme.colors.error;
      default:
        return theme.colors.primary;
    }
  }

  IconData _getTripStatusIcon(TripStatus status) {
    switch (status) {
      case TripStatus.searching:
        return Icons.search;
      case TripStatus.driverAssigned:
        return Icons.check_circle;
      case TripStatus.driverArriving:
        return Icons.directions_car;
      case TripStatus.tripInProgress:
        return Icons.navigation;
      case TripStatus.completed:
        return Icons.check_circle;
      case TripStatus.cancelled:
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }
}

/// Custom painter for route line
class _RoutePainter extends CustomPainter {
  final Color color;

  _RoutePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw a simple curved line from top-left to bottom-right
    final path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.3);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.5,
      size.width * 0.8,
      size.height * 0.7,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_RoutePainter oldDelegate) => false;
}

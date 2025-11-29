import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/app_button_unified.dart';
import '../../widgets/app_card_unified.dart';
import '../../state/mobility/ride_providers.dart';

/// Component: Trip Completion Screen
/// Created by: Track B - Ride Vertical Implementation
/// Purpose: Display trip summary, rating, and receipt
/// Last updated: 2025-11-27

class TripCompletionScreen extends ConsumerStatefulWidget {
  const TripCompletionScreen({super.key});

  @override
  ConsumerState<TripCompletionScreen> createState() =>
      _TripCompletionScreenState();
}

class _TripCompletionScreenState extends ConsumerState<TripCompletionScreen> {
  int _driverRating = 0;

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final trip = ref.watch(tripProvider);

    if (trip == null || trip.status != TripStatus.completed) {
      return AppShell(
        title: 'Trip Completed',
        showBottomNav: false,
        body: Center(
          child: Text(
            'Trip not found',
            style: theme.typography.body1,
          ),
        ),
      );
    }

    return AppShell(
      title: 'Trip Completed',
      showBottomNav: false,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(theme.spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Success message
              _buildSuccessMessage(theme),
              SizedBox(height: theme.spacing.lg),

              // Driver information
              if (trip.driverId != null)
                _buildDriverCard(theme, trip),
              if (trip.driverId != null)
                SizedBox(height: theme.spacing.lg),

              // Trip summary
              _buildTripSummary(theme, trip),
              SizedBox(height: theme.spacing.lg),

              // Fare breakdown
              _buildFareBreakdown(theme, trip),
              SizedBox(height: theme.spacing.lg),

              // Rating section
              _buildRatingSection(theme),
              SizedBox(height: theme.spacing.lg),

              // Feedback section
              _buildFeedbackSection(theme),
              SizedBox(height: theme.spacing.lg),

              // Action buttons
              _buildActionButtons(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessMessage(AppThemeData theme) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.check_circle,
                size: 60,
                color: Colors.green,
              ),
            ),
          ),
          SizedBox(height: theme.spacing.md),
          Text(
            'Trip Completed!',
            style: theme.typography.headline5.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colors.onBackground,
            ),
          ),
          SizedBox(height: theme.spacing.sm),
          Text(
            'Thank you for using Delivery Ways',
            style: theme.typography.body2.copyWith(
              color: theme.colors.onBackground.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(AppThemeData theme, Trip trip) {
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
        ],
      ),
    );
  }

  Widget _buildTripSummary(AppThemeData theme, Trip trip) {
    return AppCardUnified(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trip Summary',
            style: theme.typography.subtitle1.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: theme.spacing.md),

          // From
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
                      trip.booking.pickupLocation.address,
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

          // To
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
                      trip.booking.destinationLocation.address,
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

  Widget _buildFareBreakdown(AppThemeData theme, Trip trip) {
    final baseFare = 2.50;
    final distanceFare = (trip.totalFare ?? 0) - baseFare - 1.00;

    return AppCardUnified(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fare Breakdown',
            style: theme.typography.subtitle1.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: theme.spacing.md),

          // Base fare
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Base Fare',
                style: theme.typography.body2,
              ),
              Text(
                '\$${baseFare.toStringAsFixed(2)}',
                style: theme.typography.body2,
              ),
            ],
          ),
          SizedBox(height: theme.spacing.sm),

          // Distance fare
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Distance Fare',
                style: theme.typography.body2,
              ),
              Text(
                '\$${distanceFare.toStringAsFixed(2)}',
                style: theme.typography.body2,
              ),
            ],
          ),
          SizedBox(height: theme.spacing.sm),

          // Service fee
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Service Fee',
                style: theme.typography.body2,
              ),
              Text(
                '\$1.00',
                style: theme.typography.body2,
              ),
            ],
          ),

          SizedBox(height: theme.spacing.md),
          Divider(color: theme.colors.outline),
          SizedBox(height: theme.spacing.md),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: theme.typography.headline6.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${(trip.totalFare ?? 0).toStringAsFixed(2)}',
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

  Widget _buildRatingSection(AppThemeData theme) {
    return AppCardUnified(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rate Your Trip',
            style: theme.typography.subtitle1.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: theme.spacing.md),

          // Star rating
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: theme.spacing.sm),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _driverRating = index + 1;
                      });
                    },
                    child: Icon(
                      index < _driverRating ? Icons.star : Icons.star_outline,
                      size: 40,
                      color: Colors.amber,
                    ),
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: theme.spacing.md),

          // Rating text
          if (_driverRating > 0)
            Center(
              child: Text(
                _getRatingText(_driverRating),
                style: theme.typography.body2.copyWith(
                  color: theme.colors.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection(AppThemeData theme) {
    return AppCardUnified(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Feedback (Optional)',
            style: theme.typography.subtitle1.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: theme.spacing.md),

          TextField(
            maxLines: 3,
            onChanged: (value) {
              // Feedback is captured but not used in this mock implementation
            },
            decoration: InputDecoration(
              hintText: 'Share your experience...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(theme.spacing.mediumRadius),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AppThemeData theme) {
    return Column(
      children: [
        AppButtonUnified(
          label: 'Submit Rating',
          fullWidth: true,
          style: AppButtonStyle.primary,
          isEnabled: _driverRating > 0,
          onPressed: _submitRating,
        ),
        SizedBox(height: theme.spacing.md),

        AppButtonUnified(
          label: 'Share Trip',
          fullWidth: true,
          style: AppButtonStyle.secondary,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sharing trip...')),
            );
          },
        ),
        SizedBox(height: theme.spacing.md),

        AppButtonUnified(
          label: 'Back to Home',
          fullWidth: true,
          style: AppButtonStyle.secondary,
          onPressed: () {
            ref.read(tripProvider.notifier).clearTrip();
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/',
              (route) => false,
            );
          },
        ),
      ],
    );
  }

  void _submitRating() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Thank you for rating! $_driverRating stars'),
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(
      const Duration(seconds: 2),
      () {
        if (mounted) {
          ref.read(tripProvider.notifier).clearTrip();
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/',
            (route) => false,
          );
        }
      },
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }
}

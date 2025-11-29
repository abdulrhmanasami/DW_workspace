import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/app_button_unified.dart';
import '../../widgets/app_card_unified.dart';
import '../../state/parcels/parcels_providers.dart';

/// Component: Parcel Detail Screen
/// Created by: Track C - Parcels & Food Implementation
/// Purpose: Display detailed parcel information and tracking
/// Last updated: 2025-11-27

class ParcelDetailScreen extends ConsumerWidget {
  final String parcelId;

  const ParcelDetailScreen({
    super.key,
    required this.parcelId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final parcelAsync = ref.watch(parcelDetailProvider(parcelId));

    return AppShell(
      title: 'Parcel Details',
      showBottomNav: false,
      body: parcelAsync == null
          ? Center(
              child: Text(
                'Parcel not found',
                style: theme.typography.body1,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(theme.spacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tracking number and status
                    _buildHeaderCard(theme, parcelAsync),
                    SizedBox(height: theme.spacing.lg),

                    // Status timeline
                    _buildStatusTimeline(theme, parcelAsync),
                    SizedBox(height: theme.spacing.lg),

                    // Parcel information
                    _buildParcelInfoCard(theme, parcelAsync),
                    SizedBox(height: theme.spacing.lg),

                    // Pickup details
                    _buildLocationCard(
                      theme,
                      'Pickup Location',
                      parcelAsync.pickupLocation,
                      Icons.location_on_outlined,
                    ),
                    SizedBox(height: theme.spacing.lg),

                    // Delivery details
                    _buildLocationCard(
                      theme,
                      'Delivery Location',
                      parcelAsync.deliveryLocation,
                      Icons.location_on,
                    ),
                    SizedBox(height: theme.spacing.lg),

                    // Cost breakdown
                    _buildCostCard(theme, parcelAsync),
                    SizedBox(height: theme.spacing.lg),

                    // Action buttons
                    _buildActionButtons(context, theme, parcelAsync),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeaderCard(AppThemeData theme, Parcel parcel) {
    final statusColor = _getStatusColor(theme, parcel.status);
    final statusLabel = _getStatusLabel(parcel.status);

    return AppCardUnified(
      backgroundColor: statusColor.withValues(alpha: 0.1),
      borderSide: BorderSide(color: statusColor, width: 1.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tracking Number',
                    style: theme.typography.caption.copyWith(
                      color: theme.colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    parcel.trackingNumber,
                    style: theme.typography.headline6.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: theme.spacing.md,
                  vertical: theme.spacing.sm,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(theme.spacing.mediumRadius),
                  border: Border.all(color: statusColor, width: 1),
                ),
                child: Text(
                  statusLabel,
                  style: theme.typography.subtitle2.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: theme.spacing.md),
          Text(
            parcel.description,
            style: theme.typography.body2.copyWith(
              color: theme.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(AppThemeData theme, Parcel parcel) {
    final statuses = [
      ParcelStatus.pending,
      ParcelStatus.pickedUp,
      ParcelStatus.inTransit,
      ParcelStatus.delivered,
    ];

    return AppCardUnified(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Timeline',
            style: theme.typography.subtitle1.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: theme.spacing.md),
          ...statuses.asMap().entries.map((entry) {
            final index = entry.key;
            final status = entry.value;
            final isCompleted = _isStatusCompleted(parcel.status, status);
            final isCurrent = parcel.status == status;

            return Padding(
              padding: EdgeInsets.only(bottom: theme.spacing.md),
              child: Row(
                children: [
                  // Timeline dot
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted || isCurrent
                          ? theme.colors.primary
                          : theme.colors.outline,
                      border: isCurrent
                          ? Border.all(
                              color: theme.colors.primary,
                              width: 2,
                            )
                          : null,
                    ),
                    child: Center(
                      child: isCompleted
                          ? Icon(
                              Icons.check,
                              size: 16,
                              color: theme.colors.onPrimary,
                            )
                          : Text(
                              '${index + 1}',
                              style: theme.typography.caption.copyWith(
                                color: isCompleted || isCurrent
                                    ? theme.colors.onPrimary
                                    : theme.colors.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(width: theme.spacing.md),

                  // Timeline content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getStatusLabel(status),
                          style: theme.typography.body1.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isCurrent ? theme.colors.primary : null,
                          ),
                        ),
                        if (isCurrent)
                          Text(
                            'In progress',
                            style: theme.typography.caption.copyWith(
                              color: theme.colors.primary,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Timeline line
                  if (index < statuses.length - 1)
                    Positioned(
                      left: 16,
                      top: 32,
                      child: Container(
                        width: 2,
                        height: 40,
                        color: isCompleted
                            ? theme.colors.primary
                            : theme.colors.outline,
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildParcelInfoCard(AppThemeData theme, Parcel parcel) {
    return AppCardUnified(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Parcel Information',
            style: theme.typography.subtitle1.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: theme.spacing.md),
          _buildInfoRow(theme, 'Size', _getSizeLabel(parcel.size)),
          SizedBox(height: theme.spacing.md),
          _buildInfoRow(theme, 'Weight', '${parcel.weight} kg'),
          SizedBox(height: theme.spacing.md),
          _buildInfoRow(
            theme,
            'Created',
            _formatDateTime(parcel.createdAt),
          ),
          if (parcel.estimatedDelivery != null) ...[
            SizedBox(height: theme.spacing.md),
            _buildInfoRow(
              theme,
              'Estimated Delivery',
              _formatDateTime(parcel.estimatedDelivery!),
            ),
          ],
          if (parcel.specialInstructions != null) ...[
            SizedBox(height: theme.spacing.md),
            _buildInfoRow(
              theme,
              'Special Instructions',
              parcel.specialInstructions!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationCard(
    AppThemeData theme,
    String title,
    Location location,
    IconData icon,
  ) {
    return AppCardUnified(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.typography.subtitle1.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: theme.spacing.md),
          Row(
            children: [
              Icon(
                icon,
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
                    SizedBox(height: theme.spacing.xs),
                    Text(
                      '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
                      style: theme.typography.caption.copyWith(
                        color: theme.colors.onSurface.withValues(alpha: 0.6),
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

  Widget _buildCostCard(AppThemeData theme, Parcel parcel) {
    return AppCardUnified(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cost',
            style: theme.typography.subtitle1.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: theme.spacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: theme.typography.body1,
              ),
              Text(
                '\$${parcel.cost.toStringAsFixed(2)}',
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

  Widget _buildActionButtons(BuildContext context, AppThemeData theme, Parcel parcel) {
    return Column(
      children: [
        if (parcel.status != ParcelStatus.delivered && parcel.status != ParcelStatus.cancelled)
          AppButtonUnified(
            label: 'Cancel Parcel',
            fullWidth: true,
            style: AppButtonStyle.danger,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Parcel cancellation requested')),
              );
            },
          ),
        if (parcel.status != ParcelStatus.delivered && parcel.status != ParcelStatus.cancelled)
          SizedBox(height: theme.spacing.md),
        AppButtonUnified(
          label: 'Back',
          fullWidth: true,
          style: AppButtonStyle.secondary,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildInfoRow(AppThemeData theme, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.typography.body2.copyWith(
            color: theme.colors.onSurface.withValues(alpha: 0.6),
          ),
        ),
        Text(
          value,
          style: theme.typography.body2.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(AppThemeData theme, ParcelStatus status) {
    switch (status) {
      case ParcelStatus.pending:
        return Colors.orange;
      case ParcelStatus.pickedUp:
        return Colors.blue;
      case ParcelStatus.inTransit:
        return theme.colors.primary;
      case ParcelStatus.delivered:
        return Colors.green;
      case ParcelStatus.cancelled:
        return theme.colors.error;
    }
  }

  String _getStatusLabel(ParcelStatus status) {
    switch (status) {
      case ParcelStatus.pending:
        return 'Pending';
      case ParcelStatus.pickedUp:
        return 'Picked Up';
      case ParcelStatus.inTransit:
        return 'In Transit';
      case ParcelStatus.delivered:
        return 'Delivered';
      case ParcelStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _getSizeLabel(ParcelSize size) {
    switch (size) {
      case ParcelSize.small:
        return 'Small';
      case ParcelSize.medium:
        return 'Medium';
      case ParcelSize.large:
        return 'Large';
    }
  }

  bool _isStatusCompleted(ParcelStatus current, ParcelStatus target) {
    final order = [
      ParcelStatus.pending,
      ParcelStatus.pickedUp,
      ParcelStatus.inTransit,
      ParcelStatus.delivered,
    ];
    final currentIndex = order.indexOf(current);
    final targetIndex = order.indexOf(target);
    return targetIndex < currentIndex;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

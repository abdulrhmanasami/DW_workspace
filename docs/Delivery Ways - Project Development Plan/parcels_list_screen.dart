import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/app_button_unified.dart';
import '../../widgets/app_card_unified.dart';
import '../../state/parcels/parcels_providers.dart';
import 'parcel_detail_screen.dart';

/// Component: Parcels List Screen
/// Created by: Track C - Parcels & Food Implementation
/// Purpose: Display list of user's parcels with filtering and search
/// Last updated: 2025-11-27

class ParcelsListScreen extends ConsumerStatefulWidget {
  const ParcelsListScreen({super.key});

  @override
  ConsumerState<ParcelsListScreen> createState() => _ParcelsListScreenState();
}

class _ParcelsListScreenState extends ConsumerState<ParcelsListScreen> {
  ParcelStatus? _selectedStatus;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final parcels = ref.watch(filteredParcelsProvider(_selectedStatus));

    return AppShell(
      title: 'My Parcels',
      showBottomNav: true,
      navItems: BottomNavBuilder.buildDefaultItems(),
      selectedNavIndex: 0,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(theme.spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              _buildSearchBar(theme),
              SizedBox(height: theme.spacing.md),

              // Status filter
              _buildStatusFilter(theme),
              SizedBox(height: theme.spacing.lg),

              // Parcels list
              if (parcels.isEmpty)
                _buildEmptyState(theme)
              else
                _buildParcelsList(context, theme, parcels),

              SizedBox(height: theme.spacing.lg),

              // Create parcel button
              AppButtonUnified(
                label: 'Create New Parcel',
                fullWidth: true,
                style: AppButtonStyle.primary,
                onPressed: () => Navigator.of(context).pushNamed('/parcels/create'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(AppThemeData theme) {
    return AppCardUnified(
      padding: EdgeInsets.zero,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by tracking number...',
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.search,
            color: theme.colors.primary,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  child: Icon(
                    Icons.clear,
                    color: theme.colors.onSurface.withValues(alpha: 0.5),
                  ),
                )
              : null,
          contentPadding: EdgeInsets.symmetric(
            horizontal: theme.spacing.md,
            vertical: theme.spacing.md,
          ),
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildStatusFilter(AppThemeData theme) {
    final statuses = [
      null,
      ParcelStatus.pending,
      ParcelStatus.pickedUp,
      ParcelStatus.inTransit,
      ParcelStatus.delivered,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: statuses.map((status) {
          final isSelected = _selectedStatus == status;
          final label = status == null ? 'All' : _getStatusLabel(status);

          return Padding(
            padding: EdgeInsets.only(right: theme.spacing.sm),
            child: FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedStatus = selected ? status : null;
                });
              },
              selectedColor: theme.colors.primary,
              labelStyle: theme.typography.body2.copyWith(
                color: isSelected ? theme.colors.onPrimary : theme.colors.onSurface,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(AppThemeData theme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(theme.spacing.lg),
        child: Column(
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 64,
              color: theme.colors.onSurface.withValues(alpha: 0.3),
            ),
            SizedBox(height: theme.spacing.md),
            Text(
              'No parcels found',
              style: theme.typography.headline6.copyWith(
                color: theme.colors.onSurface.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: theme.spacing.sm),
            Text(
              'Create a new parcel to get started',
              style: theme.typography.body2.copyWith(
                color: theme.colors.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParcelsList(BuildContext context, AppThemeData theme, List<Parcel> parcels) {
    return Column(
      children: parcels.map((parcel) {
        return Padding(
          padding: EdgeInsets.only(bottom: theme.spacing.md),
          child: GestureDetector(
            onTap: () => _navigateToParcelDetail(context, parcel.id),
            child: _buildParcelCard(theme, parcel),
          ),
        );
      }).toList(),
    );
  }

  void _navigateToParcelDetail(BuildContext context, String parcelId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ParcelDetailScreen(parcelId: parcelId),
      ),
    );
  }

  Widget _buildParcelCard(AppThemeData theme, Parcel parcel) {
    return AppCardUnified(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with tracking and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tracking: ${parcel.trackingNumber}',
                      style: theme.typography.subtitle2.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: theme.spacing.xs),
                    Text(
                      parcel.description,
                      style: theme.typography.body2.copyWith(
                        color: theme.colors.onSurface.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(theme, parcel.status),
            ],
          ),

          SizedBox(height: theme.spacing.md),
          Divider(color: theme.colors.outline),
          SizedBox(height: theme.spacing.md),

          // Locations
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 18,
                color: theme.colors.primary,
              ),
              SizedBox(width: theme.spacing.sm),
              Expanded(
                child: Text(
                  parcel.pickupLocation.address,
                  style: theme.typography.caption.copyWith(
                    color: theme.colors.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          SizedBox(height: theme.spacing.sm),

          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 18,
                color: theme.colors.primary,
              ),
              SizedBox(width: theme.spacing.sm),
              Expanded(
                child: Text(
                  parcel.deliveryLocation.address,
                  style: theme.typography.caption.copyWith(
                    color: theme.colors.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          SizedBox(height: theme.spacing.md),
          Divider(color: theme.colors.outline),
          SizedBox(height: theme.spacing.md),

          // Footer with date and cost
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Created',
                    style: theme.typography.caption.copyWith(
                      color: theme.colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    _formatDate(parcel.createdAt),
                    style: theme.typography.body2.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Cost',
                    style: theme.typography.caption.copyWith(
                      color: theme.colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    '\$${parcel.cost.toStringAsFixed(2)}',
                    style: theme.typography.body2.copyWith(
                      color: theme.colors.primary,
                      fontWeight: FontWeight.w600,
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

  Widget _buildStatusBadge(AppThemeData theme, ParcelStatus status) {
    final color = _getStatusColor(theme, status);
    final label = _getStatusLabel(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacing.sm,
        vertical: theme.spacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(theme.spacing.mediumRadius * 0.5),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: theme.typography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

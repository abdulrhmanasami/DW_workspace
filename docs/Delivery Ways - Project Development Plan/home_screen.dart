import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart' hide AppCard;
import '../widgets/app_shell.dart';
import '../widgets/app_card_unified.dart';
import '../widgets/app_button_unified.dart';

/// Component: Home Screen
/// Created by: Track A - Design System Implementation
/// Purpose: Main entry point with unified design system
/// Last updated: 2025-11-27

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final navItems = BottomNavBuilder.buildDefaultItems();

    return AppShell(
      showBottomNav: true,
      navItems: navItems,
      selectedNavIndex: 0,
      onNavItemTapped: (index) {
        if (index == 0) return; // Already on home
        // Navigate to other screens based on index
        switch (index) {
          case 1:
            Navigator.of(context).pushNamed('/orders');
            break;
          case 2:
            Navigator.of(context).pushNamed('/payment');
            break;
          case 3:
            Navigator.of(context).pushNamed('/settings/privacy-data');
            break;
        }
      },
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(theme.spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              _buildWelcomeSection(theme),
              SizedBox(height: theme.spacing.lg),

              // Quick actions grid
              _buildQuickActionsSection(context, theme),
              SizedBox(height: theme.spacing.lg),

              // Recent activity section
              _buildRecentActivitySection(theme),
              SizedBox(height: theme.spacing.lg),

              // Promotional section
              _buildPromotionalSection(theme),
              SizedBox(height: theme.spacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  /// Build welcome section with greeting
  Widget _buildWelcomeSection(AppThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome to Delivery Ways',
          style: theme.typography.headline4.copyWith(
            color: theme.colors.onBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: theme.spacing.sm),
        Text(
          'Your reliable delivery partner',
          style: theme.typography.body2.copyWith(
            color: theme.colors.onBackground.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  /// Build quick actions grid
  Widget _buildQuickActionsSection(BuildContext context, AppThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.typography.headline6.copyWith(
            color: theme.colors.onBackground,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: theme.spacing.md),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: theme.spacing.md,
          crossAxisSpacing: theme.spacing.md,
          children: [
            AppGridCard(
              title: 'Ride',
              subtitle: 'Book a ride',
              icon: Icons.directions_car_outlined,
              iconColor: theme.colors.primary,
              onTap: () => Navigator.of(context).pushNamed('/mobility/location-selection'),
            ),
            AppGridCard(
              title: 'Parcels',
              subtitle: 'Send package',
              icon: Icons.local_shipping_outlined,
              iconColor: theme.colors.primary,
              onTap: () => Navigator.of(context).pushNamed('/parcels'),
            ),
            AppGridCard(
              title: 'Food',
              subtitle: 'Order food',
              icon: Icons.restaurant_outlined,
              iconColor: theme.colors.primary,
              onTap: () => _showComingSoon(context, 'Food Delivery'),
            ),
          ],
        ),
      ],
    );
  }

  /// Build recent activity section
  Widget _buildRecentActivitySection(AppThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: theme.typography.headline6.copyWith(
                color: theme.colors.onBackground,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'View All',
              style: theme.typography.caption.copyWith(
                color: theme.colors.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: theme.spacing.md),
        // Empty state for recent activity
        AppCard.standard(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(theme.spacing.lg),
              child: Column(
                children: [
                  Icon(
                    Icons.history_outlined,
                    size: 48,
                    color: theme.colors.onSurface.withValues(alpha: 0.3),
                  ),
                  SizedBox(height: theme.spacing.md),
                  Text(
                    'No recent activity',
                    style: theme.typography.body2.copyWith(
                      color: theme.colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build promotional section
  Widget _buildPromotionalSection(AppThemeData theme) {
    return AppCard.filled(
      backgroundColor: theme.colors.primary.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Special Offer',
            style: theme.typography.headline6.copyWith(
              color: theme.colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: theme.spacing.sm),
          Text(
            'Get 20% off on your next order',
            style: theme.typography.body2.copyWith(
              color: theme.colors.onBackground.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: theme.spacing.md),
            AppButtonUnified(
              label: 'Claim Offer',
              fullWidth: true,
              style: AppButtonStyle.primary,
              onPressed: () => _showComingSoon(null, 'Offers'),
            ),
        ],
      ),
    );
  }

  /// Show coming soon dialog
  void _showComingSoon(BuildContext? context, String feature) {
    if (context == null) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: Text('$feature feature is coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

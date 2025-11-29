import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart';
import '../../widgets/app_button_unified.dart';
import '../../widgets/app_card_unified.dart';

/// Component: Welcome Screen
/// Created by: Track D - Onboarding Implementation
/// Purpose: First screen of onboarding flow with app introduction
/// Last updated: 2025-11-27

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);

    return Scaffold(
      backgroundColor: theme.colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(theme.spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: theme.spacing.xl),

                // App logo/icon
                _buildAppIcon(theme),
                SizedBox(height: theme.spacing.xl),

                // Welcome message
                _buildWelcomeMessage(theme),
                SizedBox(height: theme.spacing.xl),

                // Feature highlights
                _buildFeatureHighlights(theme),
                SizedBox(height: theme.spacing.xl),

                // Action buttons
                _buildActionButtons(context, theme),

                SizedBox(height: theme.spacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppIcon(AppThemeData theme) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: theme.colors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.directions_car,
          size: 60,
          color: theme.colors.primary,
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage(AppThemeData theme) {
    return Column(
      children: [
        Text(
          'Welcome to Delivery Ways',
          style: theme.typography.headline4.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colors.onBackground,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: theme.spacing.md),
        Text(
          'Your all-in-one mobility and delivery solution',
          style: theme.typography.body1.copyWith(
            color: theme.colors.onBackground.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeatureHighlights(AppThemeData theme) {
    final features = [
      ('Ride', 'Book a ride with professional drivers', Icons.directions_car_outlined),
      ('Parcels', 'Send packages safely and quickly', Icons.local_shipping_outlined),
      ('Food', 'Order food from your favorite restaurants', Icons.restaurant_outlined),
    ];

    return Column(
      children: features.map((feature) {
        return Padding(
          padding: EdgeInsets.only(bottom: theme.spacing.md),
          child: _buildFeatureCard(theme, feature.$1, feature.$2, feature.$3),
        );
      }).toList(),
    );
  }

  Widget _buildFeatureCard(AppThemeData theme, String title, String description, IconData icon) {
    return AppCardUnified(
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: theme.colors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                color: theme.colors.primary,
                size: 24,
              ),
            ),
          ),
          SizedBox(width: theme.spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.typography.subtitle1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: theme.spacing.xs),
                Text(
                  description,
                  style: theme.typography.body2.copyWith(
                    color: theme.colors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AppThemeData theme) {
    return Column(
      children: [
        AppButtonUnified(
          label: 'Get Started',
          fullWidth: true,
          style: AppButtonStyle.primary,
          onPressed: () => Navigator.of(context).pushNamed('/onboarding/permissions'),
        ),
        SizedBox(height: theme.spacing.md),
        AppButtonUnified(
          label: 'Sign In',
          fullWidth: true,
          style: AppButtonStyle.secondary,
          onPressed: () => Navigator.of(context).pushNamed('/auth/phone-login'),
        ),
      ],
    );
  }
}

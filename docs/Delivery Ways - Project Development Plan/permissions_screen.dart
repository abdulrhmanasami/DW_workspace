import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/app_button_unified.dart';
import '../../widgets/app_card_unified.dart';

/// Component: Permissions Screen
/// Created by: Track D - Onboarding Implementation
/// Purpose: Request necessary permissions during onboarding
/// Last updated: 2025-11-27

class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen> {
  bool _locationGranted = false;
  bool _notificationGranted = false;

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);

    return AppShell(
      title: 'Permissions',
      showBottomNav: false,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(theme.spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(theme),
              SizedBox(height: theme.spacing.lg),

              // Location permission
              _buildPermissionCard(
                theme,
                'Location Access',
                'We need access to your location to show nearby rides and delivery options',
                Icons.location_on_outlined,
                _locationGranted,
                (value) {
                  setState(() {
                    _locationGranted = value;
                  });
                },
              ),
              SizedBox(height: theme.spacing.md),

              // Notification permission
              _buildPermissionCard(
                theme,
                'Notifications',
                'Receive updates about your rides, deliveries, and special offers',
                Icons.notifications_outlined,
                _notificationGranted,
                (value) {
                  setState(() {
                    _notificationGranted = value;
                  });
                },
              ),
              SizedBox(height: theme.spacing.lg),

              // Info box
              _buildInfoBox(theme),
              SizedBox(height: theme.spacing.lg),

              // Action buttons
              _buildActionButtons(context, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Permissions',
          style: theme.typography.headline5.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: theme.spacing.sm),
        Text(
          'We need a few permissions to provide you with the best experience',
          style: theme.typography.body2.copyWith(
            color: theme.colors.onBackground.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionCard(
    AppThemeData theme,
    String title,
    String description,
    IconData icon,
    bool isGranted,
    Function(bool) onChanged,
  ) {
    return AppCardUnified(
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isGranted
                  ? Colors.green.withValues(alpha: 0.1)
                  : theme.colors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                color: isGranted ? Colors.green : theme.colors.primary,
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
          SizedBox(width: theme.spacing.md),
            Switch(
              value: isGranted,
              onChanged: onChanged,
              // ignore: deprecated_member_use
              activeColor: Colors.green,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(AppThemeData theme) {
    return AppCardUnified(
      backgroundColor: theme.colors.primary.withValues(alpha: 0.05),
      borderSide: BorderSide(
        color: theme.colors.primary.withValues(alpha: 0.2),
        width: 1,
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outlined,
            color: theme.colors.primary,
            size: 24,
          ),
          SizedBox(width: theme.spacing.md),
          Expanded(
            child: Text(
              'You can change these permissions later in your device settings',
              style: theme.typography.body2.copyWith(
                color: theme.colors.primary,
              ),
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
          label: 'Continue',
          fullWidth: true,
          style: AppButtonStyle.primary,
          isEnabled: _locationGranted,
          onPressed: () => Navigator.of(context).pushNamed('/onboarding/preferences'),
        ),
        SizedBox(height: theme.spacing.md),
        AppButtonUnified(
          label: 'Skip',
          fullWidth: true,
          style: AppButtonStyle.secondary,
          onPressed: () => Navigator.of(context).pushNamed('/onboarding/preferences'),
        ),
      ],
    );
  }
}

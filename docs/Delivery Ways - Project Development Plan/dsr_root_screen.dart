import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/app_button_unified.dart';
import '../../widgets/app_card_unified.dart';

/// Component: DSR Root Screen
/// Created by: Track D - DSR Implementation
/// Purpose: Data Subject Rights management interface
/// Last updated: 2025-11-27

class DSRRootScreen extends ConsumerWidget {
  const DSRRootScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);

    return AppShell(
      title: 'Your Data & Privacy',
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

              // Data export option
              _buildDSROption(
                context,
                theme,
                'Download Your Data',
                'Get a copy of your personal data in a portable format',
                Icons.download_outlined,
                Colors.blue,
                () => Navigator.of(context).pushNamed('/dsr/export'),
              ),
              SizedBox(height: theme.spacing.md),

              // Data deletion option
              _buildDSROption(
                context,
                theme,
                'Delete Your Data',
                'Permanently delete your account and all associated data',
                Icons.delete_outline,
                Colors.red,
                () => Navigator.of(context).pushNamed('/dsr/deletion'),
              ),
              SizedBox(height: theme.spacing.md),

              // Account deactivation option
              _buildDSROption(
                context,
                theme,
                'Deactivate Account',
                'Temporarily deactivate your account',
                Icons.pause_circle_outline,
                Colors.orange,
                () => _showDeactivationDialog(context, theme),
              ),
              SizedBox(height: theme.spacing.lg),

              // Info section
              _buildInfoSection(theme),
              SizedBox(height: theme.spacing.lg),

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

  Widget _buildHeader(AppThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Data & Privacy',
          style: theme.typography.headline5.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: theme.spacing.sm),
        Text(
          'Manage your personal data and privacy settings',
          style: theme.typography.body2.copyWith(
            color: theme.colors.onBackground.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildDSROption(
    BuildContext context,
    AppThemeData theme,
    String title,
    String description,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return AppCardUnified(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                color: iconColor,
                size: 28,
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
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: theme.colors.onSurface.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(AppThemeData theme) {
    return AppCardUnified(
      backgroundColor: theme.colors.primary.withValues(alpha: 0.05),
      borderSide: BorderSide(
        color: theme.colors.primary.withValues(alpha: 0.2),
        width: 1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outlined,
                color: theme.colors.primary,
                size: 24,
              ),
              SizedBox(width: theme.spacing.md),
              Expanded(
                child: Text(
                  'Data Subject Rights',
                  style: theme.typography.subtitle2.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: theme.spacing.md),
          Text(
            'Under data protection regulations, you have the right to access, download, and delete your personal data. These options allow you to exercise those rights.',
            style: theme.typography.body2.copyWith(
              color: theme.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeactivationDialog(BuildContext context, AppThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Deactivate Account',
          style: theme.typography.headline6.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Your account will be temporarily deactivated. You can reactivate it anytime by logging in again.',
          style: theme.typography.body2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: theme.typography.body1.copyWith(
                color: theme.colors.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deactivation requested'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Text(
              'Deactivate',
              style: theme.typography.body1.copyWith(
                color: Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
